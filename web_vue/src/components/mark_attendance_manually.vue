<template>
  <div class="attendance-container">
    <div class="wave-bg"></div>
    <h1>Manual Attendance Entry</h1>

    <!-- Success Modal -->
    <div v-if="showSuccessModal" class="modal">
      <div class="modal-content success">
        <div class="modal-header">
          <i class="fas fa-check-circle success-icon"></i>
          <h2>Success!</h2>
        </div>
        <div class="modal-body">
          <p>Attendance has been recorded successfully.</p>
        </div>
        <div class="modal-footer">
          <button @click="closeSuccessModal" class="modal-btn success-btn">Close</button>
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
          <p>{{ errorMessage }}</p>
        </div>
        <div class="modal-footer">
          <button @click="closeErrorModal" class="modal-btn error-btn">Close</button>
        </div>
      </div>
    </div>

    <!-- Loading Modal -->
    <div v-if="isLoading" class="modal">
      <div class="modal-content loading">
        <div class="modal-body">
          <div class="loader"></div>
          <p>Processing...</p>
        </div>
      </div>
    </div>

    <div class="form-section">
      <form @submit.prevent="submitAttendance">
        <!-- Employee Selection -->
        <div class="form-group">
          <label>Search Employee</label>
          <div class="search-employee">
            <input 
              type="text" 
              v-model="searchQuery" 
              @input="searchEmployees" 
              placeholder="Search by name or ID..."
              autocomplete="off"
            >
            <!-- Employee search results dropdown -->
            <div class="search-results" v-if="showResults && filteredEmployees.length > 0">
              <div 
                v-for="emp in filteredEmployees" 
                :key="emp.id" 
                class="search-result-item"
                @click="selectEmployee(emp)"
              >
                <div class="employee-info">
                  <span class="employee-name">{{ emp.first_name }} {{ emp.last_name }}</span>
                  <span class="employee-details">{{ emp.employee_id }} - {{ emp.department?.name || 'N/A' }}</span>
                </div>
              </div>
            </div>
            <!-- Selected employee display -->
            <div v-if="selectedEmployee" class="selected-employee">
              <span>Selected: {{ selectedEmployee.first_name }} {{ selectedEmployee.last_name }}</span>
              <button type="button" class="clear-selection" @click="clearSelection">×</button>
            </div>
          </div>
        </div>

        <!-- Date -->
        <div class="form-group">
          <label>Date</label>
          <input 
            type="date" 
            v-model="formData.date"
            required
          >
        </div>

        <!-- Move Status before Time In/Out -->
        <div class="form-group">
          <label>Status</label>
          <select v-model="formData.status" required>
            <option value="">Select Status</option>
            <option value="present">Present</option>
            <option value="late">Late</option>
            <option value="absent">Absent</option>
            <option value="on_leave">On Leave</option>
          </select>
        </div>

        <!-- Conditionally show Time In/Out -->
        <template v-if="['present', 'late'].includes(formData.status)">
          <!-- Add Night Shift Toggle -->
          <div class="form-group checkbox-group">
            <label class="checkbox-label">
              <input 
                type="checkbox" 
                v-model="formData.isNightShift"
              >
              Night Shift (Time out is next day)
            </label>
          </div>

          <!-- Time In -->
          <div class="form-group">
            <label>Time In</label>
            <input 
              type="time" 
              v-model="formData.time_in"
              required
            >
            <small class="helper-text">{{ formData.date }}</small>
          </div>

          <!-- Time Out -->
          <div class="form-group">
            <label>Time Out</label>
            <input 
              type="time" 
              v-model="formData.time_out"
              required
            >
            <small class="helper-text">
              {{ formData.isNightShift ? getNextDay(formData.date) : formData.date }}
            </small>
          </div>
        </template>

        <div v-if="errorMessage" class="error-message">
          {{ errorMessage }}
        </div>

        <button type="submit" class="submit-btn" :disabled="isLoading">
          {{ isLoading ? 'Submitting...' : 'Submit Attendance' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  data() {
    return {
      employees: [],
      formData: {
        employee_id: '',
        date: '',
        time_in: '',
        time_out: '',
        status: '',
        isNightShift: false
      },
      errorMessage: '',
      showSuccessModal: false,
      showErrorModal: false,
      isLoading: false,
      searchQuery: '',
      showResults: false,
      filteredEmployees: [],
      selectedEmployee: null,
      successMessage: 'Attendance recorded successfully.'
    }
  },
  methods: {
    async fetchEmployees() {
      this.isLoading = true;
      try {
        const response = await axios.get('/api/employees');
        this.employees = response.data;
      } catch (error) {
        this.errorMessage = 'Failed to load employees';
        this.showErrorModal = true;
      } finally {
        this.isLoading = false;
      }
    },
    getNextDay(date) {
      if (!date) return '';
      const nextDay = new Date(date);
      nextDay.setDate(nextDay.getDate() + 1);
      return nextDay.toISOString().split('T')[0];
    },
    async submitAttendance() {
      try {
        if (!this.selectedEmployee) {
          this.showError('Please select an employee');
          return;
        }

        this.isLoading = true;
        
        // Create base payload
        const payload = {
          employee_id: this.selectedEmployee.id,
          date: this.formData.date,
          status: this.formData.status,
          isNightShift: false // Default value
        };

        // Add time fields only for present/late status
        if (['present', 'late'].includes(this.formData.status)) {
          payload.time_in = this.formData.time_in;
          payload.time_out = this.formData.time_out;
          payload.isNightShift = this.formData.isNightShift;
        }

        const response = await axios.post('/api/attendance/manual', payload);
        
        if (response.data.status === 'success') {
          this.showSuccess('Attendance recorded successfully');
          this.resetForm();
        } else {
          throw new Error(response.data.message || 'Failed to record attendance');
        }
      } catch (error) {
        console.error('Attendance submission error:', error);
        const errorMessage = error.response?.data?.message 
          || error.message 
          || 'Failed to record attendance';
        this.showError(errorMessage);
      } finally {
        this.isLoading = false;
      }
    },
    closeSuccessModal() {
      this.showSuccessModal = false;
    },
    closeErrorModal() {
      this.showErrorModal = false;
      this.errorMessage = '';
    },
    searchEmployees() {
      if (!this.searchQuery.trim()) {
        this.filteredEmployees = [];
        this.showResults = false;
        return;
      }

      const query = this.searchQuery.toLowerCase();
      this.filteredEmployees = this.employees.filter(emp => 
        emp.first_name.toLowerCase().includes(query) ||
        emp.last_name.toLowerCase().includes(query) ||
        emp.employee_id.toString().includes(query)
      ).slice(0, 5); // Limit to 5 results

      this.showResults = true;
    },
    selectEmployee(employee) {
      this.selectedEmployee = employee;
      this.formData.employee_id = employee.id;
      this.searchQuery = `${employee.first_name} ${employee.last_name}`;
      this.showResults = false;
    },
    clearSelection() {
      this.selectedEmployee = null;
      this.formData.employee_id = '';
      this.searchQuery = '';
    },
    showError(message) {
      this.errorMessage = message;
      this.showErrorModal = true;
    },
    showSuccess(message) {
      this.successMessage = message;
      this.showSuccessModal = true;
    },
    resetForm() {
      this.searchQuery = '';
      this.selectedEmployee = null;
      this.formData = {
        employee_id: '',
        date: '',
        status: '',
        time_in: '',
        time_out: '',
        isNightShift: false
      };
    }
  },
  mounted() {
    this.fetchEmployees();
  }
}
</script>

<style scoped>
.attendance-container {
  min-height: 100vh;
  padding: 0;
  background: #f2e6ff;
  position: relative;
  overflow-x: hidden;
}

.wave-bg {
  position: absolute;
  top: 0;
  left: -10%;
  right: -10%;
  height: 200px;
  background: linear-gradient(135deg, #cc66ff, #660066);
  border-radius: 0 0 50% 50%;
  z-index: 0;
}

h1 {
  padding-top: 40px;
  margin-top: 0;
  color: white;
  text-align: center;
  position: relative;
  z-index: 1;
  margin-bottom: 40px;
  font-size: 2.5em;
  font-weight: 600;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.form-section {
  max-width: 500px;
  margin: 0 auto;
  padding: 2rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(102, 0, 102, 0.1);
  position: relative;
  z-index: 1;
  transition: all 0.2s;
}

.form-section:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  color: #660066;
  font-weight: 500;
}

.helper-text {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.875rem;
  color: #64748b;
  font-style: italic;
}

select, input {
  width: 100%;
  padding: 12px;
  border: 2px solid #e6ccff;
  border-radius: 8px;
  font-size: 1em;
  color: #660066;
  background-color: white;
  transition: all 0.3s ease;
}

select:hover, input:hover {
  border-color: #cc66ff;
}

select:focus, input:focus {
  border-color: #cc66ff;
  outline: none;
  box-shadow: 0 0 0 3px rgba(204, 102, 255, 0.2);
}

.submit-btn {
  width: 100%;
  padding: 1rem;
  background: linear-gradient(135deg, #cc66ff, #660066);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1.1em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.submit-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(102, 0, 102, 0.2);
}

.error-message {
  background: linear-gradient(to right, rgba(220, 53, 69, 0.05), rgba(220, 53, 69, 0.1));
  border-left: 4px solid #dc3545;
  padding: 10px;
  border-radius: 4px;
  margin: 10px 0;
  box-shadow: 0 2px 4px rgba(220, 53, 69, 0.1);
}

.success-message {
  color: #28a745;
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  padding: 10px;
  border-radius: 4px;
  margin: 10px 0;
}

@media (max-width: 768px) {
  .form-section {
    margin: 1rem;
    padding: 1.5rem;
  }
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
  width: 400px;
  max-width: 90%;
  text-align: center;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.modal-content.success {
  border-top: 6px solid #cc66ff;
}

.modal-header {
  margin-bottom: 1.5rem;
}

.success-icon {
  font-size: 3rem;
  color: #cc66ff;
  margin-bottom: 1rem;
}

.modal-header h2 {
  color: #1e293b;
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
  background: linear-gradient(135deg, #cc66ff, #660066);
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
  box-shadow: 0 4px 8px rgba(102, 0, 102, 0.2);
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
  border-top: 4px solid #cc66ff;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  margin: 0 auto 1rem;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Disabled button state */
.submit-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
}

/* Modal animations */
.modal-enter-active, .modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from, .modal-leave-to {
  opacity: 0;
}

/* Add these new styles */
.checkbox-group {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  user-select: none;
  color: #660066;
}

.checkbox-label input[type="checkbox"] {
  width: auto;
  margin-right: 0.5rem;
}

/* Add these new styles to your existing <style> section */
.search-employee {
  position: relative;
}

.search-employee input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid #e6ccff;
  border-radius: 8px;
  font-size: 0.95rem;
  color: #6b2c91;
  background-color: #fcfaff;
  transition: all 0.3s ease;
}

.search-employee input:focus {
  border-color: #6b2c91;
  outline: none;
  box-shadow: 0 0 0 4px rgba(107, 44, 145, 0.1);
  background-color: #fff;
}

.search-results {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border: 2px solid #e6ccff;
  border-radius: 8px;
  margin-top: 4px;
  max-height: 200px;
  overflow-y: auto;
  z-index: 1000;
  box-shadow: 0 4px 12px rgba(107, 44, 145, 0.1);
}

.search-result-item {
  padding: 0.75rem 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.search-result-item:hover {
  background-color: #fcfaff;
}

.search-result-item:not(:last-child) {
  border-bottom: 1px solid #e6ccff;
}

.employee-info {
  display: flex;
  flex-direction: column;
}

.employee-name {
  font-weight: 600;
  color: #6b2c91;
}

.employee-details {
  font-size: 0.85rem;
  color: #9d7bb7;
}

.selected-employee {
  margin-top: 0.5rem;
  padding: 0.5rem;
  background-color: #fcfaff;
  border: 1px solid #e6ccff;
  border-radius: 6px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #6b2c91;
}

.clear-selection {
  background: none;
  border: none;
  color: #dc3545;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 0 0.5rem;
  transition: all 0.2s ease;
}

.clear-selection:hover {
  transform: scale(1.1);
}

/* Scrollbar styling for search results */
.search-results::-webkit-scrollbar {
  width: 8px;
}

.search-results::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.search-results::-webkit-scrollbar-thumb {
  background: #c5a5db;
  border-radius: 4px;
}

.search-results::-webkit-scrollbar-thumb:hover {
  background: #6b2c91;
}
</style>