# frozen_string_literal: true

require_relative '../lib/thebrain_mcp_server'

RSpec.describe 'Debug ThebrainClient validation' do
  it 'should raise error for nil API key' do
    puts "About to create client with nil API key..."
    
    begin
      client = ThebrainMcpServer::ThebrainClient.new(
        base_url: 'https://test.example.com',
        api_key: nil,
        brain_id: 'test-brain'
      )
      puts "ERROR: Client created successfully!"
      puts "API Key: #{client.api_key.inspect}"
      puts "Brain ID: #{client.brain_id.inspect}"
      puts "Base URL: #{client.base_url.inspect}"
      fail "Expected ConfigurationError to be raised"
    rescue ThebrainMcpServer::ConfigurationError => e
      puts "SUCCESS: ConfigurationError raised: #{e.message}"
      expect(e.message).to eq('API key is required')
    end
  end
end
