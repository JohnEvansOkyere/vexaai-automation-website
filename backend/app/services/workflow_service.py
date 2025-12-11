"""
Workflow service
Business logic for workflow management
"""
import json
from fastapi import HTTPException
from app.utils.database import execute_query_dict
from app.schemas.workflow import WorkflowUpload, WorkflowUpdate


class WorkflowService:
    """Service for workflow operations"""

    @staticmethod
    def get_all_workflows(active_only: bool = True) -> list:
        """
        Get all workflows

        Args:
            active_only: Only return active workflows

        Returns:
            list: List of workflows
        """
        query = """
            SELECT
                id, name, category, icon, description,
                price, tags, downloads, revenue, is_active, created_at
            FROM workflows
        """

        if active_only:
            query += " WHERE is_active = TRUE"

        query += " ORDER BY created_at DESC"

        workflows = execute_query_dict(query, fetch_all=True) or []
        return workflows

    @staticmethod
    def get_workflow_by_id(workflow_id: int) -> dict:
        """
        Get a single workflow by ID

        Args:
            workflow_id: Workflow ID

        Returns:
            dict: Workflow data

        Raises:
            HTTPException: If workflow not found
        """
        workflow = execute_query_dict(
            """
            SELECT
                id, name, category, icon, description, price,
                tags, json_file_url, downloads, revenue, is_active
            FROM workflows
            WHERE id = %s
            """,
            (workflow_id,),
            fetch_one=True
        )

        if not workflow:
            raise HTTPException(status_code=404, detail="Workflow not found")

        return workflow

    @staticmethod
    def create_workflow(workflow_data: WorkflowUpload) -> dict:
        """
        Create a new workflow

        Args:
            workflow_data: Workflow data

        Returns:
            dict: Created workflow ID

        Raises:
            HTTPException: If creation fails
        """
        try:
            # Convert workflow JSON to string
            json_string = json.dumps(workflow_data.workflow_json)

            workflow_id = execute_query_dict(
                """
                INSERT INTO workflows (
                    name, category, icon, description, price,
                    tags, json_file_url, downloads, revenue,
                    is_active, created_at, updated_at
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, %s, 0, 0, TRUE, NOW(), NOW()
                )
                RETURNING id
                """,
                (
                    workflow_data.name,
                    workflow_data.category,
                    workflow_data.icon,
                    workflow_data.description,
                    workflow_data.price,
                    workflow_data.tags,
                    json_string
                ),
                fetch_one=True
            )

            return {
                "success": True,
                "message": "Workflow created successfully",
                "workflow_id": workflow_id["id"]
            }

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    @staticmethod
    def update_workflow(workflow_id: int, workflow_data: WorkflowUpload) -> dict:
        """
        Update an existing workflow

        Args:
            workflow_id: Workflow ID
            workflow_data: Updated workflow data

        Returns:
            dict: Success status

        Raises:
            HTTPException: If update fails
        """
        try:
            execute_query_dict(
                """
                UPDATE workflows
                SET
                    name = %s,
                    category = %s,
                    icon = %s,
                    description = %s,
                    price = %s,
                    tags = %s,
                    json_file_url = %s,
                    updated_at = NOW()
                WHERE id = %s
                """,
                (
                    workflow_data.name,
                    workflow_data.category,
                    workflow_data.icon,
                    workflow_data.description,
                    workflow_data.price,
                    workflow_data.tags,
                    json.dumps(workflow_data.workflow_json),
                    workflow_id
                )
            )

            return {
                "success": True,
                "message": "Workflow updated successfully"
            }

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    @staticmethod
    def delete_workflow(workflow_id: int) -> dict:
        """
        Delete a workflow

        Args:
            workflow_id: Workflow ID

        Returns:
            dict: Success status

        Raises:
            HTTPException: If deletion fails
        """
        try:
            execute_query_dict(
                "DELETE FROM workflows WHERE id = %s",
                (workflow_id,)
            )

            return {
                "success": True,
                "message": "Workflow deleted successfully"
            }

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
