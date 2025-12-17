class PortfolioValuation
  class ValidationError < StandardError; end
  class MarketNotFoundError < StandardError; end

  def initialize(portfolio:, fiat_currency:)
    @portfolio = portfolio || {}
    @fiat = fiat_currency&.to_s&.strip&.upcase
  end

  def call
    validate_input_format!
    tickers = BudaClient.new.fetch_tickers
    available_fiats = extract_fiats(tickers)
    validate_fiat_available!(available_fiats)
    calculate_valuation(tickers)
  end

  private

  def validate_input_format!
    raise ValidationError, "fiat_currency es requerido" if @fiat.nil? || @fiat.empty?
    raise ValidationError, "portfolio es requerido" if @portfolio.empty?

    @portfolio.each do |symbol, amount|
      raise ValidationError, "símbolo en portfolio no puede estar vacío" if symbol.to_s.strip.empty?
      raise ValidationError, "cantidad de '#{symbol}' en portfolio debe ser mayor a 0" unless amount.is_a?(Numeric) && amount > 0
    end
  end

  def extract_fiats(tickers)
    tickers.keys.map { |market_id| market_id.split("-").last }.uniq.to_set
  end

  def validate_fiat_available!(available_fiats)
    return if available_fiats.include?(@fiat)

    raise ValidationError, "fiat '#{@fiat}' no disponible en Buda"
  end

  def calculate_valuation(tickers)
    details = @portfolio.map do |symbol, amount|
      symbol_str = symbol.to_s.strip.upcase
      amount_f = amount.to_f
      market_id = "#{symbol_str}-#{@fiat}"

      price = tickers[market_id]
      raise MarketNotFoundError, "mercado '#{market_id}' no disponible en Buda" if price.nil?

      value = amount_f * price
      { symbol: symbol_str, amount: amount_f, price: price, value: value }
    end

    total = details.sum { |d| d[:value] }
    { total: total, fiat_currency: @fiat, details: details }
  end
end
