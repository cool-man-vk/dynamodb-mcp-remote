# Quick Reference Card

## Start Server

```bash
npm start
```

### Custom Configuration
```bash
MCP_HOST=127.0.0.1 MCP_PORT=8080 npm start
```

## Environment Variables

```bash
# Required
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_REGION="us-east-1"

# Optional
export MCP_HOST="0.0.0.0"  # Default: 0.0.0.0
export MCP_PORT="3000"      # Default: 3000
```

## Docker Commands

```bash
docker run -d --rm \
  -e AWS_ACCESS_KEY_ID="..." \
  -e AWS_SECRET_ACCESS_KEY="..." \
  -e AWS_REGION="us-east-1" \
  -p 3000:3000 \
  --name dynamodb-mcp \
  mcp/dynamodb-mcp-server
```

### Custom Port
```bash
docker run -d --rm \
  -e MCP_PORT=8080 \
  -e AWS_ACCESS_KEY_ID="..." \
  -e AWS_SECRET_ACCESS_KEY="..." \
  -e AWS_REGION="us-east-1" \
  -p 8080:8080 \
  --name dynamodb-mcp \
  mcp/dynamodb-mcp-server
```

## Claude Desktop Config

```json
{
  "mcpServers": {
    "dynamodb": {
      "url": "http://localhost:3000/sse"
    }
  }
}
```

### Production
```json
{
  "mcpServers": {
    "dynamodb": {
      "url": "https://your-server.com/sse"
    }
  }
}
```

## Test Commands

### Health Check
```bash
curl http://localhost:3000/health
```

### Test SSE Connection
```bash
curl -N -H "Accept: text/event-stream" http://localhost:3000/sse
```

### Run Test Script
```bash
# Linux/Mac
./test-remote.sh

# Windows
.\test-remote.ps1
```

## Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Health check |
| `/sse` | GET | SSE connection |
| `/message` | POST | Send messages |

## Common Issues

### Port Already in Use
```bash
# Use different port
MCP_PORT=8080 npm start
```

### Connection Refused
```bash
# Check if server is running
curl http://localhost:3000/health

# Check firewall
# Windows: netsh advfirewall firewall add rule name="MCP" dir=in action=allow protocol=TCP localport=3000
# Linux: sudo ufw allow 3000
```

### AWS Credentials Error
```bash
# Test credentials
aws dynamodb list-tables --region us-east-1

# Check environment
echo $AWS_ACCESS_KEY_ID
echo $AWS_REGION
```

## Build Commands

```bash
# Install dependencies
npm install

# Build project
npm run build

# Watch mode (development)
npm run watch
```

## Documentation

- [README.md](README.md) - Main documentation
- [REMOTE_MODE.md](REMOTE_MODE.md) - Remote mode guide
- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) - Migration from v0.1.0
- [CHANGELOG.md](CHANGELOG.md) - Version history

## Support

For detailed information, see the full documentation files listed above.
