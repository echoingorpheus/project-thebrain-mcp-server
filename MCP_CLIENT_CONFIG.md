# TheBrain MCP Server - Client Configuration Examples

This file shows how to configure various MCP clients to use the TheBrain MCP Server.

## Claude Desktop Configuration

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

## VS Code Configuration

For VS Code with MCP extension, add to your settings:

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

## Generic MCP Client Configuration

For any MCP-compatible client:

- **Server Command**: `ruby /path/to/thebrain-mcp-server/bin/thebrain-mcp-server`
- **Protocol**: stdio
- **Environment Variables**:
  - `THEBRAIN_API_KEY`: Your TheBrain API key
  - `THEBRAIN_BRAIN_ID`: Your TheBrain Brain ID
  - `THEBRAIN_API_URL`: https://api.thebrain.com (optional)
  - `LOG_LEVEL`: info (optional)

## Available Tools

Once connected, you'll have access to these tools:

1. **search_thoughts**: Search for thoughts by query
2. **get_thought**: Retrieve specific thought by ID
3. **create_thought**: Create new thoughts
4. **update_thought**: Modify existing thoughts
5. **delete_thought**: Remove thoughts

## Example Usage

After configuration, you can interact with your TheBrain knowledge base:

- "Search for thoughts about 'artificial intelligence'"
- "Get the content of thought ID '12345'"
- "Create a new thought called 'Meeting Notes' with content about today's meeting"
- "Update the notes for thought '67890'"

## Getting Your API Credentials

1. Visit [TheBrain API Documentation](https://help.thebrain.com/tutorials/thebrain-api/)
2. Generate an API key from your TheBrain account settings
3. Find your Brain ID in the TheBrain application URL or settings

## Troubleshooting

- Ensure Ruby 3.1+ is installed and in your PATH
- Verify your API credentials are correct
- Check that TheBrain API is accessible from your network
- Review logs for detailed error information
