# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ThebrainMcpServer::Server do
  let(:server) { described_class.new }
  let(:mock_client) { instance_double(ThebrainMcpServer::ThebrainClient) }

  before do
    allow(ThebrainMcpServer::ThebrainClient).to receive(:new).and_return(mock_client)
  end

  describe '#handle_request' do
    context 'with initialize request' do
      let(:init_request) do
        {
          'jsonrpc' => '2.0',
          'id' => 1,
          'method' => 'initialize',
          'params' => {
            'protocolVersion' => '2024-11-05',
            'capabilities' => {}
          }
        }
      end

      it 'handles initialization request' do
        response = server.handle_request(init_request.to_json)
        parsed_response = JSON.parse(response)

        expect(parsed_response['jsonrpc']).to eq('2.0')
        expect(parsed_response['id']).to eq(1)
        expect(parsed_response['result']).to have_key('protocolVersion')
        expect(parsed_response['result']).to have_key('capabilities')
        expect(parsed_response['result']['capabilities']).to have_key('tools')
        expect(parsed_response['result']['capabilities']).to have_key('resources')
      end
    end

    context 'with tools/list request' do
      let(:tools_list_request) do
        {
          'jsonrpc' => '2.0',
          'id' => 2,
          'method' => 'tools/list'
        }
      end

      it 'returns list of available tools' do
        response = server.handle_request(tools_list_request.to_json)
        parsed_response = JSON.parse(response)

        expect(parsed_response['jsonrpc']).to eq('2.0')
        expect(parsed_response['id']).to eq(2)
        expect(parsed_response['result']).to have_key('tools')

        tools = parsed_response['result']['tools']
        tool_names = tools.map { |tool| tool['name'] }

        expect(tool_names).to include('search_thoughts')
        expect(tool_names).to include('get_thought')
        expect(tool_names).to include('create_thought')
        expect(tool_names).to include('update_thought')
        expect(tool_names).to include('delete_thought')
      end
    end

    context 'with tools/call request for search_thoughts' do
      let(:search_request) do
        {
          'jsonrpc' => '2.0',
          'id' => 3,
          'method' => 'tools/call',
          'params' => {
            'name' => 'search_thoughts',
            'arguments' => {
              'query' => 'test query',
              'limit' => 5
            }
          }
        }
      end

      it 'calls search_thoughts on the client' do
        search_result = [
          { 'id' => '1', 'name' => 'Test Thought', 'notes' => 'Test notes' }
        ]

        allow(mock_client).to receive(:search_thoughts)
          .with('test query', limit: 5)
          .and_return(search_result)

        response = server.handle_request(search_request.to_json)
        parsed_response = JSON.parse(response)

        expect(parsed_response['jsonrpc']).to eq('2.0')
        expect(parsed_response['id']).to eq(3)
        expect(parsed_response['result']).to have_key('content')
        expect(parsed_response['result']['content']).to be_a(Array)
      end
    end

    context 'with tools/call request for get_thought' do
      let(:get_thought_request) do
        {
          'jsonrpc' => '2.0',
          'id' => 4,
          'method' => 'tools/call',
          'params' => {
            'name' => 'get_thought',
            'arguments' => {
              'thought_id' => '123'
            }
          }
        }
      end

      it 'calls get_thought on the client' do
        thought_result = {
          'id' => '123',
          'name' => 'Test Thought',
          'notes' => 'Test notes'
        }

        allow(mock_client).to receive(:get_thought)
          .with('123')
          .and_return(thought_result)

        response = server.handle_request(get_thought_request.to_json)
        parsed_response = JSON.parse(response)

        expect(parsed_response['jsonrpc']).to eq('2.0')
        expect(parsed_response['id']).to eq(4)
        expect(parsed_response['result']).to have_key('content')
        expect(parsed_response['result']['content']).to be_a(Array)
      end
    end

    context 'with tools/call request for create_thought' do
      let(:create_thought_request) do
        {
          'jsonrpc' => '2.0',
          'id' => 5,
          'method' => 'tools/call',
          'params' => {
            'name' => 'create_thought',
            'arguments' => {
              'name' => 'New Thought',
              'notes' => 'New notes',
              'parent_id' => '456'
            }
          }
        }
      end

      it 'calls create_thought on the client' do
        created_thought = {
          'id' => '789',
          'name' => 'New Thought',
          'notes' => 'New notes'
        }

        allow(mock_client).to receive(:create_thought)
          .with(name: 'New Thought', notes: 'New notes', parent_id: '456')
          .and_return(created_thought)

        response = server.handle_request(create_thought_request.to_json)
        parsed_response = JSON.parse(response)

        expect(parsed_response['jsonrpc']).to eq('2.0')
        expect(parsed_response['id']).to eq(5)
        expect(parsed_response['result']).to have_key('content')
        expect(parsed_response['result']['content']).to be_a(Array)
      end
    end

    context 'with resources/list request' do
      let(:resources_list_request) do
        {
          'jsonrpc' => '2.0',
          'id' => 6,
          'method' => 'resources/list'
        }
      end

      it 'returns list of available resources' do
        thoughts = [
          { 'id' => '1', 'name' => 'Thought 1' },
          { 'id' => '2', 'name' => 'Thought 2' }
        ]

        allow(mock_client).to receive(:search_thoughts)
          .with('', limit: 100)
          .and_return(thoughts)

        response = server.handle_request(resources_list_request.to_json)
        parsed_response = JSON.parse(response)

        expect(parsed_response['jsonrpc']).to eq('2.0')
        expect(parsed_response['id']).to eq(6)
        expect(parsed_response['result']).to have_key('resources')
        expect(parsed_response['result']['resources']).to be_a(Array)
        expect(parsed_response['result']['resources'].size).to eq(2)
      end
    end

    context 'with unknown method' do
      let(:unknown_request) do
        {
          'jsonrpc' => '2.0',
          'id' => 7,
          'method' => 'unknown/method'
        }
      end

      it 'returns method not found error' do
        response = server.handle_request(unknown_request.to_json)
        parsed_response = JSON.parse(response)

        expect(parsed_response['jsonrpc']).to eq('2.0')
        expect(parsed_response['id']).to eq(7)
        expect(parsed_response).to have_key('error')
        expect(parsed_response['error']['code']).to eq(-32_601)
        expect(parsed_response['error']['message']).to eq('Method not found: unknown/method')
      end
    end

    context 'with invalid JSON' do
      let(:invalid_json) { '{"invalid": json}' }

      it 'returns parse error' do
        response = server.handle_request(invalid_json)
        parsed_response = JSON.parse(response)

        expect(parsed_response['jsonrpc']).to eq('2.0')
        expect(parsed_response['id']).to be_nil
        expect(parsed_response).to have_key('error')
        expect(parsed_response['error']['code']).to eq(-32_600)
        expect(parsed_response['error']['message']).to include('Invalid JSON')
      end
    end

    context 'when client raises an error' do
      let(:search_request) do
        {
          'jsonrpc' => '2.0',
          'id' => 8,
          'method' => 'tools/call',
          'params' => {
            'name' => 'search_thoughts',
            'arguments' => {
              'query' => 'test'
            }
          }
        }
      end

      it 'returns error response for authentication error' do
        allow(mock_client).to receive(:search_thoughts)
          .and_raise(ThebrainMcpServer::AuthenticationError, 'Invalid API key')

        response = server.handle_request(search_request.to_json)
        parsed_response = JSON.parse(response)

        expect(parsed_response['jsonrpc']).to eq('2.0')
        expect(parsed_response['id']).to eq(8)
        expect(parsed_response).to have_key('error')
        expect(parsed_response['error']['message']).to include('Invalid API key')
      end

      it 'returns error response for generic error' do
        allow(mock_client).to receive(:search_thoughts)
          .and_raise(StandardError, 'Something went wrong')

        response = server.handle_request(search_request.to_json)
        parsed_response = JSON.parse(response)

        expect(parsed_response['jsonrpc']).to eq('2.0')
        expect(parsed_response['id']).to eq(8)
        expect(parsed_response).to have_key('error')
        expect(parsed_response['error']['message']).to eq('Internal error')
      end
    end
  end
end
