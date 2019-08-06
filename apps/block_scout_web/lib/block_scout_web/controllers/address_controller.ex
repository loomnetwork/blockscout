defmodule BlockScoutWeb.AddressController do
  use BlockScoutWeb, :controller

  alias Explorer.{Chain, Market}
  alias Explorer.Chain.Address
  alias Explorer.ExchangeRates.Token

  def index(conn, _params) do
    render(conn, "index.html",
      address_tx_count_pairs: Chain.list_top_addresses(),
      address_count: Chain.count_addresses_with_balance_from_cache(),
      exchange_rate: Market.get_exchange_rate(Explorer.coin()) || Token.null(),
      total_supply: Chain.total_supply()
    )
  end

  def show(conn, %{"id" => id}) do
    redirect(conn, to: address_transaction_path(conn, :index, id))
  end

  def transaction_count(%Address{} = address) do
    Chain.total_transactions_sent_by_address(address)
  end

  def validation_count(%Address{} = address) do
    Chain.address_to_validation_count(address)
  end
end
