# frozen_string_literal: true

require 'json'

module ThebrainMcpServer
  # Main MCP server that handles incoming requests and routes them appropriately
  class Server
    attr_reader :client, :input, :output

    def initialize(input: $stdin, output: $stdout, client: nil)
      @input = input
      @output = output
      @client = client || ThebrainClient.new
      @running = false
    end

    # Start the server and listen for incoming messages
    def start
      ThebrainMcpServer.logger.info('Starting TheBrain MCP Server (Ruby)...')
      @running = true

      begin
        while @running && (line = @input.gets)
          handle_message(line.chomp)
        end
      rescue Interrupt
        ThebrainMcpServer.logger.info('Received interrupt signal, shutting down...')
      rescue StandardError => e
        ThebrainMcpServer.logger.error("Server error: #{e.message}")
        ThebrainMcpServer.logger.debug(e.backtrace.join("\n"))
      ensure
        stop
      end
    end

    # Stop the server
    def stop
      @running = false
      ThebrainMcpServer.logger.info('TheBrain MCP Server stopped')
    end

    # Handle a single request (for testing purposes)
    def handle_request(json_request)
      message = McpProtocol.parse_message(json_request)
      ThebrainMcpServer.logger.debug("Received message: #{message['method']}")

      response = case message['method']
                 when McpProtocol::INITIALIZE
                   handle_initialize(message)
                 when McpProtocol::LIST_TOOLS
                   handle_list_tools(message)
                 when McpProtocol::CALL_TOOL
                   handle_call_tool(message)
                 when McpProtocol::LIST_RESOURCES
                   handle_list_resources(message)
                 when McpProtocol::READ_RESOURCE
                   handle_read_resource(message)
                 else
                   McpProtocol.create_error_response(
                     id: message['id'],
                     code: -32_601,
                     message: "Method not found: #{message['method']}"
                   )
                 end

      response.to_json if response
    rescue McpProtocolError => e
      ThebrainMcpServer.logger.error("Protocol error: #{e.message}")
      response = McpProtocol.create_error_response(
        id: message&.dig('id'),
        code: -32_600,
        message: e.message
      )
      response.to_json
    rescue StandardError => e
      ThebrainMcpServer.logger.error("Unexpected error: #{e.message}")
      ThebrainMcpServer.logger.debug(e.backtrace.join("\n"))
      response = McpProtocol.create_error_response(
        id: message&.dig('id'),
        code: -32_603,
        message: 'Internal error'
      )
      response.to_json
    end

    private

    # Handle incoming MCP message
    def handle_message(json_line)
      return if json_line.strip.empty?

      message = McpProtocol.parse_message(json_line)
      ThebrainMcpServer.logger.debug("Received message: #{message['method']}")

      response = case message['method']
                 when McpProtocol::INITIALIZE
                   handle_initialize(message)
                 when McpProtocol::LIST_TOOLS
                   handle_list_tools(message)
                 when McpProtocol::CALL_TOOL
                   handle_call_tool(message)
                 when McpProtocol::LIST_RESOURCES
                   handle_list_resources(message)
                 when McpProtocol::READ_RESOURCE
                   handle_read_resource(message)
                 else
                   McpProtocol.create_error_response(
                     id: message['id'],
                     code: -32_601,
                     message: "Method not found: #{message['method']}"
                   )
                 end

      send_response(response) if response
    rescue McpProtocolError => e
      ThebrainMcpServer.logger.error("Protocol error: #{e.message}")
      response = McpProtocol.create_error_response(
        id: message&.dig('id'),
        code: -32_600,
        message: e.message
      )
      send_response(response)
    rescue StandardError => e
      ThebrainMcpServer.logger.error("Unexpected error: #{e.message}")
      ThebrainMcpServer.logger.debug(e.backtrace.join("\n"))
      response = McpProtocol.create_error_response(
        id: message&.dig('id'),
        code: -32_603,
        message: 'Internal error'
      )
      send_response(response)
    end

    # Handle initialization request
    def handle_initialize(message)
      ThebrainMcpServer.logger.info('Handling initialize request')
      McpProtocol.create_init_response(id: message['id'])
    end

    # Handle tools list request
    def handle_list_tools(message)
      ThebrainMcpServer.logger.info('Handling list tools request')
      McpProtocol.create_tools_list_response(id: message['id'])
    end

    # Handle tool call request
    def handle_call_tool(message)
      tool_name = message.dig('params', 'name')
      arguments = message.dig('params', 'arguments') || {}

      ThebrainMcpServer.logger.info("Handling tool call: #{tool_name}")

      result = case tool_name
               when 'search_thoughts'
                 handle_search_thoughts(arguments)
               when 'get_thought'
                 handle_get_thought(arguments)
               when 'create_thought'
                 handle_create_thought(arguments)
               when 'update_thought'
                 handle_update_thought(arguments)
               when 'delete_thought'
                 handle_delete_thought(arguments)
               else
                 raise McpProtocolError, "Unknown tool: #{tool_name}"
               end

      McpProtocol.create_response(id: message['id'], result: result)
    rescue ThebrainApiError => e
      McpProtocol.create_error_response(
        id: message['id'],
        code: -32_000,
        message: e.message,
        data: { status_code: e.status_code }
      )
    end

    # Handle resources list request
    def handle_list_resources(message)
      ThebrainMcpServer.logger.info('Handling list resources request')

      thoughts = @client.search_thoughts('', limit: 100)
      thoughts_list = thoughts.is_a?(Array) ? thoughts : (thoughts['thoughts'] || thoughts['data'] || [])

      McpProtocol.create_resources_list_response(
        id: message['id'],
        thoughts: thoughts_list
      )
    rescue StandardError => e
      McpProtocol.create_error_response(
        id: message['id'],
        code: -32_000,
        message: e.message
      )
    end

    # Handle resource read request
    def handle_read_resource(message)
      uri = message.dig('params', 'uri')
      ThebrainMcpServer.logger.info("Handling read resource: #{uri}")

      if uri&.start_with?('thebrain://thought/')
        thought_id = uri.split('/').last
        thought = @client.get_thought(thought_id)

        # Format thought as markdown
        content = format_thought_as_markdown(thought)

        result = {
          contents: [
            {
              uri: uri,
              mimeType: 'text/plain',
              text: content
            }
          ]
        }

        McpProtocol.create_response(id: message['id'], result: result)
      else
        McpProtocol.create_error_response(
          id: message['id'],
          code: -32_602,
          message: "Invalid resource URI: #{uri}"
        )
      end
    rescue StandardError => e
      McpProtocol.create_error_response(
        id: message['id'],
        code: -32_000,
        message: e.message
      )
    end

    # Tool implementations
    def handle_search_thoughts(arguments)
      query = arguments['query']
      limit = arguments['limit'] || 10

      raise McpProtocolError, 'Query is required' if query.nil? || query.empty?

      results = @client.search_thoughts(query, limit: limit)
      thoughts = results.is_a?(Array) ? results : (results['thoughts'] || results['data'] || [])

      {
        content: [
          {
            type: 'text',
            text: "Found #{thoughts.length} thoughts matching '#{query}'"
          },
          {
            type: 'text',
            text: JSON.pretty_generate(results)
          }
        ]
      }
    end

    def handle_get_thought(arguments)
      thought_id = arguments['thought_id']
      raise McpProtocolError, 'thought_id is required' if thought_id.nil? || thought_id.empty?

      thought = @client.get_thought(thought_id)
      {
        content: [
          {
            type: 'text',
            text: "Retrieved thought: #{thought['name']}"
          },
          {
            type: 'text',
            text: JSON.pretty_generate(thought)
          }
        ]
      }
    end

    def handle_create_thought(arguments)
      name = arguments['name']
      raise McpProtocolError, 'name is required' if name.nil? || name.empty?

      # Convert arguments to proper format
      create_args = {
        name: name,
        notes: arguments['notes'],
        parent_id: arguments['parent_id']
      }.compact

      thought = @client.create_thought(**create_args)
      {
        content: [
          {
            type: 'text',
            text: "Created thought: #{thought['name']} (ID: #{thought['id']})"
          },
          {
            type: 'text',
            text: JSON.pretty_generate(thought)
          }
        ]
      }
    end

    def handle_update_thought(arguments)
      thought_id = arguments['thought_id']
      raise McpProtocolError, 'thought_id is required' if thought_id.nil? || thought_id.empty?

      # Remove thought_id from arguments to avoid passing it to the API
      update_args = arguments.dup
      update_args.delete('thought_id')

      # Convert to symbols
      update_args = update_args.transform_keys(&:to_sym).compact

      thought = @client.update_thought(thought_id, **update_args)
      {
        content: [
          {
            type: 'text',
            text: "Updated thought: #{thought['name']}"
          },
          {
            type: 'text',
            text: JSON.pretty_generate(thought)
          }
        ]
      }
    end

    def handle_delete_thought(arguments)
      thought_id = arguments['thought_id']
      raise McpProtocolError, 'thought_id is required' if thought_id.nil? || thought_id.empty?

      success = @client.delete_thought(thought_id)
      {
        content: [
          {
            type: 'text',
            text: success ? "Successfully deleted thought: #{thought_id}" : "Failed to delete thought: #{thought_id}"
          }
        ]
      }
    end

    # Format thought as markdown for resource content
    def format_thought_as_markdown(thought)
      content = "# #{thought['name']}\n\n"

      content += "## Notes\n\n#{thought['notes']}\n\n" if thought['notes'] && !thought['notes'].empty?

      if thought['links'] && !thought['links'].empty?
        content += "## Links\n\n"
        thought['links'].each do |link|
          content += "- #{link['name']} (#{link['type']})\n"
        end
        content += "\n"
      end

      content += "**Created:** #{thought['created_at']}\n" if thought['created_at']

      content += "**Modified:** #{thought['modified_at']}\n" if thought['modified_at']

      content
    end

    # Send response to output
    def send_response(response)
      json_response = JSON.generate(response)
      @output.puts(json_response)
      @output.flush
      ThebrainMcpServer.logger.debug("Sent response: #{response[:result] ? 'success' : 'error'}")
    end
  end
end
