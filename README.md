# VexaAI - Premium n8n Workflows Sales Platform

A modern e-commerce platform for selling premium n8n automation workflows. Built with HTML5, Tailwind CSS, vanilla JavaScript, FastAPI backend, and Neon PostgreSQL database.

## Overview

This platform provides a complete solution for selling automation workflows with integrated payment processing, user authentication, and custom request management. The system supports both individual workflow purchases and all-access subscriptions.

## Features

### Frontend
- Modern responsive design with glassmorphism effects and smooth animations
- Mobile-first approach compatible with all devices
- Paystack payment integration supporting Mobile Money and card payments
- JWT-based user authentication system
- Two-tier pricing model: Single Workflow (GHS 149) and All Access Pass (GHS 799)
- Custom workflow request form for tailored solutions
- Post-payment success page with download access
- Searchable workflow catalog with category filtering
- Customer testimonials and social proof elements
- Comprehensive FAQ section

### Backend (FastAPI)
- RESTful API architecture with OpenAPI documentation
- JWT token-based authentication with bcrypt password hashing
- Paystack payment gateway integration with webhook support
- PostgreSQL database integration (Neon serverless)
- Admin authentication and authorization
- Custom workflow request management system
- Sales analytics and reporting capabilities

### Admin Dashboard
- Real-time business metrics and KPIs
- Interactive revenue and sales charts using Chart.js
- Customer database management
- Transaction history and payment tracking
- Custom request queue with status management
- Workflow inventory management
- System configuration panel
- Responsive dashboard interface

### Database (Neon PostgreSQL)
- Normalized schema with users, customers, sales, workflows, and custom_requests tables
- Row-level security policies for data protection
- Automated timestamp triggers
- Database views for analytics aggregation
- Stored procedures for complex operations

## Technology Stack

- Frontend: HTML5, Tailwind CSS, Vanilla JavaScript
- Backend: Python 3.9+, FastAPI
- Database: Neon PostgreSQL (serverless)
- Authentication: JWT tokens, bcrypt password hashing
- Payment Processing: Paystack API
- Data Visualization: Chart.js
- Deployment: Vercel/Netlify (frontend), Railway/Render (backend)

## Prerequisites

- Python 3.9 or higher (Python 3.13 recommended)
- Neon database account
- Paystack merchant account
- Node.js (optional, for development server)

## Recent Updates

### User Authentication System
- User registration and login functionality
- JWT-based session management with 24-hour token expiration
- Bcrypt password hashing for security
- Protected purchase routes requiring authentication
- Persistent sessions using browser localStorage

### Custom Workflow Request System
- Comprehensive request form capturing project requirements
- Budget range and timeline selection
- Platform preference specification (n8n, Zapier, Make, etc.)
- Integration requirements documentation
- Admin dashboard for request management
- Status tracking system (pending, reviewing, quoted, in_progress, completed, rejected)
- Priority level management

### New Pages
- auth.html: User authentication interface with tabbed sign-up and login forms
- request-workflow.html: Custom workflow request submission form

## Installation

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Linux/Mac:
source venv/bin/activate
# Windows:
# venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment variables
cp .env.example .env
nano .env
```

### Environment Configuration

Edit backend/.env with your credentials:

```env
# Paystack Configuration
PAYSTACK_PUBLIC_KEY=pk_test_your_public_key
PAYSTACK_SECRET_KEY=sk_test_your_secret_key

# Database Configuration
DATABASE_URL=postgresql://username:password@host/database

# Authentication
SECRET_KEY=your_secret_key_change_in_production
JWT_EXPIRY_HOURS=24

# Admin Credentials
ADMIN_EMAIL=johnevansokyere@gmail.com
ADMIN_PASSWORD=admin123

# Frontend URL
FRONTEND_URL=http://localhost:8000

# Notion Integration
NOTION_LIBRARY_URL=https://notion.so/your-private-library
```

### Database Setup

1. Access your Neon dashboard at console.neon.tech
2. Create a new project or select existing project
3. Navigate to SQL Editor
4. Execute database/neon_schema.sql to create main schema
5. Execute database/auth_migration.sql to add authentication tables
6. Verify table creation in the Tables section

### Running the Application

Start the backend server:

```bash
# Method 1: Using run.py (Recommended)
cd backend
python run.py

# Method 2: Using uvicorn directly
cd backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Method 3: Using python module
cd backendpython -m app.main
```

The API will be available at http://localhost:8000

Serve the frontend using one of these methods:

Python HTTP Server:
```bash
python -m http.server 3000
```

Node.js HTTP Server:
```bash
npx http-server -p 3000
```

VS Code Live Server:
- Install Live Server extension
- Right-click index.html and select Open with Live Server

Access the application at http://localhost:3000

## Project Structure

```
Automation-Website/
├── public/
│   ├── index.html
│   ├── auth.html
│   ├── request-workflow.html
│   ├── success.html
│   ├── admin.html
│   └── js/
│       ├── env-config.js
│       └── generate-config.js
├── backend/
│   ├── main.py
│   ├── requirements.txt
│   ├── .env.example
│   └── .env
├── database/
│   ├── neon_schema.sql
│   └── auth_migration.sql
├── docs/
└── README.md
```

## API Documentation

### Public Endpoints
- GET / - API health check
- GET /api/workflows - Retrieve all workflows
- GET /api/workflows/{id} - Retrieve specific workflow
- POST /api/payment/initialize - Initialize Paystack payment
- POST /api/payment/verify - Verify payment transaction
- POST /api/webhook/paystack - Paystack webhook handler

### Authentication Endpoints
- POST /api/auth/register - Register new user account
- POST /api/auth/login - Authenticate user and return JWT token
- GET /api/auth/me - Retrieve current user information (requires authentication)
- POST /api/auth/logout - Invalidate user session (requires authentication)

### Custom Request Endpoints
- POST /api/requests/submit - Submit custom workflow request
- GET /api/admin/requests - Retrieve all custom requests (admin only)
- PATCH /api/admin/requests/{id} - Update request status (admin only)

### Admin Endpoints
- POST /api/admin/login - Admin authentication
- GET /api/admin/stats - Dashboard statistics
- GET /api/admin/sales - Sales transaction history
- GET /api/admin/customers - Customer database

### Download Endpoints
- GET /api/download/workflow/{id} - Generate workflow download

Interactive API documentation available at http://localhost:8000/docs

## Payment Testing

### Paystack Test Cards
```
Card Number: 4084084084084081
CVV: 408
Expiry Date: Any future date
PIN: 0000
OTP: 123456
```

### Mobile Money Testing
Refer to Paystack documentation for test mobile money numbers in sandbox mode.

## Deployment

### Frontend Deployment (Vercel)

```bash
npm i -g vercel
vercel
```

### Frontend Deployment (Netlify)

```bash
npm i -g netlify-cli
netlify deploy
```

Alternatively, use the Netlify web interface for drag-and-drop deployment.

### Backend Deployment (Railway)

1. Connect GitHub repository
2. Configure backend folder as root directory
3. Add environment variables
4. Deploy automatically on push

### Backend Deployment (Render)

1. Create new Web Service
2. Connect repository
3. Build command: pip install -r requirements.txt
4. Start command: uvicorn main:app --host 0.0.0.0 --port $PORT
5. Configure environment variables
6. Deploy

## Configuration

### Pricing Customization

Modify pricing in index.html and backend/.env:

```env
SINGLE_WORKFLOW_PRICE=149
ALL_ACCESS_PRICE=799
```

### Workflow Management

Edit workflow catalog in index.html and backend/main.py workflows array.

### Branding Customization

Update company information throughout the codebase:
- Company Name: VexaAI
- Founder: John Evans Okyere
- Email: johnevansokyere@gmail.com
- Phone: +233544954643

### Styling Modifications

Gradient colors defined in CSS:

```css
.gradient-bg {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
```

## Troubleshooting

### Payment Integration Issues
- Verify correct Paystack API keys (test vs live environment)
- Check browser console for JavaScript errors
- Confirm backend server is running
- Test with Paystack provided test cards

### Database Connection Errors
- Verify DATABASE_URL format and credentials
- Ensure database schema is properly initialized
- Check network connectivity to Neon
- Verify SSL mode configuration

### CORS Configuration
- Update allowed origins in backend/main.py CORSMiddleware
- Add production domain to allowed origins list
- Verify API_URL in frontend configuration

### Authentication Problems
- Verify SECRET_KEY is set in environment variables
- Check JWT token expiration settings
- Clear browser localStorage and retry
- Verify bcrypt is properly installed

## Security Considerations

1. Never commit .env files to version control
2. Change default admin credentials in production
3. Use environment variables for all sensitive configuration
4. Enable row-level security policies in database
5. Validate Paystack webhook signatures
6. Use HTTPS in production for all endpoints
7. Implement rate limiting on authentication endpoints
8. Regularly update dependencies for security patches

## Development Roadmap

- Email notification system (SendGrid/Mailgun integration)
- Automatic Notion workspace provisioning
- WhatsApp group automation for All Access members
- Workflow preview videos and demos
- Customer review and rating system
- Affiliate marketing program
- Coupon and discount code system
- Subscription billing for All Access tier
- Multi-currency support
- Enhanced admin analytics dashboard

## License

This project is created for VexaAI by John Evans Okyere.

## Contact Information

Founder: John Evans Okyere
Email: johnevansokyere@gmail.com
Phone: +233 54 495 4643
Location: Accra, Ghana

## Support

For technical support or inquiries:
- Email: johnevansokyere@gmail.com
- WhatsApp: +233544954643

## Acknowledgments

- Tailwind CSS for the utility-first CSS framework
- Paystack for payment processing infrastructure
- FastAPI for the modern Python web framework
- Neon for serverless PostgreSQL database

---

Made in Ghana by VexaAI
