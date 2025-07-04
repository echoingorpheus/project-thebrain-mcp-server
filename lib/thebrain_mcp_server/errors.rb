# frozen_string_literal: true

module ThebrainMcpServer
  # Base error class for all TheBrain MCP Server errors
  class Error < StandardError; end

  # Raised when TheBrain API returns an error
  class ThebrainApiError < Error
    attr_reader :status_code, :response_body

    def initialize(message, status_code: nil, response_body: nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end

  # Raised when a thought is not found
  class ThoughtNotFoundError < ThebrainApiError; end

  # Raised when authentication fails
  class AuthenticationError < ThebrainApiError; end

  # Raised when rate limit is exceeded
  class RateLimitError < ThebrainApiError; end

  # Raised when MCP protocol validation fails
  class McpProtocolError < Error; end

  # Raised when configuration is invalid
  class ConfigurationError < Error; end
end
