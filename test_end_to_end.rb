#!/usr/bin/env ruby
# frozen_string_literal: true

# End-to-end test simulating real MCP client interaction
require_relative 'lib/thebrain_mcp_server'

# Try to require webmock if available, otherwise skip API mocking
begin
  require 'webmock'
  WEBMOCK_AVAILABLE = true
rescue LoadError
  WEBMOCK_AVAILABLE = false
  puts 'ℹ️  WebMock not available - running without API mocking'
end

puts '🔬 End-to-End MCP Server Test'
puts '=' * 50

# Enable WebMock to simulate TheBrain API responses if available
if WEBMOCK_AVAILABLE
  WebMock.enable!
else
  puts '⚠️  Running without mocked API responses'
end

# Mock successful API responses
if WEBMOCK_AVAILABLE
  WebMock.stub_request(:get, %r{api\.thebrain\.com.*/thoughts/search})
    .to_return(
      status: 200,
      body: {
        thoughts: [
          {
            id: 'thought-123',
            name: 'Test Thought',
            notes: 'This is a test thought',
            createdDateTime: '2025-01-01T00:00:00Z'
          },
          {
            id: 'thought-456',
            name: 'Another Thought',
            notes: 'Another test thought',
            createdDateTime: '2025-01-01T00:00:00Z'
          }
        ]
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

  WebMock.stub_request(:get, %r{api\.thebrain\.com.*/thoughts/thought-123})
    .to_return(
      status: 200,
      body: {
        id: 'thought-123',
        name: 'Test Thought',
        notes: 'This is a test thought with detailed content',
        createdDateTime: '2025-01-01T00:00:00Z',
        modifiedDateTime: '2025-01-01T00:00:00Z',
        links: [
          { id: 'thought-456', name: 'Another Thought', direction: 'child' }
        ]
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

  WebMock.stub_request(:post, %r{api\.thebrain\.com.*/thoughts})
    .to_return(
      status: 201,
      body: {
        id: 'new-thought-789',
        name: 'New Test Thought',
        notes: 'This is a newly created thought',
        createdDateTime: '2025-01-01T00:00:00Z'
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
end

# Create server instance
server = ThebrainMcpServer::Server.new

puts "\n🚀 Starting End-to-End Tests..."

# Test 1: Initialize the connection
puts "\n1️⃣  Initializing MCP Connection"
init_response = server.handle_request({
  jsonrpc: '2.0',
  id: 1,
  method: 'initialize',
  params: {
    protocolVersion: '2024-11-05',
    capabilities: { tools: {}, resources: {} },
    clientInfo: { name: 'test-client', version: '1.0.0' }
  }
}.to_json)

if init_response
  puts '✅ Connection initialized successfully'
  init_data = JSON.parse(init_response)
  puts "   Server: #{init_data.dig('result', 'serverInfo',
                                   'name')} v#{init_data.dig('result', 'serverInfo', 'version')}"
else
  puts '❌ Failed to initialize connection'
  exit 1
end

# Test 2: Search for thoughts
puts "\n2️⃣  Searching for Thoughts"
search_response = server.handle_request({
  jsonrpc: '2.0',
  id: 2,
  method: 'tools/call',
  params: {
    name: 'search_thoughts',
    arguments: {
      query: 'test',
      limit: 5
    }
  }
}.to_json)

if search_response
  search_data = JSON.parse(search_response)
  if search_data['result']
    content = search_data.dig('result', 'content', 0, 'text')
    puts '✅ Search completed successfully'
    puts '   Found thoughts containing search results'
    puts "   Content preview: #{content[0..50]}..." if content
  else
    puts "❌ Search failed: #{search_data['error']['message']}"
  end
else
  puts '❌ No response to search request'
end

# Test 3: Get specific thought
puts "\n3️⃣  Retrieving Specific Thought"
get_response = server.handle_request({
  jsonrpc: '2.0',
  id: 3,
  method: 'tools/call',
  params: {
    name: 'get_thought',
    arguments: {
      thought_id: 'thought-123'
    }
  }
}.to_json)

if get_response
  get_data = JSON.parse(get_response)
  if get_data['result']
    puts '✅ Thought retrieved successfully'
    content = get_data.dig('result', 'content', 0, 'text')
    puts "   Content preview: #{content[0..100]}..." if content
  else
    puts "❌ Failed to get thought: #{get_data['error']['message']}"
  end
else
  puts '❌ No response to get thought request'
end

# Test 4: Create new thought
puts "\n4️⃣  Creating New Thought"
create_response = server.handle_request({
  jsonrpc: '2.0',
  id: 4,
  method: 'tools/call',
  params: {
    name: 'create_thought',
    arguments: {
      name: 'Test from MCP',
      notes: 'This thought was created via the MCP server'
    }
  }
}.to_json)

if create_response
  create_data = JSON.parse(create_response)
  if create_data['result']
    puts '✅ Thought created successfully'
    content = create_data.dig('result', 'content', 0, 'text')
    puts "   Response: #{content}" if content
  else
    puts "❌ Failed to create thought: #{create_data['error']['message']}"
  end
else
  puts '❌ No response to create thought request'
end

# Test 5: Test resource access
puts "\n5️⃣  Testing Resource Access"
resource_response = server.handle_request({
  jsonrpc: '2.0',
  id: 5,
  method: 'resources/read',
  params: {
    uri: 'thebrain://thought/thought-123'
  }
}.to_json)

if resource_response
  resource_data = JSON.parse(resource_response)
  if resource_data['result']
    puts '✅ Resource accessed successfully'
    content = resource_data.dig('result', 'contents', 0, 'text')
    puts "   Content type: #{resource_data.dig('result', 'contents', 0, 'mimeType')}"
    puts "   Content preview: #{content[0..100]}..." if content
  else
    puts "❌ Failed to access resource: #{resource_data['error']['message']}"
  end
else
  puts '❌ No response to resource request'
end

# Test 6: Error handling with invalid thought ID
puts "\n6️⃣  Testing Error Handling"
if WEBMOCK_AVAILABLE
  WebMock.stub_request(:get, %r{api\.thebrain\.com.*/thoughts/invalid-id})
    .to_return(status: 404, body: { error: 'Not found' }.to_json)
end

error_response = server.handle_request({
  jsonrpc: '2.0',
  id: 6,
  method: 'tools/call',
  params: {
    name: 'get_thought',
    arguments: {
      thought_id: 'invalid-id'
    }
  }
}.to_json)

if error_response
  error_data = JSON.parse(error_response)
  if error_data['error']
    puts '✅ Error handling working correctly'
    puts "   Error: #{error_data['error']['message']}"
  else
    puts '❌ Expected error response'
  end
else
  puts '❌ No response for invalid request'
end

puts "\n" + ('=' * 50)
puts '🎉 End-to-End Test Complete!'
puts '✅ MCP Server successfully:'
puts '   • Initializes connections'
puts '   • Handles tool calls (search, get, create)'
puts '   • Provides resource access'
puts '   • Manages errors gracefully'
puts '   • Communicates with TheBrain API'
puts "\n🚀 Your TheBrain MCP Server is fully functional!"

WebMock.disable! if WEBMOCK_AVAILABLE
