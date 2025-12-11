# VexaAI Frontend

Professional, modular frontend architecture with clean separation of concerns.

## Project Structure

```
public/
├── css/                    # Stylesheets
│   ├── main.css           # Main styles and utilities
│   └── modal.css          # Modal component styles
│
├── js/                     # JavaScript modules
│   ├── app-config.js      # Application configuration
│   ├── app.js             # Main application entry point
│   │
│   ├── modules/           # Feature modules
│   │   ├── auth.js       # Authentication & session management
│   │   ├── modal.js      # Modal open/close functionality
│   │   ├── payment.js    # Payment processing (Paystack)
│   │   └── workflows.js  # Workflow management
│   │
│   └── utils/             # Utility functions
│       ├── api.js        # API client wrapper
│       └── storage.js    # LocalStorage wrapper
│
├── index.html             # Main landing page
├── admin.html             # Admin dashboard
├── auth.html              # Authentication page
│
└── assets/                # Static assets
    └── images/            # Images and icons
```

## Architecture

### Separation of Concerns

**HTML Files** - Structure only
- No inline styles
- No inline scripts
- Clean, semantic markup

**CSS Files** - Styling
- `main.css` - Global styles and utilities
- `modal.css` - Modal-specific styles
- Reusable classes

**JavaScript Modules** - Functionality
- Each module has single responsibility
- Clear dependencies
- Easy to test

## Modules

### Configuration (`app-config.js`)
Centralized configuration management.

```javascript
const AppConfig = {
    API_URL: 'http://localhost:8000',
    SINGLE_WORKFLOW_PRICE: 149,
    ALL_ACCESS_PRICE: 799,
    // ... other settings
};
```

### Utilities

#### API Client (`utils/api.js`)
Handles all HTTP requests.

```javascript
const api = new API(AppConfig.API_URL);

// GET request
await api.getWorkflows();

// POST request
await api.post('/api/auth/login', { email, password });
```

**Methods:**
- `get(endpoint)` - GET request
- `post(endpoint, data, token)` - POST request
- `getWorkflows()` - Fetch all workflows
- `getWorkflow(id)` - Fetch single workflow
- `initializePayment(data)` - Initialize Paystack payment
- `register(userData)` - User registration
- `login(credentials)` - User login

#### Storage Wrapper (`utils/storage.js`)
Safe localStorage operations.

```javascript
// Set item
Storage.set('key', value);

// Get item
const value = Storage.get('key', parse = false);

// Auth-specific
Storage.setAuthToken(token);
Storage.getAuthToken();
Storage.setUser(user);
Storage.getUser();
Storage.clearAuth();
```

### Feature Modules

#### Authentication (`modules/auth.js`)
User session management.

```javascript
AuthModule.checkSession();  // Check and display user state
AuthModule.logout();         // Logout user
AuthModule.init();           // Initialize on page load
```

#### Modal (`modules/modal.js`)
Modal management.

```javascript
ModalModule.open('modalId');   // Open modal
ModalModule.close('modalId');  // Close modal
ModalModule.initializeCloseHandlers();  // Setup close handlers
```

#### Workflows (`modules/workflows.js`)
Workflow operations.

```javascript
await WorkflowModule.fetchWorkflows();     // Fetch from API
WorkflowModule.loadWorkflowsIntoModal();   // Display in modal
WorkflowModule.selectWorkflow(id);         // Select workflow
WorkflowModule.filterWorkflows();          // Search/filter
const workflow = WorkflowModule.getSelectedWorkflow();
```

#### Payment (`modules/payment.js`)
Payment processing.

```javascript
// Single workflow payment
await PaymentModule.initializeSingleWorkflowPayment(workflow, email);

// All access payment
await PaymentModule.initializeAllAccessPayment(email);

// Custom request
await PaymentModule.submitCustomRequest(formData);
```

### Main Application (`app.js`)
Coordinates all modules and handles initialization.

```javascript
// Exposes global functions for onclick handlers
function openSingleWorkflowModal() { ... }
function proceedToSinglePayment() { ... }
function handleLogout() { ... }

// Initialize on page load
window.addEventListener('load', async () => {
    ModalModule.initializeCloseHandlers();
    AuthModule.init();
    await WorkflowModule.fetchWorkflows();
});
```

## Usage

### Include Scripts in HTML

```html
<!-- In <head> -->
<link rel="stylesheet" href="css/main.css">
<link rel="stylesheet" href="css/modal.css">

<!-- Before </body> -->
<script src="js/app-config.js"></script>
<script src="js/utils/storage.js"></script>
<script src="js/utils/api.js"></script>
<script src="js/modules/modal.js"></script>
<script src="js/modules/auth.js"></script>
<script src="js/modules/workflows.js"></script>
<script src="js/modules/payment.js"></script>
<script src="js/app.js"></script>
```

### HTML onclick Handlers

```html
<button onclick="openSingleWorkflowModal()">Buy Workflow</button>
<button onclick="handleLogout()">Logout</button>
<button onclick="proceedToSinglePayment()">Pay Now</button>
```

## Adding New Features

### Example: Add Newsletter Feature

**1. Create Module** (`js/modules/newsletter.js`):
```javascript
const NewsletterModule = {
    async subscribe(email) {
        const api = new API(AppConfig.API_URL);
        return await api.post('/api/newsletter/subscribe', { email });
    }
};
```

**2. Add to app.js**:
```javascript
async function subscribeNewsletter() {
    const email = document.getElementById('newsletterEmail').value;
    await NewsletterModule.subscribe(email);
}
```

**3. Include in HTML**:
```html
<script src="js/modules/newsletter.js"></script>
```

**4. Use in HTML**:
```html
<button onclick="subscribeNewsletter()">Subscribe</button>
```

## CSS Architecture

### Main Styles (`css/main.css`)
- Base styles
- Utility classes
- Gradient effects
- Animations
- Hover effects

### Modal Styles (`css/modal.css`)
- Modal overlay
- Modal content
- Modal header/body/footer
- Close button
- Responsive design

### Naming Convention
- `.gradient-bg` - Background gradients
- `.gradient-text` - Text gradients
- `.glass-card` - Glass morphism effect
- `.hover-lift` - Lift on hover
- `.animate-fade-in` - Fade in animation

## Configuration

### Environment Variables
Set in `js/env-config.js`:

```javascript
window.ENV = {
    API_URL: 'http://localhost:8000',
    PAYSTACK_PUBLIC_KEY: 'pk_test_xxx'
};
```

### App Configuration
Edit `js/app-config.js`:

```javascript
const AppConfig = {
    API_URL: window.ENV?.API_URL || 'http://localhost:8000',
    SINGLE_WORKFLOW_PRICE: 149,
    ALL_ACCESS_PRICE: 799,
    // ... other settings
};
```

## Testing

### Manual Testing
1. Open `index.html` in browser
2. Check console for errors
3. Test each feature:
   - Workflow browsing
   - Modal interactions
   - User authentication
   - Payment flows
   - Custom requests

### Browser Console
```javascript
// Test API
const api = new API(AppConfig.API_URL);
await api.getWorkflows();

// Test Storage
Storage.set('test', 'value');
Storage.get('test');

// Test Modules
WorkflowModule.workflows;
AuthModule.checkSession();
```

## Browser Compatibility

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Performance

### Optimization
- Minify CSS/JS for production
- Lazy load images
- Cache API responses
- Use CDN for libraries

### Loading Order
1. CSS files (in `<head>`)
2. External libraries (Tailwind, Paystack)
3. Configuration
4. Utilities
5. Modules
6. Main app

## Deployment

### Development
```bash
# Serve locally
python -m http.server 8000
# or
npx serve .
```

### Production
1. Minify CSS/JS files
2. Set production API_URL
3. Enable HTTPS
4. Configure CSP headers
5. Enable caching

## File Sizes

| File | Size | Purpose |
|------|------|---------|
| main.css | ~2KB | Main styles |
| modal.css | ~1KB | Modal styles |
| app-config.js | ~1KB | Configuration |
| api.js | ~3KB | API client |
| storage.js | ~2KB | Storage wrapper |
| auth.js | ~2KB | Authentication |
| modal.js | ~2KB | Modal management |
| workflows.js | ~3KB | Workflow handling |
| payment.js | ~3KB | Payment processing |
| app.js | ~3KB | Main application |

**Total JS**: ~22KB (unminified)
**Total CSS**: ~3KB (unminified)

## Migration Notes

### Old Structure
```
index.html (2000+ lines)
- Inline CSS (100+ lines)
- Inline JavaScript (800+ lines)
```

### New Structure
```
index.html (~1200 lines) - HTML only
+ 2 CSS files
+ 8 JavaScript modules
= Clean, maintainable code
```

### Breaking Changes
None - All functionality preserved

### Backward Compatibility
✅ All onclick handlers work
✅ All features function identically
✅ No API changes

## Support

For issues:
- Check browser console
- Verify script loading order
- Check API_URL configuration
- Review module dependencies

## Best Practices

1. **Never mix concerns** - Keep HTML, CSS, JS separate
2. **Use modules** - Don't add to global scope
3. **Handle errors** - Always use try-catch
4. **Test thoroughly** - Test each feature
5. **Comment code** - Explain complex logic
6. **Follow conventions** - Consistent naming
7. **Keep it simple** - Don't over-engineer

---

**Clean. Modular. Maintainable.**
