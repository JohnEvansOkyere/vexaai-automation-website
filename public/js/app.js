/**
 * VexaAI Main Application
 * Coordinates all modules and handles page initialization
 */

// Global functions for onclick handlers (backward compatibility)
function openSingleWorkflowModal() {
    WorkflowModule.loadWorkflowsIntoModal();
    ModalModule.open('singleWorkflowModal');
}

function closeSingleWorkflowModal() {
    ModalModule.close('singleWorkflowModal');
}

function filterWorkflows() {
    WorkflowModule.filterWorkflows();
}

function selectWorkflow(id) {
    WorkflowModule.selectWorkflow(id);
}

function openAllAccessModal() {
    ModalModule.open('allAccessModal');
}

function closeAllAccessModal() {
    ModalModule.close('allAccessModal');
}

function openCustomRequestModal() {
    ModalModule.open('customRequestModal');
}

function closeCustomRequestModal() {
    ModalModule.close('customRequestModal');
}

function handleLogout() {
    AuthModule.logout();
}

// Single Workflow Purchase Handler
async function proceedToSinglePayment() {
    // Check if user is logged in
    if (!AuthModule.isLoggedIn()) {
        AuthModule.redirectToLogin('Please login or register to purchase workflows');
        return;
    }

    const workflow = WorkflowModule.getSelectedWorkflow();
    if (!workflow) {
        alert('Please select a workflow');
        return;
    }

    const user = Storage.getUser();
    const email = user.email;

    await PaymentModule.initializeSingleWorkflowPayment(workflow, email);
}

// All Access Purchase Handler
async function proceedToAllAccessPayment() {
    // Check if user is logged in
    if (!AuthModule.isLoggedIn()) {
        AuthModule.redirectToLogin('Please login or register to purchase All Access Pass');
        return;
    }

    const user = Storage.getUser();
    const email = user.email;

    await PaymentModule.initializeAllAccessPayment(email);
}

// Proceed to checkout (alias for proceedToSinglePayment)
async function proceedToCheckout() {
    await proceedToSinglePayment();
}

// Buy all access (alias for proceedToAllAccessPayment)
async function buyAllAccess() {
    await proceedToAllAccessPayment();
}

// Custom Request Form Handler
async function submitCustomRequest(event) {
    event.preventDefault();

    const formData = {
        name: document.getElementById('requestName').value,
        email: document.getElementById('requestEmail').value,
        phone: document.getElementById('requestPhone').value,
        workflow_description: document.getElementById('requestDescription').value,
        use_case: document.getElementById('requestUseCase').value,
        budget: document.getElementById('requestBudget').value,
        timeline: document.getElementById('requestTimeline').value
    };

    const success = await PaymentModule.submitCustomRequest(formData);

    if (success) {
        document.getElementById('customRequestForm').reset();
        closeCustomRequestModal();
    }
}

// Toggle FAQ
function toggleFAQ(button) {
    const content = button.nextElementSibling;
    const icon = button.querySelector('svg');

    if (content.classList.contains('hidden')) {
        content.classList.remove('hidden');
        icon.style.transform = 'rotate(180deg)';
    } else {
        content.classList.add('hidden');
        icon.style.transform = 'rotate(0deg)';
    }
}

// Validate email
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

// Initialize application on page load
window.addEventListener('load', async () => {
    // Initialize modules
    ModalModule.initializeCloseHandlers();
    AuthModule.init();

    // Fetch workflows
    await WorkflowModule.fetchWorkflows();

    // Add event listeners
    const customRequestForm = document.getElementById('customRequestForm');
    if (customRequestForm) {
        customRequestForm.addEventListener('submit', submitCustomRequest);
    }
});
