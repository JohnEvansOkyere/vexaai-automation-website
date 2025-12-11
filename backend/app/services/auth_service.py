"""
Authentication service
Business logic for user authentication and authorization
"""
import uuid
from fastapi import HTTPException
from app.utils.database import execute_query_dict
from app.utils.auth import hash_password, verify_password, create_access_token
from app.schemas.user import UserRegister, UserLogin


class AuthService:
    """Service for authentication operations"""

    @staticmethod
    def register_user(user_data: UserRegister) -> dict:
        """
        Register a new user

        Args:
            user_data: User registration data

        Returns:
            dict: Success status and message

        Raises:
            HTTPException: If email already exists
        """
        # Check if user exists
        existing_user = execute_query_dict(
            "SELECT id FROM users WHERE email = %s",
            (user_data.email,),
            fetch_one=True
        )

        if existing_user:
            raise HTTPException(status_code=400, detail="Email already registered")

        # Hash password
        hashed_pwd = hash_password(user_data.password)

        # Generate user ID
        user_id = str(uuid.uuid4())

        # Insert user
        execute_query_dict(
            """
            INSERT INTO users (
                id, email, password_hash, first_name, last_name, phone,
                is_verified, is_active, created_at, updated_at
            ) VALUES (
                %s, %s, %s, %s, %s, %s, FALSE, TRUE, NOW(), NOW()
            )
            """,
            (
                user_id,
                user_data.email,
                hashed_pwd,
                user_data.first_name,
                user_data.last_name,
                user_data.phone
            )
        )

        return {
            "success": True,
            "message": "User registered successfully"
        }

    @staticmethod
    def login_user(credentials: UserLogin) -> dict:
        """
        Login a user

        Args:
            credentials: User login credentials

        Returns:
            dict: Token and user data

        Raises:
            HTTPException: If credentials are invalid
        """
        # Find user
        user = execute_query_dict(
            """
            SELECT id, email, password_hash, first_name, last_name, phone,
                   is_active, is_admin
            FROM users
            WHERE email = %s
            """,
            (credentials.email,),
            fetch_one=True
        )

        if not user:
            raise HTTPException(status_code=401, detail="Invalid email or password")

        # Verify password
        if not verify_password(credentials.password, user["password_hash"]):
            raise HTTPException(status_code=401, detail="Invalid email or password")

        # Check if active
        if not user.get("is_active", True):
            raise HTTPException(status_code=403, detail="Account is inactive")

        # Update last login
        execute_query_dict(
            """
            UPDATE users
            SET last_login = NOW(), login_count = COALESCE(login_count, 0) + 1
            WHERE id = %s
            """,
            (str(user["id"]),)
        )

        # Create token
        token_data = {
            "user_id": str(user["id"]),
            "email": user["email"],
            "first_name": user.get("first_name"),
            "last_name": user.get("last_name")
        }
        token = create_access_token(token_data)

        return {
            "success": True,
            "token": token,
            "user": {
                "id": str(user["id"]),
                "email": user["email"],
                "first_name": user.get("first_name"),
                "last_name": user.get("last_name"),
                "phone": user.get("phone"),
                "is_admin": user.get("is_admin", False)
            }
        }

    @staticmethod
    def get_user_info(user_id: str) -> dict:
        """
        Get user information

        Args:
            user_id: User ID from token

        Returns:
            dict: User information

        Raises:
            HTTPException: If user not found
        """
        user = execute_query_dict(
            """
            SELECT id, email, first_name, last_name, phone,
                   is_verified, is_admin, created_at
            FROM users
            WHERE id = %s
            """,
            (user_id,),
            fetch_one=True
        )

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        return {
            "success": True,
            "user": {
                "id": str(user["id"]),
                "email": user["email"],
                "first_name": user.get("first_name"),
                "last_name": user.get("last_name"),
                "phone": user.get("phone"),
                "is_verified": user.get("is_verified", False),
                "is_admin": user.get("is_admin", False),
                "created_at": str(user.get("created_at")) if user.get("created_at") else None
            }
        }

    @staticmethod
    def admin_login(credentials: UserLogin) -> dict:
        """
        Admin login with admin privileges check

        Args:
            credentials: Admin login credentials

        Returns:
            dict: Token and admin data

        Raises:
            HTTPException: If not admin or invalid credentials
        """
        # Find user
        user = execute_query_dict(
            """
            SELECT id, email, password_hash, first_name, last_name,
                   is_admin, is_active
            FROM users
            WHERE email = %s
            """,
            (credentials.email,),
            fetch_one=True
        )

        if not user:
            raise HTTPException(status_code=401, detail="Invalid email or password")

        # Verify password
        if not verify_password(credentials.password, user["password_hash"]):
            raise HTTPException(status_code=401, detail="Invalid email or password")

        # Check admin status
        if not user.get("is_admin", False):
            raise HTTPException(status_code=403, detail="Access denied. Admin privileges required.")

        # Check if active
        if not user.get("is_active", True):
            raise HTTPException(status_code=403, detail="Account is inactive")

        # Update last login
        execute_query_dict(
            """
            UPDATE users
            SET last_login = NOW(), login_count = COALESCE(login_count, 0) + 1
            WHERE id = %s
            """,
            (str(user["id"]),)
        )

        # Create token
        token_data = {
            "user_id": str(user["id"]),
            "email": user["email"],
            "is_admin": True
        }
        token = create_access_token(token_data)

        return {
            "success": True,
            "token": token,
            "admin": {
                "id": str(user["id"]),
                "email": user["email"],
                "name": f"{user.get('first_name', '')} {user.get('last_name', '')}".strip() or user["email"]
            }
        }
