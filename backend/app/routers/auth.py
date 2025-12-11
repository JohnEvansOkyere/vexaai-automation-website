"""
Authentication routes
User registration, login, and profile management
"""
from fastapi import APIRouter, Depends
from app.schemas.user import UserRegister, UserLogin, AdminLogin
from app.services.auth_service import AuthService
from app.utils.auth import get_current_user

router = APIRouter(prefix="/api/auth", tags=["Authentication"])


@router.post("/register")
async def register(user_data: UserRegister):
    """Register a new user"""
    return AuthService.register_user(user_data)


@router.post("/login")
async def login(credentials: UserLogin):
    """Login user and return JWT token"""
    return AuthService.login_user(credentials)


@router.get("/me")
async def get_current_user_info(current_user: dict = Depends(get_current_user)):
    """Get current authenticated user information"""
    return AuthService.get_user_info(current_user["user_id"])


@router.post("/logout")
async def logout(current_user: dict = Depends(get_current_user)):
    """Logout user (client-side token removal)"""
    return {
        "success": True,
        "message": "Logged out successfully"
    }
