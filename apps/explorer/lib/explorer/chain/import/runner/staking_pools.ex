defmodule Explorer.Chain.Import.Runner.StakingPools do
  @moduledoc """
  Bulk imports staking pools to Address.Name tabe.
  """

  require Ecto.Query

  alias Ecto.{Changeset, Multi, Repo}
  alias Explorer.Chain.{Address, Import}

  import Ecto.Query, only: [from: 2]

  @behaviour Import.Runner

  # milliseconds
  @timeout 60_000

  @type imported :: [Address.Name.t()]

  @impl Import.Runner
  def ecto_schema_module, do: Address.Name

  @impl Import.Runner
  def option_key, do: :staking_pools

  @impl Import.Runner
  def imported_table_row do
    %{
      value_type: "[#{ecto_schema_module()}.t()]",
      value_description: "List of `t:#{ecto_schema_module()}.t/0`s"
    }
  end

  @impl Import.Runner
  def run(multi, changes_list, %{timestamps: timestamps} = options) do
    insert_options =
      options
      |> Map.get(option_key(), %{})
      |> Map.take(~w(on_conflict timeout)a)
      |> Map.put_new(:timeout, @timeout)
      |> Map.put(:timestamps, timestamps)

    multi
    |> Multi.run(:mark_as_deleted, fn repo, _ ->
      mark_as_deleted(repo, changes_list, insert_options)
    end)
    |> Multi.run(:insert_staking_pools, fn repo, _ ->
      insert(repo, changes_list, insert_options)
    end)
  end

  @impl Import.Runner
  def timeout, do: @timeout

  defp mark_as_deleted(repo, changes_list, %{timeout: timeout}) when is_list(changes_list) do
    addresses = Enum.map(changes_list, & &1.address_hash)

    query =
      from(
        address_name in Address.Name,
        where:
          address_name.address_hash not in ^addresses and
            fragment("(?->>'is_pool')::boolean = true", address_name.metadata),
        update: [
          set: [
            metadata: fragment("? || '{\"deleted\": true}'::jsonb", address_name.metadata)
          ]
        ]
      )

    try do
      {_, result} = repo.update_all(query, [], timeout: timeout)

      {:ok, result}
    rescue
      postgrex_error in Postgrex.Error ->
        {:error, %{exception: postgrex_error}}
    end
  end

  @spec insert(Repo.t(), [map()], %{
          optional(:on_conflict) => Import.Runner.on_conflict(),
          required(:timeout) => timeout,
          required(:timestamps) => Import.timestamps()
        }) ::
          {:ok, [Address.Name.t()]}
          | {:error, [Changeset.t()]}
  defp insert(repo, changes_list, %{timeout: timeout, timestamps: timestamps} = options) when is_list(changes_list) do
    on_conflict = Map.get_lazy(options, :on_conflict, &default_on_conflict/0)

    {:ok, _} =
      Import.insert_changes_list(
        repo,
        stakes_ratio(changes_list),
        conflict_target: {:unsafe_fragment, "(address_hash) where \"primary\" = true"},
        on_conflict: on_conflict,
        for: Address.Name,
        returning: [:address_hash],
        timeout: timeout,
        timestamps: timestamps
      )
  end

  defp default_on_conflict do
    from(
      name in Address.Name,
      update: [
        set: [
          name: fragment("EXCLUDED.name"),
          metadata: fragment("EXCLUDED.metadata"),
          inserted_at: fragment("LEAST(?, EXCLUDED.inserted_at)", name.inserted_at),
          updated_at: fragment("GREATEST(?, EXCLUDED.updated_at)", name.updated_at)
        ]
      ]
    )
  end

  # Calculates staked ratio for each pool
  defp stakes_ratio(pools) do
    active_pools = Enum.filter(pools, & &1.metadata[:is_active])

    stakes_total =
      Enum.reduce(pools, 0, fn pool, acc ->
        acc + pool.metadata[:staked_amount]
      end)

    Enum.map(active_pools, fn pool ->
      staked_ratio = if stakes_total > 0, do: pool.metadata[:staked_amount] / stakes_total, else: 0

      put_in(pool, [:metadata, :staked_ratio], staked_ratio)
    end)
  end
end
