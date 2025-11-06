# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAIPromptable::Providers::GeminiProvider do
  let(:configuration) do
    config = RailsAIPromptable::Configuration.new
    config.gemini_api_key = "test_gemini_key"
    config
  end
  let(:provider) { described_class.new(configuration) }

  describe "#initialize" do
    it "stores the gemini_api_key from configuration" do
      expect(provider.instance_variable_get(:@api_key)).to eq("test_gemini_key")
    end

    it "stores the base_url from configuration" do
      expect(provider.instance_variable_get(:@base_url)).to eq("https://generativelanguage.googleapis.com/v1beta")
    end

    it "stores the timeout from configuration" do
      expect(provider.instance_variable_get(:@timeout)).to eq(30)
    end

    it "falls back to generic api_key if gemini_api_key is not set" do
      config = RailsAIPromptable::Configuration.new
      config.api_key = "generic_key"
      config.gemini_api_key = nil
      provider = described_class.new(config)
      expect(provider.instance_variable_get(:@api_key)).to eq("generic_key")
    end

    it "allows custom base_url" do
      configuration.gemini_base_url = "https://custom-gemini.com/v1"
      provider = described_class.new(configuration)
      expect(provider.instance_variable_get(:@base_url)).to eq("https://custom-gemini.com/v1")
    end
  end

  describe "#generate" do
    let(:prompt) { "Tell me a joke" }
    let(:model) { "gemini-pro" }
    let(:temperature) { 0.7 }
    let(:format) { :text }

    before do
      RailsAIPromptable.configure do |config|
        config.gemini_api_key = "test_gemini_key"
      end
    end

    context "when the API call succeeds" do
      it "returns the generated content" do
        stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=test_gemini_key")
          .with(
            body: hash_including({
                                   contents: [{
                                     parts: [{ text: prompt }]
                                   }],
                                   generationConfig: {
                                     temperature: temperature,
                                     maxOutputTokens: 2048
                                   }
                                 }),
            headers: {
              "Content-Type" => "application/json"
            }
          )
          .to_return(
            status: 200,
            body: {
              candidates: [
                {
                  content: {
                    parts: [
                      { text: "Why did the chicken cross the road?" }
                    ]
                  }
                }
              ]
            }.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        result = provider.generate(
          prompt: prompt,
          model: model,
          temperature: temperature,
          format: format
        )

        expect(result).to eq("Why did the chicken cross the road?")
      end
    end

    context "when the API call fails" do
      it "logs the error and returns nil" do
        stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=test_gemini_key")
          .to_raise(StandardError.new("Network error"))

        result = provider.generate(
          prompt: prompt,
          model: model,
          temperature: temperature,
          format: format
        )

        expect(result).to be_nil
      end
    end

    context "when the API returns an error response" do
      it "logs the error and returns nil" do
        stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=test_gemini_key")
          .to_return(
            status: 400,
            body: {
              error: {
                code: 400,
                message: "Invalid API key",
                status: "INVALID_ARGUMENT"
              }
            }.to_json,
            headers: { "Content-Type" => "application/json" }
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
