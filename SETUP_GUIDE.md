# 🚀 VexaAI Quick Setup Guide

This guide will help you get your VexaAI workflow sales platform up and running in minutes.

## ⚡ 5-Minute Setup

### Step 1: Get Paystack Keys (2 minutes)

1. Visit [https://paystack.com/signup](https://paystack.com/signup)
2. Sign up with your business email
3. Verify your email and phone number
4. Go to **Settings** → **API Keys & Webhooks**
5. Copy these two keys:
   - **Test Public Key** (starts with `pk_test_`)
   - **Test Secret Key** (starts with `sk_test_`)
6. Keep them safe - you'll need them in Step 3

**💡 Tip:** Start with test keys. You can switch to live keys later after KYC verification.

### Step 2: Set Up Supabase Database (2 minutes)

1. Visit [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Sign in with GitHub (easiest)
3. Click **New Project**
4. Fill in:
   - **Name:** VexaAI-Workflows
   - **Database Password:** Choose a strong password (save it!)
   - **Region:** Choose closest to Ghana (e.g., Frankfurt)
5. Wait 2 minutes for setup
6. Click **SQL Editor** (left sidebar)
7. Click **New Query**
8. Copy ALL contents from `supabase_schema.sql` file
9. Paste and click **Run**
10. You should see "Success. No rows returned"
11. Go to **Project Settings** → **API**
12. Copy these two values:
    - **Project URL** (e.g., `https://xxxxx.supabase.co`)
    - **anon/public key** (long string starting with `eyJ...`)

### Step 3: Configure Your Backend (1 minute)

1. Open terminal in the project folder
2. Navigate to backend:
   ```bash
   cd backend
   ```
3. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
4. Edit `.env` file and paste your keys:
   ```bash
   nano .env  # or use VS Code, gedit, etc.
   ```
5. Update these values:
   ```env
   PAYSTACK_PUBLIC_KEY=pk_test_YOUR_KEY_HERE
   PAYSTACK_SECRET_KEY=sk_test_YOUR_SECRET_KEY_HERE
   SUPABASE_URL=https://xxxxx.supabase.co
   SUPABASE_KEY=eyJxxxxx_YOUR_KEY_HERE
   ```
6. Save and close (Ctrl+X, then Y, then Enter if using nano)

### Step 4: Update Frontend

1. Open `index.html` in a text editor
2. Press Ctrl+F and search for: `pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxx`
3. Replace it with your actual Paystack **Public Key** from Step 1
4. Save the file

### Step 5: Install & Run (Ready to test!)

**Terminal 1 - Start Backend:**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

**Terminal 2 - Start Frontend:**
```bash
# Open a new terminal in the project root
python -m http.server 3000
```

You should see:
```
Serving HTTP on 0.0.0.0 port 3000
```

### Step 6: Test Your Site! 🎉

1. Open browser: [http://localhost:3000](http://localhost:3000)
2. Click "Get All Access Now"
3. Use test card details:
   - **Card:** 4084 0840 8408 4081
   - **CVV:** 408
   - **Expiry:** 12/25 (any future date)
   - **PIN:** 0000
   - **OTP:** 123456
4. You should be redirected to success page! 🎉

### Step 7: Access Admin Dashboard

1. Visit: [http://localhost:3000/admin.html](http://localhost:3000/admin.html)
2. Login with:
   - **Email:** johnevansokyere@gmail.com
   - **Password:** admin123
3. See your test sale in the dashboard!

---

## 🎨 Customization Checklist

After setup works, customize these:

### Your Information
- [ ] Update company name (search "VexaAI" and replace)
- [ ] Update founder name (search "John Evans Okyere")
- [ ] Update email (search "johnevansokyere@gmail.com")
- [ ] Update phone (search "+233544954643")
- [ ] Add your Ghana flag if needed

### Pricing
- [ ] Update Single Workflow price in `index.html` (search "GHS 149")
- [ ] Update All Access price in `index.html` (search "GHS 799")
- [ ] Update prices in `backend/.env`

### Workflows
- [ ] Add your actual workflow names in `index.html` (line ~566)
- [ ] Add workflow JSON files
- [ ] Update workflow descriptions

### Notion Integration
- [ ] Create private Notion workspace
- [ ] Upload all workflow JSON files
- [ ] Get shareable link
- [ ] Update link in `success.html` (search "notion.so")

### WhatsApp
- [ ] Create WhatsApp group for All Access members
- [ ] Get group invite link
- [ ] Update in `success.html`

---

## 🚀 Going Live Checklist

Ready to accept real payments? Follow this:

### 1. Paystack Live Keys
- [ ] Complete Paystack KYC verification
- [ ] Submit business documents
- [ ] Wait for approval (1-3 days)
- [ ] Copy **Live Public Key** and **Live Secret Key**
- [ ] Update in `backend/.env`
- [ ] Update in `index.html`

### 2. Security
- [ ] Change admin password in `backend/.env`
- [ ] Use strong password (20+ characters)
- [ ] Enable 2FA on Supabase
- [ ] Enable 2FA on Paystack
- [ ] Review Supabase RLS policies

### 3. Deploy Backend
Choose one platform:

**Option A: Railway (Easiest)**
1. Visit [railway.app](https://railway.app)
2. Sign in with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repository
5. Set root directory: `/backend`
6. Add environment variables from `.env`
7. Deploy!

**Option B: Render**
1. Visit [render.com](https://render.com)
2. Click "New" → "Web Service"
3. Connect GitHub repo
4. Settings:
   - **Root Directory:** `backend`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`
5. Add environment variables
6. Deploy!

### 4. Deploy Frontend
Choose one platform:

**Option A: Vercel (Recommended)**
```bash
npm install -g vercel
vercel
```

**Option B: Netlify**
1. Visit [netlify.com](https://netlify.com)
2. Drag and drop your folder
3. Done!

### 5. Update URLs
- [ ] Update `FRONTEND_URL` in backend `.env` with your Vercel URL
- [ ] Update API endpoints in frontend if needed
- [ ] Test payment flow on live site

### 6. Test Everything
- [ ] Test with small real payment (GHS 1)
- [ ] Verify payment success
- [ ] Check admin dashboard shows sale
- [ ] Test workflow download
- [ ] Test on mobile device
- [ ] Test with different browsers

---

## 🆘 Common Issues

### "Payment Failed" Error
**Solution:**
- Verify Paystack keys are correct
- Ensure you're using test card in test mode
- Check browser console for errors
- Verify backend is running

### Database Connection Error
**Solution:**
- Check Supabase URL and key
- Verify schema was run successfully
- Check if project is active (not paused)

### CORS Error
**Solution:**
- Add your domain to allowed origins in `backend/main.py`
- Restart backend server

### Admin Dashboard Won't Load
**Solution:**
- Check credentials (default: johnevansokyere@gmail.com / admin123)
- Clear browser cache
- Check if backend is running

### Mobile Money Not Working in Test Mode
**Solution:**
- Mobile Money is only available in LIVE mode
- Use test card for testing
- Switch to live keys when ready

---

## 📞 Need Help?

**Contact:**
- Email: johnevansokyere@gmail.com
- WhatsApp: +233 54 495 4643

**Resources:**
- [Paystack Documentation](https://paystack.com/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com)

---

## 🎯 What's Next?

After going live, consider:

1. **Marketing:**
   - Create social media accounts
   - Share testimonials
   - Run targeted ads

2. **Content:**
   - Create workflow preview videos
   - Write blog posts about automation
   - Share use cases

3. **Growth:**
   - Add affiliate program
   - Create bundle deals
   - Offer seasonal discounts

4. **Features:**
   - Email automation
   - Customer reviews
   - Workflow ratings
   - Video tutorials

---

**Made with ❤️ in Ghana 🇬🇭**

Good luck with your sales! 🚀💰
