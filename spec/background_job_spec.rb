# frozen_string_literal: true

require 'spec_helper'
require 'active_job'

RSpec.describe RailsAIPromptable::BackgroundJob do
  # Create a test model that includes Promptable
  let(:test_class) do
    Class.new do
      include RailsAIPromptable::Promptable

      attr_accessor :id

      def initialize(id)
        @id = id
      end

      def self.name
        'TestModel'
      end

      def self.find_by(conditions)
        new(conditions[:id]) if conditions[:id] == 1
      end

      def ai_generate(context:, **kwargs)
        "Generated content for #{context[:name]}"
      end
    end
  end

  before do
    RailsAIPromptable.configure do |config|
      config.api_key = 'test_key'
    end

    stub_const('TestModel', test_class)
  end

  describe '#perform' do
    let(:job) { described_class.new }

    context 'when record is found' do
      it 'calls ai_generate on the record' do
        record = test_class.new(1)
        allow(test_class).to receive(:find_by).with(id: 1).and_return(record)
        expect(record).to receive(:ai_generate).with(context: { name: 'Test' }, model: 'gpt-4').and_return('result')

        job.perform('TestModel', 1, { name: 'Test' }, { model: 'gpt-4' })
      end

      it 'logs the completion' do
        expect(RailsAIPromptable.configuration.logger).to receive(:info)
          .with('[rails_ai_promptable] background generation completed for TestModel#1')

        job.perform('TestModel', 1, { name: 'Test' }, {})
      end

      it 'calls ai_generation_completed callback if defined' do
        record = test_class.new(1)
        allow(test_class).to receive(:find_by).with(id: 1).and_return(record)
        allow(record).to receive(:ai_generate).and_return('Generated content')
        allow(record).to receive(:respond_to?).and_call_original
        allow(record).to receive(:respond_to?).with(:ai_generation_completed).and_return(true)
        allow(record).to receive(:respond_to?).with(:ai_generated_content=).and_return(false)
        expect(record).to receive(:ai_generation_completed).with('Generated content')

        job.perform('TestModel', 1, { name: 'Test' }, {})
      end

      it 'stores result in ai_generated_content attribute if exists' do
        record = test_class.new(1)
        allow(test_class).to receive(:find_by).with(id: 1).and_return(record)
        allow(record).to receive(:ai_generate).and_return('Generated content')
        allow(record).to receive(:respond_to?).and_call_original
        allow(record).to receive(:respond_to?).with(:ai_generation_completed).and_return(false)
        allow(record).to receive(:respond_to?).with(:ai_generated_content=).and_return(true)
        allow(record).to receive(:respond_to?).with(:save).and_return(true)

        expect(record).to receive(:ai_generated_content=).with('Generated content')
        expect(record).to receive(:save)

        job.perform('TestModel', 1, { name: 'Test' }, {})
      end

      it 'returns the generated result' do
        record = test_class.new(1)
        allow(test_class).to receive(:find_by).with(id: 1).and_return(record)
        allow(record).to receive(:ai_generate).and_return('Generated content')

        result = job.perform('TestModel', 1, { name: 'Test' }, {})
        expect(result).to eq('Generated content')
      end
    end

    context 'when record is not found' do
      it 'does not raise an error' do
        allow(test_class).to receive(:find_by).with(id: 999).and_return(nil)

        expect {
          job.perform('TestModel', 999, { name: 'Test' }, {})
        }.not_to raise_error
      end

      it 'does not log the result' do
        allow(test_class).to receive(:find_by).with(id: 999).and_return(nil)

        expect(RailsAIPromptable.configuration.logger).not_to receive(:info)

        job.perform('TestModel', 999, { name: 'Test' }, {})
      end
    end

    context 'when kwargs is nil' do
      it 'handles nil kwargs gracefully' do
        record = test_class.new(1)
        allow(test_class).to receive(:find_by).with(id: 1).and_return(record)
        expect(record).to receive(:ai_generate).with(context: { name: 'Test' }).and_return('result')

        job.perform('TestModel', 1, { name: 'Test' }, nil)
      end
    end
  end

  describe 'queue configuration' do
    it 'is queued as :default' do
      expect(described_class.queue_name).to eq('default')
    end
  end
end
