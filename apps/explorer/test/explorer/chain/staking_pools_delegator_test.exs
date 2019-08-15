defmodule Explorer.Chain.StakingPoolsDelegatorTest do
  use Explorer.DataCase

  alias Explorer.Chain.StakingPoolsDelegator

  describe "changeset/2" do
    test "with valid attributes" do
      params = params_for(:staking_pools_delegator)
      changeset = StakingPoolsDelegator.changeset(%StakingPoolsDelegator{}, params)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = StakingPoolsDelegator.changeset(%StakingPoolsDelegator{}, %{pool_address_hash: 0})
      refute changeset.valid?
    end
  end
end
