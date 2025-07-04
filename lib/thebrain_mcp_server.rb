# frozen_string_literal: true

require 'zeitwerk'
require 'json'
require 'logger'
require 'dry-configurable'
require 'dry/logger'

# Load environment variables in development/test
if %w[development test].include?(ENV['RUBY_ENV'] || 'development')
  require 'dotenv'
  Dotenv.load
end

# Main module for TheBrain MCP Server
module ThebrainMcpServer
  extend Dry::Configurable

  # Configure default settings with environment variable fallbacks
  setting :thebrain_api_url, default: ENV.fetch('THEBRAIN_API_URL', 'http://localhost:8080')
  setting :thebrain_api_key, default: ENV.fetch('THEBRAIN_API_KEY', nil)
  setting :thebrain_brain_id, default: ENV.fetch('THEBRAIN_BRAIN_ID', nil)
  setting :log_level, default: (ENV['LOG_LEVEL'] || 'info').to_sym
  setting :timeout, default: (ENV['TIMEOUT'] || '30').to_i
  setting :retry_attempts, default: (ENV['RETRY_ATTEMPTS'] || '3').to_i
  setting :cache_ttl, default: (ENV['CACHE_TTL'] || '300').to_i
  setting :max_search_results, default: (ENV['MAX_SEARCH_RESULTS'] || '50').to_i

  # Setup Zeitwerk autoloader
  loader = Zeitwerk::Loader.for_gem
  loader.setup

  class << self
    # Configure the server
    def configure
      yield(config) if block_given?
      setup_logger
    end

    # Get configured logger
    def logger
      @logger ||= setup_logger
    end

    private

    def setup_logger
      @logger = Logger.new($stdout).tap do |logger|
        logger.level = Logger.const_get(config.log_level.to_s.upcase)
        logger.formatter = proc do |severity, datetime, _progname, msg|
          "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
        end
      end
    end
  end
end

# Load errors first
require_relative 'thebrain_mcp_server/errors'
