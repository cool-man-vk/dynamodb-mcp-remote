# Architecture Overview

## Transport Modes

### Local Mode (stdio)

```
┌──────────────────────────────────────────────────────┐
│                    Your Computer                      │
│                                                       │
│  ┌─────────────┐         stdin/stdout    ┌─────────┐ │
│  │  Smithery   │ ◄────────────────────► │   MCP   │ │
│  │   Client    │                        │  Server │ │
│  └─────────────┘                        └─────────┘ │
│                                              │       │
│                                              ▼       │
│                                         ┌─────────┐  │
│                                         │   AWS   │  │
│                                         │ DynamoDB│  │
│                                         └─────────┘  │
└──────────────────────────────────────────────────────┘
```

**Characteristics:**
- Process-to-process communication
- No network involved
- Fast and secure
- Single machine only

---

### Remote Mode (SSE over HTTP)

```
┌─────────────────┐                    ┌──────────────────┐
│  Your Computer  │                    │   Cloud Server   │
│                 │                    │                  │
│  ┌───────────┐  │   HTTP/SSE        │   ┌─────────┐   │
│  │ Smithery  │  │ ◄───────────────► │   │   MCP   │   │
│  │  Client   │  │  Public Internet  │   │  Server │   │
│  └───────────┘  │                    │   └─────────┘   │
│                 │                    │        │        │
└─────────────────┘                    │        ▼        │
                                       │   ┌─────────┐   │
┌─────────────────┐                    │   │   AWS   │   │
│ Friend's Device │   HTTP/SSE        │   │ DynamoDB│   │
│                 │ ◄─────────────────┤   └─────────┘   │
│  ┌───────────┐  │                    │                  │
│  │ Smithery  │  │                    └──────────────────┘
│  │  Client   │  │
│  └───────────┘  │
└─────────────────┘
```

**Characteristics:**
- HTTP-based communication
- Network involved
- Accessible from anywhere
- Multiple clients can connect
- Requires deployment

---

## Data Flow

### Query Operation Example

```
1. Client Request
   ┌─────────┐
   │ Client  │ "List DynamoDB tables"
   └────┬────┘
        │
        ▼
2. MCP Server
   ┌─────────┐
   │   MCP   │ Receives request
   │  Server │ Validates parameters
   └────┬────┘
        │
        ▼
3. AWS SDK
   ┌─────────┐
   │   AWS   │ ListTablesCommand
   │   SDK   │
   └────┬────┘
        │
        ▼
4. DynamoDB
   ┌─────────┐
   │ DynamoDB│ Executes query
   │ Service │ Returns results
   └────┬────┘
        │
        ▼
5. Response Path
   ┌─────────┐
   │   MCP   │ Formats response
   │  Server │ Returns to client
   └────┬────┘
        │
        ▼
   ┌─────────┐
   │ Client  │ Displays results
   └─────────┘
```

---

## Component Architecture

```
┌────────────────────────────────────────────────────────┐
│                    MCP Server                          │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │           Transport Layer                        │ │
│  │  ┌──────────────┐      ┌──────────────┐        │ │
│  │  │    stdio     │      │     SSE      │        │ │
│  │  │  Transport   │      │  Transport   │        │ │
│  │  └──────────────┘      └──────────────┘        │ │
│  └──────────────────────────────────────────────────┘ │
│                         │                             │
│  ┌──────────────────────────────────────────────────┐ │
│  │           MCP Protocol Layer                     │ │
│  │  - Request handling                              │ │
│  │  - Tool registration                             │ │
│  │  - Response formatting                           │ │
│  └──────────────────────────────────────────────────┘ │
│                         │                             │
│  ┌──────────────────────────────────────────────────┐ │
│  │           Business Logic Layer                   │ │
│  │  ┌────────────┐  ┌────────────┐  ┌───────────┐ │ │
│  │  │   Table    │  │   Index    │  │   Data    │ │ │
│  │  │ Management │  │ Management │  │Operations │ │ │
│  │  └────────────┘  └────────────┘  └───────────┘ │ │
│  └──────────────────────────────────────────────────┘ │
│                         │                             │
│  ┌──────────────────────────────────────────────────┐ │
│  │           AWS SDK Layer                          │ │
│  │  - DynamoDB Client                               │ │
│  │  - Credential Management                         │ │
│  │  - Request/Response Marshalling                  │ │
│  └──────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────┐
              │   AWS DynamoDB   │
              │     Service      │
              └──────────────────┘
```

---

## Deployment Architectures

### Development (Local)

```
┌─────────────────────────────────┐
│      Developer Machine          │
│                                 │
│  ┌──────────┐    ┌──────────┐  │
│  │ Smithery │◄──►│   MCP    │  │
│  │          │    │  Server  │  │
│  └──────────┘    └────┬─────┘  │
│                       │         │
└───────────────────────┼─────────┘
                        │
                        ▼
                  ┌──────────┐
                  │   AWS    │
                  │ DynamoDB │
                  └──────────┘
```

### Production (Remote)

```
┌──────────────┐         ┌─────────────────────┐
│   Client 1   │         │   Cloud Platform    │
│  (Smithery)  │◄───────►│   (Railway/AWS)     │
└──────────────┘         │                     │
                         │  ┌──────────────┐   │
┌──────────────┐         │  │     MCP      │   │
│   Client 2   │◄───────►│  │    Server    │   │
│  (Smithery)  │         │  │  (Container) │   │
└──────────────┘         │  └──────┬───────┘   │
                         │         │           │
┌──────────────┐         │         │           │
│   Client 3   │◄───────►│  ┌──────▼───────┐   │
│  (Smithery)  │         │  │  Load        │   │
└──────────────┘         │  │  Balancer    │   │
                         │  └──────────────┘   │
                         └─────────────────────┘
                                   │
                                   ▼
                            ┌──────────────┐
                            │     AWS      │
                            │   DynamoDB   │
                            └──────────────┘
```

### High Availability

```
                    ┌─────────────┐
                    │   Clients   │
                    └──────┬──────┘
                           │
                           ▼
                  ┌────────────────┐
                  │  Load Balancer │
                  └────────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
   ┌────────┐         ┌────────┐        ┌────────┐
   │  MCP   │         │  MCP   │        │  MCP   │
   │Server 1│         │Server 2│        │Server 3│
   └───┬────┘         └───┬────┘        └───┬────┘
       │                  │                  │
       └──────────────────┼──────────────────┘
                          │
                          ▼
                   ┌──────────────┐
                   │   DynamoDB   │
                   │  (Multi-AZ)  │
                   └──────────────┘
```

---

## Security Layers

```
┌─────────────────────────────────────────────────┐
│                   Client                        │
└────────────────────┬────────────────────────────┘
                     │ HTTPS/TLS
                     ▼
┌─────────────────────────────────────────────────┐
│              Reverse Proxy (nginx)              │
│  - SSL Termination                              │
│  - Rate Limiting                                │
│  - Authentication                               │
└────────────────────┬────────────────────────────┘
                     │ HTTP
                     ▼
┌─────────────────────────────────────────────────┐
│                 MCP Server                      │
│  - Request Validation                           │
│  - CORS Headers                                 │
│  - Error Handling                               │
└────────────────────┬────────────────────────────┘
                     │ AWS SDK
                     ▼
┌─────────────────────────────────────────────────┐
│              AWS IAM / Security                 │
│  - Credential Management                        │
│  - Permission Policies                          │
│  - Encryption at Rest                           │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│                 DynamoDB                        │
│  - VPC Endpoints (optional)                     │
│  - Encryption                                   │
│  - Access Logging                               │
└─────────────────────────────────────────────────┘
```

---

## Request Flow (Detailed)

### SSE Connection Establishment

```
Client                    Server
  │                         │
  │  GET /sse              │
  ├────────────────────────►│
  │                         │
  │  200 OK                │
  │  Content-Type:         │
  │  text/event-stream     │
  │◄────────────────────────┤
  │                         │
  │  (Connection kept open) │
  │◄═══════════════════════►│
  │                         │
```

### Tool Invocation

```
Client              Server              AWS
  │                   │                  │
  │ POST /message     │                  │
  │ {tool: "list"}    │                  │
  ├──────────────────►│                  │
  │                   │                  │
  │                   │ ListTables       │
  │                   ├─────────────────►│
  │                   │                  │
  │                   │ Response         │
  │                   │◄─────────────────┤
  │                   │                  │
  │ SSE Event         │                  │
  │ {tables: [...]}   │                  │
  │◄──────────────────┤                  │
  │                   │                  │
```

---

## Environment Configuration

```
┌─────────────────────────────────────────┐
│         Environment Variables           │
├─────────────────────────────────────────┤
│                                         │
│  Transport Configuration                │
│  ├─ MCP_TRANSPORT_MODE                  │
│  ├─ MCP_HOST                            │
│  └─ MCP_PORT                            │
│                                         │
│  AWS Configuration                      │
│  ├─ AWS_ACCESS_KEY_ID                   │
│  ├─ AWS_SECRET_ACCESS_KEY               │
│  ├─ AWS_REGION                          │
│  └─ AWS_SESSION_TOKEN (optional)        │
│                                         │
└─────────────────────────────────────────┘
```

---

## Tool Architecture

```
┌────────────────────────────────────────┐
│            MCP Tools                   │
├────────────────────────────────────────┤
│                                        │
│  Table Operations                      │
│  ├─ create_table                       │
│  ├─ list_tables                        │
│  ├─ describe_table                     │
│  └─ update_capacity                    │
│                                        │
│  Index Operations                      │
│  ├─ create_gsi                         │
│  ├─ update_gsi                         │
│  └─ create_lsi                         │
│                                        │
│  Data Operations                       │
│  ├─ put_item                           │
│  ├─ get_item                           │
│  ├─ update_item                        │
│  ├─ query_table                        │
│  └─ scan_table                         │
│                                        │
└────────────────────────────────────────┘
```

This architecture supports both local and remote deployments while maintaining the same functionality and API.
