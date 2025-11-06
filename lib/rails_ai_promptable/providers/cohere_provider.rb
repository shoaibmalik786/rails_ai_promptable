# frozen_string_literal: true

require "net/http"
require "json"

module RailsAIPromptable
  module Providers
    class CohereProvider < BaseProvider
      def initialize(configuration)
        super
        @api_key = configuration.cohere_api_key || configuration.api_key
        @base_url = configuration.cohere_base_url || "https://api.cohere.ai/v1"
        @timeout = configuration.timeout
      end

      def generate(prompt:, model:, temperature:, format:)
        uri = URI.parse("#{@base_url}/generate")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.read_timeout = @timeout

        request = Net::HTTP::Post.new(uri.request_uri, {
                                        "Content-Type" => "application/json",
                                        "Authorization" => "Bearer #{@api_key}"
                                      })

        body = {
          model: model,
          prompt: prompt,
          temperature: temperature,
          max_tokens: 2048
        }

        request.body = body.to_json

        response = http.request(request)
        parsed = JSON.parse(response.body)

        if response.code.to_i >= 400
          error_message = parsed["message"] || "Unknown error"
          raise "Cohere API error: #{error_message}"
        end

        # Extract content from Cohere response
        parsed.dig("generations", 0, "text")
      rescue StandardError => e
        RailsAIPromptable.configuration.logger.error("[rails_ai_promptable] cohere error: #{e.message}")
        nil
      end
    end
  end
end
