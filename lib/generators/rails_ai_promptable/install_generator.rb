# frozen_string_literal: true

require 'rails/generators'

module RailsAiPromptable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Creates a RailsAIPromptable initializer file'

      class_option :provider,
                   type: :string,
                   default: 'openai',
                   desc: 'AI provider to use (openai, anthropic, gemini, cohere, azure_openai, mistral, openrouter)'

      def copy_initializer_file
        template 'rails_ai_promptable.rb.tt', 'config/initializers/rails_ai_promptable.rb'
      end

      def show_readme
        readme 'POST_INSTALL' if behavior == :invoke
      end

      private

      def provider_name
        options['provider'].to_s
      end

      def provider_config
        case provider_name
        when 'openai'
          openai_config
        when 'anthropic', 'claude'
          anthropic_config
        when 'gemini', 'google'
          gemini_config
        when 'cohere'
          cohere_config
        when 'azure_openai', 'azure'
          azure_config
        when 'mistral'
          mistral_config
        when 'openrouter'
          openrouter_config
        else
          openai_config
        end
      end

      def openai_config
        {
          provider: ':openai',
          api_key: "ENV['OPENAI_API_KEY']",
          default_model: "'gpt-4o-mini'",
          additional_config: "  # config.openai_base_url = 'https://api.openai.com/v1' # Optional: custom endpoint"
        }
      end

      def anthropic_config
        {
          provider: ':anthropic',
          api_key: "ENV['ANTHROPIC_API_KEY']",
          default_model: "'claude-3-5-sonnet-20241022'",
          additional_config: "  # config.anthropic_base_url = 'https://api.anthropic.com/v1' # Optional: custom endpoint"
        }
      end

      def gemini_config
        {
          provider: ':gemini',
          api_key: "ENV['GEMINI_API_KEY']",
          default_model: "'gemini-pro'",
          additional_config: "  # config.gemini_base_url = 'https://generativelanguage.googleapis.com/v1beta' # Optional: custom endpoint"
        }
      end

      def cohere_config
        {
          provider: ':cohere',
          api_key: "ENV['COHERE_API_KEY']",
          default_model: "'command'",
          additional_config: "  # config.cohere_base_url = 'https://api.cohere.ai/v1' # Optional: custom endpoint"
        }
      end

      def azure_config
        {
          provider: ':azure_openai',
          api_key: "ENV['AZURE_OPENAI_API_KEY']",
          default_model: "'gpt-4'",
          additional_config: <<~CONFIG.chomp
            config.azure_base_url = ENV['AZURE_OPENAI_BASE_URL'] # Required: e.g., https://your-resource.openai.azure.com
              config.azure_deployment_name = ENV['AZURE_OPENAI_DEPLOYMENT_NAME'] # Required
              # config.azure_api_version = '2024-02-15-preview' # Optional: API version
          CONFIG
        }
      end

      def mistral_config
        {
          provider: ':mistral',
          api_key: "ENV['MISTRAL_API_KEY']",
          default_model: "'mistral-small-latest'",
          additional_config: "  # config.mistral_base_url = 'https://api.mistral.ai/v1' # Optional: custom endpoint"
        }
      end

      def openrouter_config
        {
          provider: ':openrouter',
          api_key: "ENV['OPENROUTER_API_KEY']",
          default_model: "'openai/gpt-3.5-turbo'",
          additional_config: <<~CONFIG.chomp
            # config.openrouter_app_name = 'Your App Name' # Optional: for tracking
              # config.openrouter_site_url = 'https://yourapp.com' # Optional: for attribution
              # config.openrouter_base_url = 'https://openrouter.ai/api/v1' # Optional: custom endpoint
          CONFIG
        }
      end
    end
  end
end
