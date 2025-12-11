/**
 * Workflow Module
 * Handles workflow fetching, filtering, and selection
 */

const WorkflowModule = {
    workflows: [],
    selectedWorkflow: null,

    /**
     * Fetch workflows from API
     */
    async fetchWorkflows() {
        try {
            const api = new API(AppConfig.API_URL);
            const data = await api.getWorkflows();

            if (data.success) {
                this.workflows = data.workflows;
            }
        } catch (error) {
            console.error('Error fetching workflows:', error);
            this.workflows = [];
        }
    },

    /**
     * Load workflows into modal
     */
    loadWorkflowsIntoModal() {
        const workflowList = document.getElementById('workflowList');
        if (!workflowList) return;

        workflowList.innerHTML = this.workflows.map(workflow => `
            <div class="workflow-item p-4 border-2 border-gray-200 rounded-xl cursor-pointer"
                 onclick="selectWorkflow(${workflow.id})"
                 data-id="${workflow.id}"
                 data-name="${workflow.name.toLowerCase()}">
                <div class="flex items-center space-x-3">
                    <div class="text-3xl">${workflow.icon}</div>
                    <div class="flex-1">
                        <div class="font-bold">${workflow.name}</div>
                        <div class="text-sm text-gray-500">${workflow.category}</div>
                    </div>
                    <div class="workflow-checkbox w-6 h-6 border-2 border-gray-300 rounded-full flex items-center justify-center">
                        <svg class="w-4 h-4 text-white hidden" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                        </svg>
                    </div>
                </div>
            </div>
        `).join('');
    },

    /**
     * Filter workflows by search term
     */
    filterWorkflows() {
        const searchTerm = document.getElementById('workflowSearch')?.value.toLowerCase() || '';
        const items = document.querySelectorAll('.workflow-item');

        items.forEach(item => {
            const name = item.dataset.name || '';
            if (name.includes(searchTerm)) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    },

    /**
     * Select a workflow
     */
    selectWorkflow(id) {
        // Remove previous selection
        document.querySelectorAll('.workflow-item').forEach(item => {
            item.classList.remove('selected');
            // Reset checkbox styling
            const checkbox = item.querySelector('.workflow-checkbox');
            const checkmark = item.querySelector('.workflow-checkbox svg');
            if (checkbox) {
                checkbox.classList.remove('bg-blue-600', 'border-blue-600');
                checkbox.classList.add('border-gray-300');
            }
            if (checkmark) {
                checkmark.classList.add('hidden');
            }
        });

        // Add selection to clicked item
        const selectedItem = document.querySelector(`.workflow-item[data-id="${id}"]`);
        if (selectedItem) {
            selectedItem.classList.add('selected');
            // Update checkbox to show blue background and checkmark
            const checkbox = selectedItem.querySelector('.workflow-checkbox');
            const checkmark = selectedItem.querySelector('.workflow-checkbox svg');
            if (checkbox) {
                checkbox.classList.remove('border-gray-300');
                checkbox.classList.add('bg-blue-600', 'border-blue-600');
            }
            if (checkmark) {
                checkmark.classList.remove('hidden');
            }
        }

        // Store selected workflow
        this.selectedWorkflow = this.workflows.find(w => w.id === id);

        // Enable the payment button
        const paymentButton = document.querySelector('#singleWorkflowModal button[onclick*="proceedToCheckout"]');
        if (paymentButton) {
            paymentButton.disabled = false;
        }
    },

    /**
     * Get selected workflow
     */
    getSelectedWorkflow() {
        return this.selectedWorkflow;
    }
};
