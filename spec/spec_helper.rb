# frozen_string_literal: true

require "rails_ai_promptable"
require "webmock/rspec"
require "active_support"
require "active_support/core_ext"

# Disable external HTTP requests during tests
WebMock.disable_net_connect!(allow_localhost: true)

# Generator testing support
begin
  require 'rails/generators'
  require 'generator_spec'
rescue LoadError
  # Generator testing gems not available, skip generator tests
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset configuration before each test
  config.before(:each) do
    RailsAIPromptable.configuration = nil
    RailsAIPromptable.reset_client!
  end
end
