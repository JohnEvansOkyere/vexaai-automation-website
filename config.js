/**
 * VexaAI Frontend Configuration
 *
 * This file loads environment variables for the frontend.
 * For development: Uses values from .env file
 * For production: Uses values set in your hosting platform (Vercel/Netlify)
 */

// Function to load environment variables from .env file (for local development)
async function loadEnvFile() {
    try {
        const response = await fetch('/.env');
        if (!response.ok) return {};

        const text = await response.text();
        const env = {};

        text.split('\n').forEach(line => {
            line = line.trim();
            if (line && !line.startsWith('#')) {
                const [key, ...valueParts] = line.split('=');
                const value = valueParts.join('=').trim();
                env[key] = value;
            }
        });

        return env;
    } catch (error) {
        console.warn('Could not load .env file (this is normal in production):', error.message);
        return {};
    }
}

// Configuration object
const config = {
    // Paystack Public Key (safe to expose in frontend)
    PAYSTACK_PUBLIC_KEY: 'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxx', // Will be replaced

    // Backend API URL
    API_URL: 'http://localhost:8000',

    // Notion Library URL
    NOTION_LIBRARY_URL: 'https://notion.so/your-private-library',

    // WhatsApp Support
    WHATSAPP_NUMBER: '233544954643',

    // Admin credentials (for development only)
    ADMIN_EMAIL: 'johnevansokyere@gmail.com',
    ADMIN_PASSWORD: 'admin123', // Change this in production!

    // Pricing
    SINGLE_WORKFLOW_PRICE: 149,
    ALL_ACCESS_PRICE: 799,
};

// Load environment variables and override config
async function initConfig() {
    // Try to load from .env file (local development)
    const envFile = await loadEnvFile();

    // Override with environment variables (works in both development and production)
    // In production (Vercel/Netlify), these are set in the platform dashboard
    if (envFile.VITE_PAYSTACK_PUBLIC_KEY || window.ENV?.PAYSTACK_PUBLIC_KEY) {
        config.PAYSTACK_PUBLIC_KEY = envFile.VITE_PAYSTACK_PUBLIC_KEY || window.ENV?.PAYSTACK_PUBLIC_KEY || config.PAYSTACK_PUBLIC_KEY;
    }

    if (envFile.VITE_API_URL || window.ENV?.API_URL) {
        config.API_URL = envFile.VITE_API_URL || window.ENV?.API_URL || config.API_URL;
    }

    if (envFile.VITE_NOTION_LIBRARY_URL || window.ENV?.NOTION_LIBRARY_URL) {
        config.NOTION_LIBRARY_URL = envFile.VITE_NOTION_LIBRARY_URL || window.ENV?.NOTION_LIBRARY_URL || config.NOTION_LIBRARY_URL;
    }

    if (envFile.VITE_WHATSAPP_NUMBER || window.ENV?.WHATSAPP_NUMBER) {
        config.WHATSAPP_NUMBER = envFile.VITE_WHATSAPP_NUMBER || window.ENV?.WHATSAPP_NUMBER || config.WHATSAPP_NUMBER;
    }

    if (envFile.VITE_ADMIN_EMAIL || window.ENV?.ADMIN_EMAIL) {
        config.ADMIN_EMAIL = envFile.VITE_ADMIN_EMAIL || window.ENV?.ADMIN_EMAIL || config.ADMIN_EMAIL;
    }

    console.log('✅ Configuration loaded:', {
        paystackKey: config.PAYSTACK_PUBLIC_KEY.substring(0, 15) + '...',
        apiUrl: config.API_URL,
        notionUrl: config.NOTION_LIBRARY_URL.substring(0, 30) + '...',
    });

    return config;
}

// Export for use in other files
window.VexaConfig = config;
window.initVexaConfig = initConfig;

// Auto-initialize on load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initConfig);
} else {
    initConfig();
}
