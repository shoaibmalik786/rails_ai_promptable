# frozen_string_literal: true

require 'net/http'
require 'json'

module RailsAIPromptable
  module Providers
    class OpenRouterProvider < BaseProvider
      def initialize(configuration)
        super
        @api_key = configuration.openrouter_api_key || configuration.api_key
        @base_url = configuration.openrouter_base_url || 'https://openrouter.ai/api/v1'
        @timeout = configuration.timeout
        @app_name = configuration.openrouter_app_name
        @site_url = configuration.openrouter_site_url
      end

      def generate(prompt:, model:, temperature:, format:)
        uri = URI.parse("#{@base_url}/chat/completions")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.read_timeout = @timeout

        headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@api_key}"
        }

        # OpenRouter requires these headers for tracking/attribution
        headers['HTTP-Referer'] = @site_url if @site_url
        headers['X-Title'] = @app_name if @app_name

        request = Net::HTTP::Post.new(uri.request_uri, headers)

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
          error_message = parsed.dig('error', 'message') || 'Unknown error'
          raise "OpenRouter API error: #{error_message}"
        end

        # Extract content (OpenAI-compatible format)
        parsed.dig('choices', 0, 'message', 'content')
      rescue => e
        RailsAIPromptable.configuration.logger.error("[rails_ai_promptable] openrouter error: #{e.message}")
        nil
      end
    end
  end
end
