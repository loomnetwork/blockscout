defmodule Explorer.Chain.Address.HistoryCache do

  use GenServer

  alias Explorer.Chain

  @table :address_total_cache_history

  @cache_key "address_total_cache_history"

  def table_name do
    @table
  end

  def cache_key do
    @cache_key
  end

  config = Application.get_env(:explorer, Explorer.Chain.Transaction.HistoryCache)
  @enable_consolidation Keyword.get(config, :enable_consolidation)

  @update_interval_in_seconds Keyword.get(config, :update_interval_in_seconds)

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(args) do
    create_table()

    if enable_consolidation?() do
      Task.start_link(&consolidate/0)
      schedule_next_consolidation()
    end

    {:ok, args}
  end

  def create_table do
    opts = [
      :set,
      :named_table,
      :public,
      read_concurrency: true
    ]

    :ets.new(table_name(), opts)
  end

  defp schedule_next_consolidation do
    if enable_consolidation?() do
      Process.send_after(self(), :consolidate, :timer.seconds(@update_interval_in_seconds))
    end
  end

  def insert_address_total_history({key, info}) do
    :ets.insert(table_name(), {key, info})
  end

  @impl true
  def handle_info(:consolidate, state) do
    consolidate()

    schedule_next_consolidation()

    {:noreply, state}
  end

  def fetch do
    do_fetch(:ets.lookup(table_name(), cache_key()))
  end

  defp do_fetch([{_, result}]), do: result
  defp do_fetch([]), do: 0

  def consolidate do
    address_total_history = Chain.count_address_total_per_day()

    insert_address_total_history({cache_key(), address_total_history})
  end

  def enable_consolidation?, do: @enable_consolidation
end
