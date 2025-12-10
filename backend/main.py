"""
VexaAI Workflow Sales Backend
FastAPI application for handling payments and data management
"""

from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime
import os
import httpx
from dotenv import load_dotenv
import secrets

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
SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")
ADMIN_EMAIL = os.getenv("ADMIN_EMAIL", "johnevansokyere@gmail.com")
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD", "admin123")

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

class DashboardStats(BaseModel):
    total_revenue: float
    total_sales: int
    total_customers: int
    all_access_sales: int
    recent_sales: List[dict]

# In-memory storage (replace with Supabase in production)
# This is just for demonstration
sales_db = []
customers_db = []

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


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
