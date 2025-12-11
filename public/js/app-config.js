/**
 * Application Configuration
 * Centralized configuration settings
 */

const AppConfig = {
    // API Configuration
    API_URL: window.ENV?.API_URL || 'http://localhost:8000',

    // Pricing
    SINGLE_WORKFLOW_PRICE: 149,
    ALL_ACCESS_PRICE: 799,

    // Currency
    CURRENCY: 'GHS',
    CURRENCY_SYMBOL: 'GHS',

    // Paystack
    PAYSTACK_PUBLIC_KEY: window.ENV?.PAYSTACK_PUBLIC_KEY || '',

    // Application
    APP_NAME: 'VexaAI',

    // Contact
    WHATSAPP_NUMBER: '+233544954643',
    EMAIL: 'johnevansokyere@gmail.com',
};
