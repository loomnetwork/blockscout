defmodule BlockScoutWeb.AddressControllerTest do
  use BlockScoutWeb.ConnCase,
    # ETS tables are shared in `Explorer.Counters.*`
    async: false

  alias Explorer.Counters.AddressesWithBalanceCounter

  describe "GET index/2" do
    test "returns top addresses", %{conn: conn} do
      address_hashes =
        4..1
        |> Enum.map(&insert(:address, fetched_coin_balance: &1))
        |> Enum.map(& &1.hash)

      start_supervised!(AddressesWithBalanceCounter)
      AddressesWithBalanceCounter.consolidate()

      conn = get(conn, address_path(conn, :index, %{type: "JSON"}))
      {:ok, %{"items" => items}} = Poison.decode(conn.resp_body)

      assert Enum.count(items) == Enum.count(address_hashes)
    end

    test "returns an address's primary name when present", %{conn: conn} do
      address = insert(:address, fetched_coin_balance: 1)
      insert(:address_name, address: address, primary: true, name: "POA Wallet")

      start_supervised!(AddressesWithBalanceCounter)
      AddressesWithBalanceCounter.consolidate()

      conn = get(conn, address_path(conn, :index, %{type: "JSON"}))

      {:ok, %{"items" => [item]}} = Poison.decode(conn.resp_body)

      assert String.contains?(item, "POA Wallet")
    end
  end

  describe "GET show/3" do
    test "redirects to address/:address_id/transactions", %{conn: conn} do
      insert(:address, hash: "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed")

      conn = get(conn, "/address/0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed")

      assert redirected_to(conn) =~ "/address/0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed/transactions"
    end
  end
end
