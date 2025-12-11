/**
 * Modal Module
 * Handles modal opening, closing, and interactions
 */

const ModalModule = {
    /**
     * Open a modal by ID
     */
    open(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
    },

    /**
     * Close a modal by ID
     */
    close(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
    },

    /**
     * Close modal when clicking outside
     */
    handleOutsideClick(event, modalId) {
        const modal = document.getElementById(modalId);
        if (event.target === modal) {
            this.close(modalId);
        }
    },

    /**
     * Initialize modal close handlers
     */
    initializeCloseHandlers() {
        // Close modals when clicking outside
        window.onclick = (event) => {
            if (event.target.classList.contains('modal')) {
                event.target.style.display = 'none';
                document.body.style.overflow = 'auto';
            }
        };

        // Close buttons
        document.querySelectorAll('.close').forEach(closeBtn => {
            closeBtn.onclick = function() {
                const modal = this.closest('.modal');
                if (modal) {
                    modal.style.display = 'none';
                    document.body.style.overflow = 'auto';
                }
            };
        });

        // ESC key to close modals
        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                document.querySelectorAll('.modal').forEach(modal => {
                    modal.style.display = 'none';
                });
                document.body.style.overflow = 'auto';
            }
        });
    }
};
