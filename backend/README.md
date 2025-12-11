# VexaAI Backend

A professional, scalable FastAPI application for selling n8n workflow automations.

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # Application entry point
│   ├── config.py            # Configuration and environment variables
│   │
│   ├── routers/             # API route handlers
│   │   ├── __init__.py
│   │   ├── auth.py          # Authentication routes
│   │   ├── workflows.py     # Workflow routes
│   │   ├── admin.py         # Admin dashboard routes
│   │   └── payment.py       # Payment and Paystack routes
│   │
│   ├── services/            # Business logic layer
│   │   ├── __init__.py
│   │   ├── auth_service.py  # Authentication logic
│   │   ├── workflow_service.py  # Workflow management
│   │   └── admin_service.py # Admin operations
│   │
│   ├── schemas/             # Pydantic models for validation
│   │   ├── __init__.py
│   │   ├── user.py          # User schemas
│   │   ├── workflow.py      # Workflow schemas
│   │   └── payment.py       # Payment schemas
│   │
│   └── utils/               # Utility functions
│       ├── __init__.py
│       ├── database.py      # Database connection
│       └── auth.py          # JWT and password utilities
│
├── run.py                   # Development server runner
├── requirements.txt         # Python dependencies
├── .env                     # Environment variables (not in git)
└── README.md               # This file
```

## Architecture

### Separation of Concerns

1. **Routers** (`app/routers/`): Handle HTTP requests and responses
2. **Services** (`app/services/`): Contain business logic
3. **Schemas** (`app/schemas/`): Define data validation models
4. **Utils** (`app/utils/`): Provide shared utilities

### Design Principles

- **Single Responsibility**: Each module has one clear purpose
- **Dependency Injection**: Services are injected into routes
- **Type Safety**: Full Pydantic validation on all inputs
- **Scalability**: Easy to add new features without touching existing code

## Setup

### 1. Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate  # Windows
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Environment

Create a `.env` file in the backend directory:

```env
# Database
DATABASE_URL=postgresql://user:password@host/database

# Security
SECRET_KEY=your-secret-key-here
JWT_ALGORITHM=HS256

# Paystack
PAYSTACK_SECRET_KEY=sk_test_xxxxx
PAYSTACK_PUBLIC_KEY=pk_test_xxxxx

# Pricing
SINGLE_WORKFLOW_PRICE=149
ALL_ACCESS_PRICE=799

# CORS
FRONTEND_URL=http://localhost:8000

# Admin (optional)
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=secure-password

# Debug
DEBUG=True
```

### 4. Run Development Server

```bash
python run.py
```

Or directly:

```bash
uvicorn app.main:app --reload
```

The API will be available at: `http://localhost:8000`

## API Documentation

Once running, visit:
- **Swagger UI**: http://localhost:8000/api/docs
- **ReDoc**: http://localhost:8000/api/redoc

## API Endpoints

### Authentication (`/api/auth`)

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user info
- `POST /api/auth/logout` - Logout user

### Workflows (`/api/workflows`)

- `GET /api/workflows` - List all active workflows
- `GET /api/workflows/{id}` - Get workflow details

### Admin (`/api/admin`)

- `POST /api/admin/login` - Admin login
- `GET /api/admin/stats` - Dashboard statistics
- `GET /api/admin/workflows` - All workflows
- `POST /api/admin/workflows` - Create workflow
- `PUT /api/admin/workflows/{id}` - Update workflow
- `DELETE /api/admin/workflows/{id}` - Delete workflow
- `GET /api/admin/users` - List all users
- `GET /api/admin/requests` - Custom workflow requests

### Payment (`/api/payment`)

- `POST /api/payment/initialize` - Initialize Paystack payment
- `POST /api/payment/verify/{reference}` - Verify payment
- `POST /api/payment/webhook` - Paystack webhook
- `POST /api/payment/custom-request` - Submit custom request

## Database

Uses Neon PostgreSQL (serverless). Connection is managed through `psycopg` 3.x.

### Connection Pooling

The `get_db_connection()` context manager handles:
- Automatic connection opening/closing
- Transaction commit/rollback
- Error handling

### Queries

Use `execute_query_dict()` for dictionary-based results:

```python
from app.utils.database import execute_query_dict

user = execute_query_dict(
    "SELECT * FROM users WHERE email = %s",
    (email,),
    fetch_one=True
)
```

## Adding New Features

### 1. Add a New Route

Create a new router file in `app/routers/`:

```python
# app/routers/new_feature.py
from fastapi import APIRouter

router = APIRouter(prefix="/api/new-feature", tags=["New Feature"])

@router.get("")
async def get_feature():
    return {"message": "New feature"}
```

Register it in `app/main.py`:

```python
from app.routers.new_feature import router as new_feature_router

app.include_router(new_feature_router)
```

### 2. Add Business Logic

Create a service in `app/services/`:

```python
# app/services/new_service.py
class NewService:
    @staticmethod
    def do_something():
        # Business logic here
        pass
```

### 3. Add Data Validation

Create schemas in `app/schemas/`:

```python
# app/schemas/new_model.py
from pydantic import BaseModel

class NewModel(BaseModel):
    name: str
    value: int
```

## Testing

```bash
# Run tests (when implemented)
pytest

# Run with coverage
pytest --cov=app
```

## Production Deployment

### 1. Set Environment Variables

Set all required environment variables on your hosting platform.

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Run with Gunicorn

```bash
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker
```

Or use the built-in uvicorn:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## Security Best Practices

1. **Never commit** `.env` files
2. **Use strong** `SECRET_KEY` in production
3. **Enable HTTPS** in production
4. **Validate all inputs** with Pydantic schemas
5. **Use parameterized queries** to prevent SQL injection
6. **Hash passwords** with bcrypt (already implemented)
7. **Verify JWT tokens** on protected routes

## Code Style

- Follow PEP 8
- Use type hints
- Write docstrings for all functions
- Keep functions small and focused
- Use meaningful variable names

## Migration from Old Structure

The old `main.py` has been backed up as `main.py.old`. The new structure provides:

✅ Better organization
✅ Easier testing
✅ Improved scalability
✅ Clear separation of concerns
✅ Reusable business logic
✅ Type safety throughout

## Support

For issues or questions:
- Check API documentation at `/api/docs`
- Review this README
- Check environment variables in `.env`

---

Built with FastAPI, PostgreSQL, and Paystack
