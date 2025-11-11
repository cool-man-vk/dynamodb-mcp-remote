# Remote Mode Configuration Guide

This guide explains how to configure and use the DynamoDB MCP Server in remote mode using Server-Sent Events (SSE) transport.

## Overview

The DynamoDB MCP Server now supports two transport modes:

1. **Local Mode (stdio)**: Default mode for local development, uses standard input/output
2. **Remote Mode (SSE)**: HTTP-based transport for remote connections, allows multiple clients

## Architecture

### Local Mode (stdio)
```
Claude Desktop <--stdin/stdout--> MCP Server <--AWS SDK--> DynamoDB
```

### Remote Mode (SSE)
```
Claude Desktop <--HTTP/SSE--> MCP Server <--AWS SDK--> DynamoDB
                                   ^
                                   |
                          Other Clients (HTTP/SSE)
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MCP_TRANSPORT_MODE` | `stdio` | Transport mode: `stdio` or `sse` |
| `MCP_HOST` | `localhost` | Host to bind to (SSE mode only) |
| `MCP_PORT` | `3000` | Port to listen on (SSE mode only) |
| `AWS_ACCESS_KEY_ID` | - | AWS access key (required) |
| `AWS_SECRET_ACCESS_KEY` | - | AWS secret key (required) |
| `AWS_REGION` | - | AWS region (required) |
| `AWS_SESSION_TOKEN` | - | AWS session token (optional) |

### Starting the Server

#### Local Mode
```bash
npm start
```

#### Remote Mode
```bash
npm run start:remote
```

Or with custom configuration:
```bash
MCP_TRANSPORT_MODE=sse MCP_HOST=0.0.0.0 MCP_PORT=8080 npm start
```

### Docker Deployment

#### Local Mode
```bash
docker run -i --rm \
  -e AWS_ACCESS_KEY_ID="your_key" \
  -e AWS_SECRET_ACCESS_KEY="your_secret" \
  -e AWS_REGION="us-east-1" \
  mcp/dynamodb-mcp-server
```

#### Remote Mode
```bash
docker run -d --rm \
  -e MCP_TRANSPORT_MODE=sse \
  -e MCP_HOST=0.0.0.0 \
  -e MCP_PORT=3000 \
  -e AWS_ACCESS_KEY_ID="your_key" \
  -e AWS_SECRET_ACCESS_KEY="your_secret" \
  -e AWS_REGION="us-east-1" \
  -p 3000:3000 \
  --name dynamodb-mcp \
  mcp/dynamodb-mcp-server
```

## API Endpoints (Remote Mode)

### Health Check
```bash
GET /health
```

Response:
```json
{
  "status": "healthy",
  "server": "dynamodb-mcp-server"
}
```

### SSE Connection
```bash
GET /sse
```

Establishes a Server-Sent Events connection for receiving messages from the server.

### Message Endpoint
```bash
POST /message
Content-Type: application/json
```

Sends messages to the MCP server.

## Client Configuration

### Claude Desktop

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "dynamodb-remote": {
      "url": "http://your-server-host:3000/sse"
    }
  }
}
```

### Custom MCP Client

```javascript
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { SSEClientTransport } from "@modelcontextprotocol/sdk/client/sse.js";

const transport = new SSEClientTransport(
  new URL("http://localhost:3000/sse")
);

const client = new Client({
  name: "my-client",
  version: "1.0.0"
}, {
  capabilities: {}
});

await client.connect(transport);
```

## Security Considerations

### Production Deployment

When deploying in production, implement these security measures:

1. **Use HTTPS/TLS**
   - Deploy behind a reverse proxy (nginx, Apache, Traefik)
   - Configure SSL/TLS certificates
   - Redirect HTTP to HTTPS

2. **Authentication & Authorization**
   - Implement API key authentication
   - Use OAuth 2.0 or JWT tokens
   - Validate client credentials

3. **Network Security**
   - Use firewall rules to restrict access
   - Deploy in a private network/VPC
   - Use VPN for remote access

4. **AWS Credentials**
   - Use IAM roles instead of access keys when possible
   - Implement least privilege principle
   - Rotate credentials regularly
   - Use AWS Secrets Manager or Parameter Store

### Example: Nginx Reverse Proxy with SSL

```nginx
server {
    listen 443 ssl http2;
    server_name mcp.example.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # SSE specific settings
        proxy_buffering off;
        proxy_cache off;
        proxy_read_timeout 86400s;
    }
}
```

## Monitoring

### Health Checks

Use the `/health` endpoint for monitoring:

```bash
# Simple check
curl http://localhost:3000/health

# With monitoring tools
watch -n 5 'curl -s http://localhost:3000/health | jq .'
```

### Logging

The server logs to stderr. In remote mode, you'll see:
- Connection establishment messages
- Client connection/disconnection events
- Error messages

Example:
```
DynamoDB MCP Server running on http://0.0.0.0:3000
SSE endpoint: http://0.0.0.0:3000/sse
Message endpoint: http://0.0.0.0:3000/message
Health check: http://0.0.0.0:3000/health
SSE connection established from ::ffff:192.168.1.100
```

## Troubleshooting

### Connection Issues

**Problem**: Cannot connect to remote server

**Solutions**:
1. Check if server is running: `curl http://host:port/health`
2. Verify firewall rules allow traffic on the port
3. Check network connectivity: `ping host`
4. Verify correct URL in client configuration

### AWS Credential Issues

**Problem**: AWS operations fail with authentication errors

**Solutions**:
1. Verify environment variables are set correctly
2. Check IAM permissions for DynamoDB operations
3. Ensure credentials haven't expired (for temporary credentials)
4. Test credentials with AWS CLI: `aws dynamodb list-tables`

### Performance Issues

**Problem**: Slow response times

**Solutions**:
1. Check network latency between client and server
2. Verify AWS region is optimal for your location
3. Monitor DynamoDB table capacity and throttling
4. Consider using DynamoDB on-demand billing mode

## Use Cases

### Team Development
Deploy a shared MCP server for your team to access common DynamoDB resources without individual AWS credentials.

### CI/CD Integration
Use remote mode in CI/CD pipelines to interact with DynamoDB during automated testing.

### Multi-Region Access
Deploy MCP servers in multiple regions and route clients to the nearest server for optimal performance.

### Centralized Management
Maintain a single MCP server with proper IAM roles and permissions, reducing credential management overhead.

## Limitations

1. **No Built-in Authentication**: Implement authentication at the reverse proxy level
2. **Single AWS Account**: Each server instance connects to one AWS account
3. **No Message Queuing**: Messages are processed synchronously
4. **Connection Limits**: Depends on Node.js and system resources

## Future Enhancements

Potential improvements for remote mode:
- Built-in authentication mechanisms
- WebSocket transport support
- Connection pooling and load balancing
- Metrics and observability endpoints
- Rate limiting and throttling
- Multi-account support

## Support

For issues, questions, or contributions, please visit the project repository.
