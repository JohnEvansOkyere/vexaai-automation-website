# VexaAI - Premium n8n Workflows Sales Platform

A stunning, modern, and fully functional e-commerce website for selling premium n8n automation workflows. Built with pure HTML, Tailwind CSS, vanilla JavaScript, FastAPI backend, and Supabase database.

## 🚀 Features

### Frontend
- ✨ **Beautiful Modern Design**: Glassmorphism cards, smooth animations, gradient backgrounds
- 📱 **Fully Responsive**: Mobile-first design that looks great on all devices
- 💳 **Paystack Integration**: Support for Mobile Money (MTN, Vodafone, AirtelTigo) and Cards (Visa/Mastercard)
- 🎯 **Two Purchase Options**:
  - Single Workflow Access (GHS 149)
  - All Access Pass (GHS 799) - Most Popular
- ✅ **Success Page**: Automatic redirect with download links and access information
- 🎨 **Dark Mode Friendly**: Default light mode with beautiful color schemes
- 🔍 **Searchable Workflow Modal**: Easy workflow selection with search functionality
- 📊 **Social Proof**: Testimonials, trust indicators, and customer avatars
- ❓ **FAQ Section**: Accordion-style frequently asked questions

### Backend (FastAPI)
- 🔐 **Secure Payment Processing**: Paystack integration with webhook support
- 📊 **RESTful API**: Clean, documented API endpoints
- 💾 **Database Integration**: Supabase for persistent data storage
- 🔑 **Admin Authentication**: Secure admin dashboard access
- 📈 **Analytics & Reporting**: Sales tracking and customer insights

### Admin Dashboard
- 📊 **Real-time Statistics**: Revenue, sales, customers, conversion rates
- 📈 **Beautiful Charts**: Revenue trends and sales distribution (Chart.js)
- 👥 **Customer Management**: View and manage customer data
- 🛒 **Sales Tracking**: Monitor all transactions and payment details
- 🔧 **Workflow Management**: Add, edit, and track workflow performance
- ⚙️ **Settings Panel**: Configure Paystack, Supabase, Notion, and pricing
- 🎨 **Modern UI**: Gradient sidebar, glassmorphism cards, responsive design

### Database (Supabase)
- 📦 **Complete Schema**: Customers, sales, workflows, downloads, admin users
- 🔒 **Row Level Security**: Secure data access policies
- 🔄 **Automated Triggers**: Auto-update timestamps
- 📊 **Useful Views**: Dashboard stats, popular workflows
- 🎯 **Stored Functions**: Simplified sale recording and processing

## 🛠️ Tech Stack

- **Frontend**: HTML5, Tailwind CSS (CDN), Vanilla JavaScript
- **Backend**: Python 3.9+, FastAPI
- **Database**: Supabase (PostgreSQL)
- **Payment**: Paystack (Mobile Money + Card)
- **Charts**: Chart.js
- **Hosting**: Can be deployed to Vercel, Netlify, or any static host

## 📋 Prerequisites

- Python 3.9 or higher
- Supabase account (free tier works)
- Paystack account (for payment processing)
- Node.js (optional, for local development server)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
cd /path/to/Automation-Website
```

### 2. Set Up Backend

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/Mac:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy environment file
cp .env.example .env

# Edit .env with your credentials
nano .env  # or use your preferred editor
```

### 3. Configure Environment Variables

Edit `backend/.env` and add your credentials:

```env
# Paystack Configuration
PAYSTACK_PUBLIC_KEY=pk_test_your_public_key
PAYSTACK_SECRET_KEY=sk_test_your_secret_key

# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_supabase_anon_key

# Admin Credentials
ADMIN_EMAIL=johnevansokyere@gmail.com
ADMIN_PASSWORD=admin123

# Frontend URL
FRONTEND_URL=http://localhost:8000

# Notion Integration
NOTION_LIBRARY_URL=https://notion.so/your-private-library
```

### 4. Set Up Supabase Database

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Create a new project or select existing one
3. Navigate to SQL Editor
4. Copy the contents of `supabase_schema.sql`
5. Paste and run the SQL script
6. Verify tables are created in the Table Editor

### 5. Update Frontend with Your Paystack Key

Edit `index.html` line 563 and replace the Paystack public key:

```javascript
key: 'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxx', // Replace with your actual key
```

### 6. Run the Backend Server

```bash
# From backend directory
python main.py

# Or using uvicorn directly
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

### 7. Serve the Frontend

You can use any static file server. Here are some options:

**Option A: Python HTTP Server**
```bash
# From root directory
python -m http.server 3000
```

**Option B: Node.js HTTP Server**
```bash
npx http-server -p 3000
```

**Option C: VS Code Live Server**
- Install "Live Server" extension
- Right-click `index.html` and select "Open with Live Server"

Visit `http://localhost:3000` in your browser.

## 📁 Project Structure

```
Automation-Website/
├── index.html              # Main landing page
├── success.html            # Payment success page
├── admin.html              # Admin dashboard
├── supabase_schema.sql     # Database schema
├── README.md               # This file
└── backend/
    ├── main.py             # FastAPI application
    ├── requirements.txt    # Python dependencies
    ├── .env.example        # Environment variables template
    └── .env                # Your actual environment variables (gitignored)
```

## 🔑 Getting API Keys

### Paystack
1. Sign up at [Paystack](https://paystack.com/)
2. Go to Settings → API Keys & Webhooks
3. Copy your Test Public Key and Test Secret Key
4. For production, copy your Live keys

### Supabase
1. Sign up at [Supabase](https://supabase.com/)
2. Create a new project
3. Go to Project Settings → API
4. Copy the Project URL and `anon/public` key

## 💳 Payment Testing

### Test Cards (Paystack)
```
Card Number: 4084084084084081
CVV: 408
Expiry: Any future date
PIN: 0000
OTP: 123456
```

### Test Mobile Money
Use the test numbers provided by Paystack in test mode.

## 🔐 Admin Dashboard Access

**Default Credentials:**
- Email: `johnevansokyere@gmail.com`
- Password: `admin123`

**⚠️ IMPORTANT**: Change these credentials in production!

Access the admin dashboard at: `http://localhost:3000/admin.html`

## 🎨 Customization

### Update Pricing
Edit these values in `index.html`:
- Single Workflow: Line 254 (GHS 149)
- All Access Pass: Line 281 (GHS 799)

Also update in `backend/.env`:
```env
SINGLE_WORKFLOW_PRICE=149
ALL_ACCESS_PRICE=799
```

### Add More Workflows
Edit the `workflows` array in `index.html` (line 566) and `backend/main.py` (line 70).

### Change Company Information
- Company Name: VexaAI (search and replace)
- Founder: John Evans Okyere
- Email: johnevansokyere@gmail.com
- Phone: +233544954643

### Update Colors and Styling
The gradient colors are defined in the `<style>` section:
```css
.gradient-bg {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
```

## 🚀 Deployment

### Deploy Frontend (Vercel/Netlify)

**Vercel:**
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

**Netlify:**
```bash
# Install Netlify CLI
npm i -g netlify-cli

# Deploy
netlify deploy
```

Or simply drag and drop the frontend files in the Netlify dashboard.

### Deploy Backend (Railway/Render/Heroku)

**Railway:**
1. Connect your GitHub repository
2. Select the `backend` folder as root
3. Add environment variables
4. Deploy automatically

**Render:**
1. Create new Web Service
2. Connect repository
3. Set build command: `pip install -r requirements.txt`
4. Set start command: `uvicorn main:app --host 0.0.0.0 --port $PORT`
5. Add environment variables
6. Deploy

### Update Frontend URL
After deploying backend, update `FRONTEND_URL` in backend `.env` and update API endpoints in frontend files.

## 📊 API Endpoints

### Public Endpoints
- `GET /` - Health check
- `GET /api/workflows` - Get all workflows
- `GET /api/workflows/{id}` - Get specific workflow
- `POST /api/payment/initialize` - Initialize payment
- `POST /api/payment/verify` - Verify payment
- `POST /api/webhook/paystack` - Paystack webhook

### Admin Endpoints
- `POST /api/admin/login` - Admin login
- `GET /api/admin/stats` - Dashboard statistics
- `GET /api/admin/sales` - All sales
- `GET /api/admin/customers` - All customers

### Download Endpoints
- `GET /api/download/workflow/{id}` - Download workflow

Full API documentation available at: `http://localhost:8000/docs` (Swagger UI)

## 🔧 Troubleshooting

### Payment Not Working
- Verify Paystack keys are correct (test vs live)
- Check browser console for errors
- Ensure backend is running
- Test with Paystack test cards

### Database Connection Failed
- Verify Supabase URL and key
- Check if database schema is properly set up
- Ensure RLS policies are configured

### CORS Errors
- Update CORS settings in `backend/main.py`
- Add your frontend domain to allowed origins

### Admin Dashboard Not Loading
- Check admin credentials
- Ensure backend is running
- Check browser console for errors

## 🎯 Features to Add (Optional Enhancements)

- [ ] Email notifications after purchase (SendGrid/Mailgun)
- [ ] Automatic Notion access provisioning
- [ ] WhatsApp group auto-invite
- [ ] Workflow preview videos
- [ ] Customer reviews and ratings
- [ ] Affiliate program
- [ ] Discount codes/coupons
- [ ] Subscription model for All Access
- [ ] Multi-currency support
- [ ] Custom workflow request form

## 📝 License

This project is created for **VexaAI** by John Evans Okyere.

## 👨‍💻 Contact & Support

**Founder:** John Evans Okyere
**Email:** johnevansokyere@gmail.com
**Phone:** +233 54 495 4643
**Location:** Accra, Ghana 🇬🇭

---

**Need Help?**
- Check the [FAQ section](#-troubleshooting)
- Email: johnevansokyere@gmail.com
- WhatsApp: +233544954643

## 🙏 Acknowledgments

- Tailwind CSS for the amazing utility-first CSS framework
- Paystack for seamless payment processing in Ghana
- Supabase for the powerful backend infrastructure
- FastAPI for the modern Python web framework

---

**Made with ❤️ in Ghana by VexaAI**

## 🚨 Important Security Notes

1. **Never commit `.env` file** - It's already in `.gitignore`
2. **Change default admin password** immediately in production
3. **Use environment variables** for all sensitive data
4. **Enable RLS policies** in Supabase for data security
5. **Verify Paystack webhooks** using signature validation
6. **Use HTTPS** in production for all endpoints
7. **Implement rate limiting** on payment endpoints
8. **Hash admin passwords** using bcrypt (update in production)

## 📈 Next Steps

1. ✅ Set up Paystack account and get API keys
2. ✅ Create Supabase project and run schema
3. ✅ Test payment flow with test cards
4. ✅ Customize branding and colors
5. ✅ Add your actual n8n workflow JSON files
6. ✅ Set up Notion library for All Access members
7. ✅ Configure email notifications
8. ✅ Test on mobile devices
9. ✅ Deploy to production
10. ✅ Launch and start selling! 🚀

---

**Happy Selling! 💰**
