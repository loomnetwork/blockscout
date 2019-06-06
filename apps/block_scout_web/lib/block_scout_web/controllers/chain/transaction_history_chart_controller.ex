defmodule BlockScoutWeb.Chain.TransactionHistoryChartController do
  use BlockScoutWeb, :controller

  alias Explorer.{Chain}

  def show(conn, _params) do
    json(conn, %{
      transaction_data: to_string(transaction_data())
    })
  end


  defp transaction_data() do
    case Chain.count_transactions_per_day_from_cache do
      "" -> []
      cache -> cache
    end
    |> Jason.encode()
    |> case do
      {:ok, data} -> data
      _ -> []
    end
  end
end
