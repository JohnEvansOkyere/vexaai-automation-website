/**
 * Payment Module
 * Handles Paystack payment initialization and processing
 */

const PaymentModule = {
    /**
     * Initialize single workflow payment
     */
    async initializeSingleWorkflowPayment(workflow, customerEmail) {
        if (!workflow) {
            alert('Please select a workflow');
            return;
        }

        try {
            const api = new API(AppConfig.API_URL);
            const paymentData = {
                email: customerEmail,
                amount: workflow.price || AppConfig.SINGLE_WORKFLOW_PRICE,
                purchase_type: 'single',
                workflow_id: workflow.id,
                workflow_name: workflow.name
            };

            const response = await api.initializePayment(paymentData);

            if (response.success) {
                // Redirect to Paystack payment page
                window.location.href = response.authorization_url;
            } else {
                alert('Payment initialization failed. Please try again.');
            }
        } catch (error) {
            console.error('Payment error:', error);
            alert('Payment initialization failed. Please try again.');
        }
    },

    /**
     * Initialize all-access payment
     */
    async initializeAllAccessPayment(customerEmail) {
        try {
            const api = new API(AppConfig.API_URL);
            const paymentData = {
                email: customerEmail,
                amount: AppConfig.ALL_ACCESS_PRICE,
                purchase_type: 'all-access',
                workflow_id: null,
                workflow_name: 'All Access Pass'
            };

            const response = await api.initializePayment(paymentData);

            if (response.success) {
                window.location.href = response.authorization_url;
            } else {
                alert('Payment initialization failed. Please try again.');
            }
        } catch (error) {
            console.error('Payment error:', error);
            alert('Payment initialization failed. Please try again.');
        }
    },

    /**
     * Submit custom workflow request
     */
    async submitCustomRequest(formData) {
        try {
            const api = new API(AppConfig.API_URL);
            const response = await api.submitCustomRequest(formData);

            if (response.success) {
                alert('✅ Custom request submitted successfully! We will contact you soon.');
                return true;
            } else {
                alert('❌ Failed to submit request. Please try again.');
                return false;
            }
        } catch (error) {
            console.error('Custom request error:', error);
            alert('❌ Failed to submit request. Please try again.');
            return false;
        }
    }
};
