#!/bin/bash

# Test script for DynamoDB MCP Server
echo "Testing DynamoDB MCP Server"
echo "==========================================="
echo ""

# Start the server in background
echo "Starting server..."
npm start &
SERVER_PID=$!

# Wait for server to start
echo "Waiting for server to start..."
sleep 3

# Test health endpoint
echo ""
echo "Testing health endpoint..."
curl -s http://localhost:3000/health | jq .

# Test SSE endpoint (just check if it responds)
echo ""
echo "Testing SSE endpoint..."
curl -s -N -H "Accept: text/event-stream" http://localhost:3000/sse &
CURL_PID=$!
sleep 2
kill $CURL_PID 2>/dev/null

echo ""
echo "Server is running on PID: $SERVER_PID"
echo "To stop the server, run: kill $SERVER_PID"
echo ""
echo "SSE endpoint: http://localhost:3000/sse"
echo "Message endpoint: http://localhost:3000/message"
echo "Health check: http://localhost:3000/health"
