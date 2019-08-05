defmodule Explorer.Repo.Migrations.CreateStakingPoolsDelegator do
  use Ecto.Migration

  def change do
    create table(:staking_pools_delegators) do
      add(:delegator_address_hash, :bytea)
      add(:pool_address_hash, :bytea)
      add(:stake_amount, :numeric, precision: 100)
      add(:ordered_withdraw, :numeric, precision: 100)
      add(:max_withdraw_allowed, :numeric, precision: 100)
      add(:max_ordered_withdraw_allowed, :numeric, precision: 100)
      add(:ordered_withdraw_epoch, :integer)

      timestamps(null: false, type: :utc_datetime_usec)
    end

    create(index(:staking_pools_delegators, [:delegator_address_hash]))

    create(
      index(:staking_pools_delegators, [:delegator_address_hash, :pool_address_hash],
        unique: true,
        name: :pools_delegator_index
      )
    )
  end
end
