# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Portfolios", type: :request do
  path "/api/v1/portfolios/value" do
    post "Valoriza un portafolio cripto en una moneda fiat" do
      tags "Portfolios"
      consumes "application/json"
      produces "application/json"

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          portfolio: {
            type: :object,
            additionalProperties: { type: :number },
            example: { "BTC" => 0.5, "ETH" => 2.0 }
          },
          fiat_currency: {
            type: :string,
            example: "CLP"
          }
        },
        required: %w[portfolio fiat_currency]
      }

      response "200", "valorización exitosa" do
        schema type: :object,
               properties: {
                 total: { type: :number },
                 fiat_currency: { type: :string },
                 details: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       symbol: { type: :string },
                       amount: { type: :number },
                       price: { type: :number },
                       value: { type: :number }
                     }
                   }
                 }
               }

        let(:payload) { { portfolio: { "BTC" => 0.5, "ETH" => 2.0 }, fiat_currency: "CLP" } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["fiat_currency"]).to eq("CLP")
          expect(data["details"].size).to eq(2)
          expect(data["total"]).to be > 0
        end
      end

      response "422", "input inválido" do
        schema type: :object,
               properties: { error: { type: :string } },
               required: [ "error" ]

        examples "application/json" => {
          portfolio_vacio: {
            summary: "Portfolio vacío",
            value: { error: "portfolio es requerido" }
          },
          fiat_vacia: {
            summary: "fiat_currency vacío",
            value: { error: "fiat_currency es requerido" }
          },
          fiat_no_disponible: {
            summary: "Fiat no disponible en Buda",
            value: { error: "fiat 'USD' no disponible en Buda" }
          },
          mercado_no_existe: {
            summary: "Mercado directo no disponible",
            value: { error: "mercado 'NOCOIN-CLP' no disponible en Buda" }
          },
          cantidad_invalida: {
            summary: "Cantidad <= 0",
            value: { error: "cantidad de 'BTC' en portfolio debe ser mayor a 0" }
          }
        }

        let(:payload) { { portfolio: {}, fiat_currency: "CLP" } }

        run_test!
      end

      response "502", "error en API" do
        schema type: :object,
               properties: { error: { type: :string } },
               required: [ "error" ]

        let(:payload) { { portfolio: { "BTC" => 1.0 }, fiat_currency: "CLP" } }

        before do
          allow_any_instance_of(BudaClient).to receive(:fetch_tickers)
            .and_raise(BudaClient::ApiError, "error en API de Buda: timeout")
        end

        run_test!
      end
    end
  end
end

RSpec.describe "Api::V1::Portfolios validations", type: :request do
  describe "POST /api/v1/portfolios/value" do
    let(:headers) { { "Content-Type" => "application/json" } }

    it "retorna 422 cuando portfolio está vacío" do
      post "/api/v1/portfolios/value",
           params: { portfolio: {}, fiat_currency: "CLP" }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("portfolio es requerido")
    end

    it "retorna 422 cuando fiat_currency está vacío" do
      post "/api/v1/portfolios/value",
           params: { portfolio: { "BTC" => 1.0 }, fiat_currency: "" }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("fiat_currency es requerido")
    end

    it "retorna 422 cuando fiat no está disponible en Buda" do
      post "/api/v1/portfolios/value",
           params: { portfolio: { "BTC" => 1.0 }, fiat_currency: "USD" }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("fiat 'USD' no disponible en Buda")
    end

    it "retorna 422 cuando el mercado no existe" do
      post "/api/v1/portfolios/value",
           params: { portfolio: { "NOCOIN" => 1.0 }, fiat_currency: "CLP" }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("mercado 'NOCOIN-CLP' no disponible en Buda")
    end

    it "retorna 422 cuando amount es negativo" do
      post "/api/v1/portfolios/value",
           params: { portfolio: { "BTC" => -1 }, fiat_currency: "CLP" }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("cantidad de 'BTC' en portfolio debe ser mayor a 0")
    end

    it "retorna 422 cuando símbolo está vacío" do
      post "/api/v1/portfolios/value",
           params: { portfolio: { "" => 1.0 }, fiat_currency: "CLP" }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("símbolo en portfolio no puede estar vacío")
    end
  end
end
