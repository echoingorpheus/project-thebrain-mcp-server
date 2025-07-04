# VS Code Development Guide - TheBrain MCP Server

This guide explains how to use VS Code effectively for developing and debugging the TheBrain MCP Server.

## Getting Started

### 1. Open the Project

You can open the project in two ways:

**Option A: Open Folder**
- Open VS Code
- File → Open Folder
- Select the `project-thebrain-mcp-server` folder

**Option B: Open Workspace (Recommended)**
- Open VS Code  
- File → Open Workspace from File
- Select `thebrain-mcp-server.code-workspace`

### 2. Install Recommended Extensions

When you first open the project, VS Code will suggest installing recommended extensions. Click "Install All" for the best development experience.

Key extensions include:
- **Ruby**: Language support and syntax highlighting
- **Solargraph**: Ruby language server for IntelliSense
- **RuboCop**: Code linting and formatting
- **Test Explorer**: Visual test runner interface

## Available Commands

### 🚀 Running the Server

**Command Palette (Cmd/Ctrl+Shift+P):**
- `Tasks: Run Task` → `Start MCP Server`
- `Tasks: Run Task` → `Start MCP Server (Debug)`

**Debug Panel (Cmd/Ctrl+Shift+D):**
- Select "Start TheBrain MCP Server" and press F5
- Select "Start MCP Server (Debug Mode)" for verbose logging

### 🧪 Running Tests

**Command Palette:**
- `Tasks: Run Task` → `Run Tests`
- `Tasks: Run Task` → `Run Tests with Coverage`

**Debug Panel:**
- Select "Run All Tests" and press F5

**Terminal Commands:**
```bash
# Run all tests
bundle exec rspec

# Run with coverage report
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/server_spec.rb
```

### 🔍 Code Quality

**Command Palette:**
- `Tasks: Run Task` → `Run Linting`
- `Tasks: Run Task` → `Fix Linting Issues`

**Debug Panel:**
- Select "Run Linting" and press F5

## Project-Specific Coding Guidelines

This project follows specific coding standards and architectural patterns. When contributing or developing, please adhere to these guidelines:

### Code Style Standards
- **String Literals**: Use `frozen_string_literal: true` in all Ruby files
- **Naming Conventions**: Follow Ruby standards (snake_case for methods/variables)
- **Return Statements**: Use explicit return statements where clarity is needed
- **Method Parameters**: Prefer keyword arguments for methods with multiple parameters

### Error Handling Best Practices
- Use custom error classes inherited from base `Error` class
- Always include context in error messages
- Log errors appropriately with structured logging
- Handle both API errors and protocol errors gracefully

### Testing Requirements
- Write comprehensive RSpec tests for all functionality
- Use `webmock` for HTTP request stubbing
- Include both positive and negative test cases
- Test error conditions and edge cases
- Maintain high test coverage (aim for >90%)

### API Integration Standards
- Use Faraday for HTTP requests with proper error handling
- Implement caching for frequently accessed data
- Include retry logic for transient failures
- Follow TheBrain API conventions and rate limits

### MCP Protocol Implementation
- Implement JSON-RPC 2.0 specification correctly
- Validate all incoming messages
- Provide proper error responses with appropriate codes
- Support all required MCP capabilities (tools and resources)

### Architecture Components

The project follows a modular design with clear separation of concerns:

1. **ThebrainMcpServer::ThebrainClient** - HTTP client for TheBrain API
2. **ThebrainMcpServer::McpProtocol** - JSON-RPC 2.0 protocol implementation  
3. **ThebrainMcpServer::Server** - Main MCP server handling requests
4. **Error Classes** - Comprehensive error handling hierarchy

### MCP Tools Available
- `search_thoughts` - Search for thoughts with query and optional limit
- `get_thought` - Retrieve specific thought by ID
- `create_thought` - Create new thought with name, notes, and optional parent
- `update_thought` - Update existing thought attributes
- `delete_thought` - Remove thought from TheBrain

### Resource Format
- **URI Pattern**: `thebrain://thought/{thought_id}`
- **Content**: Markdown-formatted thought data
- **MIME Type**: `text/plain`

### Development Priorities
When writing code for this project, prioritize:
1. **Reliability** - Robust error handling and validation
2. **Maintainability** - Clear, well-documented code
3. **Performance** - Efficient API usage with caching
4. **Compliance** - Strict adherence to MCP protocol
5. **Testability** - Comprehensive test coverage

### Common Code Patterns

**API Client Usage:**
```ruby
client = ThebrainMcpServer::ThebrainClient.new(
  base_url: url,
  api_key: key,
  brain_id: id
)
```

**Error Handling:**
```ruby
rescue ThebrainMcpServer::ThebrainApiError => e
  logger.error("API error: #{e.message}")
  # Handle specific error type
end
```

**MCP Response Format:**
```ruby
McpProtocol.create_response(
  id: message_id,
  result: response_data
)
```

## Key Features Configured

### ⚙️ Editor Settings
- **Tab Size**: 2 spaces (Ruby convention)
- **Rulers**: 120 character line limit
- **Auto-format**: Disabled (RuboCop handles this)
- **Code Actions**: RuboCop auto-fix on save

### 📁 File Management
- **Excluded Folders**: `coverage/`, `tmp/`, `log/`, `.bundle/`
- **File Associations**: Proper syntax highlighting for Ruby files
- **Search Exclusions**: Ignores generated/cache directories

### 🔧 Ruby Configuration
- **Linter**: RuboCop integration
- **Formatter**: RuboCop formatting
- **IntelliSense**: Solargraph language server
- **Test Command**: `bundle exec rspec`

### 🖥️ Terminal Setup
- **Environment**: Automatically sets `RUBY_ENV=development`
- **Working Directory**: Project root
- **Shell**: zsh with environment variables

## Debugging

### Setting Breakpoints
1. Open a Ruby file (e.g., `lib/thebrain_mcp_server/server.rb`)
2. Click in the gutter next to line numbers to set breakpoints
3. Use the Debug panel to start debugging sessions

### Debug Console
- Access via View → Debug Console
- Execute Ruby expressions in the current context
- Inspect variables and call stack

### Environment Variables
Debug sessions automatically include:
- `RUBY_ENV=development`
- `LOG_LEVEL=debug` (in debug mode)

## Testing Workflow

### Running Individual Tests
1. Open a test file in `spec/`
2. Click the "Run Test" code lens above test methods
3. Or use Command Palette: `Ruby: Run Test at Cursor`

### Test Coverage
- Coverage reports are generated in `coverage/`
- Open `coverage/index.html` in browser for detailed report
- Coverage summary appears in terminal after test runs

## Useful Shortcuts

| Action | Shortcut |
|--------|----------|
| Open Command Palette | `Cmd/Ctrl+Shift+P` |
| Run Task | `Cmd/Ctrl+Shift+P` → "Tasks: Run Task" |
| Open Debug Panel | `Cmd/Ctrl+Shift+D` |
| Start Debugging | `F5` |
| Open Terminal | `Cmd/Ctrl+`` |
| Go to Definition | `F12` |
| Find References | `Shift+F12` |
| Format Document | `Shift+Alt+F` |

## Project Structure

```
.vscode/
├── extensions.json     # Recommended extensions
├── launch.json        # Debug configurations  
├── settings.json      # Workspace settings
└── tasks.json         # Build/run tasks

lib/thebrain_mcp_server/
├── server.rb          # Main MCP server
├── thebrain_client.rb # TheBrain API client
├── mcp_protocol.rb    # MCP protocol handler
└── errors.rb          # Error classes

spec/                  # Test files
bin/                   # Executables
```

## Troubleshooting

### Ruby Language Server Issues
1. Open Command Palette
2. Run "Ruby: Restart Language Server"
3. If issues persist, check Ruby installation: `ruby --version`

### Test Runner Problems
1. Ensure `bundle install` has been run
2. Check Ruby environment: `bundle exec ruby --version`
3. Verify test files are in `spec/` directory

### Extension Issues
1. Check Extensions view (Cmd/Ctrl+Shift+X)
2. Ensure recommended extensions are installed and enabled
3. Reload window: Command Palette → "Developer: Reload Window"

## Tips for Effective Development

### 🔄 Development Workflow

1. **Start with Tests**: Always run tests before making changes
   ```bash
   bundle exec rspec
   ```

2. **Use the Integrated Terminal**: Configured with proper environment variables

3. **Test MCP Protocol**: Use our custom test scripts for quick verification
   ```bash
   ruby test_mcp_protocol.rb    # Test protocol communication
   ruby test_end_to_end.rb      # Test full workflow
   ```

4. **Leverage Code Actions**: Right-click → "Refactor" for RuboCop fixes

5. **Utilize IntelliSense**: Hover over methods for documentation

6. **Run Tests Frequently**: Use keyboard shortcuts for quick testing

7. **Monitor Coverage**: Keep an eye on test coverage percentages

8. **Test with Real Clients**: Configure Claude Desktop or other MCP clients to test real-world usage

### 🚀 From Development to Production

1. **Develop**: Use VS Code with our configured environment
2. **Test**: Run comprehensive test suite
3. **Validate**: Test MCP protocol communication
4. **Configure**: Set up your preferred MCP client
5. **Deploy**: Use the server with AI assistants

### 🎯 Quick Commands Reference

```bash
# Development
bundle exec rspec                    # Run tests
bundle exec rubocop                  # Check code style
ruby bin/thebrain-mcp-server        # Start server
ruby test_mcp_protocol.rb           # Test protocol

# Client Testing  
echo '...' | ruby bin/thebrain-mcp-server  # Manual protocol test
LOG_LEVEL=debug ruby bin/thebrain-mcp-server  # Debug mode
```

## MCP Client Configuration

Once your TheBrain MCP Server is working in VS Code, you'll want to connect it to MCP clients like Claude Desktop or other AI assistants.

### 🤖 Claude Desktop Configuration

Add this to your Claude Desktop configuration file (`claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "thebrain": {
      "command": "ruby",
      "args": ["/Users/enogrob/Projects/project-thebrain-mcp-server/bin/thebrain-mcp-server"],
      "env": {
        "THEBRAIN_API_URL": "https://api.thebrain.com",
        "THEBRAIN_API_KEY": "your_api_key_here",
        "THEBRAIN_BRAIN_ID": "your_brain_id_here",
        "LOG_LEVEL": "info"
      }
    }
  }
}
```

**Claude Desktop Config File Locations:**
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

### 🔌 VS Code MCP Extension

If you're using VS Code with an MCP extension, add to your VS Code settings:

```json
{
  "mcp.servers": [
    {
      "name": "thebrain",
      "command": "ruby",
      "args": ["/Users/enogrob/Projects/project-thebrain-mcp-server/bin/thebrain-mcp-server"],
      "env": {
        "THEBRAIN_API_URL": "https://api.thebrain.com",
        "THEBRAIN_API_KEY": "your_api_key_here",
        "THEBRAIN_BRAIN_ID": "your_brain_id_here"
      }
    }
  ]
}
```

### 🛠️ Generic MCP Client

For any MCP-compatible client:

- **Command**: `ruby`
- **Arguments**: `["/Users/enogrob/Projects/project-thebrain-mcp-server/bin/thebrain-mcp-server"]`
- **Protocol**: stdio
- **Environment Variables**:
  - `THEBRAIN_API_KEY`: Your TheBrain API key (required)
  - `THEBRAIN_BRAIN_ID`: Your TheBrain Brain ID (required)
  - `THEBRAIN_API_URL`: https://api.thebrain.com (optional)
  - `LOG_LEVEL`: info (optional)

### 🔑 Getting TheBrain API Credentials

1. **Visit TheBrain API Documentation**: [https://help.thebrain.com/tutorials/thebrain-api/](https://help.thebrain.com/tutorials/thebrain-api/)
2. **Generate API Key**: 
   - Log into your TheBrain account
   - Go to Account Settings
   - Navigate to API section
   - Generate a new API key
3. **Find Brain ID**: 
   - Open TheBrain application
   - Look in the URL bar or application settings
   - Brain ID is usually a UUID format

### 🎯 Available Tools

Once connected, AI assistants will have access to these tools:

| Tool | Description | Example Usage |
|------|-------------|---------------|
| `search_thoughts` | Search for thoughts by query | "Search for thoughts about 'machine learning'" |
| `get_thought` | Retrieve specific thought by ID | "Get the content of thought ID 'abc123'" |
| `create_thought` | Create new thoughts | "Create a thought called 'Project Ideas'" |
| `update_thought` | Modify existing thoughts | "Update the notes for thought 'xyz789'" |
| `delete_thought` | Remove thoughts | "Delete the thought with ID 'def456'" |

### 💬 Example AI Interactions

After configuration, you can ask AI assistants:

- *"Search my TheBrain for thoughts about artificial intelligence"*
- *"Create a new thought called 'Meeting Notes' with today's discussion points"*
- *"Show me the content of my 'Project Planning' thought"*
- *"Update my 'ToDo List' thought with new tasks"*
- *"Find all thoughts related to 'customer feedback'"*

### 🧪 Testing MCP Connection

You can test your MCP server connection directly from VS Code:

**Quick Protocol Test:**
1. Open Command Palette (`Cmd/Ctrl+Shift+P`)
2. Run task: "Tasks: Run Task" → "Start MCP Server"
3. In another terminal, run our test scripts:
   ```bash
   # Test MCP protocol communication
   ruby test_mcp_protocol.rb
   
   # Run end-to-end tests
   ruby test_end_to_end.rb
   ```

**Manual Testing with curl:**
```bash
# Test if server responds (while server is running)
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | ruby bin/thebrain-mcp-server
```

**Debug Logging:**
- Use "Start MCP Server (Debug)" task for verbose output
- Check logs for connection and API call details
- Monitor environment variable loading

### 🐛 Client Configuration Troubleshooting

**Connection Issues:**
- Verify Ruby is in your system PATH: `ruby --version`
- Check that the server path is correct in configuration
- Ensure environment variables are properly set

**Authentication Errors:**
- Double-check your API key is valid and active
- Verify the Brain ID matches your TheBrain account
- Test API access: `curl -H "Authorization: Bearer YOUR_API_KEY" https://api.thebrain.com/brains/YOUR_BRAIN_ID/thoughts`

**Permission Issues:**
- Ensure your TheBrain account has API access enabled
- Check that the API key has sufficient permissions
- Verify your TheBrain subscription includes API access

Happy coding! 🎉
