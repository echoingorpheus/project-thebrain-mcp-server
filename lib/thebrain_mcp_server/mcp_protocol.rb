# frozen_string_literal: true

module ThebrainMcpServer
  # Handles MCP (Model Context Protocol) message formatting and validation
  module McpProtocol
    # MCP message types
    REQUEST = 'request'
    RESPONSE = 'response'
    NOTIFICATION = 'notification'

    # MCP methods
    INITIALIZE = 'initialize'
    LIST_TOOLS = 'tools/list'
    CALL_TOOL = 'tools/call'
    LIST_RESOURCES = 'resources/list'
    READ_RESOURCE = 'resources/read'

    # MCP protocol version
    PROTOCOL_VERSION = '2024-11-05'

    class << self
      # Create a JSON-RPC 2.0 response
      def create_response(id:, result: nil, error: nil)
        response = {
          jsonrpc: '2.0',
          id: id
        }

        if error
          response[:error] = format_error(error)
        else
          response[:result] = result
        end

        response
      end

      # Create a JSON-RPC 2.0 error response
      def create_error_response(id:, code:, message:, data: nil)
        error = {
          code: code,
          message: message
        }
        error[:data] = data if data

        create_response(id: id, error: error)
      end

      # Create an initialization response
      def create_init_response(id:)
        result = {
          protocolVersion: PROTOCOL_VERSION,
          capabilities: {
            tools: {},
            resources: {}
          },
          serverInfo: {
            name: 'thebrain-mcp-server-ruby',
            version: ThebrainMcpServer::VERSION
          }
        }

        create_response(id: id, result: result)
      end

      # Create tools list response
      def create_tools_list_response(id:)
        tools = [
          {
            name: 'search_thoughts',
            description: 'Search for thoughts in TheBrain',
            inputSchema: {
              type: 'object',
              properties: {
                query: {
                  type: 'string',
                  description: 'Search query'
                },
                limit: {
                  type: 'integer',
                  description: 'Maximum number of results',
                  default: 10
                }
              },
              required: ['query']
            }
          },
          {
            name: 'get_thought',
            description: 'Get a specific thought by ID',
            inputSchema: {
              type: 'object',
              properties: {
                thought_id: {
                  type: 'string',
                  description: 'Unique identifier of the thought'
                }
              },
              required: ['thought_id']
            }
          },
          {
            name: 'create_thought',
            description: 'Create a new thought',
            inputSchema: {
              type: 'object',
              properties: {
                name: {
                  type: 'string',
                  description: 'Name of the thought'
                },
                notes: {
                  type: 'string',
                  description: 'Notes content for the thought'
                },
                parent_id: {
                  type: 'string',
                  description: 'ID of the parent thought'
                }
              },
              required: ['name']
            }
          },
          {
            name: 'update_thought',
            description: 'Update an existing thought',
            inputSchema: {
              type: 'object',
              properties: {
                thought_id: {
                  type: 'string',
                  description: 'Unique identifier of the thought'
                },
                name: {
                  type: 'string',
                  description: 'New name for the thought'
                },
                notes: {
                  type: 'string',
                  description: 'New notes content'
                }
              },
              required: ['thought_id']
            }
          },
          {
            name: 'delete_thought',
            description: 'Delete a thought',
            inputSchema: {
              type: 'object',
              properties: {
                thought_id: {
                  type: 'string',
                  description: 'Unique identifier of the thought to delete'
                }
              },
              required: ['thought_id']
            }
          }
        ]

        create_response(id: id, result: { tools: tools })
      end

      # Create resources list response
      def create_resources_list_response(id:, thoughts: [])
        resources = thoughts.map do |thought|
          {
            uri: "thebrain://thought/#{thought['id']}",
            name: thought['name'],
            description: thought['notes']&.slice(0, 100),
            mimeType: 'text/plain'
          }
        end

        create_response(id: id, result: { resources: resources })
      end

      # Validate MCP message
      def validate_message(message)
        raise McpProtocolError, 'Message must be a hash' unless message.is_a?(Hash)

        raise McpProtocolError, 'Invalid JSON-RPC version' unless message['jsonrpc'] == '2.0'

        raise McpProtocolError, 'Method must be a string' unless message['method'].is_a?(String)

        true
      end

      # Parse and validate incoming message
      def parse_message(json_string)
        message = JSON.parse(json_string)
        validate_message(message)
        message
      rescue JSON::ParserError => e
        raise McpProtocolError, "Invalid JSON: #{e.message}"
      end

      private

      def format_error(error)
        case error
        when Hash
          error
        when Exception
          {
            code: -32_603,
            message: error.message,
            data: {
              type: error.class.name,
              backtrace: error.backtrace&.first(5)
            }
          }
        else
          {
            code: -32_603,
            message: error.to_s
          }
        end
      end
    end
  end
end
