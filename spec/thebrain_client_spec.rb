# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ThebrainMcpServer::ThebrainClient do
  subject(:client) do
    described_class.new(
      base_url: 'https://test.example.com',
      api_key: 'test-key',
      brain_id: 'test-brain'
    )
  end

  describe '#initialize' do
    it 'sets up the client with provided configuration' do
      expect(client.base_url).to eq('https://test.example.com')
      expect(client.api_key).to eq('test-key')
      expect(client.brain_id).to eq('test-brain')
      expect(client.connection).to be_a(Faraday::Connection)
    end

    it 'uses default configuration when no parameters provided' do
      default_client = described_class.new
      expect(default_client.base_url).to eq(ThebrainMcpServer.config.thebrain_api_url)
      expect(default_client.api_key).to eq(ThebrainMcpServer.config.thebrain_api_key)
      expect(default_client.brain_id).to eq(ThebrainMcpServer.config.thebrain_brain_id)
    end

    context 'when configuration is invalid' do
      it 'raises ConfigurationError for missing API key' do
        expect do
          described_class.new(
            base_url: 'https://test.example.com',
            api_key: nil,
            brain_id: 'test-brain'
          )
        end.to raise_error(ThebrainMcpServer::ConfigurationError, 'API key is required')
      end

      it 'raises ConfigurationError for missing brain ID' do
        expect do
          described_class.new(
            base_url: 'https://test.example.com',
            api_key: 'test-key',
            brain_id: nil
          )
        end.to raise_error(ThebrainMcpServer::ConfigurationError, 'Brain ID is required')
      end

      it 'raises ConfigurationError for missing base URL' do
        expect do
          described_class.new(
            base_url: nil,
            api_key: 'test-key',
            brain_id: 'test-brain'
          )
        end.to raise_error(ThebrainMcpServer::ConfigurationError, 'Base URL is required')
      end
    end
  end

  describe '#search_thoughts' do
    let(:search_response) do
      {
        'thoughts' => [
          {
            'id' => '123',
            'name' => 'Test Thought',
            'notes' => 'This is a test thought'
          }
        ],
        'total' => 1
      }
    end

    before do
      stub_request(:get, 'https://test.example.com/brains/test-brain/thoughts/search')
        .with(query: { q: 'test', limit: 10 })
        .to_return(
          status: 200,
          body: search_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'searches for thoughts successfully' do
      result = client.search_thoughts('test')

      expect(result).to include_json(search_response)
      expect(result['thoughts']).to have_attributes(length: 1)
      expect(result['thoughts'].first['name']).to eq('Test Thought')
    end

    it 'handles search with custom limit' do
      stub_request(:get, 'https://test.example.com/brains/test-brain/thoughts/search')
        .with(query: { q: 'test', limit: 5 })
        .to_return(status: 200, body: search_response.to_json)

      result = client.search_thoughts('test', limit: 5)
      expect(result).to include_json(search_response)
    end
  end

  describe '#get_thought' do
    let(:thought_response) do
      {
        'id' => '123',
        'name' => 'Test Thought',
        'notes' => 'This is a test thought',
        'created_at' => '2024-01-01T00:00:00Z'
      }
    end

    before do
      stub_request(:get, 'https://test.example.com/brains/test-brain/thoughts/123')
        .to_return(
          status: 200,
          body: thought_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'retrieves a thought successfully' do
      result = client.get_thought('123')

      expect(result).to include_json(thought_response)
      expect(result['id']).to eq('123')
      expect(result['name']).to eq('Test Thought')
    end

    it 'caches thought data' do
      # First call
      result1 = client.get_thought('123')

      # Second call should use cache (no additional HTTP request)
      result2 = client.get_thought('123')

      expect(result1).to eq(result2)
      expect(WebMock).to have_requested(:get, 'https://test.example.com/brains/test-brain/thoughts/123').once
    end
  end

  describe '#create_thought' do
    let(:create_response) do
      {
        'id' => '456',
        'name' => 'New Thought',
        'notes' => 'New thought notes',
        'created_at' => '2024-01-01T00:00:00Z'
      }
    end

    before do
      stub_request(:post, 'https://test.example.com/brains/test-brain/thoughts')
        .with(
          body: {
            name: 'New Thought',
            notes: 'New thought notes'
          }.to_json
        )
        .to_return(
          status: 201,
          body: create_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'creates a thought successfully' do
      result = client.create_thought(name: 'New Thought', notes: 'New thought notes')

      expect(result).to include_json(create_response)
      expect(result['id']).to eq('456')
      expect(result['name']).to eq('New Thought')
    end
  end

  describe '#update_thought' do
    let(:update_response) do
      {
        'id' => '123',
        'name' => 'Updated Thought',
        'notes' => 'Updated notes',
        'modified_at' => '2024-01-02T00:00:00Z'
      }
    end

    before do
      stub_request(:put, 'https://test.example.com/brains/test-brain/thoughts/123')
        .with(
          body: {
            name: 'Updated Thought',
            notes: 'Updated notes'
          }.to_json
        )
        .to_return(
          status: 200,
          body: update_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'updates a thought successfully' do
      result = client.update_thought('123', name: 'Updated Thought', notes: 'Updated notes')

      expect(result).to include_json(update_response)
      expect(result['name']).to eq('Updated Thought')
    end
  end

  describe '#delete_thought' do
    before do
      stub_request(:delete, 'https://test.example.com/brains/test-brain/thoughts/123')
        .to_return(status: 204)
    end

    it 'deletes a thought successfully' do
      result = client.delete_thought('123')
      expect(result).to be true
    end
  end

  describe 'error handling' do
    it 'raises AuthenticationError for 401 responses' do
      stub_request(:get, 'https://test.example.com/brains/test-brain/thoughts/123')
        .to_return(status: 401, body: '{"error": "Unauthorized"}')

      expect do
        client.get_thought('123')
      end.to raise_error(ThebrainMcpServer::AuthenticationError)
    end

    it 'raises ThoughtNotFoundError for 404 responses' do
      stub_request(:get, 'https://test.example.com/brains/test-brain/thoughts/nonexistent')
        .to_return(status: 404, body: '{"error": "Not found"}')

      expect do
        client.get_thought('nonexistent')
      end.to raise_error(ThebrainMcpServer::ThoughtNotFoundError)
    end

    it 'raises RateLimitError for 429 responses' do
      stub_request(:get, 'https://test.example.com/brains/test-brain/thoughts/123')
        .to_return(status: 429, body: '{"error": "Rate limit exceeded"}')

      expect do
        client.get_thought('123')
      end.to raise_error(ThebrainMcpServer::RateLimitError)
    end
  end
end
