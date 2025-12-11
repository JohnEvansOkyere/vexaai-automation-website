"""
Payment and sales schemas
"""
from pydantic import BaseModel, EmailStr
from typing import Optional


class PaymentRequest(BaseModel):
    """Payment initialization request"""
    email: EmailStr
    amount: float
    purchase_type: str  # "single" or "all-access"
    workflow_id: Optional[int] = None
    workflow_name: Optional[str] = None


class CustomWorkflowRequest(BaseModel):
    """Custom workflow request submission"""
    name: str
    email: EmailStr
    phone: Optional[str] = None
    workflow_description: str
    use_case: str
    budget: Optional[str] = None
    timeline: Optional[str] = None
