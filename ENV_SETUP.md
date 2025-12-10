# 🔐 Environment Variables Setup Guide

## Why Use Environment Variables?

You're absolutely right to be concerned about security! Here's why we use environment variables:

### ✅ **What's Safe**
- **Paystack PUBLIC key** - Designed to be used in frontend (client-side)
- It's called "public" because it's meant to be visible in browser
- Cannot be used to steal money or access sensitive data
- Only allows initiating payments (verification happens on backend)

### ❌ **What's NEVER Safe**
- **Paystack SECRET key** - Must ONLY be in backend
- Database credentials
- API secret tokens
- Private keys

## 🎯 **Our Solution: Environment-Based Configuration**

We've created a system that keeps your configuration out of Git while making it easy to deploy.

---

## 📁 **File Structure**

```
Automation-Website/
├── .env                    # Your actual secrets (NOT in Git)
├── .env.example            # Template (safe to commit)
├── env-config.js           # Generated config (NOT in Git)
├── generate-config.js      # Generator script
├── backend/
│   ├── .env                # Backend secrets (NOT in Git)
│   └── .env.example        # Backend template
```

---

## ⚙️ **Setup Steps**

### 1. Create Your .env File

```bash
# Copy the example file
cp .env.example .env

# Edit with your actual values
nano .env  # or code .env
```

### 2. Fill In Your Values

```env
# Frontend Environment Variables

# Paystack Public Key (get from paystack.com/signup)
VITE_PAYSTACK_PUBLIC_KEY=pk_test_your_actual_key_here

# Backend API URL
VITE_API_URL=http://localhost:8000

# Notion Library URL (for All Access members)
VITE_NOTION_LIBRARY_URL=https://notion.so/your-actual-library

# WhatsApp Support Number
VITE_WHATSAPP_NUMBER=233544954643

# Admin Login (for development)
VITE_ADMIN_EMAIL=johnevansokyere@gmail.com
```

### 3. Generate Config File

```bash
# Generate env-config.js from .env
node generate-config.js
```

You should see:
```
✅ Generated env-config.js successfully!
📄 Configuration:
   Paystack Key: pk_test_abc123...
   API URL: http://localhost:8000
   Notion URL: https://notion.so/...
```

### 4. Include in HTML

Add this line to your HTML files (already done in updated files):

```html
<head>
    <!-- Load environment config FIRST -->
    <script src="env-config.js"></script>

    <!-- Then your other scripts -->
    <script src="https://cdn.tailwindcss.com"></script>
    ...
</head>
```

### 5. Use in JavaScript

```javascript
// Access config anywhere in your code
const paystackKey = window.ENV.PAYSTACK_PUBLIC_KEY;
const apiUrl = window.ENV.API_URL;
const notionUrl = window.ENV.NOTION_LIBRARY_URL;

// Example: Initialize Paystack
const handler = PaystackPop.setup({
    key: window.ENV.PAYSTACK_PUBLIC_KEY,  // From env
    email: email,
    amount: amount,
    // ...
});
```

---

## 🚀 **Development Workflow**

### Start Development

```bash
# Option 1: Using npm (auto-generates config)
npm run dev

# Option 2: Manual
node generate-config.js
python -m http.server 3000
```

### Update Configuration

```bash
# 1. Edit .env file
nano .env

# 2. Regenerate config
node generate-config.js

# 3. Reload browser (config is automatically updated)
```

---

## 🌐 **Production Deployment**

### Vercel/Netlify

**Option 1: Environment Variables (Recommended)**

1. Go to your project settings
2. Add environment variables:
   ```
   VITE_PAYSTACK_PUBLIC_KEY=pk_live_your_live_key
   VITE_API_URL=https://your-api.railway.app
   VITE_NOTION_LIBRARY_URL=https://notion.so/your-library
   ```

3. Add build command:
   ```bash
   node generate-config.js
   ```

4. Vercel/Netlify will auto-inject these into `env-config.js`

**Option 2: Manual (Quick)**

1. Create `.env` with production values
2. Run `node generate-config.js`
3. Deploy (env-config.js will be included)

---

## 🔒 **Security Best Practices**

### ✅ DO

- ✅ Use environment variables for all configuration
- ✅ Keep `.env` files out of Git (already in `.gitignore`)
- ✅ Use different keys for development and production
- ✅ Commit `.env.example` as a template
- ✅ Use `pk_test_*` keys for testing
- ✅ Use `pk_live_*` keys only in production

### ❌ DON'T

- ❌ Commit `.env` files to Git
- ❌ Commit `env-config.js` to Git
- ❌ Put SECRET keys in frontend
- ❌ Share your `.env` file with anyone
- ❌ Use live keys in development

---

## 📝 **Files Explanation**

### `.env.example`
- Template showing what variables are needed
- Safe to commit to Git
- Copy this to create your `.env`

### `.env`
- Your actual configuration
- **NEVER commit to Git**
- Different for each environment (dev/prod)

### `generate-config.js`
- Reads `.env` file
- Generates `env-config.js`
- Safe to commit to Git

### `env-config.js`
- Auto-generated from `.env`
- Contains actual values
- **NEVER commit to Git**
- Loaded in browser

---

## 🆘 **Troubleshooting**

### "Cannot find module 'fs'"

You need Node.js installed:
```bash
# Install Node.js (if not installed)
# Then run:
node generate-config.js
```

### ".env file not found"

```bash
# Create from example
cp .env.example .env

# Edit with your values
nano .env
```

### "Config not loading in browser"

1. Check if `env-config.js` exists
2. Check if it's included in HTML:
   ```html
   <script src="env-config.js"></script>
   ```
3. Check browser console for errors
4. Regenerate:
   ```bash
   node generate-config.js
   ```

### "Paystack key still hardcoded"

After generating config, update your HTML to use `window.ENV`:

```javascript
// Old (hardcoded)
key: 'pk_test_xxxxxxxxxx',

// New (from env)
key: window.ENV.PAYSTACK_PUBLIC_KEY,
```

---

## 📊 **Configuration Reference**

| Variable | Example | Required | Description |
|----------|---------|----------|-------------|
| `VITE_PAYSTACK_PUBLIC_KEY` | `pk_test_abc...` | ✅ Yes | Paystack public key |
| `VITE_API_URL` | `http://localhost:8000` | ✅ Yes | Backend API URL |
| `VITE_NOTION_LIBRARY_URL` | `https://notion.so/lib` | No | Notion library |
| `VITE_WHATSAPP_NUMBER` | `233544954643` | No | Support number |
| `VITE_ADMIN_EMAIL` | `your@email.com` | No | Admin email |
| `VITE_SINGLE_WORKFLOW_PRICE` | `149` | No | Single price (GHS) |
| `VITE_ALL_ACCESS_PRICE` | `799` | No | All access price (GHS) |

---

## 🎯 **Quick Commands**

```bash
# Setup
cp .env.example .env
nano .env

# Generate config
node generate-config.js

# Start development
npm run dev

# Check config
cat env-config.js

# Clean up (if needed)
rm env-config.js
```

---

## ✅ **Verification Checklist**

- [ ] `.env` file created and filled
- [ ] `backend/.env` file created and filled
- [ ] `env-config.js` generated successfully
- [ ] `.gitignore` includes `.env` and `env-config.js`
- [ ] HTML files include `<script src="env-config.js"></script>`
- [ ] JavaScript uses `window.ENV.PAYSTACK_PUBLIC_KEY`
- [ ] Test keys work in development
- [ ] Ready to deploy with production keys

---

## 📞 **Still Have Questions?**

This approach:
- ✅ Keeps secrets out of Git
- ✅ Makes deployment easy
- ✅ Works with all hosting platforms
- ✅ Separates dev and production config
- ✅ Industry-standard practice

**Note:** Paystack PUBLIC keys are DESIGNED to be visible in the browser. The real security is in your backend verification using the SECRET key (which is never exposed).

---

**Made with ❤️ for VexaAI | Secure by Design**
