"""API routers"""
from app.routers.auth import router as auth_router
from app.routers.workflows import router as workflows_router
from app.routers.admin import router as admin_router
from app.routers.payment import router as payment_router

__all__ = ["auth_router", "workflows_router", "admin_router", "payment_router"]
