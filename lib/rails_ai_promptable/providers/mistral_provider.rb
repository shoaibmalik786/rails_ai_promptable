# frozen_string_literal: true

require 'net/http'
require 'json'

module RailsAIPromptable
  module Providers
    class MistralProvider < BaseProvider
      def initialize(configuration)
        super
        @api_key = configuration.mistral_api_key || configuration.api_key
        @base_url = configuration.mistral_base_url || 'https://api.mistral.ai/v1'
        @timeout = configuration.timeout
      end

      def generate(prompt:, model:, temperature:, format:)
        uri = URI.parse("#{@base_url}/chat/completions")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.read_timeout = @timeout

        request = Net::HTTP::Post.new(uri.request_uri, {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@api_key}"
        })

        body = {
          model: model,
          messages: [{ role: 'user', content: prompt }],
          temperature: temperature,
          max_tokens: 2048
        }

        request.body = body.to_json

        response = http.request(request)
        parsed = JSON.parse(response.body)

        if response.code.to_i >= 400
          error_message = parsed.dig('message') || 'Unknown error'
          raise "Mistral API error: #{error_message}"
        end

        # Extract content (OpenAI-compatible format)
        parsed.dig('choices', 0, 'message', 'content')
      rescue => e
        RailsAIPromptable.configuration.logger.error("[rails_ai_promptable] mistral error: #{e.message}")
        nil
      end
    end
  end
end
