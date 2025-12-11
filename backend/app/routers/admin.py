"""
Admin routes
Admin dashboard, workflow management, and statistics
"""
from fastapi import APIRouter, Depends
from app.schemas.user import AdminLogin
from app.schemas.workflow import WorkflowUpload
from app.services.auth_service import AuthService
from app.services.workflow_service import WorkflowService
from app.services.admin_service import AdminService
from app.utils.auth import get_current_user

router = APIRouter(prefix="/api/admin", tags=["Admin"])


@router.post("/login")
async def admin_login(credentials: AdminLogin):
    """Admin login with admin privileges check"""
    return AuthService.admin_login(credentials)


@router.get("/stats")
async def get_admin_stats():
    """Get dashboard statistics"""
    return AdminService.get_dashboard_stats()


@router.get("/workflows")
async def get_all_workflows_admin():
    """Get all workflows with full details (admin only)"""
    workflows = WorkflowService.get_all_workflows(active_only=False)

    return {
        "success": True,
        "workflows": [
            {
                "id": w["id"],
                "name": w["name"],
                "category": w["category"],
                "icon": w["icon"],
                "description": w.get("description"),
                "price": float(w["price"]),
                "tags": w.get("tags", []),
                "downloads": w.get("downloads", 0),
                "revenue": float(w.get("revenue", 0)),
                "is_active": w.get("is_active", True),
                "created_at": str(w.get("created_at")) if w.get("created_at") else None,
                "updated_at": str(w.get("updated_at")) if w.get("updated_at") else None
            }
            for w in workflows
        ]
    }


@router.post("/workflows")
async def upload_workflow(workflow_data: WorkflowUpload):
    """Upload/create a new workflow (admin only)"""
    return WorkflowService.create_workflow(workflow_data)


@router.put("/workflows/{workflow_id}")
async def update_workflow(workflow_id: int, workflow_data: WorkflowUpload):
    """Update an existing workflow (admin only)"""
    return WorkflowService.update_workflow(workflow_id, workflow_data)


@router.delete("/workflows/{workflow_id}")
async def delete_workflow(workflow_id: int):
    """Delete a workflow (admin only)"""
    return WorkflowService.delete_workflow(workflow_id)


@router.get("/users")
async def get_all_users():
    """Get all registered users (admin only)"""
    return AdminService.get_all_users()


@router.get("/requests")
async def get_custom_requests():
    """Get all custom workflow requests (admin only)"""
    return AdminService.get_custom_requests()


@router.patch("/requests/{request_id}")
async def update_request_status(request_id: int, status: str):
    """Update custom request status (admin only)"""
    return AdminService.update_request_status(request_id, status)
