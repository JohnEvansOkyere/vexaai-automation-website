"""
VexaAI Workflow Sales Backend
FastAPI application for handling payments and data management
"""

from fastapi import FastAPI, HTTPException, Depends, Request, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, EmailStr, validator
from typing import Optional, List, Dict, Any
from datetime import datetime, timedelta
import os
import httpx
from dotenv import load_dotenv
import secrets
import jwt
from passlib.context import CryptContext
import uuid

# Load environment variables
load_dotenv()

# Initialize FastAPI app
app = FastAPI(
    title="VexaAI Workflow Sales API",
    description="Backend API for VexaAI n8n workflow sales platform",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Environment variables
PAYSTACK_SECRET_KEY = os.getenv("PAYSTACK_SECRET_KEY", "sk_test_your_secret_key")
DATABASE_URL = os.getenv("DATABASE_URL", "")
ADMIN_EMAIL = os.getenv("ADMIN_EMAIL", "johnevansokyere@gmail.com")
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD", "admin123")
SECRET_KEY = os.getenv("SECRET_KEY", "your_secret_key_change_this_in_production")
JWT_ALGORITHM = "HS256"
JWT_EXPIRY_HOURS = int(os.getenv("JWT_EXPIRY_HOURS", "24"))

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Security
security = HTTPBearer()

# Helper functions for password and JWT
def hash_password(password: str) -> str:
    """Hash a password using bcrypt"""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against a hash"""
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict) -> str:
    """Create JWT access token"""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(hours=JWT_EXPIRY_HOURS)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=JWT_ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> dict:
    """Decode JWT access token"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Get current authenticated user from JWT token"""
    token = credentials.credentials
    payload = decode_access_token(token)
    user_id = payload.get("user_id")
    email = payload.get("email")

    if not user_id or not email:
        raise HTTPException(status_code=401, detail="Invalid authentication credentials")

    # In production, fetch user from database
    return {
        "user_id": user_id,
        "email": email,
        "first_name": payload.get("first_name"),
        "last_name": payload.get("last_name")
    }

# Pydantic models
class WorkflowItem(BaseModel):
    id: int
    name: str
    category: str
    icon: str
    description: Optional[str] = None
    price: int = 149  # in GHS

class PaymentRequest(BaseModel):
    email: EmailStr
    amount: int
    purchase_type: str  # 'single' or 'all-access'
    workflow_id: Optional[int] = None
    workflow_name: Optional[str] = None

class PaymentVerification(BaseModel):
    reference: str

class Customer(BaseModel):
    email: EmailStr
    name: str
    purchase_type: str
    workflow_id: Optional[int] = None
    workflow_name: Optional[str] = None
    amount: int
    payment_reference: str

class AdminLogin(BaseModel):
    email: EmailStr
    password: str

# Authentication models
class UserRegister(BaseModel):
    email: EmailStr
    password: str
    first_name: str
    last_name: str
    phone: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class CustomRequestSubmit(BaseModel):
    name: str
    email: EmailStr
    phone: Optional[str] = None
    company: Optional[str] = None
    workflow_title: str
    description: str
    use_case: Optional[str] = None
    budget_range: Optional[str] = None
    timeline: Optional[str] = None
    preferred_platforms: Optional[List[str]] = []
    integration_needs: Optional[str] = None

class DashboardStats(BaseModel):
    total_revenue: float
    total_sales: int
    total_customers: int
    all_access_sales: int
    recent_sales: List[dict]

# In-memory storage (replace with PostgreSQL/Neon in production)
# This is just for demonstration
sales_db = []
customers_db = []
users_db = []  # Store users
custom_requests_db = []  # Store custom workflow requests

# Workflows list
WORKFLOWS = [
    {"id": 1, "name": "Email Marketing Automation", "category": "Marketing", "icon": "📧", "description": "Automated email sequences with personalization"},
    {"id": 2, "name": "Sales Pipeline Manager", "category": "Sales", "icon": "💰", "description": "Track leads and automate follow-ups"},
    {"id": 3, "name": "Social Media Scheduler", "category": "Marketing", "icon": "📱", "description": "Schedule posts across all platforms"},
    {"id": 4, "name": "Lead Generation & Nurturing", "category": "Sales", "icon": "🎯", "description": "Capture and nurture leads automatically"},
    {"id": 5, "name": "Customer Support Automation", "category": "Support", "icon": "💬", "description": "Automate customer support workflows"},
    {"id": 6, "name": "Invoice & Payment Tracker", "category": "Finance", "icon": "💳", "description": "Track invoices and payments"},
    {"id": 7, "name": "Content Publishing System", "category": "Content", "icon": "📝", "description": "Automated content publishing"},
    {"id": 8, "name": "Data Sync Across Platforms", "category": "Integration", "icon": "🔄", "description": "Sync data across multiple platforms"},
    {"id": 9, "name": "WhatsApp Business Automation", "category": "Communication", "icon": "💚", "description": "Automate WhatsApp business messages"},
    {"id": 10, "name": "E-commerce Order Processor", "category": "E-commerce", "icon": "🛒", "description": "Process e-commerce orders automatically"},
    {"id": 11, "name": "Inventory Management System", "category": "Operations", "icon": "📦", "description": "Manage inventory levels"},
    {"id": 12, "name": "HR Onboarding Automation", "category": "HR", "icon": "👥", "description": "Automate employee onboarding"},
    {"id": 13, "name": "Task & Project Management", "category": "Productivity", "icon": "✅", "description": "Manage tasks and projects"},
    {"id": 14, "name": "Website Analytics Dashboard", "category": "Analytics", "icon": "📊", "description": "Track website analytics"},
    {"id": 15, "name": "Appointment Booking System", "category": "Scheduling", "icon": "📅", "description": "Automated appointment booking"},
]


# Routes
@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "online",
        "message": "VexaAI Workflow Sales API",
        "version": "1.0.0"
    }


@app.get("/api/workflows")
async def get_workflows():
    """Get all available workflows"""
    return {
        "success": True,
        "workflows": WORKFLOWS
    }


@app.get("/api/workflows/{workflow_id}")
async def get_workflow(workflow_id: int):
    """Get a specific workflow by ID"""
    workflow = next((w for w in WORKFLOWS if w["id"] == workflow_id), None)
    if not workflow:
        raise HTTPException(status_code=404, detail="Workflow not found")
    return {
        "success": True,
        "workflow": workflow
    }


@app.post("/api/payment/initialize")
async def initialize_payment(payment: PaymentRequest):
    """Initialize Paystack payment"""
    try:
        # Paystack API endpoint
        url = "https://api.paystack.co/transaction/initialize"

        # Prepare metadata
        metadata = {
            "purchase_type": payment.purchase_type,
            "workflow_id": payment.workflow_id,
            "workflow_name": payment.workflow_name,
            "custom_fields": [
                {
                    "display_name": "Purchase Type",
                    "variable_name": "purchase_type",
                    "value": payment.purchase_type
                }
            ]
        }

        if payment.workflow_name:
            metadata["custom_fields"].append({
                "display_name": "Workflow",
                "variable_name": "workflow",
                "value": payment.workflow_name
            })

        # Paystack payload
        payload = {
            "email": payment.email,
            "amount": payment.amount * 100,  # Convert to pesewas
            "currency": "GHS",
            "callback_url": f"{os.getenv('FRONTEND_URL', 'http://localhost:8000')}/success.html",
            "metadata": metadata
        }

        # Make request to Paystack
        async with httpx.AsyncClient() as client:
            response = await client.post(
                url,
                json=payload,
                headers={
                    "Authorization": f"Bearer {PAYSTACK_SECRET_KEY}",
                    "Content-Type": "application/json"
                }
            )

        response_data = response.json()

        if response.status_code == 200 and response_data.get("status"):
            return {
                "success": True,
                "data": response_data["data"]
            }
        else:
            raise HTTPException(
                status_code=400,
                detail=response_data.get("message", "Payment initialization failed")
            )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/payment/verify")
async def verify_payment(verification: PaymentVerification):
    """Verify Paystack payment"""
    try:
        url = f"https://api.paystack.co/transaction/verify/{verification.reference}"

        async with httpx.AsyncClient() as client:
            response = await client.get(
                url,
                headers={
                    "Authorization": f"Bearer {PAYSTACK_SECRET_KEY}"
                }
            )

        response_data = response.json()

        if response.status_code == 200 and response_data.get("status"):
            transaction = response_data["data"]

            # Store sale in database (implement Supabase integration)
            sale = {
                "id": f"VEX{len(sales_db) + 1:04d}",
                "reference": verification.reference,
                "email": transaction["customer"]["email"],
                "amount": transaction["amount"] / 100,  # Convert from pesewas
                "status": transaction["status"],
                "purchase_type": transaction["metadata"].get("purchase_type"),
                "workflow_name": transaction["metadata"].get("workflow_name"),
                "created_at": datetime.utcnow().isoformat(),
                "payment_channel": transaction.get("channel", "unknown")
            }

            sales_db.append(sale)

            return {
                "success": True,
                "verified": transaction["status"] == "success",
                "transaction": transaction,
                "sale": sale
            }
        else:
            raise HTTPException(
                status_code=400,
                detail=response_data.get("message", "Payment verification failed")
            )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/webhook/paystack")
async def paystack_webhook(request: Request):
    """Handle Paystack webhooks"""
    try:
        # Get the webhook payload
        payload = await request.json()

        # Verify webhook signature (important for production)
        signature = request.headers.get("x-paystack-signature")

        # Process the event
        event = payload.get("event")
        data = payload.get("data")

        if event == "charge.success":
            # Handle successful payment
            sale = {
                "id": f"VEX{len(sales_db) + 1:04d}",
                "reference": data["reference"],
                "email": data["customer"]["email"],
                "amount": data["amount"] / 100,
                "status": data["status"],
                "purchase_type": data["metadata"].get("purchase_type"),
                "workflow_name": data["metadata"].get("workflow_name"),
                "created_at": datetime.utcnow().isoformat(),
                "payment_channel": data.get("channel", "unknown")
            }
            sales_db.append(sale)

            # TODO: Send email with workflow access
            # TODO: Update Supabase

        return {"status": "success"}

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/admin/login")
async def admin_login(credentials: AdminLogin):
    """Admin login"""
    if credentials.email == ADMIN_EMAIL and credentials.password == ADMIN_PASSWORD:
        # Generate a simple token (use JWT in production)
        token = secrets.token_urlsafe(32)
        return {
            "success": True,
            "token": token,
            "admin": {
                "email": credentials.email,
                "name": "John Evans Okyere"
            }
        }
    else:
        raise HTTPException(status_code=401, detail="Invalid credentials")


@app.get("/api/admin/stats")
async def get_admin_stats():
    """Get dashboard statistics"""
    total_revenue = sum(sale["amount"] for sale in sales_db)
    total_sales = len(sales_db)
    all_access_sales = len([s for s in sales_db if s.get("purchase_type") == "all-access"])

    # Get unique customers
    unique_emails = set(sale["email"] for sale in sales_db)
    total_customers = len(unique_emails)

    # Recent sales
    recent_sales = sorted(sales_db, key=lambda x: x["created_at"], reverse=True)[:10]

    return {
        "success": True,
        "stats": {
            "total_revenue": total_revenue,
            "total_sales": total_sales,
            "total_customers": total_customers,
            "all_access_sales": all_access_sales,
            "recent_sales": recent_sales
        }
    }


@app.get("/api/admin/sales")
async def get_all_sales():
    """Get all sales"""
    return {
        "success": True,
        "sales": sorted(sales_db, key=lambda x: x["created_at"], reverse=True)
    }


@app.get("/api/admin/customers")
async def get_all_customers():
    """Get all customers"""
    # Aggregate customer data
    customer_map = {}

    for sale in sales_db:
        email = sale["email"]
        if email not in customer_map:
            customer_map[email] = {
                "email": email,
                "purchases": 0,
                "total_spent": 0,
                "first_purchase": sale["created_at"],
                "type": "Single"
            }

        customer_map[email]["purchases"] += 1
        customer_map[email]["total_spent"] += sale["amount"]

        if sale.get("purchase_type") == "all-access":
            customer_map[email]["type"] = "All Access"

    customers = list(customer_map.values())

    return {
        "success": True,
        "customers": customers
    }


@app.get("/api/download/workflow/{workflow_id}")
async def download_workflow(workflow_id: int, email: str):
    """Generate workflow download link"""
    workflow = next((w for w in WORKFLOWS if w["id"] == workflow_id), None)

    if not workflow:
        raise HTTPException(status_code=404, detail="Workflow not found")

    # Verify purchase (check in database)
    # For demo, we'll generate a sample workflow

    workflow_json = {
        "name": workflow["name"],
        "nodes": [
            {
                "parameters": {},
                "name": "Start",
                "type": "n8n-nodes-base.start",
                "typeVersion": 1,
                "position": [250, 300]
            }
        ],
        "connections": {},
        "createdAt": datetime.utcnow().isoformat(),
        "updatedAt": datetime.utcnow().isoformat(),
        "settings": {},
        "staticData": None
    }

    return {
        "success": True,
        "workflow": workflow_json,
        "download_url": f"/downloads/{workflow['name'].replace(' ', '_')}.json"
    }


# ============================================
# AUTHENTICATION ROUTES
# ============================================

@app.post("/api/auth/register")
async def register_user(user_data: UserRegister):
    """Register a new user"""
    try:
        # Check if user already exists
        existing_user = next((u for u in users_db if u["email"] == user_data.email), None)
        if existing_user:
            raise HTTPException(status_code=400, detail="Email already registered")

        # Validate password length
        if len(user_data.password) < 8:
            raise HTTPException(status_code=400, detail="Password must be at least 8 characters")

        # Create new user
        user_id = str(uuid.uuid4())
        hashed_pwd = hash_password(user_data.password)

        new_user = {
            "id": user_id,
            "email": user_data.email,
            "password_hash": hashed_pwd,
            "first_name": user_data.first_name,
            "last_name": user_data.last_name,
            "phone": user_data.phone,
            "is_verified": False,
            "is_active": True,
            "created_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat()
        }

        users_db.append(new_user)

        return {
            "success": True,
            "message": "User registered successfully",
            "user": {
                "id": user_id,
                "email": user_data.email,
                "first_name": user_data.first_name,
                "last_name": user_data.last_name
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/auth/login")
async def login_user(credentials: UserLogin):
    """Login user and return JWT token"""
    try:
        # Find user by email
        user = next((u for u in users_db if u["email"] == credentials.email), None)

        if not user:
            raise HTTPException(status_code=401, detail="Invalid email or password")

        # Verify password
        if not verify_password(credentials.password, user["password_hash"]):
            raise HTTPException(status_code=401, detail="Invalid email or password")

        # Check if user is active
        if not user.get("is_active", True):
            raise HTTPException(status_code=403, detail="Account is inactive")

        # Create JWT token
        token_data = {
            "user_id": user["id"],
            "email": user["email"],
            "first_name": user.get("first_name"),
            "last_name": user.get("last_name")
        }
        token = create_access_token(token_data)

        # Update last login (in production, update in database)
        user["last_login"] = datetime.utcnow().isoformat()

        return {
            "success": True,
            "token": token,
            "user": {
                "id": user["id"],
                "email": user["email"],
                "first_name": user.get("first_name"),
                "last_name": user.get("last_name"),
                "phone": user.get("phone")
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/auth/me")
async def get_current_user_info(current_user: dict = Depends(get_current_user)):
    """Get current authenticated user information"""
    try:
        # Find full user details
        user = next((u for u in users_db if u["id"] == current_user["user_id"]), None)

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        return {
            "success": True,
            "user": {
                "id": user["id"],
                "email": user["email"],
                "first_name": user.get("first_name"),
                "last_name": user.get("last_name"),
                "phone": user.get("phone"),
                "is_verified": user.get("is_verified", False),
                "created_at": user.get("created_at")
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/auth/logout")
async def logout_user(current_user: dict = Depends(get_current_user)):
    """Logout user (in production, invalidate token in database)"""
    return {
        "success": True,
        "message": "Logged out successfully"
    }


# ============================================
# CUSTOM WORKFLOW REQUEST ROUTES
# ============================================

@app.post("/api/requests/submit")
async def submit_custom_request(request_data: CustomRequestSubmit):
    """Submit a custom workflow request"""
    try:
        # Create new request
        request_id = str(uuid.uuid4())

        new_request = {
            "id": request_id,
            "user_id": None,  # Will be set if user is authenticated
            "name": request_data.name,
            "email": request_data.email,
            "phone": request_data.phone,
            "company": request_data.company,
            "workflow_title": request_data.workflow_title,
            "description": request_data.description,
            "use_case": request_data.use_case,
            "budget_range": request_data.budget_range,
            "timeline": request_data.timeline,
            "preferred_platforms": request_data.preferred_platforms,
            "integration_needs": request_data.integration_needs,
            "status": "pending",
            "priority": "normal",
            "response_email_sent": False,
            "created_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat()
        }

        custom_requests_db.append(new_request)

        # TODO: Send email notification to admin
        # TODO: Send confirmation email to user

        return {
            "success": True,
            "message": "Custom workflow request submitted successfully",
            "request_id": request_id,
            "request": {
                "id": request_id,
                "workflow_title": request_data.workflow_title,
                "status": "pending",
                "created_at": new_request["created_at"]
            }
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/admin/requests")
async def get_all_requests():
    """Get all custom workflow requests (admin only)"""
    # TODO: Add admin authentication
    try:
        # Sort by priority and date
        sorted_requests = sorted(
            custom_requests_db,
            key=lambda x: (
                0 if x["priority"] == "urgent" else
                1 if x["priority"] == "high" else
                2 if x["priority"] == "normal" else 3,
                x["created_at"]
            ),
            reverse=True
        )

        return {
            "success": True,
            "total": len(sorted_requests),
            "requests": sorted_requests
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.patch("/api/admin/requests/{request_id}")
async def update_request_status(request_id: str, status: str, admin_notes: Optional[str] = None):
    """Update custom request status (admin only)"""
    # TODO: Add admin authentication
    try:
        # Find request
        request = next((r for r in custom_requests_db if r["id"] == request_id), None)

        if not request:
            raise HTTPException(status_code=404, detail="Request not found")

        # Validate status
        valid_statuses = ["pending", "reviewing", "quoted", "in_progress", "completed", "rejected"]
        if status not in valid_statuses:
            raise HTTPException(status_code=400, detail=f"Invalid status. Must be one of: {', '.join(valid_statuses)}")

        # Update request
        request["status"] = status
        request["updated_at"] = datetime.utcnow().isoformat()

        if admin_notes:
            request["admin_notes"] = admin_notes

        # TODO: Send status update email to user

        return {
            "success": True,
            "message": "Request status updated successfully",
            "request": request
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
