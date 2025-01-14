<template>
  <div class="salary-container">
    <div class="wave-bg"></div>
    
    <div class="content-wrapper">
      <!-- Header Section -->
      <div class="header-section">
        <h1>Salary Adjustment</h1>
      </div>

      <!-- Error Message Display -->
      <div v-if="errorMessage" class="error-message">
        {{ errorMessage }}
      </div>

      <!-- Search Bar -->
      <div class="search-section">
        <div class="search-box">
          <input 
            type="text" 
            v-model="searchName"
            placeholder="Search employee..."
            class="purple-input"
          >
        </div>
      </div>

      <!-- Employees Table -->
      <div class="table-container">
        <table>
          <thead>
            <tr>
              <th>Employee ID</th>
              <th>Name</th>
              <th>Department</th>
              <th>Position</th>
              <th>Base Salary</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="employee in filteredEmployees" :key="employee.id">
              <td>{{ employee.employee_id }}</td>
              <td>{{ employee.first_name }} {{ employee.last_name }}</td>
              <td>{{ employee.department.name }}</td>
              <td>{{ employee.position.title }}</td>
              <td>₱{{ formatCurrency(employee.base_salary) }}</td>
              <td>
                <button 
                  class="adjust-btn"
                  @click="selectEmployee(employee)"
                >
                  Adjust
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Adjustment Modal -->
      <div class="modal" v-if="selectedEmployee">
        <div class="modal-content">
          <div class="modal-header">
            <h2>Adjust Salary - {{ selectedEmployee.first_name }} {{ selectedEmployee.last_name }}</h2>
            <button class="close-btn" @click="closeModal">&times;</button>
          </div>

          <!-- Employee Details -->
          <div class="employee-details">
            <div class="info-grid">
              <div class="info-item">
                <label>Employee ID</label>
                <input type="text" :value="selectedEmployee.employee_id" disabled class="purple-input">
              </div>
              <div class="info-item">
                <label>Department</label>
                <input type="text" :value="selectedEmployee.department.name" disabled class="purple-input">
              </div>
              <div class="info-item">
                <label>Position</label>
                <input type="text" :value="selectedEmployee.position.title" disabled class="purple-input">
              </div>
            </div>

            <!-- Rate Adjustment -->
            <div class="adjustment-section">
              <h3>Rate Adjustment</h3>
              <div class="rate-group">
                <div class="current-rate">
                  <label>Current Base Salary</label>
                  <input 
                    type="text" 
                    :value="'₱' + formatCurrency(selectedEmployee.base_salary)"
                    disabled 
                    class="purple-input"
                  >
                </div>
                <div class="new-rate">
                  <label>New Base Salary</label>
                  <input 
                    type="number" 
                    v-model="newRate"
                    class="purple-input"
                    step="0.01"
                    min="0"
                  >
                </div>
              </div>
            </div>

            <!-- Save Button -->
            <div class="form-buttons">
              <button class="save-btn" @click="saveAdjustments">
                Save Changes
              </button>
              <button class="cancel-btn" @click="closeModal">
                Cancel
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modals -->
    <div>
      <!-- Success Modal -->
      <div v-if="showSuccessModal" class="modal">
        <div class="modal-content success">
          <div class="modal-header">
            <i class="fas fa-check-circle success-icon"></i>
            <h2>Success</h2>
          </div>
          <div class="modal-body">
            <p>{{ modalMessage }}</p>
          </div>
          <div class="modal-footer">
            <button @click="closeModals" class="modal-btn success-btn">Close</button>
          </div>
        </div>
      </div>

      <!-- Error Modal -->
      <div v-if="showErrorModal" class="modal">
        <div class="modal-content error">
          <div class="modal-header">
            <i class="fas fa-exclamation-circle error-icon"></i>
            <h2>Error</h2>
          </div>
          <div class="modal-body">
            <p>{{ modalMessage }}</p>
          </div>
          <div class="modal-footer">
            <button @click="closeModals" class="modal-btn error-btn">Close</button>
          </div>
        </div>
      </div>

      <!-- Loading Modal -->
      <div v-if="showLoadingModal" class="modal">
        <div class="modal-content loading">
          <div class="modal-body">
            <div class="loader"></div>
            <p>{{ modalMessage }}</p>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'SalaryAdjustment',
  data() {
    return {
      searchName: '',
      selectedEmployee: null,
      newRate: 0,
      errorMessage: '',
      successMessage: '',
      employees: [],
      departments: [],
      showSuccessModal: false,
      showErrorModal: false,
      showLoadingModal: false,
      modalMessage: '',
    }
  },
  
  computed: {
    filteredEmployees() {
      const searchTerm = this.searchName.toLowerCase();
      return this.employees.filter(emp => 
        !emp.deleted_at && emp.status !== 'deleted' &&
        (
          (emp.first_name && emp.first_name.toLowerCase().includes(searchTerm)) ||
          (emp.last_name && emp.last_name.toLowerCase().includes(searchTerm)) ||
          (emp.employee_id && emp.employee_id.toString().includes(searchTerm)) ||
          (emp.department && emp.department.name.toLowerCase().includes(searchTerm)) ||
          (emp.position && emp.position.title.toLowerCase().includes(searchTerm))
        )
      );
    }
  },
  
  methods: {
    async fetchEmployees() {
      try {
        this.showLoading('Loading employees data...');
        await axios.get('/sanctum/csrf-cookie');
        
        const response = await axios.get('/api/employees');
        this.employees = response.data;
        this.hideLoading();
      } catch (error) {
        this.hideLoading();
        this.showError(
          error.response?.status === 401 
            ? 'Please log in to access this feature' 
            : 'Failed to load employees'
        );
      }
    },
    async fetchAdjustments(employeeId) {
    try {
        const response = await axios.get(`/api/salary-adjustments/${employeeId}`);
        if (response.status === 200) {
            this.adjustments = Array.isArray(response.data) ? response.data : [response.data];
        }
    } catch (error) {
        console.error('Error fetching adjustments:', error);
        if (error.response?.status === 404) {
            this.adjustments = []; // Clear existing adjustments
            this.showError('No salary adjustment found for this employee.');
        } else {
            this.showError('Failed to fetch salary adjustments. Please try again.');
        }
    }
},

    selectEmployee(employee) {
      this.selectedEmployee = employee;
      this.newRate = employee.base_salary;
      this.fetchAdjustments(employee.id);
    },
    async fetchDepartments() {
      try {
        const response = await axios.get('/api/departments');
        this.departments = response.data.data;
      } catch (error) {
        this.showError('Failed to load departments');
      }
    },
    formatCurrency(value) {
      const number = parseFloat(value) || 0;
      return number.toLocaleString('en-PH', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      });
    },
  
    closeModal() {
      this.selectedEmployee = null;
      this.newRate = 0;
    },
  
    async saveAdjustments() {
      try {
        this.showLoading('Saving salary adjustment...');
        
        const response = await axios.put(`/api/salary/adjust/${this.selectedEmployee.id}`, {
          new_base_salary: this.newRate,
        });

        this.showSuccess('Salary adjustment saved successfully');
        this.closeModal();
        this.fetchEmployees(); // Refresh the list
      } catch (error) {
        this.showError('Failed to save salary adjustment');
        console.error('Salary adjustment error:', error);
      }
    },
    showLoading(message = 'Processing...') {
      this.showLoadingModal = true;
      this.modalMessage = message;
    },

    hideLoading() {
      this.showLoadingModal = false;
      this.modalMessage = '';
    },

    showSuccess(message) {
      this.showSuccessModal = true;
      this.modalMessage = message;
    },

    showError(message) {
      this.showErrorModal = true;
      this.modalMessage = message;
    },

    closeModals() {
      this.showSuccessModal = false;
      this.showErrorModal = false;
      this.showLoadingModal = false;
      this.modalMessage = '';
    }
  },
  async mounted() {
    this.showLoading('Initializing...');
    try {
      await Promise.all([
        this.fetchEmployees(),
        this.fetchDepartments()
      ]);
    } catch (error) {
      // Error handling is done in individual methods
    } finally {
      this.hideLoading();
    }
  }
}
</script>

<style scoped>
.salary-container {
  min-height: 100vh;
  padding: 0;
  margin: 0;
  background: #f2e6ff;
  position: relative;
  overflow-x: hidden;
}

.wave-bg {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  width: 100%;
  height: 200px;
  background: linear-gradient(135deg, #cc66ff, #660066);
  border-radius: 0 0 50% 50%;
  z-index: 0;
}

.content-wrapper {
  position: relative;
  z-index: 1;
  padding: 2rem;
}

.header-section {
  margin-bottom: 2rem;
}

.header-section h1 {
  color: white;
  font-size: 1.8rem;
}

/* Search Section */
.search-section {
  background: white;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

/* Table Styles */
.table-container {
  background: white;
  border-radius: 8px;
  padding: 1rem;
  margin-top: 1rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  overflow-x: auto;
}
td,h2,label{
  color: #660066;
}
table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #e1e4e8;
}

th {
  background: #f8fafc;
  font-weight: 600;
  color: #2d3748;
}

/* Button Styles */
.adjust-btn {
  background: #6b2c91;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 5px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.adjust-btn:hover {
  background: #561d74;
}

/* Modal Styles */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  width: 800px;
  max-width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  text-align: center;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  scrollbar-width: thin;
  scrollbar-color: #cc66ff #f0f0f0;
}

.modal-content.success,
.modal-content.error,
.modal-content.loading {
  width: 400px;
  max-height: none;
  overflow-y: visible;
}

.modal-header {
  margin-bottom: 1.5rem;
}

.success-icon {
  font-size: 3rem;
  color: #28a745;
  margin-bottom: 1rem;
}

.modal-header h2 {
  color: #28a745;
  margin: 0;
  font-size: 1.8rem;
}

.modal-body {
  margin-bottom: 1.5rem;
}

.modal-body p {
  color: #666;
  font-size: 1.1rem;
  margin: 0;
}

.modal-footer {
  display: flex;
  justify-content: center;
}

.modal-btn {
  padding: 0.8rem 2rem;
  background: linear-gradient(135deg, #2ecc71, #27ae60);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1.1em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.modal-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(46, 204, 113, 0.2);
}

/* Animation for modal */
@keyframes modalFadeIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-content {
  animation: modalFadeIn 0.3s ease-out;
}

/* Updated Modal Styles */
.modal-content.error {
  border-top: 6px solid #dc3545;
}

.modal-content.loading {
  border-top: 6px solid #007bff;
}

.error-icon {
  font-size: 3rem;
  color: #dc3545;
  margin-bottom: 1rem;
}

.modal-header h2.error {
  color: #dc3545;
}

.error-btn {
  background: linear-gradient(135deg, #dc3545, #c82333);
}

.error-btn:hover {
  box-shadow: 0 4px 8px rgba(220, 53, 69, 0.2);
}

/* Loading Spinner */
.loader {
  border: 4px solid #f3f3f3;
  border-radius: 50%;
  border-top: 4px solid #007bff;
  width: 40px;
  height: 40px;
  margin: 0 auto 1rem;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Modal animations */
.modal-enter-active, .modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from, .modal-leave-to {
  opacity: 0;
}

/* Form Styles */
.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.purple-input {
  width: 100%;
  padding: 0.8rem;
  border: 2px solid #e6ccff;
  border-radius: 8px;
  font-size: 1em;
  color: #660066;
  background-color: white;
  transition: all 0.3s ease;
}

.purple-input:focus {
  border-color: #cc66ff;
  outline: none;
  box-shadow: 0 0 0 3px rgba(204, 102, 255, 0.2);
}

.purple-input:disabled {
  background-color: #f8f9fa;
  cursor: not-allowed;
}

.adjustment-section {
  margin-bottom: 2rem;
}

.adjustment-section h3 {
  color: #660066;
  margin-bottom: 1rem;
}

.rate-group {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.form-buttons {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
}

.save-btn,
.cancel-btn {
  padding: 0.8rem 2rem;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
}

.save-btn {
  background: linear-gradient(135deg, #cc66ff, #660066);
  color: white;
}

.cancel-btn {
  background: #dc3545;
  color: white;
}

.save-btn:hover,
.cancel-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(102, 0, 102, 0.2);
}

/* Responsive Styles */
@media (max-width: 768px) {
  .content-wrapper {
    padding: 1rem;
  }
  
  .modal-content {
    padding: 1rem;
    margin: 1rem;
  }
  
  .info-grid,
  .rate-group {
    grid-template-columns: 1fr;
  }
  
  .form-buttons {
    flex-direction: column;
  }
  
  .save-btn,
  .cancel-btn {
    width: 100%;
  }
}

.modal-content::-webkit-scrollbar {
  width: 8px;
}

.modal-content::-webkit-scrollbar-track {
  background: #f0f0f0;
  border-radius: 4px;
}

.modal-content::-webkit-scrollbar-thumb {
  background: #cc66ff;
  border-radius: 4px;
}

.modal-content::-webkit-scrollbar-thumb:hover {
  background: #660066;
}
</style>