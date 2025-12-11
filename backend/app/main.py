"""
VexaAI Backend Application
A scalable FastAPI application for selling n8n workflow automations.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import os

from app.config import settings
from app.routers import auth_router, workflows_router, admin_router, payment_router

# Create FastAPI application
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    description="API for selling n8n workflow automations",
    docs_url="/api/docs",
    redoc_url="/api/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins in development
    allow_credentials=False,  # Cannot use credentials with wildcard origins
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"]
)

# Include routers
app.include_router(auth_router)
app.include_router(workflows_router)
app.include_router(admin_router)
app.include_router(payment_router)

# Get public path
public_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "..", "public")

# Define HTML page routes BEFORE static files mount
@app.get("/")
async def root():
    """Serve the main index page"""
    index_path = os.path.join(public_path, "index.html")
    if os.path.exists(index_path):
        return FileResponse(index_path)
    return {
        "message": "VexaAI API",
        "version": settings.VERSION,
        "docs": "/api/docs"
    }


@app.get("/workflows.html")
async def workflows_page():
    """Serve the workflows page"""
    workflows_path = os.path.join(public_path, "workflows.html")
    if os.path.exists(workflows_path):
        return FileResponse(workflows_path)
    return {"error": "Workflows page not found"}


@app.get("/auth.html")
async def auth_page():
    """Serve the auth page"""
    auth_path = os.path.join(public_path, "auth.html")
    if os.path.exists(auth_path):
        return FileResponse(auth_path)
    return {"error": "Auth page not found"}


@app.get("/admin.html")
async def admin_page():
    """Serve the admin page"""
    admin_path = os.path.join(public_path, "admin.html")
    if os.path.exists(admin_path):
        return FileResponse(admin_path)
    return {"error": "Admin page not found"}


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "version": settings.VERSION
    }


@app.get("/api")
async def api_info():
    """API information"""
    return {
        "name": settings.APP_NAME,
        "version": settings.VERSION,
        "endpoints": {
            "auth": "/api/auth",
            "workflows": "/api/workflows",
            "admin": "/api/admin",
            "payment": "/api/payment"
        },
        "docs": "/api/docs"
    }


# Mount static files for CSS, JS, images, etc. (AFTER all specific routes)
if os.path.exists(public_path):
    css_path = os.path.join(public_path, "css")
    js_path = os.path.join(public_path, "js")
    assets_path = os.path.join(public_path, "assets")

    if os.path.exists(css_path):
        app.mount("/css", StaticFiles(directory=css_path), name="css")
    if os.path.exists(js_path):
        app.mount("/js", StaticFiles(directory=js_path), name="js")
    if os.path.exists(assets_path):
        app.mount("/assets", StaticFiles(directory=assets_path), name="assets")


# Catch-all route for SPA behavior - serve index.html for any unmatched route
# This must be LAST to not override other routes
@app.get("/{full_path:path}")
async def catch_all(full_path: str):
    """Catch all other routes and serve index.html for SPA routing"""
    # Don't catch empty path (root), it's handled by the / route above
    if not full_path or full_path == "":
        index_path = os.path.join(public_path, "index.html")
        if os.path.exists(index_path):
            return FileResponse(index_path)

    # Ignore API routes and static files
    if full_path.startswith("api/") or full_path.startswith("css/") or full_path.startswith("js/") or full_path.startswith("assets/"):
        return {"error": "Not found"}

    # Serve index.html for all other routes
    index_path = os.path.join(public_path, "index.html")
    if os.path.exists(index_path):
        return FileResponse(index_path)
    return {"error": "Page not found"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG
    )
