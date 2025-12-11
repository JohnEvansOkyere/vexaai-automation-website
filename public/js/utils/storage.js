/**
 * Local Storage Utility Functions
 * Handles localStorage operations with error handling
 */

const Storage = {
    /**
     * Set item in localStorage
     */
    set(key, value) {
        try {
            const serialized = typeof value === 'string' ? value : JSON.stringify(value);
            localStorage.setItem(key, serialized);
            return true;
        } catch (error) {
            console.error('Storage set error:', error);
            return false;
        }
    },

    /**
     * Get item from localStorage
     */
    get(key, parse = false) {
        try {
            const value = localStorage.getItem(key);
            if (!value) return null;

            if (parse) {
                try {
                    return JSON.parse(value);
                } catch {
                    return value;
                }
            }

            return value;
        } catch (error) {
            console.error('Storage get error:', error);
            return null;
        }
    },

    /**
     * Remove item from localStorage
     */
    remove(key) {
        try {
            localStorage.removeItem(key);
            return true;
        } catch (error) {
            console.error('Storage remove error:', error);
            return false;
        }
    },

    /**
     * Clear all localStorage
     */
    clear() {
        try {
            localStorage.clear();
            return true;
        } catch (error) {
            console.error('Storage clear error:', error);
            return false;
        }
    },

    // Auth-specific methods
    setAuthToken(token) {
        return this.set('auth_token', token);
    },

    getAuthToken() {
        return this.get('auth_token');
    },

    setUser(user) {
        return this.set('user', user);
    },

    getUser() {
        return this.get('user', true);
    },

    clearAuth() {
        this.remove('auth_token');
        this.remove('user');
    }
};
