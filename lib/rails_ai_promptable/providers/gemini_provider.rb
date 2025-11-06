# frozen_string_literal: true

require "net/http"
require "json"

module RailsAIPromptable
  module Providers
    class GeminiProvider < BaseProvider
      def initialize(configuration)
        super
        @api_key = configuration.gemini_api_key || configuration.api_key
        @base_url = configuration.gemini_base_url || "https://generativelanguage.googleapis.com/v1beta"
        @timeout = configuration.timeout
      end

      def generate(prompt:, model:, temperature:, format:)
        # Gemini uses the API key as a query parameter
        uri = URI.parse("#{@base_url}/models/#{model}:generateContent?key=#{@api_key}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.read_timeout = @timeout

        request = Net::HTTP::Post.new(uri.request_uri, {
                                        "Content-Type" => "application/json"
                                      })

        body = {
          contents: [{
            parts: [{ text: prompt }]
          }],
          generationConfig: {
            temperature: temperature,
            maxOutputTokens: 2048
          }
        }

        request.body = body.to_json

        response = http.request(request)
        parsed = JSON.parse(response.body)

        if response.code.to_i >= 400
          error_message = parsed.dig("error", "message") || "Unknown error"
          raise "Gemini API error: #{error_message}"
        end

        # Extract content from Gemini response
        parsed.dig("candidates", 0, "content", "parts", 0, "text")
      rescue StandardError => e
        RailsAIPromptable.configuration.logger.error("[rails_ai_promptable] gemini error: #{e.message}")
        nil
      end
    end
  end
end
