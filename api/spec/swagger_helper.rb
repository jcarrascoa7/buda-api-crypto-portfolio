# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Buda Crypto Portfolio API",
        version: "v1",
        description: "API para valorizar portafolios cripto"
      },
      paths: {},
      servers: [
        {
          url: "http://localhost:3000",
          description: "Desarrollo local"
        }
      ]
    }
  }

  config.openapi_format = :yaml
end