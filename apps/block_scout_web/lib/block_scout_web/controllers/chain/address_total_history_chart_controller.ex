defmodule BlockScoutWeb.Chain.AddressTotalHistoryChartController do
  use BlockScoutWeb, :controller

  alias Explorer.{Chain}

  def show(conn, _params) do
    json(conn, %{
      address_total_data: to_string(address_total_data())
    })
  end


  defp address_total_data() do
    case Chain.count_address_total_per_day_from_cache do
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
