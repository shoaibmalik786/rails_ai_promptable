# frozen_string_literal: true

require 'net/http'
require 'json'

module RailsAIPromptable
  module Providers
    class AzureOpenAIProvider < BaseProvider
      def initialize(configuration)
        super
        @api_key = configuration.azure_api_key || configuration.api_key
        @base_url = configuration.azure_base_url
        @api_version = configuration.azure_api_version || '2024-02-15-preview'
        @timeout = configuration.timeout
        @deployment_name = configuration.azure_deployment_name

        validate_azure_configuration!
      end

      def generate(prompt:, model:, temperature:, format:)
        # Azure uses deployment name instead of model in the URL
        deployment = @deployment_name || model
        uri = URI.parse("#{@base_url}/openai/deployments/#{deployment}/chat/completions?api-version=#{@api_version}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.read_timeout = @timeout

        request = Net::HTTP::Post.new(uri.request_uri, {
          'Content-Type' => 'application/json',
          'api-key' => @api_key
        })

        body = {
          messages: [{ role: 'user', content: prompt }],
          temperature: temperature,
          max_tokens: 2048
        }

        request.body = body.to_json

        response = http.request(request)
        parsed = JSON.parse(response.body)

        if response.code.to_i >= 400
          error_message = parsed.dig('error', 'message') || 'Unknown error'
          raise "Azure OpenAI API error: #{error_message}"
        end

        # Extract content (same structure as OpenAI)
        parsed.dig('choices', 0, 'message', 'content')
      rescue => e
        RailsAIPromptable.configuration.logger.error("[rails_ai_promptable] azure_openai error: #{e.message}")
        nil
      end

      private

      def validate_azure_configuration!
        unless @base_url
          raise ArgumentError, 'Azure OpenAI requires azure_base_url to be set (e.g., https://your-resource.openai.azure.com)'
        end
      end
    end
  end
end
