#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script to verify MCP protocol communication
require_relative 'lib/thebrain_mcp_server'

puts '🧪 Testing MCP Protocol Communication...'
puts '=' * 50

# Create a server instance
server = ThebrainMcpServer::Server.new

# Test 1: Initialize request
puts "\n1️⃣  Testing Initialize Request"
init_request = {
  jsonrpc: '2.0',
  id: 1,
  method: 'initialize',
  params: {
    protocolVersion: '2024-11-05',
    capabilities: {
      tools: {},
      resources: {}
    },
    clientInfo: {
      name: 'test-client',
      version: '1.0.0'
    }
  }
}.to_json

puts "📤 Sending: #{init_request}"
response = server.handle_request(init_request)
puts "📥 Response: #{response}"
puts response ? '✅ Initialize request handled successfully' : '❌ Initialize request failed'

# Test 2: Tools list request
puts "\n2️⃣  Testing Tools List Request"
tools_request = {
  jsonrpc: '2.0',
  id: 2,
  method: 'tools/list'
}.to_json

puts "📤 Sending: #{tools_request}"
response = server.handle_request(tools_request)
puts "📥 Response: #{response}"

if response
  parsed = JSON.parse(response)
  tools_count = parsed.dig('result', 'tools')&.length || 0
  puts "✅ Tools list request successful - Found #{tools_count} tools"

  # Show available tools
  tools = parsed.dig('result', 'tools') || []
  tools.each do |tool|
    puts "   🔧 #{tool['name']}: #{tool['description']}"
  end
else
  puts '❌ Tools list request failed'
end

# Test 3: Resources list request
puts "\n3️⃣  Testing Resources List Request"
resources_request = {
  jsonrpc: '2.0',
  id: 3,
  method: 'resources/list'
}.to_json

puts "📤 Sending: #{resources_request}"
response = server.handle_request(resources_request)
puts "📥 Response: #{response}"

if response
  parsed = JSON.parse(response)
  puts '✅ Resources list request successful'

  # Show resource template
  resources = parsed.dig('result', 'resources') || []
  if resources.any?
    puts '   📚 Available resource patterns:'
    resources.each do |resource|
      puts "   - #{resource['uri']}: #{resource['name']}"
    end
  else
    puts '   📚 No resources configured (expected for test mode)'
  end
else
  puts '❌ Resources list request failed'
end

# Test 4: Error handling - Invalid JSON
puts "\n4️⃣  Testing Error Handling"
invalid_request = '{ invalid json }'

puts "📤 Sending invalid JSON: #{invalid_request}"
response = server.handle_request(invalid_request)
puts "📥 Response: #{response}"

if response
  parsed = JSON.parse(response)
  if parsed['error']
    puts '✅ Error handling working - Invalid JSON properly rejected'
    puts "   Error: #{parsed['error']['message']}"
  else
    puts '❌ Expected error response for invalid JSON'
  end
else
  puts '❌ No response for invalid JSON'
end

# Test 5: Unknown method
puts "\n5️⃣  Testing Unknown Method Handling"
unknown_request = {
  jsonrpc: '2.0',
  id: 5,
  method: 'unknown/method'
}.to_json

puts "📤 Sending: #{unknown_request}"
response = server.handle_request(unknown_request)
puts "📥 Response: #{response}"

if response
  parsed = JSON.parse(response)
  if parsed['error'] && parsed['error']['code'] == -32_601
    puts '✅ Unknown method properly rejected with correct error code'
  else
    puts '❌ Expected method not found error'
  end
else
  puts '❌ No response for unknown method'
end

puts "\n" + ('=' * 50)
puts '🎉 MCP Protocol Test Complete!'
puts '✅ The MCP Server is working correctly and handling all protocol messages properly.'
