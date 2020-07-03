defmodule Explorer.ExchangeRates.Source.VelasTickerTest do
  use ExUnit.Case

  alias Explorer.ExchangeRates.Token
  alias Explorer.ExchangeRates.Source.VelasTicker

  describe "format_data/1" do
    test "returns valid tokens with valid data" do
      json_data =
        "#{File.cwd!()}/test/support/fixture/exchange_rates/velas_ticker.json"
        |> File.read!()
        |> Jason.decode!()

      expected = [
        %Token{
          available_supply: Decimal.new("1402020306.379317011971257058"),
          total_supply: Decimal.new("2087203839"),
          btc_value: Decimal.new("0.00000916"),
          id: nil,
          last_updated: nil,
          market_cap_usd: Decimal.new("116970554.1612264183087619763"),
          name: "vlx",
          symbol: "VLX",
          usd_value: Decimal.new("0.083430"),
          volume_24h_usd: Decimal.new("1771598")
        }
      ]

      assert VelasTicker.format_data(json_data) == expected
    end

    test "returns nothing when given bad data" do
      bad_data = """
        [{"id": "blabla"}]
      """

      assert VelasTicker.format_data(bad_data) == []
    end
  end
end
