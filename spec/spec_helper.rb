# frozen_string_literal: true

require 'simplecov'
require 'simplecov-console'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                 SimpleCov::Formatter::HTMLFormatter,
                                                                 SimpleCov::Formatter::Console
                                                               ])
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
end

require 'rspec'
require 'rspec/json_expectations'
require 'webmock/rspec'
require 'vcr'
require 'pry'

require_relative '../lib/thebrain_mcp_server'

# Configure VCR for HTTP request recording
VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: %i[method uri body]
  }
end

# Configure WebMock
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  config.order = :random
  Kernel.srand config.seed

  # Configure ThebrainMcpServer for testing
  config.before(:suite) do
    ThebrainMcpServer.configure do |server_config|
      server_config.thebrain_api_url = 'https://test.example.com'
      server_config.thebrain_api_key = 'test-api-key'
      server_config.thebrain_brain_id = 'test-brain-id'
      server_config.log_level = :debug
      server_config.timeout = 5
      server_config.retry_attempts = 1
    end
  end
end
