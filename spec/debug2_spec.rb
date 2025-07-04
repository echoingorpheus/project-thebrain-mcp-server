# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Debug Configuration Error' do
  it 'can create and raise ConfigurationError directly' do
    expect do
      raise ThebrainMcpServer::ConfigurationError, 'API key is required'
    end.to raise_error(ThebrainMcpServer::ConfigurationError, 'API key is required')
  end

  it 'shows what actually happens when creating a client with nil api_key' do
    puts "\n=== DEBUG: Creating client with nil API key ==="
    
    exception_raised = nil
    client_created = nil
    
    begin
      client_created = ThebrainMcpServer::ThebrainClient.new(
        base_url: 'https://test.example.com',
        api_key: nil,
        brain_id: 'test-brain'
      )
      puts "CLIENT CREATED: #{client_created.class}"
      puts "api_key: #{client_created.api_key.inspect}"
      puts "brain_id: #{client_created.brain_id.inspect}"
    rescue => e
      exception_raised = e
      puts "EXCEPTION RAISED: #{e.class} - #{e.message}"
    end
    
    if exception_raised
      expect(exception_raised).to be_a(ThebrainMcpServer::ConfigurationError)
      expect(exception_raised.message).to eq('API key is required')
    else
      fail "Expected ConfigurationError to be raised, but client was created instead"
    end
  end
end
