# Using TheBrain MCP Server in VS Code

This guide explains how to set up and use the TheBrain MCP server within Visual Studio Code to interact with your TheBrain knowledge base directly from the editor.

## 📋 Prerequisites

Before you begin, ensure you have:

- ✅ **VS Code** version 1.85 or later
- ✅ **TheBrain MCP Server** installed and working (Ruby or TypeScript version)
- ✅ **TheBrain API credentials** (API key and Brain ID)
- ✅ **MCP support enabled** in VS Code

## 🚀 Quick Setup

### Step 1: Enable MCP in VS Code

Add the following to your VS Code settings (`settings.json`):

```json
{
  "chat.mcp.enabled": true,
  "chat.agent.enabled": true
}
```

### Step 2: Configure Your Server

Choose one of the configuration methods below:

#### Method A: Interactive Setup (Recommended)

1. Open the Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`)
2. Run **MCP: Add Server...**
3. Follow the prompts to configure your TheBrain server

#### Method B: Manual Configuration

Create a `.vscode/mcp.json` file in your workspace:

```json
{
  "mcpServers": {
    "thebrain-ruby": {
      "command": "ruby",
      "args": ["bin/thebrain-mcp-server"],
      "cwd": "/path/to/your/thebrain-mcp-server-ruby",
      "env": {
        "THEBRAIN_API_URL": "${input:thebrain_api_url}",
        "THEBRAIN_API_KEY": "${input:thebrain_api_key}",
        "THEBRAIN_BRAIN_ID": "${input:thebrain_brain_id}",
        "LOG_LEVEL": "info"
      }
    }
  },
  "inputs": [
    {
      "id": "thebrain_api_url",
      "description": "TheBrain API URL",
      "default": "https://api.thebrain.com",
      "type": "promptString"
    },
    {
      "id": "thebrain_api_key",
      "description": "Your TheBrain API Key",
      "type": "promptString",
      "password": true
    },
    {
      "id": "thebrain_brain_id",
      "description": "Your TheBrain Brain ID",
      "type": "promptString"
    }
  ]
}
```

## 🔧 Configuration Options

### Ruby Server Configuration

```json
{
  "mcpServers": {
    "thebrain-ruby": {
      "command": "ruby",
      "args": ["bin/thebrain-mcp-server"],
      "cwd": "/path/to/thebrain-mcp-server-ruby",
      "env": {
        "THEBRAIN_API_URL": "https://api.thebrain.com",
        "THEBRAIN_API_KEY": "${input:api_key}",
        "THEBRAIN_BRAIN_ID": "${input:brain_id}",
        "LOG_LEVEL": "info",
        "TIMEOUT": "30",
        "RETRY_ATTEMPTS": "3"
      }
    }
  }
}
```

### TypeScript Server Configuration

```json
{
  "mcpServers": {
    "thebrain-ts": {
      "command": "node",
      "args": ["dist/index.js"],
      "cwd": "/path/to/thebrain-mcp-server",
      "env": {
        "THEBRAIN_API_URL": "https://api.thebrain.com",
        "THEBRAIN_API_KEY": "${input:api_key}",
        "THEBRAIN_BRAIN_ID": "${input:brain_id}",
        "LOG_LEVEL": "info"
      }
    }
  }
}
```

### Development Configuration

For development with hot reload:

```json
{
  "mcpServers": {
    "thebrain-dev": {
      "command": "npm",
      "args": ["run", "dev"],
      "cwd": "/path/to/thebrain-mcp-server",
      "env": {
        "NODE_ENV": "development",
        "THEBRAIN_API_KEY": "${input:api_key}",
        "THEBRAIN_BRAIN_ID": "${input:brain_id}",
        "LOG_LEVEL": "debug"
      }
    }
  }
}
```

## 🎯 Using the MCP Server

### Starting the Server

1. **Automatic Start**: The server starts automatically when you first use MCP tools in chat
2. **Manual Start**: Use **MCP: Restart Server** command to restart if needed
3. **Check Status**: Use **MCP: Show Server Status** to verify connection

### Browsing Your TheBrain

1. **Open Command Palette** (`Cmd+Shift+P` / `Ctrl+Shift+P`)
2. **Run MCP: Browse Resources...**
3. **Select your TheBrain server**
4. **Browse your thoughts** as resources

### Using Tools in Chat

1. **Open VS Code Chat** (`Cmd+I` / `Ctrl+I`)
2. **Enable Agent Mode** by clicking the tools button
3. **Select TheBrain tools** from the tools picker
4. **Start chatting** with natural language commands

## 💬 Example Conversations

### Searching for Thoughts

**You:** "Search my thoughts about machine learning"

**Assistant will use:** `search_thoughts` tool with query "machine learning"

**Result:** List of matching thoughts with summaries

### Creating New Thoughts

**You:** "Create a new thought called 'VS Code MCP Integration' with notes about setting up MCP servers"

**Assistant will use:** `create_thought` tool with appropriate parameters

**Result:** New thought created in your TheBrain

### Getting Specific Thoughts

**You:** "Show me the details of thought ID abc123"

**Assistant will use:** `get_thought` tool with the specified ID

**Result:** Complete thought details including notes and links

### Updating Thoughts

**You:** "Update my project planning thought to include new milestones"

**Assistant will:** 
1. Search for "project planning" thoughts
2. Use `update_thought` tool to add your milestones

### Working with Resources

**You:** "What's in my thebrain://thought/xyz789 resource?"

**Assistant will:** Access the resource directly and show formatted content

## 🛠️ Available Tools

| Tool Name | Description | Usage Example |
|-----------|-------------|---------------|
| `search_thoughts` | Find thoughts by query | "Find thoughts about AI ethics" |
| `get_thought` | Retrieve specific thought | "Get thought abc123" |
| `create_thought` | Create new thought | "Create a thought about VS Code tips" |
| `update_thought` | Modify existing thought | "Update my research notes" |
| `delete_thought` | Remove thought | "Delete the outdated meeting notes" |

## 📚 Resource Access

All your thoughts are available as MCP resources with URIs like:

- `thebrain://thought/thought-id-1`
- `thebrain://thought/thought-id-2`

Resources provide:
- ✅ **Markdown-formatted content**
- ✅ **Thought metadata** (creation date, modification date)
- ✅ **Link information** (connected thoughts)
- ✅ **Rich text formatting**

## 🔍 Troubleshooting

### Common Issues

#### Server Won't Start
```bash
# Check server configuration
MCP: Show Server Status

# Verify credentials
MCP: Test Server Connection

# Restart server
MCP: Restart Server
```

#### Authentication Errors
```json
{
  "error": "Authentication failed - check your API key"
}
```

**Solution:** Verify your `THEBRAIN_API_KEY` in the configuration

#### Connection Timeouts
```json
{
  "error": "Request timeout - server unreachable"
}
```

**Solution:** Check your `THEBRAIN_API_URL` and network connection

#### Tool Not Available
**Problem:** TheBrain tools don't appear in the tools picker

**Solution:** 
1. Ensure MCP is enabled: `"chat.mcp.enabled": true`
2. Restart the server: **MCP: Restart Server**
3. Check server logs: **MCP: Show Server Logs**

### Debug Mode

Enable debug logging by setting `LOG_LEVEL=debug` in your configuration:

```json
{
  "env": {
    "LOG_LEVEL": "debug"
  }
}
```

Then check logs with **MCP: Show Server Logs**

### Server Health Check

Test your server connection:

1. **MCP: Test Server Connection**
2. **MCP: Browse Resources** (should show your thoughts)
3. **MCP: Show Server Status** (should show "Connected")

## 🎨 VS Code Integration Features

### Command Palette Commands

- **MCP: Add Server...** - Interactive server setup
- **MCP: Browse Resources...** - Explore your thoughts
- **MCP: Show Server Status** - Check connection status
- **MCP: Restart Server** - Restart MCP server
- **MCP: Show Server Logs** - View debug information
- **MCP: Test Server Connection** - Verify connectivity

### Chat Integration

- **Agent Mode** - Enable tools in chat conversations
- **Resource References** - Direct access to thought URIs
- **Natural Language** - Intuitive interaction with your knowledge base
- **Context Awareness** - AI understands your TheBrain structure

### Workspace Integration

- **Project-Specific Config** - Different servers per workspace
- **Environment Variables** - Secure credential management
- **Hot Reload** - Development mode with automatic restarts
- **Status Bar** - Connection status indicator

## 🔐 Security Best Practices

### Credential Management

1. **Use Input Variables** for sensitive data:
   ```json
   "THEBRAIN_API_KEY": "${input:api_key}"
   ```

2. **Never commit** API keys to version control

3. **Use environment files** for local development:
   ```bash
   # .env (gitignored)
   THEBRAIN_API_KEY=your_secret_key
   ```

4. **Rotate keys regularly** and update configurations

### Network Security

- ✅ **HTTPS only** for API communications
- ✅ **Timeout limits** to prevent hanging connections
- ✅ **Rate limiting** to respect API quotas
- ✅ **Error sanitization** to avoid exposing sensitive data

## 📈 Performance Optimization

### Caching Strategy

The server implements intelligent caching:

- **Thought metadata**: Cached for 5 minutes
- **Search results**: Cached for 2 minutes
- **Full thought content**: Cached for 10 minutes

### Rate Limiting

Configure rate limiting to optimize performance:

```json
{
  "env": {
    "RETRY_ATTEMPTS": "3",
    "TIMEOUT": "30",
    "CACHE_TTL": "300"
  }
}
```

### Resource Management

- **Connection pooling** for HTTP requests
- **Memory management** for large brains
- **Lazy loading** for resource browsing
- **Background refresh** for cache updates

## 🚀 Advanced Usage

### Multi-Brain Setup

Configure multiple TheBrain instances:

```json
{
  "mcpServers": {
    "thebrain-personal": {
      "command": "ruby",
      "args": ["bin/thebrain-mcp-server"],
      "env": {
        "THEBRAIN_BRAIN_ID": "${input:personal_brain_id}"
      }
    },
    "thebrain-work": {
      "command": "ruby",
      "args": ["bin/thebrain-mcp-server"],
      "env": {
        "THEBRAIN_BRAIN_ID": "${input:work_brain_id}"
      }
    }
  }
}
```

### Custom Workflows

Create custom chat workflows:

```json
{
  "chat.workflows": {
    "research": {
      "name": "Research Assistant",
      "tools": ["thebrain-ruby"],
      "prompt": "Help me research and organize information using my TheBrain knowledge base."
    }
  }
}
```

### Integration with Extensions

Combine with other VS Code extensions:

- **GitHub Copilot** - AI coding with TheBrain context
- **Markdown Preview** - Rich preview of thought content
- **Todo Tree** - Track tasks across thoughts
- **Bookmarks** - Quick access to important thoughts

## 📚 Additional Resources

- [VS Code MCP Documentation](https://code.visualstudio.com/docs/copilot/mcp)
- [Model Context Protocol Specification](https://modelcontextprotocol.io)
- [TheBrain API Documentation](https://help.thebrain.com/tutorials/thebrain-api/)
- [Ruby MCP Server Examples](https://github.com/modelcontextprotocol/servers)

## 🆘 Support

If you encounter issues:

1. **Check the troubleshooting section** above
2. **Review server logs** with **MCP: Show Server Logs**
3. **Test connection** with **MCP: Test Server Connection**
4. **Restart server** with **MCP: Restart Server**
5. **Submit issues** to the project repository

---

**Happy knowledge management with TheBrain and VS Code! 🧠✨**
