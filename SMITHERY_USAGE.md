# Using DynamoDB MCP Server with Smithery

This guide explains how to use the DynamoDB MCP Server with Smithery.

## Quick Start

### 1. Install Smithery CLI (if not already installed)

```bash
npm install -g @smithery/cli
```

### 2. Configure AWS Credentials

Make sure your `.env` file has the correct credentials:

```bash
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1
```

**Important**: Use `AWS_ACCESS_KEY_ID`, not `AWS_ACCESS_ID`!

### 3. Run in Development Mode

Use the helper script that loads credentials from `.env`:

```bash
npm run smithery
```

Or manually set environment variables and run Smithery:

```bash
# Windows PowerShell
$env:AWS_ACCESS_KEY_ID="your_key"
$env:AWS_SECRET_ACCESS_KEY="your_secret"
$env:AWS_REGION="us-east-1"
npx smithery dev

# Linux/Mac
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_REGION="us-east-1"
npx smithery dev
```

📖 **For detailed credential configuration, see [SMITHERY_CREDENTIALS.md](SMITHERY_CREDENTIALS.md)**

## How It Works

### Smithery Export Format

The server exports a default function that Smithery expects:

```typescript
export default function({ config }: { config?: Record<string, any> }) {
  // Server initialization
  return server;
}
```

This allows Smithery to:
1. Import your server as a module
2. Pass configuration (AWS credentials) at runtime
3. Handle the HTTP transport automatically
4. Provide a web interface for testing

### Dual Mode Support

The server supports both:

1. **Smithery Mode**: When imported by Smithery, it returns a server instance
2. **Standalone Mode**: When run directly (`npm start`), it starts its own HTTP server

## Available Tools

Once running in Smithery, you'll have access to these DynamoDB tools:

### Table Management
- `create_table` - Create a new DynamoDB table
- `list_tables` - List all tables
- `describe_table` - Get table details
- `update_capacity` - Update table capacity

### Index Management
- `create_gsi` - Create Global Secondary Index
- `update_gsi` - Update GSI capacity
- `create_lsi` - Create Local Secondary Index

### Data Operations
- `put_item` - Insert or replace an item
- `get_item` - Retrieve an item by key
- `update_item` - Update specific attributes
- `query_table` - Query with conditions
- `scan_table` - Scan with filters

## Testing in Smithery

### Example: List Tables

1. Start Smithery dev server: `npx smithery dev`
2. Open the Smithery web interface
3. Select the `list_tables` tool
4. Click "Execute"
5. View the results

### Example: Create a Table

1. Select the `create_table` tool
2. Fill in parameters:
   ```json
   {
     "tableName": "Users",
     "partitionKey": "userId",
     "partitionKeyType": "S",
     "readCapacity": 5,
     "writeCapacity": 5
   }
   ```
3. Click "Execute"
4. Verify the table was created

### Example: Put an Item

1. Select the `put_item` tool
2. Fill in parameters:
   ```json
   {
     "tableName": "Users",
     "item": {
       "userId": "123",
       "name": "John Doe",
       "email": "john@example.com"
     }
   }
   ```
3. Click "Execute"
4. Verify the item was added

## Deployment with Smithery

### Option 1: Smithery Cloud (Recommended)

```bash
# Login to Smithery
smithery login

# Deploy your server
smithery deploy

# Get your deployment URL
smithery status
```

Your server will be available at: `https://your-app.smithery.ai`

### Option 2: Self-Hosted

Deploy to your own infrastructure and configure Smithery to use your endpoint:

```bash
# Deploy to Railway, Render, etc.
# See SMITHERY_DEPLOYMENT.md for details

# Configure Smithery to use your endpoint
smithery config set endpoint https://your-server.com
```

## Configuration File

The `smithery.json` file defines the configuration schema:

```json
{
  "name": "dynamodb-mcp-server",
  "version": "0.2.0",
  "config": {
    "AWS_ACCESS_KEY_ID": {
      "type": "string",
      "description": "AWS Access Key ID",
      "required": true
    },
    "AWS_SECRET_ACCESS_KEY": {
      "type": "string",
      "description": "AWS Secret Access Key",
      "required": true,
      "secret": true
    },
    "AWS_REGION": {
      "type": "string",
      "description": "AWS Region",
      "required": true,
      "default": "us-east-1"
    }
  }
}
```

This tells Smithery:
- What configuration values are needed
- Which values are secrets (hidden in UI)
- Default values
- Required vs optional fields

## Troubleshooting

### Issue: "No valid server export found"

**Solution**: Make sure you've built the project:
```bash
npm run build
```

### Issue: AWS credentials not working

**Solution**: 
1. Check that credentials are set in Smithery config
2. Verify IAM permissions for DynamoDB
3. Test credentials with AWS CLI:
   ```bash
   aws dynamodb list-tables --region us-east-1
   ```

### Issue: Build warnings about import.meta

**Solution**: This is expected when Smithery bundles your code. The warning is harmless as we handle both ESM and CJS formats.

### Issue: Port already in use

**Solution**: 
1. Stop any other Smithery dev servers
2. Or specify a different port:
   ```bash
   smithery dev --port 8082
   ```

## Development Workflow

### 1. Make Changes
Edit `src/index.ts` with your changes

### 2. Build
```bash
npm run build
```

### 3. Test Locally
```bash
npx smithery dev
```

### 4. Test in Browser
Open the Smithery web interface and test your tools

### 5. Deploy
```bash
smithery deploy
```

## Comparison: Smithery vs Standalone

| Feature | Smithery Mode | Standalone Mode |
|---------|---------------|-----------------|
| Transport | HTTP (managed by Smithery) | stdio or SSE |
| Configuration | Via Smithery UI | Environment variables |
| Testing | Web interface | CLI/curl |
| Deployment | Smithery Cloud | Self-hosted |
| Best For | Development & Testing | Production |

## Next Steps

1. **Test locally**: Run `npx smithery dev` and test all tools
2. **Deploy**: Use `smithery deploy` to make it available remotely
3. **Share**: Share your Smithery URL with team members
4. **Monitor**: Use Smithery dashboard to monitor usage

## Resources

- [Smithery Documentation](https://smithery.ai/docs)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [AWS DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)

## Support

For issues specific to:
- **Smithery integration**: Check Smithery documentation or support
- **DynamoDB operations**: See AWS DynamoDB documentation
- **This server**: Check the main README.md and other documentation files
