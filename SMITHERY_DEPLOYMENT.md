# Smithery Deployment Guide

This guide explains how to deploy the DynamoDB MCP Server for use with Smithery as a remote MCP server.

## Understanding Remote MCP Servers

For Smithery to recognize this as a **remote MCP server**, you need to:

1. Deploy the server to a publicly accessible location (cloud server, VPS, etc.)
2. Run it in SSE mode (Server-Sent Events over HTTP)
3. Provide the HTTP endpoint URL to Smithery

**Important**: Simply running SSE mode on localhost won't make it "remote" for Smithery - it needs to be accessible over the internet.

## Deployment Options

### Option 1: Deploy to a Cloud Platform

#### Railway.app
1. Create a new project on Railway
2. Connect your GitHub repository
3. Set environment variables:
   ```
   MCP_TRANSPORT_MODE=sse
   MCP_HOST=0.0.0.0
   MCP_PORT=3000
   AWS_ACCESS_KEY_ID=your_key
   AWS_SECRET_ACCESS_KEY=your_secret
   AWS_REGION=us-east-1
   ```
4. Railway will provide a public URL like: `https://your-app.railway.app`
5. Your SSE endpoint will be: `https://your-app.railway.app/sse`

#### Render.com
1. Create a new Web Service
2. Connect your repository
3. Set build command: `npm install && npm run build`
4. Set start command: `npm start`
5. Add environment variables (same as above)
6. Render provides a URL like: `https://your-app.onrender.com`
7. Your SSE endpoint: `https://your-app.onrender.com/sse`

#### Heroku
```bash
# Login to Heroku
heroku login

# Create app
heroku create your-dynamodb-mcp

# Set environment variables
heroku config:set MCP_TRANSPORT_MODE=sse
heroku config:set MCP_HOST=0.0.0.0
heroku config:set MCP_PORT=$PORT
heroku config:set AWS_ACCESS_KEY_ID=your_key
heroku config:set AWS_SECRET_ACCESS_KEY=your_secret
heroku config:set AWS_REGION=us-east-1

# Deploy
git push heroku main

# Your endpoint: https://your-dynamodb-mcp.herokuapp.com/sse
```

#### AWS EC2
```bash
# SSH into your EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# Clone and setup
git clone your-repo
cd dynamodb-mcp-server
npm install
npm run build

# Set environment variables
export MCP_TRANSPORT_MODE=sse
export MCP_HOST=0.0.0.0
export MCP_PORT=3000
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_REGION=us-east-1

# Run with PM2 for persistence
npm install -g pm2
pm2 start npm --name "dynamodb-mcp" -- start
pm2 save
pm2 startup

# Configure security group to allow port 3000
# Your endpoint: http://your-ec2-ip:3000/sse
```

#### DigitalOcean Droplet
```bash
# SSH into droplet
ssh root@your-droplet-ip

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Setup application
git clone your-repo
cd dynamodb-mcp-server
npm install
npm run build

# Create systemd service
sudo nano /etc/systemd/system/dynamodb-mcp.service
```

Add this content:
```ini
[Unit]
Description=DynamoDB MCP Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/dynamodb-mcp-server
Environment="MCP_TRANSPORT_MODE=sse"
Environment="MCP_HOST=0.0.0.0"
Environment="MCP_PORT=3000"
Environment="AWS_ACCESS_KEY_ID=your_key"
Environment="AWS_SECRET_ACCESS_KEY=your_secret"
Environment="AWS_REGION=us-east-1"
ExecStart=/usr/bin/npm start
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# Start service
sudo systemctl daemon-reload
sudo systemctl enable dynamodb-mcp
sudo systemctl start dynamodb-mcp

# Your endpoint: http://your-droplet-ip:3000/sse
```

### Option 2: Docker Deployment

#### Docker Hub + Cloud
```bash
# Build and push to Docker Hub
docker build -t your-username/dynamodb-mcp-server .
docker push your-username/dynamodb-mcp-server

# Deploy on any cloud platform that supports Docker
# Example: AWS ECS, Google Cloud Run, Azure Container Instances
```

#### Docker Compose (for VPS)
Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  dynamodb-mcp:
    image: mcp/dynamodb-mcp-server
    ports:
      - "3000:3000"
    environment:
      - MCP_TRANSPORT_MODE=sse
      - MCP_HOST=0.0.0.0
      - MCP_PORT=3000
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - AWS_REGION=${AWS_REGION}
    restart: unless-stopped
```

Deploy:
```bash
docker-compose up -d
```

### Option 3: Serverless (Advanced)

For serverless deployment, you'd need to adapt the code to work with:
- AWS Lambda + API Gateway
- Google Cloud Functions
- Azure Functions

This requires additional modifications to handle serverless event models.

## Configuring Smithery

Once deployed, configure Smithery with your remote endpoint:

1. Go to Smithery settings
2. Add a new MCP server
3. Select "Remote Server"
4. Enter your SSE endpoint URL:
   ```
   https://your-deployment-url.com/sse
   ```
   or
   ```
   http://your-server-ip:3000/sse
   ```

## Testing Your Deployment

### 1. Test Health Endpoint
```bash
curl https://your-deployment-url.com/health
```

Expected response:
```json
{
  "status": "healthy",
  "server": "dynamodb-mcp-server",
  "version": "0.2.0",
  "transport": "sse",
  "endpoints": {
    "sse": "https://your-deployment-url.com/sse",
    "message": "https://your-deployment-url.com/message",
    "health": "https://your-deployment-url.com/health"
  }
}
```

### 2. Test SSE Connection
```bash
curl -N -H "Accept: text/event-stream" https://your-deployment-url.com/sse
```

You should see an SSE connection established.

### 3. Test from Smithery
- Add the server in Smithery
- Try listing DynamoDB tables
- Verify operations work correctly

## Security Considerations

### 1. Use HTTPS
Always use HTTPS in production. Most cloud platforms provide this automatically.

### 2. Add Authentication
Consider adding API key authentication:

```typescript
// Add to your server code
const API_KEY = process.env.MCP_API_KEY;

if (req.headers['x-api-key'] !== API_KEY) {
  res.writeHead(401, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ error: "Unauthorized" }));
  return;
}
```

### 3. Use IAM Roles (AWS)
Instead of access keys, use IAM roles when deploying on AWS:

```typescript
// Remove hardcoded credentials
const dynamoClient = new DynamoDBClient({
  region: process.env.AWS_REGION,
  // Credentials will be automatically loaded from IAM role
});
```

### 4. Rate Limiting
Add rate limiting to prevent abuse:

```bash
npm install express-rate-limit
```

### 5. Firewall Rules
Restrict access to known IP addresses if possible.

## Environment Variables Summary

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `MCP_TRANSPORT_MODE` | Yes | `stdio` | Set to `sse` for remote |
| `MCP_HOST` | No | `0.0.0.0` | Host to bind to |
| `MCP_PORT` | No | `3000` | Port to listen on |
| `AWS_ACCESS_KEY_ID` | Yes | - | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Yes | - | AWS secret key |
| `AWS_REGION` | Yes | - | AWS region |
| `AWS_SESSION_TOKEN` | No | - | For temporary credentials |

## Troubleshooting

### Smithery Can't Connect

**Check:**
1. Server is running: `curl https://your-url.com/health`
2. URL is correct (must end with `/sse`)
3. Server is publicly accessible (not localhost)
4. No firewall blocking the connection
5. CORS headers are set correctly

### AWS Operations Fail

**Check:**
1. AWS credentials are set correctly
2. IAM permissions include DynamoDB operations
3. Region is correct
4. Credentials haven't expired

### Server Crashes

**Check:**
1. Logs for error messages
2. Memory limits (increase if needed)
3. AWS rate limits
4. Network connectivity

## Cost Considerations

### Cloud Platform Costs
- **Railway**: Free tier available, then ~$5-20/month
- **Render**: Free tier available, then ~$7/month
- **Heroku**: ~$7/month (no free tier)
- **AWS EC2**: ~$5-10/month for t2.micro
- **DigitalOcean**: $6/month for basic droplet

### AWS DynamoDB Costs
- On-demand: Pay per request
- Provisioned: Pay for capacity units
- Free tier: 25 GB storage, 25 WCU, 25 RCU

## Next Steps

1. Choose a deployment platform
2. Deploy your server
3. Test the endpoints
4. Configure Smithery with your SSE endpoint
5. Start using your remote DynamoDB MCP server!

## Support

For issues or questions:
- Check server logs
- Test endpoints with curl
- Verify AWS credentials and permissions
- Review Smithery documentation
