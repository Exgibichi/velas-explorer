defmodule Explorer.Chain.VLX do
  @alphabet ~c(123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz)

  @spec is_hex?(String.t()) :: boolean()
  defp is_hex?(hash) do
    case Regex.run(~r|[0-9a-f]{40}|i, hash) do
      nil -> false
      [_] -> true
    end
  end

  @doc """
  Encodes the given ethereum address to vlx format.
  """
  def eth_to_vlx(address) do
    encoded_address = address |> String.trim_leading("0x") |> Integer.parse(16) |> elem(0) |> b58_encode()
    "V" <> encoded_address
  end

  @doc """
  Decodes the given vlx address to ethereum format.
  """
  def vlx_to_eth(address) do
      "0x" <> address |> String.downcase()
    else
      encoded_address = address |> String.trim_leading("V") |> b58_decode() |> Integer.to_string(16)
      "0x" <> encoded_address |> String.downcase()
    end
  end

  defp b58_encode(x), do: _encode(x, [])

  defp b58_decode(enc), do: _decode(enc |> to_char_list, 0)

  defp _encode(0, []), do: [@alphabet |> hd] |> to_string
  defp _encode(0, acc), do: acc |> to_string

  defp _encode(x, acc) do
    _encode(div(x, 58), [Enum.at(@alphabet, rem(x, 58)) | acc])
  end

  defp _decode([], acc), do: acc

  defp _decode([c | cs], acc) do
    _decode(cs, acc * 58 + Enum.find_index(@alphabet, &(&1 == c)))
  end
end
