#!/bin/bash

# Quick deployment script for Railway.app
echo "🚂 Deploying DynamoDB MCP Server to Railway"
echo "==========================================="
echo ""

# Check if railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    npm install -g @railway/cli
fi

# Login to Railway
echo "📝 Logging in to Railway..."
railway login

# Create new project
echo "🆕 Creating new project..."
railway init

# Set environment variables
echo "⚙️  Setting environment variables..."
echo ""
echo "Please enter your AWS credentials:"
read -p "AWS_ACCESS_KEY_ID: " aws_key
read -sp "AWS_SECRET_ACCESS_KEY: " aws_secret
echo ""
read -p "AWS_REGION (default: us-east-1): " aws_region
aws_region=${aws_region:-us-east-1}

railway variables set MCP_TRANSPORT_MODE=sse
railway variables set MCP_HOST=0.0.0.0
railway variables set MCP_PORT=3000
railway variables set AWS_ACCESS_KEY_ID="$aws_key"
railway variables set AWS_SECRET_ACCESS_KEY="$aws_secret"
railway variables set AWS_REGION="$aws_region"

# Deploy
echo ""
echo "🚀 Deploying to Railway..."
railway up

# Get the URL
echo ""
echo "✅ Deployment complete!"
echo ""
echo "Getting your deployment URL..."
railway domain

echo ""
echo "📋 Your SSE endpoint will be: https://your-app.railway.app/sse"
echo "   Use this URL in Smithery to connect to your remote MCP server"
echo ""
echo "🔍 To check deployment status: railway status"
echo "📊 To view logs: railway logs"
