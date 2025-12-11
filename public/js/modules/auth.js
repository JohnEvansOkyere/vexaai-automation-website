/**
 * Authentication Module
 * Handles user authentication and session management
 */

const AuthModule = {
    /**
     * Handle user logout
     */
    logout() {
        Storage.clearAuth();
        window.location.reload();
    },

    /**
     * Check and display user session
     */
    checkSession() {
        const token = Storage.getAuthToken();
        const user = Storage.getUser();

        if (token && user) {
            try {
                // Show user menu, hide auth buttons
                const authButtons = document.getElementById('authButtons');
                const userMenu = document.getElementById('userMenu');
                const userName = document.getElementById('userName');

                if (authButtons) authButtons.classList.add('hidden');
                if (userMenu) userMenu.classList.remove('hidden');
                if (userName) userName.textContent = user.first_name || 'User';

                // Show admin dashboard link if user is admin
                if (user.is_admin) {
                    const adminLink = document.getElementById('adminDashboardLink');
                    if (adminLink) adminLink.classList.remove('hidden');
                }
            } catch (error) {
                console.error('Error parsing user data:', error);
                Storage.clearAuth();
            }
        } else {
            // Show auth buttons, hide user menu
            const authButtons = document.getElementById('authButtons');
            const userMenu = document.getElementById('userMenu');

            if (authButtons) authButtons.classList.remove('hidden');
            if (userMenu) userMenu.classList.add('hidden');
        }
    },

    /**
     * Initialize authentication state on page load
     */
    init() {
        this.checkSession();
    },

    /**
     * Check if user is logged in
     */
    isLoggedIn() {
        const token = Storage.getAuthToken();
        const user = Storage.getUser();
        return !!(token && user);
    },

    /**
     * Redirect to login page
     */
    redirectToLogin(message = 'Please login to continue') {
        alert(message);
        window.location.href = '/auth.html';
    }
};
