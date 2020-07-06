defmodule Explorer.ExchangeRates.Source.VelasTicker do
  @moduledoc """
  Adapter for fetching exchange rate from https://explorer.velas.com/ticker
  """

  alias Explorer.ExchangeRates.{Source, Token}

  import Source, only: [to_decimal: 1]

  @behaviour Source

  @source_url "https://explorer.velas.com/ticker"

  @impl Source
  def format_data(%{
        "available_supply" => available_supply,
        "total_supply" => total_supply,
        "price_btc" => price_btc,
        "price_usd" => price_usd,
        "volume" => volume_24h_usd
      }) do
    [
      %Token{
        available_supply: to_decimal(available_supply),
        total_supply: to_decimal(total_supply),
        btc_value: to_decimal(price_btc),
        id: nil,
        last_updated: nil,
        market_cap_usd: Decimal.mult(available_supply, price_usd),
        name: "vlx",
        symbol: "VLX",
        usd_value: to_decimal(price_usd),
        volume_24h_usd: to_decimal(volume_24h_usd)
      }
    ]
  end

  @impl Source
  def format_data(_), do: []

  @impl Source
  def source_url(), do: @source_url
end
