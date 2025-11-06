# frozen_string_literal: true

require 'net/http'
require 'json'

module RailsAIPromptable
  module Providers
    class AnthropicProvider < BaseProvider
      API_VERSION = '2023-06-01'

      def initialize(configuration)
        super
        @api_key = configuration.anthropic_api_key || configuration.api_key
        @base_url = configuration.anthropic_base_url || 'https://api.anthropic.com/v1'
        @timeout = configuration.timeout
      end

      def generate(prompt:, model:, temperature:, format:)
        uri = URI.parse("#{@base_url}/messages")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.read_timeout = @timeout

        request = Net::HTTP::Post.new(uri.request_uri, {
          'Content-Type' => 'application/json',
          'x-api-key' => @api_key,
          'anthropic-version' => API_VERSION
        })

        body = {
          model: model,
          messages: [{ role: 'user', content: prompt }],
          temperature: temperature,
          max_tokens: 4096
        }

        request.body = body.to_json

        response = http.request(request)
        parsed = JSON.parse(response.body)

        if response.code.to_i >= 400
          error_message = parsed.dig('error', 'message') || 'Unknown error'
          raise "Anthropic API error: #{error_message}"
        end

        # Extract content from Anthropic response
        parsed.dig('content', 0, 'text')
      rescue => e
        RailsAIPromptable.configuration.logger.error("[rails_ai_promptable] anthropic error: #{e.message}")
        nil
      end
    end
  end
end
