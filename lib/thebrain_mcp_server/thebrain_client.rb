# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'json'
require 'concurrent-ruby'

module ThebrainMcpServer
  # Client for interacting with TheBrain API
  class ThebrainClient
    attr_reader :base_url, :api_key, :brain_id, :connection

    def initialize(base_url: :not_provided, api_key: :not_provided, brain_id: :not_provided)
      @base_url = base_url == :not_provided ? ThebrainMcpServer.config.thebrain_api_url : base_url
      @api_key = api_key == :not_provided ? ThebrainMcpServer.config.thebrain_api_key : api_key
      @brain_id = brain_id == :not_provided ? ThebrainMcpServer.config.thebrain_brain_id : brain_id
      @cache = Concurrent::Map.new
      @connection = build_connection

      validate_configuration!
    end

    # Search for thoughts
    def search_thoughts(query, limit: 10)
      ThebrainMcpServer.logger.info("Searching thoughts with query: #{query}")

      params = { q: query, limit: limit }
      response = get("/brains/#{@brain_id}/thoughts/search", params)

      parse_response(response)
    rescue StandardError => e
      handle_error(e, 'search thoughts')
    end

    # Get a specific thought by ID
    def get_thought(thought_id)
      cache_key = "thought_#{thought_id}"

      @cache.compute_if_absent(cache_key) do
        ThebrainMcpServer.logger.info("Fetching thought: #{thought_id}")
        response = get("/brains/#{@brain_id}/thoughts/#{thought_id}")
        parse_response(response)
      end
    rescue StandardError => e
      handle_error(e, 'get thought')
    end

    # Create a new thought
    def create_thought(name:, notes: nil, parent_id: nil, **attributes)
      ThebrainMcpServer.logger.info("Creating thought: #{name}")

      body = {
        name: name,
        notes: notes,
        parentId: parent_id
      }.merge(attributes).compact

      response = post("/brains/#{@brain_id}/thoughts", body)
      result = parse_response(response)

      # Clear cache since we have new data
      clear_cache

      result
    rescue StandardError => e
      handle_error(e, 'create thought')
    end

    # Update an existing thought
    def update_thought(thought_id, **attributes)
      ThebrainMcpServer.logger.info("Updating thought: #{thought_id}")

      response = put("/brains/#{@brain_id}/thoughts/#{thought_id}", attributes.compact)
      result = parse_response(response)

      # Clear cache for this thought
      @cache.delete("thought_#{thought_id}")

      result
    rescue StandardError => e
      handle_error(e, 'update thought')
    end

    # Delete a thought
    def delete_thought(thought_id)
      ThebrainMcpServer.logger.info("Deleting thought: #{thought_id}")

      response = delete("/brains/#{@brain_id}/thoughts/#{thought_id}")

      # Clear cache for this thought
      @cache.delete("thought_#{thought_id}")

      [204, 200].include?(response.status)
    rescue StandardError => e
      handle_error(e, 'delete thought')
    end

    # Get all thoughts (paginated)
    def list_thoughts(limit: 50)
      ThebrainMcpServer.logger.info("Listing thoughts (limit: #{limit})")

      params = { limit: limit }
      response = get("/brains/#{@brain_id}/thoughts", params)

      parse_response(response)
    rescue StandardError => e
      handle_error(e, 'list thoughts')
    end

    # Get thought links/connections
    def get_thought_links(thought_id)
      ThebrainMcpServer.logger.info("Getting links for thought: #{thought_id}")

      response = get("/brains/#{@brain_id}/thoughts/#{thought_id}/links")
      parse_response(response)
    rescue StandardError => e
      handle_error(e, 'get thought links')
    end

    # Health check
    def health_check
      response = get('/health')
      response.status == 200
    rescue StandardError
      false
    end

    private

    def validate_configuration!
      raise ConfigurationError, 'API key is required' if @api_key.nil? || @api_key.to_s.empty?
      raise ConfigurationError, 'Brain ID is required' if @brain_id.nil? || @brain_id.to_s.empty?
      raise ConfigurationError, 'Base URL is required' if @base_url.nil? || @base_url.to_s.empty?
    end

    def build_connection
      Faraday.new(url: @base_url) do |conn|
        conn.request :json
        conn.request :retry, {
          max: ThebrainMcpServer.config.retry_attempts,
          interval: 0.5,
          backoff_factor: 2
        }

        conn.response :json
        conn.response :logger, ThebrainMcpServer.logger, { headers: false, bodies: false }

        conn.headers['Accept'] = 'application/json'
        conn.headers['User-Agent'] = "TheBrain MCP Server Ruby #{ThebrainMcpServer::VERSION}"
        conn.headers['Authorization'] = "Bearer #{@api_key}"

        conn.options.timeout = ThebrainMcpServer.config.timeout
        conn.adapter Faraday.default_adapter
      end
    end

    def get(path, params = {})
      @connection.get(path, params)
    end

    def post(path, body = {})
      @connection.post(path, body)
    end

    def put(path, body = {})
      @connection.put(path, body)
    end

    def delete(path)
      @connection.delete(path)
    end

    def parse_response(response)
      case response.status
      when 200..299
        response.body
      when 401
        raise AuthenticationError.new('Authentication failed',
                                      status_code: response.status,
                                      response_body: response.body)
      when 404
        raise ThoughtNotFoundError.new('Thought not found',
                                       status_code: response.status,
                                       response_body: response.body)
      when 429
        raise RateLimitError.new('Rate limit exceeded',
                                 status_code: response.status,
                                 response_body: response.body)
      else
        raise ThebrainApiError.new("API request failed: #{response.status}",
                                   status_code: response.status,
                                   response_body: response.body)
      end
    end

    def handle_error(error, operation)
      ThebrainMcpServer.logger.error("Failed to #{operation}: #{error.message}")
      raise error
    end

    def clear_cache
      @cache.clear
    end
  end
end
