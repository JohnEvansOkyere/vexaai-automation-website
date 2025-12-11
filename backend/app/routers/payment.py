"""
Payment routes
Paystack payment initialization and webhook handling
"""
from fastapi import APIRouter, HTTPException, Request
from app.schemas.payment import PaymentRequest, CustomWorkflowRequest
from app.config import settings
from app.utils.database import execute_query_dict
import httpx
import uuid

router = APIRouter(prefix="/api/payment", tags=["Payment"])


@router.post("/initialize")
async def initialize_payment(payment: PaymentRequest):
    """Initialize Paystack payment"""
    try:
        # Check if Paystack key is configured
        if not settings.PAYSTACK_SECRET_KEY or settings.PAYSTACK_SECRET_KEY == "":
            print("ERROR: PAYSTACK_SECRET_KEY is not configured in .env file")
            raise HTTPException(
                status_code=500,
                detail="Payment service not configured. Please contact administrator."
            )

        # Paystack API endpoint
        url = "https://api.paystack.co/transaction/initialize"

        # Prepare metadata
        metadata = {
            "purchase_type": payment.purchase_type,
            "workflow_id": payment.workflow_id,
            "workflow_name": payment.workflow_name
        }

        # Generate reference
        reference = f"VEXA-{uuid.uuid4().hex[:12].upper()}"

        # Paystack request payload
        payload = {
            "email": payment.email,
            "amount": int(payment.amount * 100),  # Convert to kobo
            "currency": "GHS",
            "reference": reference,
            "metadata": metadata,
            "callback_url": f"{settings.FRONTEND_URL}/payment-success"
        }

        print(f"Initializing payment for {payment.email}, amount: {payment.amount}")

        # Make request to Paystack
        async with httpx.AsyncClient() as client:
            response = await client.post(
                url,
                json=payload,
                headers={
                    "Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}",
                    "Content-Type": "application/json"
                },
                timeout=30.0
            )

        print(f"Paystack response status: {response.status_code}")

        if response.status_code != 200:
            error_detail = response.json() if response.text else "Unknown error"
            print(f"Paystack error: {error_detail}")
            raise HTTPException(
                status_code=response.status_code,
                detail=f"Payment initialization failed: {error_detail}"
            )

        data = response.json()

        return {
            "success": True,
            "authorization_url": data["data"]["authorization_url"],
            "access_code": data["data"]["access_code"],
            "reference": data["data"]["reference"]
        }

    except httpx.HTTPError as e:
        print(f"HTTP Error: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Payment service error: {str(e)}")
    except HTTPException:
        raise
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/verify/{reference}")
async def verify_payment(reference: str):
    """Verify Paystack payment"""
    try:
        url = f"https://api.paystack.co/transaction/verify/{reference}"

        async with httpx.AsyncClient() as client:
            response = await client.get(
                url,
                headers={
                    "Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}"
                },
                timeout=30.0
            )

        if response.status_code != 200:
            raise HTTPException(status_code=400, detail="Payment verification failed")

        data = response.json()

        if data["data"]["status"] == "success":
            return {
                "success": True,
                "verified": True,
                "amount": data["data"]["amount"] / 100,
                "customer": data["data"]["customer"],
                "metadata": data["data"]["metadata"]
            }
        else:
            return {
                "success": False,
                "verified": False,
                "message": "Payment not successful"
            }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/webhook")
async def payment_webhook(request: Request):
    """Handle Paystack webhook events"""
    try:
        payload = await request.json()
        event = payload.get("event")

        if event == "charge.success":
            # Handle successful payment
            data = payload.get("data", {})
            # Process payment and update database
            pass

        return {"success": True}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/custom-request")
async def submit_custom_request(request_data: CustomWorkflowRequest):
    """Submit a custom workflow request"""
    try:
        request_id = execute_query_dict(
            """
            INSERT INTO custom_requests (
                name, email, phone, workflow_description,
                use_case, budget, timeline, status, created_at, updated_at
            ) VALUES (
                %s, %s, %s, %s, %s, %s, %s, 'pending', NOW(), NOW()
            )
            RETURNING id
            """,
            (
                request_data.name,
                request_data.email,
                request_data.phone,
                request_data.workflow_description,
                request_data.use_case,
                request_data.budget,
                request_data.timeline
            ),
            fetch_one=True
        )

        return {
            "success": True,
            "message": "Custom request submitted successfully",
            "request_id": request_id["id"]
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
