"""
Workflow routes
Public workflow browsing and details
"""
from fastapi import APIRouter, HTTPException
from app.services.workflow_service import WorkflowService

router = APIRouter(prefix="/api/workflows", tags=["Workflows"])


@router.get("")
async def get_workflows():
    """Get all available workflows from database"""
    try:
        workflows = WorkflowService.get_all_workflows(active_only=True)
        return {
            "success": True,
            "workflows": workflows
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{workflow_id}")
async def get_workflow(workflow_id: int):
    """Get a specific workflow by ID"""
    workflow = WorkflowService.get_workflow_by_id(workflow_id)
    return {
        "success": True,
        "workflow": workflow
    }
