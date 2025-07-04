#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/thebrain_mcp_server'

puts 'Testing configuration validation...'

begin
  client = ThebrainMcpServer::ThebrainClient.new(api_key: nil)
  puts 'ERROR: No exception was raised!'
  puts "API Key: #{client.api_key.inspect}"
  puts "Brain ID: #{client.brain_id.inspect}"
  puts "Base URL: #{client.base_url.inspect}"
rescue ThebrainMcpServer::ConfigurationError => e
  puts "SUCCESS: ConfigurationError raised: #{e.message}"
rescue StandardError => e
  puts "ERROR: Unexpected exception: #{e.class} - #{e.message}"
end

begin
  client = ThebrainMcpServer::ThebrainClient.new(brain_id: nil)
  puts 'ERROR: No exception was raised!'
  puts "API Key: #{client.api_key.inspect}"
  puts "Brain ID: #{client.brain_id.inspect}"
  puts "Base URL: #{client.base_url.inspect}"
rescue ThebrainMcpServer::ConfigurationError => e
  puts "SUCCESS: ConfigurationError raised: #{e.message}"
rescue StandardError => e
  puts "ERROR: Unexpected exception: #{e.class} - #{e.message}"
end
