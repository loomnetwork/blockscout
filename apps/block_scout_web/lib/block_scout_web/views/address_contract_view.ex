defmodule BlockScoutWeb.AddressContractView do
  use BlockScoutWeb, :view

  alias ABI.{FunctionSelector, TypeDecoder}
  alias Explorer.Chain.{Address, Data, InternalTransaction}

  def render("scripts.html", %{conn: conn}) do
    render_scripts(conn, "address_contract/code_highlighting.js")
  end

  def format_smart_contract_abi(abi), do: Poison.encode!(abi, pretty: false)

  @doc """
  Returns the correct format for the optimization text.

    iex> BlockScoutWeb.AddressContractView.format_optimization_text(true)
    "true"

    iex> BlockScoutWeb.AddressContractView.format_optimization_text(false)
    "false"
  """
  def format_optimization_text(true), do: gettext("true")
  def format_optimization_text(false), do: gettext("false")

  def format_constructor_arguments(contract) do
    constructor_abi = Enum.find(contract.abi, fn el -> el["type"] == "constructor" && el["inputs"] != [] end)

    input_types = Enum.map(constructor_abi["inputs"], &FunctionSelector.parse_specification_type/1)

    {_, result} =
      contract.constructor_arguments
      |> decode_data(input_types)
      |> Enum.zip(constructor_abi["inputs"])
      |> Enum.reduce({0, "#{contract.constructor_arguments}\n\n"}, fn {val, %{"type" => type}}, {count, acc} ->
        formatted_val =
          if is_binary(val) do
            Base.encode16(val, case: :lower)
          else
            val
          end

        {count + 1, "#{acc}Arg [#{count}] (<b>#{type}</b>) : #{formatted_val}\n"}
      end)

    result
  rescue
    _ -> contract.constructor_arguments
  end

  defp decode_data("0x" <> encoded_data, types) do
    decode_data(encoded_data, types)
  end

  defp decode_data(encoded_data, types) do
    encoded_data
    |> Base.decode16!(case: :mixed)
    |> TypeDecoder.decode_raw(types)
  end

  def format_external_libraries(libraries) do
    Enum.reduce(libraries, "", fn %{name: name, address_hash: address_hash}, acc ->
      "#{acc}<span class=\"hljs-title\">#{name}</span> : #{address_hash}  \n"
    end)
  end

  def contract_lines_with_index(contract_source_code) do
    contract_lines = String.split(contract_source_code, "\n")

    max_digits =
      contract_lines
      |> Enum.count()
      |> Integer.digits()
      |> Enum.count()

    contract_lines
    |> Enum.with_index(1)
    |> Enum.map(fn {value, line} ->
      {value, String.pad_leading(to_string(line), max_digits, " ")}
    end)
  end

  def contract_creation_code(%Address{
        contract_code: %Data{bytes: <<>>},
        contracts_creation_internal_transaction: %InternalTransaction{init: init}
      }) do
    {:selfdestructed, init}
  end

  def contract_creation_code(%Address{contract_code: contract_code}) do
    {:ok, contract_code}
  end
end
