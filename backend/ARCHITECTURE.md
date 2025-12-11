# VexaAI Backend Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Browser  │  │  Mobile  │  │   Admin  │  │ Paystack │       │
│  │          │  │   App    │  │Dashboard │  │ Webhook  │       │
│  └─────┬────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
└────────┼────────────┼─────────────┼─────────────┼──────────────┘
         │            │             │             │
         ▼            ▼             ▼             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY LAYER                           │
│                         FastAPI App                              │
│                    ┌──────────────────┐                          │
│                    │   app/main.py    │                          │
│                    │   - CORS         │                          │
│                    │   - Middleware   │                          │
│                    │   - Static Files │                          │
│                    └────────┬─────────┘                          │
└─────────────────────────────┼────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
         ▼                    ▼                    ▼
┌────────────────┐  ┌────────────────┐  ┌────────────────┐
│  AUTH ROUTER   │  │ WORKFLOW ROUTER│  │  ADMIN ROUTER  │
│ /api/auth/*    │  │ /api/workflows*│  │  /api/admin/*  │
├────────────────┤  ├────────────────┤  ├────────────────┤
│ - register     │  │ - list         │  │ - login        │
│ - login        │  │ - get details  │  │ - stats        │
│ - me           │  │                │  │ - manage       │
│ - logout       │  │                │  │ - users        │
└───────┬────────┘  └────────┬───────┘  └────────┬───────┘
        │                    │                    │
        ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SERVICE LAYER                               │
│                    (Business Logic)                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ AuthService  │  │WorkflowServ. │  │ AdminService │          │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤          │
│  │register_user │  │get_workflows │  │get_stats     │          │
│  │login_user    │  │create_flow   │  │get_users     │          │
│  │get_user_info │  │update_flow   │  │get_requests  │          │
│  │admin_login   │  │delete_flow   │  │              │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
└─────────┼──────────────────┼──────────────────┼──────────────────┘
          │                  │                  │
          └──────────────────┼──────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      UTILITY LAYER                               │
│  ┌────────────────────┐         ┌────────────────────┐          │
│  │   Database Utils   │         │    Auth Utils      │          │
│  ├────────────────────┤         ├────────────────────┤          │
│  │get_db_connection() │         │hash_password()     │          │
│  │execute_query()     │         │verify_password()   │          │
│  │execute_query_dict()│         │create_token()      │          │
│  │                    │         │decode_token()      │          │
│  └─────────┬──────────┘         └────────────────────┘          │
└────────────┼─────────────────────────────────────────────────────┘
             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE LAYER                              │
│                   Neon PostgreSQL (Serverless)                   │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐   │
│  │ users  │  │workflow│  │ sales  │  │custom_ │  │ admins │   │
│  │        │  │   s    │  │        │  │requests│  │        │   │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Request Flow Example

### User Registration Flow

```
1. Client sends POST /api/auth/register
   ↓
2. FastAPI routes to auth_router.register()
   ↓
3. Router validates data with UserRegister schema
   ↓
4. Router calls AuthService.register_user()
   ↓
5. Service hashes password using auth utils
   ↓
6. Service inserts user via database utils
   ↓
7. Database connection executes INSERT query
   ↓
8. Service returns success response
   ↓
9. Router formats and sends JSON response
   ↓
10. Client receives response
```

### Admin Workflow Upload Flow

```
1. Admin uploads workflow via POST /api/admin/workflows
   ↓
2. FastAPI routes to admin_router.upload_workflow()
   ↓
3. Router validates with WorkflowUpload schema
   ↓
4. Router calls WorkflowService.create_workflow()
   ↓
5. Service converts JSON to string
   ↓
6. Service inserts via execute_query_dict()
   ↓
7. Database stores workflow in workflows table
   ↓
8. Service returns workflow_id
   ↓
9. Router sends success response
   ↓
10. Admin sees confirmation
```

## Data Flow

```
Request → Router → Schema Validation → Service → Database Utils → Database
                                                      ↓
Response ← Router ← Service ← Database Utils ← Database
```

## Module Dependencies

```
app/
├── main.py
│   └── depends on: routers, config
│
├── config.py
│   └── depends on: environment variables
│
├── routers/
│   ├── auth.py
│   │   └── depends on: schemas, services, utils.auth
│   ├── workflows.py
│   │   └── depends on: services
│   ├── admin.py
│   │   └── depends on: schemas, services, utils.auth
│   └── payment.py
│       └── depends on: schemas, utils.database, config
│
├── services/
│   ├── auth_service.py
│   │   └── depends on: utils.database, utils.auth, schemas
│   ├── workflow_service.py
│   │   └── depends on: utils.database, schemas
│   └── admin_service.py
│       └── depends on: utils.database
│
├── schemas/
│   ├── user.py
│   ├── workflow.py
│   └── payment.py
│       └── depends on: pydantic only
│
└── utils/
    ├── database.py
    │   └── depends on: config, psycopg
    └── auth.py
        └── depends on: config, passlib, jwt
```

## Layer Responsibilities

### Layer 1: Routers (API Interface)
- **Purpose**: HTTP request/response handling
- **Responsibilities**:
  - Route definitions
  - Input validation (via schemas)
  - Response formatting
  - Error handling
- **Should NOT**:
  - Contain business logic
  - Access database directly
  - Perform complex calculations

### Layer 2: Services (Business Logic)
- **Purpose**: Core application logic
- **Responsibilities**:
  - Business rules
  - Data processing
  - Database operations (via utils)
  - Transaction management
- **Should NOT**:
  - Handle HTTP concerns
  - Format responses
  - Validate inputs (use schemas)

### Layer 3: Schemas (Data Validation)
- **Purpose**: Data structure definition
- **Responsibilities**:
  - Input validation
  - Type checking
  - Default values
  - Custom validators
- **Should NOT**:
  - Contain business logic
  - Access database
  - Have side effects

### Layer 4: Utils (Shared Utilities)
- **Purpose**: Reusable helper functions
- **Responsibilities**:
  - Database connections
  - Password hashing
  - JWT operations
  - Common functions
- **Should NOT**:
  - Contain business logic
  - Be feature-specific
  - Handle HTTP requests

## Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      SECURITY LAYERS                             │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Layer 1: CORS Middleware                                   │ │
│  │ - Validates origin                                         │ │
│  │ - Allows specific domains only                             │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Layer 2: JWT Authentication                                │ │
│  │ - Validates Bearer tokens                                  │ │
│  │ - Checks expiration                                        │ │
│  │ - Extracts user identity                                   │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Layer 3: Input Validation                                  │ │
│  │ - Pydantic schema validation                               │ │
│  │ - Type checking                                            │ │
│  │ - Sanitization                                             │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Layer 4: SQL Injection Prevention                          │ │
│  │ - Parameterized queries                                    │ │
│  │ - No string concatenation                                  │ │
│  │ - Prepared statements                                      │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Layer 5: Password Security                                 │ │
│  │ - Bcrypt hashing                                           │ │
│  │ - Salt generation                                          │ │
│  │ - Never store plain text                                   │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Scalability Strategy

### Horizontal Scaling
```
Load Balancer
    ├── App Instance 1 (port 8000)
    ├── App Instance 2 (port 8001)
    ├── App Instance 3 (port 8002)
    └── App Instance 4 (port 8003)
             ↓
    Shared Database (Neon PostgreSQL)
```

### Feature Scaling
```
New Feature Required?
    ↓
1. Add schema in schemas/
    ↓
2. Add service in services/
    ↓
3. Add router in routers/
    ↓
4. Register in main.py
    ↓
Done! (No existing code modified)
```

### Database Scaling
```
Current: Neon PostgreSQL
Future Options:
- Read replicas for queries
- Write master for updates
- Caching layer (Redis)
- Connection pooling
```

## Error Handling Flow

```
Error Occurs
    ↓
Service catches exception
    ↓
Logs error details
    ↓
Raises HTTPException
    ↓
FastAPI error handler
    ↓
Formats error response
    ↓
Returns to client
```

## Monitoring Points

```
1. Request Level
   - Request count
   - Response time
   - Error rate

2. Service Level
   - Database query time
   - Business logic execution
   - External API calls

3. Database Level
   - Connection pool usage
   - Query performance
   - Slow queries

4. System Level
   - CPU usage
   - Memory usage
   - Network I/O
```

---

This architecture supports:
✅ Easy testing
✅ Team collaboration
✅ Code reusability
✅ Horizontal scaling
✅ Feature additions
✅ Maintenance
