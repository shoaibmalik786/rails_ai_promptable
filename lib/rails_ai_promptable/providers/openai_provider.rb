# frozen_string_literal: true

require 'net/http'
require 'json'

module RailsAIPromptable
  module Providers
    class OpenAIProvider < BaseProvider
      def initialize(configuration)
        super
        @api_key = configuration.api_key
        @base_url = configuration.openai_base_url
        @timeout = configuration.timeout
      end

      def generate(prompt:, model:, temperature:, format:)
        uri = URI.parse("#{@base_url}/chat/completions")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        request = Net::HTTP::Post.new(uri.request_uri, initheader = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@api_key}"
        })

        body = {
          model: model,
          messages: [{ role: 'user', content: prompt }],
          temperature: temperature
        }

        request.body = body.to_json

        response = http.request(request)
        parsed = JSON.parse(response.body)

        # naive extraction
        parsed.dig('choices', 0, 'message', 'content')
      rescue => e
        RailsAIPromptable.configuration.logger.error("[rails_ai_promptable] openai error: #{e.message}")
        nil
      end
    end
  end
end
