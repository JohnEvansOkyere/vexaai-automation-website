# Authentication & Custom Request System Setup Guide

This document explains the new authentication and custom workflow request features added to the VexaAI platform.

## 🔐 Authentication System

### Overview
Users must now sign up and log in before they can purchase workflows. This provides better tracking, customer management, and security.

### Features Implemented

#### 1. User Registration
- Users can create accounts with:
  - Email address (unique)
  - Password (minimum 8 characters, bcrypt hashed)
  - First name & last name
  - Phone number (optional)
- Passwords are securely hashed using bcrypt before storage
- Email validation ensures proper format

#### 2. User Login
- JWT (JSON Web Token) based authentication
- Tokens expire after 24 hours (configurable)
- Secure password verification
- Auto-login on return visits using localStorage

#### 3. Protected Purchase Flow
- Purchase buttons now check for authentication
- Unauthenticated users are redirected to [auth.html](public/auth.html)
- After login, users return to their intended page
- Email is automatically filled from user session

#### 4. Session Management
- Tokens stored in browser localStorage
- User data cached for quick access
- Logout clears all session data
- Navigation shows user name when logged in

### Files Modified/Created

**Frontend:**
- `public/auth.html` - Sign up/login page with tabbed interface
- `public/index.html` - Updated with auth buttons and protected purchase flow
- Navigation now shows:
  - "Sign In" and "Sign Up" buttons (logged out)
  - User name and "Logout" button (logged in)

**Backend:**
- `backend/main.py` - Added authentication routes:
  - `POST /api/auth/register` - Create new user
  - `POST /api/auth/login` - Login and get JWT token
  - `GET /api/auth/me` - Get current user info
  - `POST /api/auth/logout` - Logout user
- JWT token generation and verification
- Password hashing with bcrypt
- Bearer token authentication middleware

**Database:**
- `database/auth_migration.sql` - New tables:
  - `users` - User accounts with hashed passwords
  - `user_sessions` - Active JWT sessions
  - Functions for user stats and session cleanup

### Testing Authentication

1. **Start the backend:**
```bash
cd backend
source venv/bin/activate
python main.py
```

2. **Open the frontend:**
```bash
# In browser, go to:
http://localhost:8000/public/index.html
```

3. **Test Registration:**
- Click "Sign Up" in navigation
- Fill in the form (password min 8 chars)
- Submit and verify success message

4. **Test Login:**
- Switch to "Sign In" tab
- Enter email and password
- Verify you're redirected and logged in
- Check navigation shows your name

5. **Test Protected Purchase:**
- Logout if logged in
- Try to click "Buy Single Workflow"
- Verify redirect to auth page
- Login and verify redirect back

### Security Features

- **Password Hashing**: Bcrypt with salt rounds
- **JWT Tokens**: Signed with SECRET_KEY from .env
- **Token Expiry**: 24 hours (configurable via JWT_EXPIRY_HOURS)
- **HTTPOnly**: Tokens stored in localStorage (consider HTTPOnly cookies for production)
- **HTTPS**: Recommended for production deployment

### Configuration

Add these to `backend/.env`:
```env
SECRET_KEY=your_secret_key_change_this_in_production
JWT_EXPIRY_HOURS=24
```

## 📝 Custom Workflow Request System

### Overview
Users can now request custom automation solutions tailored to their specific needs. Requests are tracked and managed through the admin dashboard.

### Features Implemented

#### 1. Request Form
- Accessible from navigation: "Custom Request" link
- Located at: `public/request-workflow.html`
- Collects detailed information:
  - **Contact Info**: Name, email, phone, company
  - **Workflow Details**: Title, description, use case
  - **Project Specs**: Budget range, timeline, platforms, integrations

#### 2. Form Fields

**Contact Information:**
- Full Name (required)
- Email Address (required)
- Phone Number (optional)
- Company/Organization (optional)

**Workflow Details:**
- Workflow Title (required)
- Detailed Description (required)
- Use Case / Business Goal (optional)

**Project Specifications:**
- Budget Range: Dropdown with options (Under GHS 500 to Above GHS 5,000)
- Timeline: Dropdown (ASAP, 1-2 weeks, 2-4 weeks, etc.)
- Preferred Platforms: Checkboxes (n8n, Zapier, Make, Power Automate, Custom API)
- Integration Requirements: Text area for specific tools/APIs

#### 3. Request Management

**For Users:**
- Submit request via form
- Receive confirmation message
- Pre-filled contact info if logged in
- Visual success feedback with confetti

**For Admins:**
- View all requests: `GET /api/admin/requests`
- Update status: `PATCH /api/admin/requests/{id}`
- Status options: pending, reviewing, quoted, in_progress, completed, rejected
- Priority levels: low, normal, high, urgent
- Add admin notes and quotes

### Files Created

**Frontend:**
- `public/request-workflow.html` - Beautiful request form with:
  - 3-step layout (Contact → Workflow → Specs)
  - Platform checkboxes
  - Budget and timeline dropdowns
  - Success message with confetti
  - Pre-filled data for logged-in users

**Backend Routes:**
- `POST /api/requests/submit` - Submit new request
- `GET /api/admin/requests` - Get all requests (sorted by priority)
- `PATCH /api/admin/requests/{id}` - Update request status

**Database:**
- `database/auth_migration.sql` includes:
  - `custom_requests` table with all fields
  - Indexes for performance
  - Status and priority tracking
  - View: `custom_requests_overview` for admin

### Testing Custom Requests

1. **Access the form:**
```
http://localhost:8000/public/request-workflow.html
```

2. **Fill out the form:**
- Enter contact details
- Describe workflow needs
- Select budget and timeline
- Check preferred platforms

3. **Submit and verify:**
- Click "Submit Request"
- Check for success message
- Verify in backend logs

4. **Check admin dashboard:**
```bash
# In backend terminal, you'll see the request logged
```

### Request Flow

```
User fills form → Submit to API → Store in database → Email admin (TODO) → Admin reviews → Update status → Email user (TODO)
```

### Future Enhancements (TODO)

1. **Email Notifications:**
   - Send email to admin when request submitted
   - Send confirmation email to user
   - Send updates when status changes

2. **Admin Dashboard Integration:**
   - Add "Custom Requests" tab to admin.html
   - Display requests table with status colors
   - Quick actions (approve, quote, reject)
   - Inline status updates

3. **User Portal:**
   - Users can view their request history
   - Track request status
   - Receive quotes
   - Approve/reject quotes

## 🔧 Installation Steps

### 1. Install Dependencies
```bash
cd backend
source venv/bin/activate
pip install passlib[bcrypt] pyjwt
```

### 2. Run Database Migration
```sql
-- In your Neon database, run:
-- /database/auth_migration.sql
```

### 3. Configure Environment
```bash
# Add to backend/.env:
SECRET_KEY=your_random_secret_key_here
JWT_EXPIRY_HOURS=24
```

### 4. Generate Frontend Config
```bash
cd public/js
node generate-config.js
```

### 5. Start Backend
```bash
cd backend
python main.py
```

### 6. Test Everything
- Visit http://localhost:8000/public/index.html
- Test registration and login
- Test protected purchase flow
- Submit a custom request
- Check API docs: http://localhost:8000/docs

## 📊 Database Schema Updates

### New Tables

#### users
```sql
- id (UUID, primary key)
- email (unique, not null)
- password_hash (not null)
- first_name, last_name
- phone
- is_verified, is_active
- verification_token, reset_token
- last_login, login_count
- created_at, updated_at
```

#### user_sessions
```sql
- id (UUID, primary key)
- user_id (foreign key → users)
- token (unique JWT token)
- ip_address, user_agent
- expires_at
- is_active
- created_at
```

#### custom_requests
```sql
- id (UUID, primary key)
- user_id (foreign key → users, nullable)
- name, email, phone, company
- workflow_title, description, use_case
- budget_range, timeline
- preferred_platforms (array)
- integration_needs
- status (pending/reviewing/quoted/etc.)
- priority (low/normal/high/urgent)
- admin_notes, quote_amount
- response_email_sent, quote_sent_at
- created_at, updated_at, completed_at
```

## 🚀 API Documentation

### Authentication

**POST /api/auth/register**
```json
Request:
{
  "email": "user@example.com",
  "password": "securepass123",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+233544954643"
}

Response:
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

**POST /api/auth/login**
```json
Request:
{
  "email": "user@example.com",
  "password": "securepass123"
}

Response:
{
  "success": true,
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone": "+233544954643"
  }
}
```

**GET /api/auth/me**
```
Headers:
Authorization: Bearer {token}

Response:
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone": "+233544954643",
    "is_verified": false,
    "created_at": "2025-01-15T10:30:00Z"
  }
}
```

### Custom Requests

**POST /api/requests/submit**
```json
Request:
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+233544954643",
  "company": "Acme Inc",
  "workflow_title": "Customer Onboarding Automation",
  "description": "We need to automate our customer onboarding...",
  "use_case": "Reduce manual work and improve experience",
  "budget_range": "GHS 1,000 - 2,500",
  "timeline": "2-4 weeks",
  "preferred_platforms": ["n8n", "Zapier"],
  "integration_needs": "Salesforce, Slack, Google Sheets"
}

Response:
{
  "success": true,
  "message": "Custom workflow request submitted successfully",
  "request_id": "uuid",
  "request": {
    "id": "uuid",
    "workflow_title": "Customer Onboarding Automation",
    "status": "pending",
    "created_at": "2025-01-15T10:30:00Z"
  }
}
```

## 🎯 What's Next?

### Immediate Tasks
1. ✅ User authentication working
2. ✅ Custom request form working
3. ⏳ Connect to Neon database (currently in-memory)
4. ⏳ Add email notifications
5. ⏳ Update admin dashboard with requests tab

### Future Enhancements
- Email verification for new accounts
- Password reset functionality
- User dashboard to view purchase history
- Request status tracking for users
- Quote approval workflow
- WhatsApp integration for notifications

## 💡 Tips

### For Development
- Use test accounts for development
- Check browser console for errors
- Monitor backend logs
- Use Swagger docs: http://localhost:8000/docs

### For Production
- Change SECRET_KEY to strong random value
- Use HTTPS for all endpoints
- Implement rate limiting
- Add email verification
- Set up proper CORS origins
- Use HTTPOnly cookies for tokens
- Enable Neon database connection
- Set up email service (SendGrid/Mailgun)

## 🐛 Troubleshooting

**Problem: Login not working**
- Check JWT_SECRET in .env
- Verify password is minimum 8 characters
- Check browser console for errors
- Verify backend is running

**Problem: Can't submit request**
- Check API_URL in env-config.js
- Verify backend is running
- Check network tab for API errors
- Ensure CORS is configured

**Problem: User not staying logged in**
- Check localStorage in browser dev tools
- Verify JWT token is being saved
- Check token expiry time
- Clear browser cache and retry

---

**Made with ❤️ by VexaAI**
