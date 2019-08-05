defmodule BlockScoutWeb.API.RPC.EthRPCView do
  use BlockScoutWeb, :view

  defstruct [:result, :id, :error]

  def render("show.json", %{result: result, id: id}) do
    %__MODULE__{
      result: result,
      id: id
    }
  end

  def render("error.json", %{error: message, id: id}) do
    %__MODULE__{
      error: message,
      id: id
    }
  end

  def render("response.json", %{response: %{error: error, id: id}}) do
    %__MODULE__{
      error: error,
      id: id
    }
  end

  def render("response.json", %{response: %{result: result, id: id}}) do
    %__MODULE__{
      result: result,
      id: id
    }
  end

  def render("responses.json", %{responses: responses}) do
    Enum.map(responses, fn
      %{error: error, id: id} ->
        %__MODULE__{
          error: error,
          id: id
        }

      %{result: result, id: id} ->
        %__MODULE__{
          result: result,
          id: id
        }
    end)
  end

  defimpl Poison.Encoder, for: BlockScoutWeb.API.RPC.EthRPCView do
    def encode(%BlockScoutWeb.API.RPC.EthRPCView{result: result, id: id, error: error}, _options) when is_nil(error) do
      result = Poison.encode!(result)

      """
      {"jsonrpc":"2.0","result":#{result},"id":#{id}}
      """
    end

    def encode(%BlockScoutWeb.API.RPC.EthRPCView{id: id, error: error}, _options) do
      """
      {"jsonrpc":"2.0","error": "#{error}","id": #{id}}
      """
    end
  end
end
