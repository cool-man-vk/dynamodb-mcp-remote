# Test script for DynamoDB MCP Server (PowerShell)
Write-Host "Testing DynamoDB MCP Server" -ForegroundColor Green
Write-Host "==========================================="
Write-Host ""

# Start the server in background
Write-Host "Starting server..." -ForegroundColor Yellow

$serverJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    npm start
}

# Wait for server to start
Write-Host "Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Test health endpoint
Write-Host ""
Write-Host "Testing health endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method Get
    Write-Host "Health check response:" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "Failed to connect to health endpoint: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Server is running in background job: $($serverJob.Id)" -ForegroundColor Green
Write-Host "To stop the server, run: Stop-Job -Id $($serverJob.Id); Remove-Job -Id $($serverJob.Id)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Endpoints:" -ForegroundColor Yellow
Write-Host "  SSE endpoint: http://localhost:3000/sse"
Write-Host "  Message endpoint: http://localhost:3000/message"
Write-Host "  Health check: http://localhost:3000/health"
Write-Host ""
Write-Host "Press Ctrl+C to stop monitoring. The server will continue running in the background."

# Keep script running to show server output
Receive-Job -Job $serverJob -Wait
