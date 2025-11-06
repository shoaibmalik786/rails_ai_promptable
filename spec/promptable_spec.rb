# frozen_string_literal: true

require "spec_helper"
require "active_support/concern"

RSpec.describe RailsAIPromptable::Promptable do
  # Create a test class that includes the Promptable module
  let(:test_class) do
    Class.new do
      include RailsAIPromptable::Promptable

      attr_accessor :id

      def initialize(id = 1)
        @id = id
      end

      def self.name
        "TestModel"
      end

      def self.find_by(conditions)
        new(conditions[:id]) if conditions[:id] == 1
      end
    end
  end

  let(:test_instance) { test_class.new }
  let(:mock_client) { instance_double("Client") }

  before do
    RailsAIPromptable.configure do |config|
      config.api_key = "test_key"
      config.default_model = "gpt-4o-mini"
    end

    allow(RailsAIPromptable).to receive(:client).and_return(mock_client)
  end

  describe ".prompt_template" do
    context "when called with a template" do
      it "sets the ai_prompt_template" do
        test_class.prompt_template("Hello %<name>s!")
        expect(test_class.ai_prompt_template).to eq("Hello %<name>s!")
      end
    end

    context "when called without a template" do
      it "returns the current template" do
        test_class.prompt_template("Test template")
        expect(test_class.prompt_template).to eq("Test template")
      end
    end
  end

  describe "#ai_generate" do
    before do
      test_class.prompt_template("Hello %<name>s, you are %<age>s years old.")
      allow(mock_client).to receive(:generate).and_return("Generated response")
    end

    context "with valid context" do
      it "generates AI content using the template and context" do
        expect(mock_client).to receive(:generate).with(
          prompt: "Hello John, you are 30 years old.",
          model: "gpt-4o-mini",
          temperature: 0.7,
          format: :text
        )

        result = test_instance.ai_generate(context: { name: "John", age: 30 })
        expect(result).to eq("Generated response")
      end
    end

    context "with custom model" do
      it "uses the specified model" do
        expect(mock_client).to receive(:generate).with(
          prompt: "Hello Jane, you are 25 years old.",
          model: "gpt-4",
          temperature: 0.7,
          format: :text
        )

        test_instance.ai_generate(context: { name: "Jane", age: 25 }, model: "gpt-4")
      end
    end

    context "with custom temperature" do
      it "uses the specified temperature" do
        expect(mock_client).to receive(:generate).with(
          prompt: "Hello Bob, you are 40 years old.",
          model: "gpt-4o-mini",
          temperature: 0.9,
          format: :text
        )

        test_instance.ai_generate(context: { name: "Bob", age: 40 }, temperature: 0.9)
      end
    end

    context "with custom format" do
      it "uses the specified format" do
        expect(mock_client).to receive(:generate).with(
          prompt: "Hello Alice, you are 35 years old.",
          model: "gpt-4o-mini",
          temperature: 0.7,
          format: :json
        )

        test_instance.ai_generate(context: { name: "Alice", age: 35 }, format: :json)
      end
    end

    context "when template is not set" do
      before do
        test_class.ai_prompt_template = nil
      end

      it "uses an empty template" do
        expect(mock_client).to receive(:generate).with(
          prompt: "",
          model: "gpt-4o-mini",
          temperature: 0.7,
          format: :text
        )

        test_instance.ai_generate
      end
    end

    context "when context has string keys" do
      it "converts string keys to symbols" do
        expect(mock_client).to receive(:generate).with(
          prompt: "Hello Charlie, you are 50 years old.",
          model: "gpt-4o-mini",
          temperature: 0.7,
          format: :text
        )

        test_instance.ai_generate(context: { "name" => "Charlie", "age" => 50 })
      end
    end
  end

  describe "#ai_generate_later" do
    let(:mock_job_class) { class_double("RailsAIPromptable::BackgroundJob") }

    before do
      stub_const("RailsAIPromptable::BackgroundJob", mock_job_class)
      allow(mock_job_class).to receive(:perform_later)
    end

    it "enqueues a background job" do
      expect(mock_job_class).to receive(:perform_later).with(
        "TestModel",
        1,
        { name: "Test" },
        { model: "gpt-4" }
      )

      test_instance.ai_generate_later(context: { name: "Test" }, model: "gpt-4")
    end

    it "logs the enqueue action" do
      expect(RailsAIPromptable.configuration.logger).to receive(:info)
        .with("[rails_ai_promptable] enqueuing ai_generate_later")

      test_instance.ai_generate_later(context: {})
    end
  end

  describe ".ai_use_template" do
    before do
      RailsAIPromptable::TemplateRegistry.clear!
    end

    after do
      RailsAIPromptable::TemplateRegistry.clear!
    end

    context "when template exists in registry" do
      it "loads the template from registry" do
        RailsAIPromptable::TemplateRegistry.register(:greeting, "Hello %<name>s!")

        test_class.ai_use_template(:greeting)

        expect(test_class.ai_prompt_template).to eq("Hello %<name>s!")
      end

      it "can be used with ai_generate" do
        RailsAIPromptable::TemplateRegistry.register(:greeting, "Hello %<name>s!")

        test_class.ai_use_template(:greeting)

        expect(mock_client).to receive(:generate).with(
          prompt: "Hello World!",
          model: "gpt-4o-mini",
          temperature: 0.7,
          format: :text
        )

        test_instance.ai_generate(context: { name: "World" })
      end
    end

    context "when template does not exist in registry" do
      it "raises ArgumentError with helpful message" do
        RailsAIPromptable::TemplateRegistry.register(:existing, "Existing template")

        expect do
          test_class.ai_use_template(:nonexistent)
        end.to raise_error(ArgumentError, /Template 'nonexistent' not found.*existing/)
      end
    end
  end

  describe "#render_template (private)" do
    it "renders template with symbol keys" do
      test_class.prompt_template("Hello %<name>s!")
      result = test_instance.send(:render_template, "Hello %<name>s!", { name: "World" })
      expect(result).to eq("Hello World!")
    end

    it "handles missing keys gracefully with fallback" do
      test_class.prompt_template("Hello %<name>s, %<missing>s!")
      result = test_instance.send(:render_template, "Hello %<name>s, %<missing>s!", { name: "World" })
      expect(result).to eq("Hello World, %<missing>s!")
    end
  end
end
