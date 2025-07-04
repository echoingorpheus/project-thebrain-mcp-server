<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# TheBrain MCP Server Ruby - Copilot Instructions

This is a Ruby implementation of a Model Context Protocol (MCP) server for TheBrain integration.

## Project Context

- **Language**: Ruby 3.1+
- **Purpose**: MCP server for connecting AI assistants to TheBrain knowledge management
- **Architecture**: Modular design with clear separation of concerns
- **Testing**: RSpec with comprehensive test coverage
- **Code Style**: RuboCop with Ruby community standards

## Key Components

1. **ThebrainMcpServer::ThebrainClient** - HTTP client for TheBrain API
2. **ThebrainMcpServer::McpProtocol** - JSON-RPC 2.0 protocol implementation
3. **ThebrainMcpServer::Server** - Main MCP server handling requests
4. **Error Classes** - Comprehensive error handling hierarchy

## Development Guidelines

### Code Style
- Use `frozen_string_literal: true` in all Ruby files
- Follow Ruby naming conventions (snake_case for methods/variables)
- Use explicit return statements where clarity is needed
- Prefer keyword arguments for methods with multiple parameters

### Error Handling
- Use custom error classes inherited from base `Error` class
- Always include context in error messages
- Log errors appropriately with structured logging

### Testing
- Write comprehensive RSpec tests for all functionality
- Use `webmock` for HTTP request stubbing
- Include both positive and negative test cases
- Test error conditions and edge cases

### API Integration
- Use Faraday for HTTP requests with proper error handling
- Implement caching for frequently accessed data
- Include retry logic for transient failures
- Follow TheBrain API conventions and rate limits

### MCP Protocol
- Implement JSON-RPC 2.0 specification correctly
- Validate all incoming messages
- Provide proper error responses with appropriate codes
- Support all required MCP capabilities (tools and resources)

## Reference Information

You can find more info and examples at https://modelcontextprotocol.io/llms-full.txt

### MCP Tools Implemented
- `search_thoughts` - Search for thoughts with query and optional limit
- `get_thought` - Retrieve specific thought by ID
- `create_thought` - Create new thought with name, notes, and optional parent
- `update_thought` - Update existing thought attributes
- `delete_thought` - Remove thought from TheBrain

### Resource Format
- URI pattern: `thebrain://thought/{thought_id}`
- Content: Markdown-formatted thought data
- MIME type: `text/plain`

## Common Patterns

### API Client Usage
```ruby
client = ThebrainMcpServer::ThebrainClient.new(
  base_url: url,
  api_key: key,
  brain_id: id
)
```

### Error Handling
```ruby
rescue ThebrainMcpServer::ThebrainApiError => e
  logger.error("API error: #{e.message}")
  # Handle specific error type
end
```

### MCP Response Format
```ruby
McpProtocol.create_response(
  id: message_id,
  result: response_data
)
```

When writing code for this project, prioritize:
1. **Reliability** - Robust error handling and validation
2. **Maintainability** - Clear, well-documented code
3. **Performance** - Efficient API usage with caching
4. **Compliance** - Strict adherence to MCP protocol
5. **Testability** - Comprehensive test coverage
