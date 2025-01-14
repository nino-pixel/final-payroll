<template>
  <div class="employee-container">
    <div class="wave-bg"></div>
    
    <div class="content-wrapper">
      <!-- Header Section -->
      <div class="header-section">
        <h1>Employee Management</h1>
        <div class="header-right">
          <div class="total-count">
            <span>Total Employees: {{ totalEmployees }}</span>
          </div>
          <button class="add-btn" @click="openAddModal">
            <span>+</span> Add Employee
          </button>
        </div>
      </div>

      <!-- Search and Filter Section -->
      <div class="search-section">
        <div class="search-box">
          <input 
            type="text" 
            v-model="searchQuery" 
            placeholder="Search employees by name or ID..."
          >
        </div>
        <div class="filter-box">
          <select v-model="departmentFilter" @change="fetchPositionsByDepartment">
            <option value="">All Departments</option>
            <option v-for="department in departments" :key="department.id" :value="department.id">
              {{ department.name }}
            </option>
          </select>
        </div>
        <div class="filter-box">
          <select v-model="statusFilter">
            <option value="">All Status</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
            <option value="on_leave">On Leave</option>
          </select>
        </div>
        <div class="filter-box">
          <select v-model="shiftFilter">
            <option value="">All Shifts</option>
            <option v-for="schedule in shiftSchedules" 
                    :key="schedule.id" 
                    :value="schedule.id">
              {{ schedule.name }}
            </option>
          </select>
        </div>
      </div>

      <!-- Employee Table -->
      <div class="table-container">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Department</th>
              <th>Position</th>
              <th>Email</th>
              <th>Phone</th>
              <th>Shift Schedule</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="employee in filteredEmployees" :key="employee.id">
              <td>{{ employee.employee_id }}</td>
              <td>{{ employee.first_name }} {{ employee.last_name }}</td>
              <td>{{ employee.department?.name }}</td>
              <td>{{ employee.position?.title }}</td>
              <td>{{ employee.email }}</td>
              <td>{{ employee.phone }}</td>
              <td>
                <span :class="['shift-badge', getShiftClass(employee)]">
                  {{ getShiftScheduleDisplay(employee) }}
                </span>
              </td>
              <td>
                <span :class="['status-badge', employee.status]">
                  {{ employee.status }}
                </span>
              </td>
              <td>
                <div class="action-buttons">
                  <button @click="viewEmployee(employee)" class="view-btn">
                    <i class="fas fa-eye"></i>
                  </button>
                  <button @click="openEditModal(employee)" class="edit-btn">
                    <i class="fas fa-edit"></i>
                  </button>
                  <button @click="openSetPasswordModal(employee)" class="password-btn">
                    <i class="fas fa-key"></i>
                  </button>
                  <button @click="deleteEmployee(employee.id)" class="delete-btn">
                    <i class="fas fa-trash"></i>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <div class="modal" v-if="showModal">
      <div class="modal-content">
        <h2>{{ isEditing ? 'Edit Employee' : 'Add Employee' }}</h2>
        <form @submit.prevent="saveEmployee" class="employee-form">
          <!-- Error Message Display -->
          <div v-if="errorMessage" class="error-message">
            {{ errorMessage }}
          </div>
          <!-- Success Message Display -->
          <div v-if="successMessage" class="success-message">
            {{ successMessage }}
          </div>
          <div class="form-group" v-if="isEditing">
            <label>Employee ID</label>
            <input type="text" v-model="formData.employee_id" required readonly>
          </div>
          <div class="form-group">
            <label>First Name</label>
            <input type="text" v-model="formData.first_name" required>
          </div>
          <div class="form-group">
            <label>Last Name</label>
            <input type="text" v-model="formData.last_name" required>
          </div>
          <div class="form-group">
            <label>Email</label>
            <input 
              type="email" 
              v-model="formData.email" 
              @input="validateEmail"
              required
            >
            <small class="helper-text">Enter a valid email address</small>
          </div>
          <div class="form-group">
            <label>Phone</label>
            <input 
              type="tel" 
              v-model="formData.phone"
              @input="validatePhone"
              required
              pattern="[09]\d{9,10}"
            >
            <small class="helper-text">Enter a valid phone number</small>
          </div>
          <div class="form-group">
            <label>Department</label>
            <select v-model="formData.department_id" @change="loadPositions">
              <option value="">Select Department</option>
              <option v-for="dept in departments" :key="dept.id" :value="dept.id">
                {{ dept.name }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>Position</label>
            <select v-model="formData.position_id" :disabled="!formData.department_id">
              <option value="">Select Position</option>
              <option v-for="pos in positions" :key="pos.id" :value="pos.id">
                {{ pos.title }} - Base Salary: {{ pos.base_salary }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>Base Salary</label>
            <input 
              type="number" 
              v-model="formData.base_salary" 
              step="0.01" 
              min="0"
              max="999999.99"
              required
              @input="validateSalary"
            >
            <small class="helper-text">Maximum salary: ₱999,999.99</small>
          </div>
          <div class="form-group">
            <label>Hire Date</label>
            <input type="date" v-model="formData.hire_date" required>
          </div>
          <div class="form-group">
            <label>Status</label>
            <select v-model="formData.status" required>
              <option value="">Select Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
              <option value="on_leave">On Leave</option>
            </select>
          </div>
          <div class="form-group">
            <label>Shift Schedule</label>
            <select v-model="formData.shift_schedule_id" class="form-select" required>
              <option value="">Select Shift Schedule</option>
              <option v-for="schedule in shiftSchedules" 
                      :key="schedule.id" 
                      :value="schedule.id">
                {{ schedule.name }}
              </option>
            </select>
          </div>
          <div class="form-group" v-if="isCustomShift">
            <label>Custom Schedule Times</label>
            <div class="schedule-inputs">
              <div class="time-input">
                <label class="sub-label">Start Time</label>
                <input 
                  type="time" 
                  v-model="formData.custom_start_time" 
                  @input="validateScheduleTimes"
                  class="form-control"
                  required
                >
              </div>
              <div class="time-input">
                <label class="sub-label">End Time</label>
                <input 
                  type="time" 
                  v-model="formData.custom_end_time" 
                  @input="validateScheduleTimes"
                  class="form-control"
                  required
                >
              </div>
            </div>

            <small class="helper-text">Set custom shift times</small>
            <div v-if="scheduleError" class="schedule-error">
              {{ scheduleError }}
            </div>
          </div>

          <div class="form-buttons">
            <button 
              type="submit" 
              class="submit-btn" 
              :disabled="isLoading || scheduleError"  
            >
              <span v-if="isLoading">
                <i class="fas fa-spinner fa-spin"></i>
              </span>
              <span v-else>
                {{ isEditing ? 'Update' : 'Add' }} Employee
              </span>
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- View Modal -->
    <div class="modal" v-if="showViewModal">
      <div class="modal-content">
        <h2>Employee Details</h2>
        <div class="employee-details">
          <div class="detail-row">
            <span class="label">ID:</span>
            <span class="value">{{ selectedEmployee.employee_id }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Name:</span>
            <span class="value">{{ selectedEmployee.first_name }} {{ selectedEmployee.last_name }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Department:</span>
            <span class="value">{{ selectedEmployee.department.name }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Position:</span>
            <span class="value">{{ selectedEmployee.position.title }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Email:</span>
            <span class="value">{{ selectedEmployee.email }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Phone:</span>
            <span class="value">{{ selectedEmployee.phone }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Shift Schedule:</span>
            <span class="value">
              <span :class="['shift-badge', getShiftClass(selectedEmployee)]">
                {{ getShiftScheduleDisplay(selectedEmployee) }}
              </span>
            </span>
          </div>
          <div class="detail-row" v-if="hasCustomSchedule(selectedEmployee)">
            <span class="label">Custom Times:</span>
            <span class="value">
              {{ formatTime(selectedEmployee.custom_start_time) }} - 
              {{ formatTime(selectedEmployee.custom_end_time) }}
            </span>
          </div>
          <div class="detail-row">
            <span class="label">Status:</span>
            <span class="value" :class="'status-' + selectedEmployee.status">
              {{ selectedEmployee.status }}
            </span>
          </div>
          <div class="detail-row">
            <span class="label">Hire Date:</span>
            <span class="value">{{ formatDate(selectedEmployee.hire_date) }}</span>
          </div>
        </div>
        <button @click="closeViewModal" class="close-btn">Close</button>
      </div>
    </div>

    <!-- Modals -->
    <div>
      <!-- Success Modal -->
      <div v-if="showSuccessModal" class="modal">
        <div class="modal-content success">
          <div class="modal-header">
            <i class="fas fa-check-circle success-icon"></i>
            <h2>Success!</h2>
          </div>
          <div class="modal-body">
            <p>{{ successMessage }}</p>
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
            <p>{{ loadingMessage }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Add this new modal -->
    <div class="modal" v-if="showPasswordModal">
      <div class="modal-content">
        <h2>Set Password for {{ selectedEmployee?.first_name }} {{ selectedEmployee?.last_name }}</h2>
        <form @submit.prevent="submitPassword">
          <div class="form-group">
            <label>New Password</label>
            <input 
              type="password" 
              v-model="passwordForm.password"
              required
              minlength="8"
            >
            <small class="helper-text">
              Password must contain at least 8 characters, including uppercase, lowercase, 
              number and special character
            </small>
          </div>
          <div class="form-group">
            <label>Confirm Password</label>
            <input 
              type="password" 
              v-model="passwordForm.password_confirmation"
              required
            >
          </div>
          <div class="form-buttons">
            <button type="submit" class="submit-btn" :disabled="loading">
              Set Password
            </button>
            <button type="button" class="cancel-btn" @click="closePasswordModal">
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'EmployeeManagement',
  data() {
    return {
      employees: [],
      departments: [],
      positions: [],
      shiftSchedules: [],
      searchQuery: '',
      departmentFilter: '',
      statusFilter: '',
      shiftFilter: '',
      showModal: false,
      showViewModal: false,
      selectedEmployee: null,
      isEditing: false,
      loading: false,
      errorMessage: '',
      successMessage: '',
      showDeleteModal: false,
      employeeToDelete: null,
      scheduleError: '',
      formData: {
        id: null,
        employee_id: '',
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        department_id: '',
        position_id: '',
        base_salary: '',
        hire_date: '',
        status: 'active',
        shift_schedule_id: null,
        custom_start_time: null,
        custom_end_time: null,
        created_at: null,
        updated_at: null,
        deleted_at: null
      },
      isLoading: false,
      loadingMessage: '',
      showSuccessModal: false,
      showErrorModal: false,
      showPasswordModal: false,
      passwordForm: {
        password: '',
        password_confirmation: ''
      }
    };
  },

  computed: {
    totalEmployees() {
      return this.employees.filter(emp => !emp.deleted_at).length;
    },
    filteredEmployees() {
      return this.employees.filter(emp => {
        if (emp.deleted_at) return false;
        
        const searchQueryLower = this.searchQuery.toLowerCase();
        const matchesSearch = emp.first_name.toLowerCase().includes(searchQueryLower) ||
                              emp.last_name.toLowerCase().includes(searchQueryLower) ||
                              emp.employee_id.toString().includes(searchQueryLower);
        const matchesDepartment = !this.departmentFilter || emp.department.id === this.departmentFilter;
        const matchesStatus = !this.statusFilter || emp.status === this.statusFilter;
        const matchesShift = !this.shiftFilter || emp.shift_schedule_id === this.shiftFilter;

        return matchesSearch && matchesDepartment && matchesStatus && matchesShift;
      });
    },
    isCustomShift() {
      if (!this.formData.shift_schedule_id) return false;
      const selectedSchedule = this.shiftSchedules.find(
        s => s.id === this.formData.shift_schedule_id
      );
      return selectedSchedule?.name.toLowerCase() === 'custom shift';
    },
  },
  watch: {
    'formData.shift_schedule_id': {
      handler(newValue) {
        if (!this.isCustomShift) {
          // Clear custom times if not custom shift
          this.formData.custom_start_time = null;
          this.formData.custom_end_time = null;
        }
      },
      immediate: true
    }
  },
  methods: {
    async fetchEmployees() {
      try {
        this.isLoading = true;
        const response = await axios.get('/api/employees');
        this.employees = response.data;
      } catch (error) {
        console.error('Error fetching employees:', error);
        this.showError('Failed to load employees');
      } finally {
        this.isLoading = false;
      }
    },
    async fetchDepartments() {
      try {
        const response = await axios.get('/api/departments');
        this.departments = response.data.data;
      } catch (error) {
        console.error('Error fetching departments:', error);
        this.errorMessage = 'Failed to load departments';
      }
    },
    async fetchPositions() {
      try {
        const response = await axios.get('/api/positions');
        this.positions = response.data.data;
      } catch (error) {
        console.error('Error fetching positions:', error);
        this.errorMessage = 'Failed to load positions';
      }
    },
    async fetchPositionsByDepartment() {
      if (!this.formData.department_id) return;
      
      try {
        const response = await axios.get(`/api/departments/${this.formData.department_id}/positions`);
        this.positions = response.data;
      } catch (error) {
        console.error('Error fetching positions:', error);
        this.showError('Failed to load positions');
      }
    },
    openAddModal() {
      this.isEditing = false;
      this.formData = {
        id: null,
        employee_id: '',
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        department_id: '',
        position_id: '',
        base_salary: '',
        hire_date: '',
        status: 'active',
        shift_schedule_id: null,
        custom_start_time: null,
        custom_end_time: null,
        created_at: null,
        updated_at: null,
        deleted_at: null
      };
      this.showModal = true;
    },
    openEditModal(employee) {
      this.isEditing = true;
      this.formData = {
        id: employee.id,
        employee_id: employee.employee_id,
        first_name: employee.first_name,
        last_name: employee.last_name,
        email: employee.email,
        phone: employee.phone || '',
        department_id: parseInt(employee.department_id),
        position_id: parseInt(employee.position_id),
        base_salary: parseFloat(employee.base_salary),
        hire_date: this.formatDate(employee.hire_date), // Format hire_date correctly
        status: employee.status,
        shift_schedule_id: employee.shift_schedule_id ? parseInt(employee.shift_schedule_id) : null,
        custom_start_time: employee.custom_start_time,
        custom_end_time: employee.custom_end_time
      };
      this.showModal = true;
      this.fetchPositionsByDepartment();
    },
    formatDate(dateString) {
      if (!dateString) return '';
      const date = new Date(dateString);
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      return `${year}-${month}-${day}`;
    },
    closeModal() {
      this.showModal = false;
      this.isEditing = false;
      this.formData = {
        id: null,
        employee_id: '',
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        department_id: '',
        position_id: '',
        base_salary: '',
        hire_date: '',
        status: 'active',
        shift_schedule_id: null,
        custom_start_time: null,
        custom_end_time: null
      };
    },
    async saveEmployee() {
      try {
        this.isLoading = true;
        const employeeData = {
          id: this.formData.id,
          employee_id: this.formData.employee_id,
          first_name: this.formData.first_name,
          last_name: this.formData.last_name,
          email: this.formData.email,
          phone: this.formData.phone,
          department_id: this.formData.department_id,
          position_id: this.formData.position_id,
          base_salary: this.formData.base_salary,
          hire_date: this.formData.hire_date,
          status: this.formData.status,
          shift_schedule_id: this.formData.shift_schedule_id,
          custom_start_time: this.formData.custom_start_time,
          custom_end_time: this.formData.custom_end_time
        };

        let response;
        if (this.isEditing) {
          response = await axios.put(`/api/employees/${this.formData.id}`, employeeData);
        } else {
          response = await axios.post('/api/employees', employeeData);
        }

        if (response.data) {
          this.showSuccess(this.isEditing ? 'Employee updated successfully' : 'Employee added successfully');
          this.closeModal();
          await this.fetchEmployees();
        }
      } catch (error) {
        console.error('Error saving employee:', error);
        this.showError(error.response?.data?.message || 'Failed to save employee');
      } finally {
        this.isLoading = false;
      }
    },
    viewEmployee(employee) {
      this.selectedEmployee = employee;
      this.showViewModal = true;
    },
    deleteEmployee(employee) {
      this.employeeToDelete = employee;
      this.showDeleteModal = true;
    },
    async confirmDelete() {
      this.showLoading('Deleting employee...');
      try {
        await axios.delete(`/api/employees/${this.employeeToDelete.id}`);
        this.showSuccess('Employee deleted successfully');
        this.fetchEmployees();
      } catch (error) {
        this.showError('Failed to delete employee: ' + (error.response?.data?.message || error.message));
      } finally {
        this.hideLoading();
        this.cancelDelete();
      }
    },
    cancelDelete() {
      this.showDeleteModal = false;
      this.employeeToDelete = null;
    },
    resetForm() {
      this.formData = {
        id: null,
        employee_id: '',
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        department_id: '',
        position_id: '',
        base_salary: '',
        hire_date: '',
        status: 'active',
        shift_schedule_id: null,
        custom_start_time: null,
        custom_end_time: null
      };
      this.scheduleError = '';
      this.errorMessage = '';
      this.successMessage = '';
    },
    closeViewModal() {
      this.showViewModal = false;
      this.selectedEmployee = null;
    },
    formatCurrency(value) {
      return new Intl.NumberFormat('en-PH', {
        style: 'currency',
        currency: 'PHP'
      }).format(value);
    },
    validateSalary() {
      const salary = parseFloat(this.formData.base_salary);
      if (salary > 999999.99) {
        this.formData.base_salary = 999999.99;
        this.errorMessage = 'The maximum allowed salary is ₱999,999.99';
      } else if (salary < 0) {
        this.formData.base_salary = 0;
        this.errorMessage = 'Salary cannot be negative';
      } else {
        this.errorMessage = '';
      }
    },
    validateEmail() {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(this.formData.email)) {
        this.errorMessage = 'Please enter a valid email address';
      } else {
        this.errorMessage = '';
      }
    },
    validatePhone() {
      const phoneRegex = /^[09]\d{9,10}$/;
      if (!phoneRegex.test(this.formData.phone)) {
        this.errorMessage = 'Please enter a valid number';
        // Remove any non-digit characters
        this.formData.phone = this.formData.phone.replace(/\D/g, '');
      } else {
        this.errorMessage = '';
      }
    },
    async loadDepartments() {
      try {
        const response = await axios.get('/api/departments')
        this.departments = response.data.data
      } catch (error) {
        console.error('Error loading departments:', error)
      }
    },
    async loadPositions() {
      try {
        this.positions = []
        this.formData.position_id = ''
        
        if (!this.formData.department_id) return
        
        const response = await axios.get(`/api/departments/${this.formData.department_id}/positions`)
        this.positions = response.data
      } catch (error) {
        console.error('Error loading positions:', error)
      }
    },
    closeSuccessModal() {
      this.showSuccessModal = false;
      this.successMessage = '';
    },
    closeErrorModal() {
      this.showErrorModal = false;
      this.errorMessage = '';
    },
    showLoading(message = 'Processing...') {
      this.loadingMessage = message;
      this.isLoading = true;
    },
    hideLoading() {
      this.isLoading = false;
      this.loadingMessage = '';
    },
    showSuccess(message) {
      this.successMessage = message;
      this.showSuccessModal = true;
      // Auto-close after 2 seconds
      setTimeout(() => {
        this.closeSuccessModal();
      }, 2000);
    },
    showError(message) {
      this.errorMessage = message;
      this.showErrorModal = true;
    },
    async updateEmployee(employee) {
      this.showLoading('Updating employee...');
      try {
        const response = await axios.put(`/api/employees/${employee.id}`, employee);
        this.showSuccess('Employee updated successfully');
      } catch (error) {
        this.showError('Failed to update employee: ' + (error.response?.data?.message || error.message));
      } finally {
        this.hideLoading();
      }
    },
    async deleteEmployee(id) {
      if (confirm('Are you sure you want to delete this employee?')) {
        this.showLoading('Deleting employee...');
        try {
          await axios.delete(`/api/employees/${id}`);
          this.showSuccess('Employee deleted successfully');
          await this.fetchEmployees(); // Refresh the list
        } catch (error) {
          this.showError('Failed to delete employee: ' + (error.response?.data?.message || error.message));
        } finally {
          this.hideLoading();
        }
      }
    },
    async fetchAttendanceHistory(employeeId) {
      try {
        const response = await axios.get(`/api/attendance/employee/${employeeId}`);
        if (response.data.status === 'success') {
          console.log('Attendance history:', response.data.data);
        }
      } catch (error) {
        console.error('Error fetching attendance history:', error);
        this.showError('Failed to fetch attendance history');
      }
    },
    openSetPasswordModal(employee) {
      this.selectedEmployee = employee;
      this.showPasswordModal = true;
      this.passwordForm = {
        password: '',
        password_confirmation: ''
      };
    },
    closePasswordModal() {
      this.showPasswordModal = false;
      this.selectedEmployee = null;
      this.passwordForm = {
        password: '',
        password_confirmation: ''
      };
    },
    async submitPassword() {
      try {
        this.loading = true;
        const response = await axios.post(
          `/api/employees/${this.selectedEmployee.id}/set-password`,
          this.passwordForm
        );

        this.showSuccessModal = true;
        this.successMessage = 'Password set successfully';
        this.closePasswordModal();
      } catch (error) {
        this.showErrorModal = true;
        this.errorMessage = error.response?.data?.message || 'Failed to set password';
      } finally {
        this.loading = false;
      }
    },
    async loadShiftSchedules() {
      try {
        const response = await axios.get('/api/shift-schedules');
        this.shiftSchedules = response.data;
      } catch (error) {
        console.error('Error loading shift schedules:', error);
        this.showError('Failed to load shift schedules');
      }
    },
    formatTime(time) {
      if (!time) return '';
      return new Date('2000-01-01 ' + time).toLocaleTimeString([], {
        hour: '2-digit',
        minute: '2-digit'
      });
    },
    getShiftScheduleDisplay(employee) {
      if (!employee?.shift_schedule_id) return 'No schedule set';
      
      const schedule = this.shiftSchedules.find(s => s.id === employee.shift_schedule_id);
      if (!schedule) return 'Unknown schedule';

      if (schedule.name.toLowerCase() === 'custom shift') {
        const startTime = this.formatTime(employee.custom_start_time);
        const endTime = this.formatTime(employee.custom_end_time);
        return `Custom Shift (${startTime} - ${endTime})`;
      }

      return `${schedule.name} (${this.formatTime(schedule.start_time)} - ${this.formatTime(schedule.end_time)})`;
    },
    getShiftClass(employee) {
      if (!employee?.shift_schedule_id) return 'no-shift';
      const schedule = this.shiftSchedules.find(s => s.id === employee.shift_schedule_id);
      if (!schedule) return 'unknown-shift';
      
      return schedule.name.toLowerCase().replace(' ', '-');
    },
    hasCustomSchedule(employee) {
      return employee?.custom_start_time || employee?.custom_end_time;
    },
    validateScheduleTimes() {
      this.scheduleError = '';
      if (!this.formData.custom_start_time || !this.formData.custom_end_time) return;

      const start = new Date(`2000-01-01 ${this.formData.custom_start_time}`);
      const end = new Date(`2000-01-01 ${this.formData.custom_end_time}`);

      if (end <= start) {
        this.scheduleError = 'End time must be after start time';
      }
    }
  },
  mounted() {
    this.fetchEmployees();
    this.fetchDepartments();
    this.fetchPositions();
    this.loadDepartments();
    this.loadShiftSchedules();
  }
};
</script>

<style scoped>
.employee-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  position: relative;
  background-color: #f8f9fa;
}

.wave-bg {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 150px;
  background: linear-gradient(135deg, #6b2c91, #4a1f64);
  border-radius: 0 0 50% 50%;
  z-index: 0;
  box-shadow: 0 4px 20px rgba(107, 44, 145, 0.2);
}

.content-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 2rem;
  height: calc(100vh - 64px);
  position: relative;
  z-index: 1;
  max-width: 1400px;
  margin: 0 auto;
  width: 100%;
}

.header-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  padding: 0 1rem;
}

.header-section h1 {
  color: white;
  font-size: 2rem;
  font-weight: 600;
  margin: 0;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.total-count {
  background: rgba(255, 255, 255, 0.9);
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  color: #6b2c91;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.add-btn {
  background: white;
  color: #6b2c91;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 1rem;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.add-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(107, 44, 145, 0.2);
  background: #6b2c91;
  color: white;
}

.search-section {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  padding: 0 1rem;
}

.search-box {
  flex: 2;
}

.search-box input {
  width: 100%;
  padding: 1rem 1.5rem;
  border: 2px solid #e6ccff;
  border-radius: 10px;
  font-size: 1rem;
  color: #4a1f64;
  background-color: white;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.search-box input:focus {
  border-color: #6b2c91;
  outline: none;
  box-shadow: 0 0 0 4px rgba(107, 44, 145, 0.1);
}

.filter-box {
  flex: 1;
}

.filter-box select {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid #e6ccff;
  border-radius: 8px;
  font-size: 0.95rem;
  color: #6b2c91;
  background-color: #fcfaff;
  cursor: pointer;
  transition: all 0.3s ease;
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%236b2c91' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 0.8rem center;
  padding-right: 2.5rem;
}

.filter-box select:hover {
  border-color: #6b2c91;
}

.filter-box select:focus {
  border-color: #6b2c91;
  outline: none;
  box-shadow: 0 0 0 4px rgba(107, 44, 145, 0.1);
  background-color: #fff;
}

.table-container {
  flex: 1;
  overflow: auto;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  margin: 0 1rem 1rem;
}

table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
}

thead {
  position: sticky;
  top: 0;
  background: white;
  z-index: 2;
}

th {
  background: #f8f4fb;
  color: #4a1f64;
  font-weight: 600;
  padding: 1.25rem 1rem;
  text-align: left;
  border-bottom: 2px solid #e9ecef;
  white-space: nowrap;
  font-size: 0.95rem;
  letter-spacing: 0.5px;
}

td {
  padding: 1.25rem 1rem;
  border-bottom: 1px solid #e9ecef;
  color: #444;
  font-size: 0.95rem;
  transition: all 0.2s ease;
}

tr:hover td {
  background-color: #f8f4fb;
}

.status-badge {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: capitalize;
  white-space: nowrap;
  transition: all 0.3s ease;
}

.status-badge.active {
  background-color: #dcfce7;
  color: #16a34a;
}

.status-badge.inactive {
  background-color: #fee2e2;
  color: #dc2626;
}

.status-badge.on_leave {
  background-color: #fef3c7;
  color: #d97706;
}

.action-buttons {
  display: flex;
  gap: 0.75rem;
  justify-content: flex-start;
}

.action-buttons button {
  padding: 0.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
}

.view-btn { 
  background-color: #e0e7ff;
  color: #4f46e5;
}

.edit-btn { 
  background-color: #e0f2fe;
  color: #0284c7;
}

.delete-btn { 
  background-color: #fee2e2;
  color: #dc2626;
}

.action-buttons button:hover {
  transform: translateY(-2px);
}

.view-btn:hover {
  background-color: #4f46e5;
  color: white;
}

.edit-btn:hover {
  background-color: #0284c7;
  color: white;
}

.delete-btn:hover {
  background-color: #dc2626;
  color: white;
}

/* Modal Styles */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100vh;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
  overflow: hidden;
}

.modal-content {
  background: white;
  padding: 1.5rem;
  border-radius: 16px;
  width: 500px;
  max-width: 90%;
  max-height: 90vh;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  animation: modalSlideIn 0.3s ease-out;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

/* Add styles for the modal scrollbar */
.modal-content::-webkit-scrollbar {
  width: 8px;
}

.modal-content::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.modal-content::-webkit-scrollbar-thumb {
  background: #c5a5db;
  border-radius: 4px;
}

.modal-content::-webkit-scrollbar-thumb:hover {
  background: #6b2c91;
}

/* Update form styles to work better in scrollable container */
form {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  padding-right: 1rem;
}

.form-group {
  margin-bottom: 0.75rem;
  text-align: left;
  flex-shrink: 0;
}

/* Modal header styles */
.modal-content h2 {
  position: sticky;
  top: 0;
  background: white;
  padding: 1rem 1.5rem 0.75rem 1.5rem;
  margin: -1.5rem -1.5rem 1rem -1.5rem;
  font-size: 1.3rem;
  color: #4a1f64;
  z-index: 1;
}

/* Update form buttons container */
.form-buttons {
  position: sticky;
  bottom: 0;
  background: white;
  padding: 0.75rem 1.5rem;
  margin: 0.75rem -1.5rem -1.5rem -1.5rem;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  z-index: 1;
}

/* Add smooth scroll behavior */
.modal-content {
  scroll-behavior: smooth;
}

/* Add responsive adjustments */
@media (max-height: 800px) {
  .modal-content {
    max-height: 85vh;
  }
}

@media (max-height: 600px) {
  .modal-content {
    max-height: 80vh;
  }
}

/* Update animation for better performance */
@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.form-group {
  margin-bottom: 1.5rem;
  text-align: left;
}

.form-group label {
  display: block;
  margin-bottom: 0.25rem;
  color: #4a1f64;
  font-weight: 600;
  font-size: 0.9rem;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 0.6rem 0.8rem;
  border: 2px solid #e6ccff;
  border-radius: 8px;
  font-size: 0.95rem;
  color: #6b2c91;
  background-color: #fcfaff;
  transition: all 0.3s ease;
}

.form-group input::placeholder,
.form-group select::placeholder {
  color: #9d7bb7;
}

.form-group input:focus,
.form-group select:focus {
  border-color: #6b2c91;
  outline: none;
  box-shadow: 0 0 0 4px rgba(107, 44, 145, 0.1);
  background-color: #fff;
}

.form-group input:disabled,
.form-group select:disabled {
  background-color: #f8f4fb;
  border-color: #e6ccff;
  color: #9d7bb7;
  cursor: not-allowed;
}

.form-group select {
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%236b2c91' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 0.8rem center;
  padding-right: 2.5rem;
}

.form-group input[type="number"]::-webkit-inner-spin-button,
.form-group input[type="number"]::-webkit-outer-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

.form-group input[type="number"] {
  -moz-appearance: textfield;
}

.form-group input[type="date"] {
  color: #6b2c91;
}

.form-group input[type="date"]::-webkit-calendar-picker-indicator {
  filter: invert(20%) sepia(82%) saturate(1404%) hue-rotate(256deg) brightness(88%) contrast(93%);
  cursor: pointer;
}

.helper-text {
  font-size: 0.8rem;
  color: #666;
  margin-top: 0.25rem;
}

.form-buttons {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
}

.submit-btn,
.cancel-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.submit-btn {
  background: #6b2c91;
  color: white;
}

.cancel-btn {
  background: #f3f4f6;
  color: #4b5563;
}

.submit-btn:hover {
  background: #4a1f64;
  transform: translateY(-2px);
}

.cancel-btn:hover {
  background: #e5e7eb;
  transform: translateY(-2px);
}

/* Error and Success Messages */
.error-message,
.success-message {
  padding: 0.75rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  font-weight: 500;
}

.error-message {
  background-color: #fee2e2;
  color: #dc2626;
  border: 1px solid #fecaca;
}

.success-message {
  background-color: #dcfce7;
  color: #16a34a;
  border: 1px solid #bbf7d0;
}

/* Modal Styles */
.modal-content.success {
  border-top: 6px solid #28a745;
}

.modal-content.error {
  border-top: 6px solid #dc3545;
}

.modal-content.loading {
  border-top: 6px solid #007bff;
}

.modal-header {
  margin-bottom: 1.5rem;
}

.success-icon {
  font-size: 3rem;
  color: #28a745;
  margin-bottom: 1rem;
}

.error-icon {
  font-size: 3rem;
  color: #dc3545;
  margin-bottom: 1rem;
}

.modal-header h2 {
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
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1.1em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.success-btn {
  background: linear-gradient(135deg, #2ecc71, #27ae60);
}

.error-btn {
  background: linear-gradient(135deg, #dc3545, #c82333);
}

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

/* Update the employee details view modal styles */
.employee-details {
  padding: 1rem;
}

.detail-row {
  display: flex;
  margin-bottom: 1rem;
  padding: 0.5rem;
  border-bottom: 1px solid #e6ccff;
}

.detail-row:last-child {
  border-bottom: none;
}

.detail-row .label {
  flex: 1;
  font-weight: 600;
  color: #6b2c91; /* Purple theme color */
  min-width: 120px;
}

.detail-row .value {
  flex: 2;
  color: #4a1f64; /* Darker purple for values */
}

/* Update the view modal header */
.modal-content h2 {
  color: #6b2c91;
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
  border-bottom: 2px solid #e6ccff;
  padding-bottom: 0.75rem;
}

/* Style the close button */
.close-btn {
  margin-top: 1rem;
  padding: 0.75rem 2rem;
  background: linear-gradient(135deg, #6b2c91, #4a1f64);
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.close-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(107, 44, 145, 0.2);
}

/* Add status styling */
.detail-row .value.status {
  text-transform: capitalize;
  font-weight: 500;
}

.status-active {
  color: #16a34a;
}

.status-inactive {
  color: #dc2626;
}

.status-on_leave {
  color: #f59e0b;
}

.password-btn {
  background-color: #fbbf24;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.password-btn:hover {
  background-color: #f59e0b;
  transform: translateY(-2px);
}
</style>