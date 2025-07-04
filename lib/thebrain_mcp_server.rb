# frozen_string_literal: true

require 'zeitwerk'
require 'json'
require 'logger'
require 'dry-configurable'

# Main module for TheBrain MCP Server
module ThebrainMcpServer
  extend Dry::Configurable

  # Configure default settings
  setting :thebrain_api_url, default: 'https://api.thebrain.com'
  setting :thebrain_api_key, default: nil
  setting :thebrain_brain_id, default: nil
  setting :log_level, default: :info
  setting :timeout, default: 30
  setting :retry_attempts, default: 3
  setting :cache_ttl, default: 300
  setting :max_search_results, default: 50

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
