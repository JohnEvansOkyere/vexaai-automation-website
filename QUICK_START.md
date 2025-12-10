# ⚡ VexaAI - Quick Start Cheat Sheet

**Get your workflow sales platform running in 5 minutes!**

---

## 🎯 What You Built

A complete, production-ready e-commerce platform for selling n8n workflows with:
- 💳 Paystack payment (Mobile Money + Cards)
- 💾 Supabase database
- 🔧 FastAPI backend
- 🎨 Beautiful modern frontend
- 📊 Admin dashboard with analytics

---

## 🚀 Super Quick Start (Copy & Paste)

### 1️⃣ Get API Keys (2 minutes)

**Paystack** → [paystack.com/signup](https://paystack.com/signup)
```
Get these:
✓ Test Public Key:  pk_test_...
✓ Test Secret Key:  sk_test_...
```

**Supabase** → [supabase.com/dashboard](https://supabase.com/dashboard)
```
1. Create New Project
2. Run SQL Editor → paste supabase_schema.sql
3. Get these from Settings → API:
   ✓ Project URL
   ✓ anon/public key
```

### 2️⃣ Configure (1 minute)

```bash
# Create environment file
cd backend
cp .env.example .env
nano .env  # or code .env
```

**Paste your keys:**
```env
PAYSTACK_PUBLIC_KEY=pk_test_YOUR_KEY
PAYSTACK_SECRET_KEY=sk_test_YOUR_KEY
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_KEY=eyJ...YOUR_KEY
```

### 3️⃣ Update Frontend (30 seconds)

Open `index.html`, find line ~563, replace:
```javascript
key: 'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxx',
```
with:
```javascript
key: 'pk_test_YOUR_ACTUAL_KEY',
```

### 4️⃣ Run (1 command)

**Linux/Mac:**
```bash
./start.sh
```

**Windows:**
```cmd
start.bat
```

**Manual:**
```bash
# Terminal 1 - Backend
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py

# Terminal 2 - Frontend
python -m http.server 3000
```

### 5️⃣ Access

```
🌐 Website:     http://localhost:3000
🎛️  Dashboard:   http://localhost:3000/admin.html
📊 API Docs:    http://localhost:8000/docs
```

---

## 💳 Test Payment

**Test Card:**
```
Card:   4084 0840 8408 4081
CVV:    408
Expiry: 12/25
PIN:    0000
OTP:    123456
```

**Test Flow:**
1. Visit http://localhost:3000
2. Click "Get All Access Now"
3. Enter email (any valid email)
4. Use test card above
5. Get redirected to success page! 🎉

---

## 🎛️ Admin Dashboard

**Login:**
```
Email:    johnevansokyere@gmail.com
Password: admin123
```

**What you'll see:**
- 📊 Revenue stats
- 📈 Sales charts
- 👥 Customer list
- 🔧 Workflow management
- ⚙️  Settings panel

---

## ✏️ Customize (5 minutes)

### Update Your Info

**Find & Replace in all files:**
```
VexaAI → Your Company Name
John Evans Okyere → Your Name
johnevansokyere@gmail.com → Your Email
+233544954643 → Your Phone
```

### Update Pricing

**In `index.html`:**
- Line ~254: Single price (GHS 149)
- Line ~281: All Access price (GHS 799)

**In `backend/.env`:**
```env
SINGLE_WORKFLOW_PRICE=149
ALL_ACCESS_PRICE=799
```

### Add Your Workflows

**Edit `index.html` line ~566:**
```javascript
const workflows = [
    { id: 1, name: "Your Workflow 1", category: "Category", icon: "📧" },
    { id: 2, name: "Your Workflow 2", category: "Category", icon: "💰" },
    // Add more...
];
```

**Also update in `backend/main.py` line ~70**

---

## 🚀 Deploy to Production

### Frontend → Vercel (2 minutes)

```bash
npm install -g vercel
vercel
# Follow prompts, done!
```

**Or use Netlify:** Drag & drop files to netlify.com

### Backend → Railway (3 minutes)

1. Visit [railway.app](https://railway.app)
2. New Project → Deploy from GitHub
3. Select `backend` folder
4. Add environment variables from `.env`
5. Deploy!

**Or use Render:** Similar process

### Update Production URLs

**In `backend/.env`:**
```env
FRONTEND_URL=https://your-site.vercel.app
```

**Switch to Live Paystack Keys:**
```env
PAYSTACK_PUBLIC_KEY=pk_live_...
PAYSTACK_SECRET_KEY=sk_live_...
```

**Update in `index.html`:**
- Line ~563: Use live public key

---

## 🎯 File Overview

```
📁 Your Project
├── index.html          → Main landing page
├── success.html        → Payment success page
├── admin.html          → Admin dashboard
├── supabase_schema.sql → Database setup
├── start.sh            → Quick start (Linux/Mac)
├── start.bat           → Quick start (Windows)
└── backend/
    ├── main.py         → FastAPI server
    ├── requirements.txt → Dependencies
    └── .env            → Your API keys
```

---

## 📚 Documentation Map

```
START HERE → SETUP_GUIDE.md (5-min setup)
             ↓
DETAILS    → README.md (full documentation)
             ↓
FEATURES   → FEATURES.md (what's included)
             ↓
STRUCTURE  → PROJECT_STRUCTURE.md (code overview)
```

---

## 🆘 Quick Fixes

### Payment Not Working
```bash
✓ Check Paystack keys are correct
✓ Verify backend is running (localhost:8000)
✓ Use test card in test mode
✓ Check browser console for errors
```

### Database Error
```bash
✓ Run supabase_schema.sql in SQL Editor
✓ Check Supabase URL and key
✓ Verify project is not paused
```

### Can't Login to Admin
```bash
✓ Default: johnevansokyere@gmail.com / admin123
✓ Check backend is running
✓ Clear browser cache
```

---

## 💡 Pro Tips

**Before Going Live:**
- [ ] Complete Paystack KYC (1-3 days)
- [ ] Test with small real payment (GHS 1)
- [ ] Change admin password
- [ ] Set up Notion library
- [ ] Create WhatsApp group
- [ ] Enable HTTPS
- [ ] Test on mobile

**Marketing:**
- Share on Twitter/X
- Post in n8n community
- Create demo videos
- Get testimonials
- Run ads on Google/Facebook

**Support:**
- Set up email automation
- Create FAQ page
- Join n8n Discord
- Monitor dashboard daily

---

## 📞 Support

**Creator:** John Evans Okyere
**Email:** johnevansokyere@gmail.com
**WhatsApp:** +233 54 495 4643
**Location:** Ghana 🇬🇭

---

## 🎉 Success Checklist

- [ ] Site running locally
- [ ] Test payment successful
- [ ] Admin dashboard accessible
- [ ] Database connected
- [ ] Your info updated
- [ ] Pricing configured
- [ ] Workflows added
- [ ] Deployed to production
- [ ] Live payment tested
- [ ] First sale! 💰

---

**You're ready to start selling! 🚀**

**Next Step:** Read [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions.

---

Made with ❤️ in Ghana | VexaAI
