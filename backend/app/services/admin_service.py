"""
Admin service
Business logic for admin dashboard operations
"""
from app.utils.database import execute_query_dict


class AdminService:
    """Service for admin operations"""

    @staticmethod
    def get_dashboard_stats() -> dict:
        """
        Get dashboard statistics

        Returns:
            dict: Dashboard statistics
        """
        # Sales stats
        sales_stats = execute_query_dict(
            """
            SELECT
                COALESCE(SUM(amount), 0) as total_revenue,
                COUNT(*) as total_sales,
                COUNT(CASE WHEN purchase_type = 'all-access' THEN 1 END) as all_access_sales
            FROM sales
            WHERE payment_status = 'success'
            """,
            fetch_one=True
        ) or {}

        # User count
        user_count = execute_query_dict(
            "SELECT COUNT(*) as count FROM users",
            fetch_one=True
        ) or {"count": 0}

        # Workflow count
        workflow_count = execute_query_dict(
            "SELECT COUNT(*) as count FROM workflows WHERE is_active = TRUE",
            fetch_one=True
        ) or {"count": 0}

        # Customer count
        customer_count = execute_query_dict(
            "SELECT COUNT(DISTINCT customer_email) as count FROM sales",
            fetch_one=True
        ) or {"count": 0}

        # Recent sales
        recent_sales = execute_query_dict(
            """
            SELECT
                reference, customer_email as email, purchase_type,
                amount, created_at
            FROM sales
            WHERE payment_status = 'success'
            ORDER BY created_at DESC
            LIMIT 10
            """,
            fetch_all=True
        ) or []

        return {
            "success": True,
            "stats": {
                "total_revenue": float(sales_stats.get("total_revenue", 0)),
                "total_sales": int(sales_stats.get("total_sales", 0)),
                "all_access_sales": int(sales_stats.get("all_access_sales", 0)),
                "total_users": int(user_count.get("count", 0)),
                "total_workflows": int(workflow_count.get("count", 0)),
                "total_customers": int(customer_count.get("count", 0)),
                "recent_sales": recent_sales
            }
        }

    @staticmethod
    def get_all_users() -> dict:
        """
        Get all registered users

        Returns:
            dict: List of users
        """
        users = execute_query_dict(
            """
            SELECT
                id, email, first_name, last_name, phone,
                is_admin, is_verified, is_active, login_count,
                last_login, created_at
            FROM users
            ORDER BY created_at DESC
            """,
            fetch_all=True
        ) or []

        return {
            "success": True,
            "users": users
        }

    @staticmethod
    def get_custom_requests() -> dict:
        """
        Get all custom workflow requests

        Returns:
            dict: List of custom requests
        """
        requests = execute_query_dict(
            """
            SELECT
                id, name, email, phone, workflow_description,
                use_case, budget, timeline, status, created_at
            FROM custom_requests
            ORDER BY created_at DESC
            """,
            fetch_all=True
        ) or []

        return {
            "success": True,
            "requests": requests
        }

    @staticmethod
    def update_request_status(request_id: int, status: str) -> dict:
        """
        Update custom request status

        Args:
            request_id: Request ID
            status: New status

        Returns:
            dict: Success status
        """
        execute_query_dict(
            "UPDATE custom_requests SET status = %s, updated_at = NOW() WHERE id = %s",
            (status, request_id)
        )

        return {
            "success": True,
            "message": "Request status updated"
        }
