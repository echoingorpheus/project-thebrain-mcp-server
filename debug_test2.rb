#!/usr/bin/env ruby
# frozen_string_literal: true

# First, let's test the validation logic directly
class TestValidation
  def validate_test(api_key, brain_id, base_url)
    puts "Testing with api_key=#{api_key.inspect}, brain_id=#{brain_id.inspect}, base_url=#{base_url.inspect}"

    if api_key.nil? || api_key.empty?
      puts 'API key validation would fail'
    else
      puts 'API key validation would pass'
    end

    if brain_id.nil? || brain_id.empty?
      puts 'Brain ID validation would fail'
    else
      puts 'Brain ID validation would pass'
    end

    if base_url.nil? || base_url.empty?
      puts 'Base URL validation would fail'
    else
      puts 'Base URL validation would pass'
    end
    puts '---'
  end
end

test = TestValidation.new

puts '=== Direct validation tests ==='
test.validate_test(nil, 'test-brain', 'https://test.example.com')
test.validate_test('test-key', nil, 'https://test.example.com')
test.validate_test('test-key', 'test-brain', nil)

puts "\n=== Now testing actual TheBrain client ==="
require_relative 'lib/thebrain_mcp_server'

# Let's see what happens when we create the client
begin
  puts 'Creating client with api_key=nil...'
  client = ThebrainMcpServer::ThebrainClient.new(
    base_url: 'https://test.example.com',
    api_key: nil,
    brain_id: 'test-brain'
  )
  puts 'CLIENT CREATED SUCCESSFULLY! This is the problem.'
  puts "API Key: #{client.api_key.inspect}"
  puts "Brain ID: #{client.brain_id.inspect}"
  puts "Base URL: #{client.base_url.inspect}"
rescue StandardError => e
  puts "Exception raised: #{e.class} - #{e.message}"
end
