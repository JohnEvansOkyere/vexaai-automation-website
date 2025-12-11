/**
 * API Utility Functions
 * Handles all API requests
 */

class API {
    constructor(baseURL) {
        this.baseURL = baseURL;
    }

    /**
     * Make a GET request
     */
    async get(endpoint) {
        try {
            const response = await fetch(`${this.baseURL}${endpoint}`);
            return await response.json();
        } catch (error) {
            console.error(`API GET Error (${endpoint}):`, error);
            throw error;
        }
    }

    /**
     * Make a POST request
     */
    async post(endpoint, data, token = null) {
        try {
            const headers = {
                'Content-Type': 'application/json'
            };

            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }

            const response = await fetch(`${this.baseURL}${endpoint}`, {
                method: 'POST',
                headers,
                body: JSON.stringify(data)
            });

            return await response.json();
        } catch (error) {
            console.error(`API POST Error (${endpoint}):`, error);
            throw error;
        }
    }

    /**
     * Fetch all workflows
     */
    async getWorkflows() {
        return await this.get('/api/workflows');
    }

    /**
     * Fetch single workflow
     */
    async getWorkflow(id) {
        return await this.get(`/api/workflows/${id}`);
    }

    /**
     * Initialize payment
     */
    async initializePayment(paymentData) {
        return await this.post('/api/payment/initialize', paymentData);
    }

    /**
     * Verify payment
     */
    async verifyPayment(reference) {
        return await this.post(`/api/payment/verify/${reference}`);
    }

    /**
     * Submit custom workflow request
     */
    async submitCustomRequest(requestData) {
        return await this.post('/api/payment/custom-request', requestData);
    }

    /**
     * User registration
     */
    async register(userData) {
        return await this.post('/api/auth/register', userData);
    }

    /**
     * User login
     */
    async login(credentials) {
        return await this.post('/api/auth/login', credentials);
    }

    /**
     * Get current user info
     */
    async getCurrentUser(token) {
        try {
            const response = await fetch(`${this.baseURL}/api/auth/me`, {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });
            return await response.json();
        } catch (error) {
            console.error('Get current user error:', error);
            throw error;
        }
    }
}
