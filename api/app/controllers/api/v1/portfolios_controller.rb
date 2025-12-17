module Api
  module V1
    class PortfoliosController < ApplicationController
      wrap_parameters false

      def value
        result = PortfolioValuation.new(
          portfolio: portfolio_params,
          fiat_currency: params[:fiat_currency]
        ).call

        render json: result, status: :ok
      rescue PortfolioValuation::ValidationError, PortfolioValuation::MarketNotFoundError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue BudaClient::ApiError => e
        render json: { error: e.message }, status: :bad_gateway
      end

      private

      def portfolio_params
        params[:portfolio]&.to_unsafe_h || {}
      end
    end
  end
end
