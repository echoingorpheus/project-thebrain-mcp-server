# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ThebrainMcpServer::McpProtocol do
  describe '.parse_message' do
    it 'parses valid JSON-RPC message' do
      json = {
        jsonrpc: '2.0',
        method: 'test/method',
        id: 1
      }.to_json

      result = described_class.parse_message(json)
      expect(result).to be_a(Hash)
      expect(result['method']).to eq('test/method')
    end

    it 'raises error for invalid JSON' do
      expect do
        described_class.parse_message('invalid json')
      end.to raise_error(ThebrainMcpServer::McpProtocolError, /Invalid JSON/)
    end

    it 'raises error for wrong JSON-RPC version' do
      json = {
        jsonrpc: '1.0',
        method: 'test'
      }.to_json

      expect do
        described_class.parse_message(json)
      end.to raise_error(ThebrainMcpServer::McpProtocolError, 'Invalid JSON-RPC version')
    end
  end

  describe '.create_response' do
    it 'creates successful response' do
      response = described_class.create_response(
        id: 1,
        result: { data: 'test' }
      )

      expect(response).to include(
        jsonrpc: '2.0',
        id: 1,
        result: { data: 'test' }
      )
    end

    it 'creates error response' do
      error = { code: -32_603, message: 'Internal error' }
      response = described_class.create_response(
        id: 1,
        error: error
      )

      expect(response).to include(
        jsonrpc: '2.0',
        id: 1,
        error: error
      )
    end
  end

  describe '.create_init_response' do
    it 'creates proper initialization response' do
      response = described_class.create_init_response(id: 1)

      expect(response[:result]).to include(
        protocolVersion: ThebrainMcpServer::McpProtocol::PROTOCOL_VERSION,
        capabilities: { tools: {}, resources: {} },
        serverInfo: {
          name: 'thebrain-mcp-server-ruby',
          version: ThebrainMcpServer::VERSION
        }
      )
    end
  end

  describe '.create_tools_list_response' do
    it 'creates tools list with all expected tools' do
      response = described_class.create_tools_list_response(id: 1)
      tools = response[:result][:tools]

      expect(tools).to be_an(Array)
      expect(tools.length).to eq(5)

      tool_names = tools.map { |tool| tool[:name] }
      expect(tool_names).to include(
        'search_thoughts',
        'get_thought',
        'create_thought',
        'update_thought',
        'delete_thought'
      )
    end

    it 'includes proper input schemas for tools' do
      response = described_class.create_tools_list_response(id: 1)
      search_tool = response[:result][:tools].find { |tool| tool[:name] == 'search_thoughts' }

      expect(search_tool[:inputSchema]).to include(
        type: 'object',
        properties: hash_including(
          query: { type: 'string', description: 'Search query' }
        ),
        required: ['query']
      )
    end
  end

  describe '.create_resources_list_response' do
    let(:thoughts) do
      [
        { 'id' => '123', 'name' => 'Test Thought', 'notes' => 'Test notes' },
        { 'id' => '456', 'name' => 'Another Thought', 'notes' => 'More notes' }
      ]
    end

    it 'creates resources list from thoughts' do
      response = described_class.create_resources_list_response(id: 1, thoughts: thoughts)
      resources = response[:result][:resources]

      expect(resources).to be_an(Array)
      expect(resources.length).to eq(2)

      first_resource = resources.first
      expect(first_resource).to include(
        uri: 'thebrain://thought/123',
        name: 'Test Thought',
        mimeType: 'text/plain'
      )
    end
  end
end
