# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsAIPromptable::Providers::AzureOpenAIProvider do
  let(:configuration) do
    config = RailsAIPromptable::Configuration.new
    config.azure_api_key = 'test_azure_key'
    config.azure_base_url = 'https://my-resource.openai.azure.com'
    config.azure_deployment_name = 'my-deployment'
    config
  end
  let(:provider) { described_class.new(configuration) }

  describe '#initialize' do
    it 'stores the azure_api_key from configuration' do
      expect(provider.instance_variable_get(:@api_key)).to eq('test_azure_key')
    end

    it 'stores the base_url from configuration' do
      expect(provider.instance_variable_get(:@base_url)).to eq('https://my-resource.openai.azure.com')
    end

    it 'stores the api_version from configuration' do
      expect(provider.instance_variable_get(:@api_version)).to eq('2024-02-15-preview')
    end

    it 'stores the deployment_name from configuration' do
      expect(provider.instance_variable_get(:@deployment_name)).to eq('my-deployment')
    end

    it 'stores the timeout from configuration' do
      expect(provider.instance_variable_get(:@timeout)).to eq(30)
    end

    it 'falls back to generic api_key if azure_api_key is not set' do
      config = RailsAIPromptable::Configuration.new
      config.api_key = 'generic_key'
      config.azure_api_key = nil
      config.azure_base_url = 'https://my-resource.openai.azure.com'
      provider = described_class.new(config)
      expect(provider.instance_variable_get(:@api_key)).to eq('generic_key')
    end

    it 'allows custom api_version' do
      configuration.azure_api_version = '2023-12-01-preview'
      provider = described_class.new(configuration)
      expect(provider.instance_variable_get(:@api_version)).to eq('2023-12-01-preview')
    end

    context 'when azure_base_url is not set' do
      it 'raises ArgumentError' do
        config = RailsAIPromptable::Configuration.new
        config.azure_base_url = nil

        expect {
          described_class.new(config)
        }.to raise_error(ArgumentError, /Azure OpenAI requires azure_base_url/)
      end
    end
  end

  describe '#generate' do
    let(:prompt) { 'Tell me a joke' }
    let(:model) { 'gpt-4' }
    let(:temperature) { 0.7 }
    let(:format) { :text }

    before do
      RailsAIPromptable.configure do |config|
        config.azure_api_key = 'test_azure_key'
        config.azure_base_url = 'https://my-resource.openai.azure.com'
        config.azure_deployment_name = 'my-deployment'
      end
    end

    context 'when the API call succeeds' do
      it 'returns the generated content using deployment name' do
        stub_request(:post, "https://my-resource.openai.azure.com/openai/deployments/my-deployment/chat/completions?api-version=2024-02-15-preview")
          .with(
            body: hash_including({
              messages: [{ role: 'user', content: prompt }],
              temperature: temperature,
              max_tokens: 2048
            }),
            headers: {
              'Content-Type' => 'application/json',
              'api-key' => 'test_azure_key'
            }
          )
          .to_return(
            status: 200,
            body: {
              choices: [
                {
                  message: {
                    content: 'Why did the chicken cross the road?'
                  }
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = provider.generate(
          prompt: prompt,
          model: model,
          temperature: temperature,
          format: format
        )

        expect(result).to eq('Why did the chicken cross the road?')
      end
    end

    context 'when deployment_name is not set' do
      it 'uses the model parameter as deployment name' do
        config = RailsAIPromptable::Configuration.new
        config.azure_api_key = 'test_azure_key'
        config.azure_base_url = 'https://my-resource.openai.azure.com'
        config.azure_deployment_name = nil
        provider = described_class.new(config)

        stub_request(:post, "https://my-resource.openai.azure.com/openai/deployments/gpt-4/chat/completions?api-version=2024-02-15-preview")
          .to_return(
            status: 200,
            body: {
              choices: [
                { message: { content: 'Response' } }
              ]
            }.to_json
          )

        result = provider.generate(
          prompt: prompt,
          model: 'gpt-4',
          temperature: temperature,
          format: format
        )

        expect(result).to eq('Response')
      end
    end

    context 'when the API call fails' do
      it 'logs the error and returns nil' do
        stub_request(:post, "https://my-resource.openai.azure.com/openai/deployments/my-deployment/chat/completions?api-version=2024-02-15-preview")
          .to_raise(StandardError.new('Network error'))

        result = provider.generate(
          prompt: prompt,
          model: model,
          temperature: temperature,
          format: format
        )

        expect(result).to be_nil
      end
    end

    context 'when the API returns an error response' do
      it 'logs the error and returns nil' do
        stub_request(:post, "https://my-resource.openai.azure.com/openai/deployments/my-deployment/chat/completions?api-version=2024-02-15-preview")
          .to_return(
            status: 401,
            body: {
              error: {
                code: '401',
                message: 'Unauthorized'
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = provider.generate(
          prompt: prompt,
          model: model,
          temperature: temperature,
          format: format
        )

        expect(result).to be_nil
      end
    end
  end
end
