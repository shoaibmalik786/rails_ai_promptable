# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsAIPromptable::Logger do
  let(:io) { StringIO.new }
  let(:logger) { described_class.new(io) }

  describe '#initialize' do
    it 'creates a logger with the provided IO' do
      expect { described_class.new(io) }.not_to raise_error
    end

    it 'defaults to $stdout if no IO provided' do
      expect { described_class.new }.not_to raise_error
    end
  end

  describe '#info' do
    it 'logs info messages' do
      logger.info('Test info message')
      io.rewind
      output = io.read
      expect(output).to include('INFO')
      expect(output).to include('Test info message')
    end
  end

  describe '#error' do
    it 'logs error messages' do
      logger.error('Test error message')
      io.rewind
      output = io.read
      expect(output).to include('ERROR')
      expect(output).to include('Test error message')
    end
  end
end
