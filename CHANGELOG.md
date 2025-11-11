# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2024-11-10

### Changed
- **BREAKING**: Server now runs exclusively in remote mode using SSE transport
- Removed local stdio transport support
- Server binds to `0.0.0.0:3000` by default for remote access
- Simplified configuration with only HTTP/SSE transport

### Added
- HTTP server with SSE endpoint for remote client connections
- Health check endpoint (`/health`) for monitoring
- Comprehensive remote mode documentation (REMOTE_MODE.md)
- Example configuration files for Claude Desktop
- Test scripts (bash and PowerShell)
- Docker support optimized for remote deployment

### Removed
- Local stdio transport mode
- `MCP_TRANSPORT_MODE` environment variable (no longer needed)

### Environment Variables
- `MCP_HOST`: Host binding (default: `0.0.0.0`)
- `MCP_PORT`: Port to listen on (default: `3000`)

## [0.1.0] - Initial Release

### Added
- DynamoDB table management (create, list, describe)
- Global Secondary Index (GSI) operations (create, update)
- Local Secondary Index (LSI) creation
- Table capacity management
- Data operations (put, get, update, query, scan)
- AWS SDK integration
- stdio transport for local MCP communication
- Docker support
- Comprehensive documentation
