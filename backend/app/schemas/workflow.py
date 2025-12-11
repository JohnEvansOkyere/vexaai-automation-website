"""
Workflow schemas for request/response validation
"""
from pydantic import BaseModel
from typing import Optional, List
from decimal import Decimal


class WorkflowUpload(BaseModel):
    """Workflow upload request"""
    name: str
    category: str
    icon: str
    description: str
    price: float = 149.00
    tags: Optional[List[str]] = []
    workflow_json: dict


class WorkflowResponse(BaseModel):
    """Workflow response model"""
    id: int
    name: str
    category: str
    icon: str
    description: Optional[str] = None
    price: Decimal
    tags: Optional[List[str]] = []
    downloads: int = 0
    revenue: Decimal = 0
    is_active: bool = True


class WorkflowUpdate(BaseModel):
    """Workflow update request"""
    name: Optional[str] = None
    category: Optional[str] = None
    icon: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    tags: Optional[List[str]] = None
    workflow_json: Optional[dict] = None
