class BudaClient
  BASE_URL = "https://www.buda.com/api/v2"
  TIMEOUT = 5

  class ApiError < StandardError; end

  def initialize
    @conn = Faraday.new(url: BASE_URL) do |f|
      f.options.timeout = TIMEOUT
      f.options.open_timeout = TIMEOUT
      f.response :raise_error
    end
  end

  def fetch_tickers
    response = @conn.get("tickers")
    body = JSON.parse(response.body)

    body["tickers"].each_with_object({}) do |ticker, hash|
      market_id = ticker["market_id"]
      price = ticker["last_price"][0].to_f
      hash[market_id] = price
    end
  rescue Faraday::Error, JSON::ParserError => e
    raise ApiError, "error en API de Buda: #{e.message}"
  end
end
