# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsAIPromptable::Providers::OpenRouterProvider do
  let(:configuration) do
    config = RailsAIPromptable::Configuration.new
    config.openrouter_api_key = 'test_openrouter_key'
    config.openrouter_app_name = 'TestApp'
    config.openrouter_site_url = 'https://example.com'
    config
  end
  let(:provider) { described_class.new(configuration) }

  describe '#initialize' do
    it 'stores the openrouter_api_key from configuration' do
      expect(provider.instance_variable_get(:@api_key)).to eq('test_openrouter_key')
    end

    it 'stores the base_url from configuration' do
      expect(provider.instance_variable_get(:@base_url)).to eq('https://openrouter.ai/api/v1')
    end

    it 'stores the timeout from configuration' do
      expect(provider.instance_variable_get(:@timeout)).to eq(30)
    end

    it 'stores the app_name from configuration' do
      expect(provider.instance_variable_get(:@app_name)).to eq('TestApp')
    end

    it 'stores the site_url from configuration' do
      expect(provider.instance_variable_get(:@site_url)).to eq('https://example.com')
    end

    it 'falls back to generic api_key if openrouter_api_key is not set' do
      config = RailsAIPromptable::Configuration.new
      config.api_key = 'generic_key'
      config.openrouter_api_key = nil
      provider = described_class.new(config)
      expect(provider.instance_variable_get(:@api_key)).to eq('generic_key')
    end

    it 'allows custom base_url' do
      configuration.openrouter_base_url = 'https://custom-openrouter.com/v1'
      provider = described_class.new(configuration)
      expect(provider.instance_variable_get(:@base_url)).to eq('https://custom-openrouter.com/v1')
    end
  end

  describe '#generate' do
    let(:prompt) { 'Tell me a joke' }
    let(:model) { 'openai/gpt-3.5-turbo' }
    let(:temperature) { 0.7 }
    let(:format) { :text }

    before do
      RailsAIPromptable.configure do |config|
        config.openrouter_api_key = 'test_openrouter_key'
        config.openrouter_app_name = 'TestApp'
        config.openrouter_site_url = 'https://example.com'
      end
    end

    context 'when the API call succeeds' do
      it 'returns the generated content with proper headers' do
        stub_request(:post, "https://openrouter.ai/api/v1/chat/completions")
          .with(
            body: hash_including({
              model: model,
              messages: [{ role: 'user', content: prompt }],
              temperature: temperature,
              max_tokens: 2048
            }),
            headers: {
              'Content-Type' => 'application/json',
              'Authorization' => 'Bearer test_openrouter_key',
              'HTTP-Referer' => 'https://example.com',
              'X-Title' => 'TestApp'
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

      it 'works without optional headers' do
        config = RailsAIPromptable::Configuration.new
        config.openrouter_api_key = 'test_key'
        config.openrouter_app_name = nil
        config.openrouter_site_url = nil
        provider = described_class.new(config)

        stub_request(:post, "https://openrouter.ai/api/v1/chat/completions")
          .with(
            headers: {
              'Content-Type' => 'application/json',
              'Authorization' => 'Bearer test_key'
            }
          )
          .to_return(
            status: 200,
            body: {
              choices: [{ message: { content: 'Response' } }]
            }.to_json
          )

        result = provider.generate(
          prompt: prompt,
          model: model,
          temperature: temperature,
          format: format
        )

        expect(result).to eq('Response')
      end
    end

    context 'when the API call fails' do
      it 'logs the error and returns nil' do
        stub_request(:post, "https://openrouter.ai/api/v1/chat/completions")
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
        stub_request(:post, "https://openrouter.ai/api/v1/chat/completions")
          .to_return(
            status: 401,
            body: {
              error: {
                message: 'Invalid API key'
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
