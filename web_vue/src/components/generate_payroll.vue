<template>
  <div class="payroll-container">
    <!-- Loading Overlay -->
    <div class="loading-overlay" v-if="isLoading">
      <div class="loading-spinner"></div>
    </div>

    <div class="wave-bg"></div>
    <h1>Generate Payroll</h1>

    <!-- Alert Messages -->
    <div v-if="errorMessage" class="alert alert-error">
      <span class="close-btn" @click="errorMessage = ''">×</span>
      {{ errorMessage }}
    </div>
    <div v-if="successMessage" class="alert alert-success">
      <span class="close-btn" @click="successMessage = ''">×</span>
      {{ successMessage }}
    </div>

    <!-- Employee Selection Section -->
    <div class="section employee-section">
      <div class="employee-search-container">
        <label>Select Employee</label>
        <div class="search-dropdown">
          <input
            type="text"
            v-model="searchQuery"
            placeholder="Search employee..."
            class="purple-input"
            @focus="showDropdown = true"
          >
          <div v-if="showDropdown" class="dropdown-list">
            <div 
              v-for="emp in filteredEmployees" 
              :key="emp.id"
              class="dropdown-item"
              @click="selectEmployee(emp)"
            >
              <div class="employee-info">
                <span class="employee-name">{{ emp.name }}</span>
                <span class="employee-dept">{{ emp.department }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    
      <!-- Employee Details Card -->
      <div class="employee-details" v-if="selectedEmployee">
  <div class="detail-item">
    <span class="label">Employee ID</span>
    <span class="value">{{ employeeDetails.id }}</span>
  </div>
  <div class="detail-item">
    <span class="label">Department</span>
    <span class="value">{{ employeeDetails.department }}</span>
  </div>
  <div class="detail-item">
    <span class="label">Position</span>
    <span class="value">{{ employeeDetails.position }}</span>
  </div>
  <div class="detail-item">
    <span class="label">Base Salary</span> <!-- Change label to Base Salary -->
    <span class="value">₱{{ formatCurrency(employeeDetails.baseSalary) }}</span> <!-- Use baseSalary -->
  </div>
</div>
    </div>

    <!-- Attendance Records Section -->
    <div class="section attendance-section" v-if="selectedEmployee">
      <h2>Attendance Records</h2>
      
      <!-- Attendance Controls -->
      <div class="attendance-controls">
        <div class="controls-left">
        <div class="records-per-page">
          <label>Show entries:</label>
          <select v-model="recordsPerPage" class="purple-select">
            <option value="10">10</option>
            <option value="25">25</option>
            <option value="50">50</option>
            <option value="100">100</option>
          </select>
        </div>
        <!-- Add year selector -->
        <div class="year-selector">
  <label>Year:</label>
  <select v-model="selectedYear" class="purple-select">
    <option v-for="year in availableYears" 
            :key="year" 
            :value="year">
      {{ year }}
    </option>
  </select>
</div>
        <!-- Add month selector -->
        <div class="month-selector">
          <label>Month:</label>
          <select v-model="selectedMonth" class="purple-select" @change="fetchAttendanceHistory">
            <option v-for="(month, index) in months" :key="index" :value="index + 1">
              {{ month }}
            </option>
          </select>
        </div>
        </div>
        <div class="controls-right">
          <button 
            class="refresh-btn" 
            @click="refreshAttendance"
            :disabled="isLoading"
          >
            <span class="icon">↻</span>
            Refresh
          </button>
          <button 
            class="show-all-btn" 
            @click="toggleShowAll"
            :class="{ active: showingAll }"
          >
            {{ showingAll ? 'Show Recent' : 'Show All' }}
          </button>
        </div>
      </div>

      <!-- Attendance Table -->
      <div class="attendance-table">
        <table>
          <thead>
            <tr>
              <th>
                <div class="th-header">
                  <span>Date</span>
                  <button class="sort-btn" @click="sortBy('date')">
                    {{ getSortIcon('date') }}
                  </button>
                </div>
                <div class="th-content">
                  <div class="filter-group">
                  <input 
                    type="date" 
                    v-model="dateFilter"
                    class="th-filter"
                      :max="currentDate"
                    >
                    <button 
                      v-if="dateFilter" 
                      class="clear-filter" 
                      @click="dateFilter = ''"
                    >×</button>
                  </div>
                </div>
              </th>
              <th>
                <div class="th-header">
                  <span>Time In</span>
                  <button class="sort-btn" @click="sortBy('timeIn')">
                    {{ getSortIcon('timeIn') }}
                  </button>
                </div>
              </th>
              <th>
                <div class="th-header">
                  <span>Time Out</span>
                  <button class="sort-btn" @click="sortBy('timeOut')">
                    {{ getSortIcon('timeOut') }}
                  </button>
                </div>
              </th>
              <th>
                <div class="th-header">
                  <span>Status</span>
                  <button class="sort-btn" @click="sortBy('status')">
                    {{ getSortIcon('status') }}
                  </button>
                </div>
                <div class="th-content">
                  <div class="filter-group">
                    <label>Status:</label>
                    <select v-model="statusFilter" class="purple-select">
                      <option value="">All Status</option>
                      <option value="present">Present</option>
                      <option value="absent">Absent</option>
                      <option value="late">Late</option>
                      <option value="on_leave">On Leave</option>
                    </select>
                    <button 
                      v-if="statusFilter" 
                      class="clear-filter" 
                      @click="statusFilter = ''"
                    >×</button>
                  </div>
                </div>
              </th>
              <th>
                <div class="th-header">
                  <span>Hours</span>
                  <button class="sort-btn" @click="sortBy('hoursWorked')">
                    {{ getSortIcon('hoursWorked') }}
                  </button>
                </div>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr 
              v-for="record in paginatedRecords" 
              :key="record.id"
              :class="{ 'highlight': isToday(record.date) }"
            >
              <td>{{ formatDate(record.date) }}</td>
              <td>{{ record.timeIn }}</td>
              <td>{{ record.timeOut }}</td>
              <td>
                <span class="status-badge" :class="record.status">
                  {{ record.status === 'on_leave' ? 'On Leave' : 
                     record.status.charAt(0).toUpperCase() + record.status.slice(1) }}
                </span>
              </td>
              <td>{{ record.hoursWorked }} hrs</td>
            </tr>
          </tbody>
          <tfoot v-if="!paginatedRecords.length">
            <tr>
              <td colspan="5" class="no-records">
                <div class="empty-state">
                  <span class="icon">📋</span>
                  <p>No attendance records found</p>
                  <small>{{ getEmptyStateMessage() }}</small>
                </div>
              </td>
            </tr>
          </tfoot>
        </table>
      </div>

      <!-- Pagination -->
      <div class="pagination-controls" v-if="filteredRecords.length > 0">
        <button 
          class="pagination-btn" 
          :disabled="currentPage === 1"
          @click="currentPage--"
        >
          Previous
        </button>
        <span class="page-info">Page {{ currentPage }} of {{ totalPages }}</span>
        <button 
          class="pagination-btn" 
          :disabled="currentPage === totalPages"
          @click="currentPage++"
        >
          Next
        </button>
      </div>

      <!-- Attendance Summary -->
      <div class="attendance-stats">
        <div class="stat-card present">
          <span class="label">Present Days</span>
          <span class="value">{{ presentDays }}</span>
          <div class="icon">✓</div>
        </div>
        <div class="stat-card late">
          <span class="label">Late Days</span>
          <span class="value">{{ lateDays }}</span>
          <div class="icon">⏰</div>
        </div>
        <div class="stat-card absent">
          <span class="label">Absent Days</span>
          <span class="value">{{ absentDays }}</span>
          <div class="icon">✗</div>
        </div>
        <div class="stat-card hours">
          <span class="label">Total Hours</span>
          <span class="value">{{ totalHours }} hrs</span>
          <div class="icon">⌛</div>
        </div>
      </div>
    </div>

    <!-- Increases Section -->
    <div class="section increases-section" v-if="selectedEmployee">
      <h2>Salary Increases and Bonuses</h2>
      <div class="increases-grid">
        <!-- Performance-Based Increases -->
        <div class="increase-category">
          <h3>Performance-Based Increases</h3>
          <div class="increase-items">
            <div 
              v-for="item in performanceIncreases" 
              :key="item.id"
              class="increase-item"
            >
              <div class="increase-header">
                <label class="checkbox-label">
                  <input type="checkbox" v-model="item.selected">
                  {{ item.name }}
                </label>
                <div class="tooltip" :data-tooltip="item.description">ⓘ</div>
              </div>
              <div class="increase-inputs" v-if="item.selected">
                <input 
                  type="number" 
                  v-model="item.amount"
                  :step="item.type === 'percentage' ? 0.1 : 1"
                  :max="item.maxAmount"
                  class="purple-input"
                >
                <span class="unit">{{ item.type === 'percentage' ? '%' : '₱' }}</span>
                <div class="calculated-amount">
                  = ₱{{ formatCurrency(calculateIncrease(item)) }}
                </div>
              </div>
            </div>
          </div>
        </div>
        <!-- Incentives and Bonuses -->
        <div class="increase-category">
          <h3>Incentives and Bonuses</h3>
          <div class="increase-items">
            <div 
              v-for="item in incentivesAndBonuses" 
              :key="item.id"
              class="increase-item"
            >
              <div class="increase-header">
                <label class="checkbox-label">
                  <input type="checkbox" v-model="item.selected">
                  {{ item.name }}
                </label>
                <div class="tooltip" :data-tooltip="item.description">ⓘ</div>
              </div>
              <div class="increase-inputs" v-if="item.selected">
                <input 
                  type="number" 
                  v-model="item.amount"
                  :step="item.type === 'percentage' ? 0.1 : 1"
                  class="purple-input"
                >
                <span class="unit">{{ item.type === 'percentage' ? '%' : '₱' }}</span>
                <div class="calculated-amount">
                  = ₱{{ formatCurrency(calculateIncrease(item)) }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Deductions Section -->
    <div class="section deductions-section" v-if="selectedEmployee">
      <h2>Deductions</h2>
      <div class="deductions-grid">
        <!-- Statutory Deductions -->
        <div class="deduction-category">
          <h3>Statutory Deductions</h3>
          <div class="deduction-items">
            <div 
              v-for="item in statutoryDeductions" 
              :key="item.id"
              class="deduction-item"
            >
              <div class="deduction-info">
                <div class="deduction-header">
                  <span class="deduction-name">{{ item.name }}</span>
                  <div class="tooltip" :data-tooltip="item.description">ⓘ</div>
                </div>
                <div class="deduction-details">
                  Base: ₱{{ formatCurrency(employeeDetails?.baseSalary || 0) }}
                  <span class="calculation-formula">
                    × {{ item.rate }}% = 
                  </span>
                </div>
              </div>
              <div class="deduction-amount">
                <div class="calculated-amount negative">
                  - ₱{{ formatCurrency(calculateDeduction(item)) }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Other Deductions -->
        <div class="deduction-category">
          <h3>Other Deductions</h3>
          <div class="deduction-items">
            <div 
              v-for="item in otherDeductions" 
              :key="item.id"
              class="deduction-item"
            >
              <div class="deduction-info">
                <label class="checkbox-label">
                  <input type="checkbox" v-model="item.selected">
                  {{ item.name }}
                </label>
                <div class="tooltip" :data-tooltip="item.description">ⓘ</div>
              </div>
              <div class="deduction-inputs" v-if="item.selected">
                <input 
                  type="number" 
                  v-model="item.amount"
                  :step="item.type === 'percentage' ? 0.1 : 1"
                  class="purple-input"
                >
                <span class="unit">{{ item.type === 'percentage' ? '%' : '₱' }}</span>
                <div class="calculated-amount negative">
                  - ₱{{ formatCurrency(calculateDeduction(item)) }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Summary Section -->
    <div class="section summary-section" v-if="selectedEmployee">
      <h2>Payroll Summary</h2>
      <div class="summary-grid">
        <div class="summary-item">
          <span class="label">Base Salary</span>
          <span class="amount">₱{{ formatCurrency(employeeDetails?.baseSalary || 0) }}</span>
        </div>
        <div class="summary-item">
          <span class="label">Total Increases</span>
          <span class="amount positive">+₱{{ formatCurrency(totalIncreases) }}</span>
        </div>
        <div class="summary-item">
          <span class="label">Total Deductions</span>
          <span class="amount negative">-₱{{ formatCurrency(totalDeductions) }}</span>
        </div>
        <div class="summary-item total">
          <span class="label">Net Salary</span>
          <span class="amount">₱{{ formatCurrency(netSalary) }}</span>
        </div>
      </div>

      <!-- Generate Button -->
      <div class="generate-section">
        <button 
          class="generate-btn" 
          @click="generatePayroll"
          :disabled="isLoading"
        >
          {{ isLoading ? 'Generating...' : 'Generate Payroll' }}
        </button>
      </div>
    </div>
  </div>
</template>
<script>
import axios from 'axios'; 
export default {
  name: 'GeneratePayroll',
  
  data() {
    return {
      // UI States
      isLoading: false,
      errorMessage: '',
      successMessage: '',
      currentPage: 1,
      recordsPerPage: 10,
      searchQuery: '',
      showDropdown: false,
      dateFilter: '',
      statusFilter: '',
      selectedMonth: new Date().toISOString().slice(0, 7),
      
      // Employee Data
      selectedEmployee: '',
      employeeDetails: {
      id: '',
      name: '',
      department: '',
      position: '',
      baseSalary: 0
    },
      employees: [],
      departments: [],
      attendanceRecords: [],

      // Performance Increases
      performanceIncreases: [
        {
          id: 1,
          name: 'Merit Raise',
          description: 'Performance-based permanent increase in base salary',
          type: 'percentage',
          amount: 0,
          selected: false,
          maxAmount: 15
        },
        {
          id: 2,
          name: 'Promotion Raise',
          description: 'Salary adjustment for position promotion',
          type: 'percentage',
          amount: 0,
          selected: false,
          maxAmount: 30
        }
      ],

      // Incentives and Bonuses
      incentivesAndBonuses: [
        {
          id: 3,
          name: 'Performance Bonus',
          description: 'One-time bonus for exceptional performance',
          type: 'fixed',
          amount: 0,
          selected: false
        },
        {
          id: 4,
          name: 'Attendance Bonus',
          description: 'Perfect attendance reward: ₱200',
          type: 'fixed',
          amount: 200,
          selected: false
        },
        {
          id: 5,
          name: '13th Month Pay',
          description: 'Prorated 13th month pay',
          type: 'percentage',
          amount: 8.33, // 1/12 of annual salary
          selected: false
        },
        // Add new items
        {
          id: 6,
          name: 'Overtime Pay',
          description: 'Additional pay for overtime hours worked',
          type: 'fixed',
          amount: 0,
          selected: false
        },
        {
          id: 7,
          name: 'Holiday Pay',
          description: 'Additional pay for working on holidays',
          type: 'fixed',
          amount: 0,
          selected: false
        },
        {
          id: 8,
          name: 'Other Increase',
          description: 'Other additional payments or allowances',
          type: 'fixed',
          amount: 0,
          selected: false
        }
      ],

      // Updated Statutory Deductions
      statutoryDeductions: [
        {
          id: 1,
          name: 'Income Tax',
          description: 'Progressive tax based on salary bracket',
          type: 'percentage',
          rate: 20,
          amount: 0
        },
        {
          id: 2,
          name: 'Social Security',
          description: 'Mandatory social security contribution',
          type: 'percentage',
          rate: 6.2,
          amount: 0
        },
        {
          id: 3,
          name: 'Medicare',
          description: 'Healthcare contribution',
          type: 'percentage',
          rate: 1.45,
          amount: 0
        },
        {
          id: 4,
          name: 'PhilHealth',
          description: 'National health insurance',
          type: 'percentage',
          rate: 2.75,
          amount: 0
        },
        {
          id: 5,
          name: 'Pag-IBIG',
          description: 'Housing development fund',
          type: 'percentage',
          rate: 2,
          amount: 0
        }
      ],

      // Other Deductions
      otherDeductions: [
        {
          id: 6,
          name: 'Health Insurance',
          description: 'Optional health insurance premium',
          type: 'fixed',
          amount: 0,
          selected: false
        },
        {
          id: 7,
          name: 'Life Insurance',
          description: 'Optional life insurance premium',
          type: 'fixed',
          amount: 0,
          selected: false
        }
      ],

      // New data properties
      showingAll: false,
      sortColumn: 'date',
      sortDirection: 'desc',
      currentDate: new Date().toISOString().split('T')[0],
      selectedYear: new Date().getFullYear(),
      availableYears: [], // Will be populated dynamically

      selectedMonth: new Date().getMonth() + 1,
      availableYears: [],
      months: [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ],
      attendanceRecords: [],
    isLoading: false,
  
    }
  },

  computed: {
    // Attendance Computations
    filteredRecords() {
      return this.attendanceRecords.filter(record => {
        let matchDate = true;
        let matchStatus = true;
        
        if (this.dateFilter) {
          matchDate = record.date.includes(this.dateFilter);
        }
        
        if (this.statusFilter) {
          matchStatus = record.status.toLowerCase() === this.statusFilter.toLowerCase();
        }
        
        return matchDate && matchStatus;
      }).sort((a, b) => {
        const modifier = this.sortDirection === 'asc' ? 1 : -1;
        if (this.sortColumn === 'date') {
          return modifier * (new Date(a.date) - new Date(b.date));
        }
        return modifier * (a[this.sortColumn] > b[this.sortColumn] ? 1 : -1);
      });
    },

    paginatedRecords() {
      const start = (this.currentPage - 1) * this.recordsPerPage;
      const end = start + this.recordsPerPage;
      return this.filteredRecords.slice(start, end);
    },

    totalPages() {
      return Math.ceil(this.filteredRecords.length / this.recordsPerPage);
    },

    // Attendance Summary
    presentDays() {
    return this.attendanceRecords.filter(r => r.status.toLowerCase() === 'present').length;
  },

  lateDays() {
    return this.attendanceRecords.filter(r => r.status.toLowerCase() === 'late').length;
  },

  absentDays() {
    return this.attendanceRecords.filter(r => r.status.toLowerCase() === 'absent').length;
  },

  totalHours() {
    return this.attendanceRecords.reduce((total, record) => total + record.hoursWorked, 0).toFixed(2);
  },

    // Financial Calculations
    totalIncreases() {
    let total = 0;
    this.performanceIncreases.forEach(item => {
      if (item.selected) {
        total += this.calculateIncrease(item);
      }
    });
    this.incentivesAndBonuses.forEach(item => {
      if (item.selected) {
        total += this.calculateIncrease(item);
      }
    });
    return parseFloat(total.toFixed(2));
  },

   
  totalDeductions() {
    let total = 0;
    this.statutoryDeductions.forEach(item => {
      total += this.calculateDeduction(item);
    });
    this.otherDeductions.forEach(item => {
      if (item.selected) {
        total += this.calculateDeduction(item);
      }
    });
    return parseFloat(total.toFixed(2));
  },

  // Calculate total salary based on hours worked
  baseSalaryWithHours() {
    const hourlyRate = parseFloat(this.employeeDetails.baseSalary) || 0; // Base salary is now hourly rate
    const totalHours = parseFloat(this.totalHours) || 0;
    return hourlyRate * totalHours;
  },

  // Update net salary calculation
  netSalary() {
    const baseSalaryWithHours = this.baseSalaryWithHours;
    const increases = this.totalIncreases;
    const deductions = this.totalDeductions;
    return parseFloat((baseSalaryWithHours + increases - deductions).toFixed(2));
  },

    filteredEmployees() {
      if (!this.searchQuery) return this.employees;
      
      const query = this.searchQuery.toLowerCase();
      return this.employees.filter(emp => 
        emp.name.toLowerCase().includes(query) ||
        emp.department.toLowerCase().includes(query)
      );
    }
  },

  methods: {
    generateAvailableYears() {
    const currentYear = new Date().getFullYear();
    const startYear = 2020; // You can adjust this based on your needs
    const years = [];
    for (let year = currentYear; year >= startYear; year--) {
      years.push(year);
    }
    this.availableYears = years;
  },
    async fetchEmployees() {
      try {
        const response = await axios.get('/api/employees')
        this.employees = response.data.map(emp => ({
          id: emp.id,
          name: `${emp.first_name} ${emp.last_name}`,
          department: emp.department?.name || 'N/A',
          position: emp.position?.title || 'N/A',
          baseSalary: emp.base_salary || 0
        }))
      } catch (error) {
        console.error('Error fetching employees:', error)
        this.errorMessage = 'Failed to load employees'
      }
    },

    async fetchDepartments() {
      try {
        const response = await axios.get('/api/departments')
        this.departments = response.data.data
      } catch (error) {
        console.error('Error fetching departments:', error)
        this.errorMessage = 'Failed to load departments'
      }
    },

    // Formatting Methods
    formatCurrency(value) {
      return Number(value).toFixed(2);
    },

    formatDate(dateString) {
    if (!dateString) return '-';
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    } catch (error) {
      console.error('Error formatting date:', error);
      return dateString;
    }
  },
    formatTime(date) {
      if (!date) return '-';
      return date.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      });
    },

    // Calculation Methods
    calculateIncrease(item) {
        if (!this.employeeDetails.baseSalary) return 0;
        
        const baseSalary = parseFloat(this.employeeDetails.baseSalary) || 0;
        const amount = parseFloat(item.amount) || 0;

        if (item.type === 'percentage') {
            return (baseSalary * amount / 100);
        }
        return amount;
    },



     calculateDeduction(item) {
      if (!this.employeeDetails.baseSalary) return 0;
    
    const baseSalary = parseFloat(this.employeeDetails.baseSalary) || 0;
    const rate = parseFloat(item.rate || item.amount) || 0;
    
    

    if (item.type === 'percentage') {
      const deduction = (baseSalary * rate / 100);
      return deduction;
    }
  return parseFloat(item.amount) || 0;
  
  },
  validateAmount(item) {
  if (item.type === 'percentage') {
    item.amount = Math.min(Math.max(0, parseFloat(item.amount) || 0), item.maxAmount || 100);
  } else {
    item.amount = Math.max(0, parseFloat(item.amount) || 0);
  }
},
    // Data Loading Methods
    async loadEmployeeData() {
    try {
      if (!this.selectedEmployee) {
        console.warn('No employee selected');
        return;
      }

      const response = await axios.get(`/api/employees/${this.selectedEmployee}`);
      
      this.employeeDetails = {
        id: response.data.id,
        name: `${response.data.first_name} ${response.data.last_name}`,
        department: response.data.department?.name || 'N/A',
        position: response.data.position?.title || 'N/A',
        baseSalary: response.data.base_salary || 0
      };

      // Generate and fetch years
      this.generateAvailableYears();
      await this.fetchAttendanceHistory();
      
      this.calculateDefaultDeductions();
      this.resetSelections();
      this.successMessage = 'Employee data loaded successfully';

    } catch (error) {
      console.error('Error in loadEmployeeData:', error);
      this.showError('Failed to load employee data: ' + 
        (error.response?.data?.message || error.message));
    }
  },

  // Calculate hours worked with proper handling of night shift
  calculateHoursWorked(timeIn, timeOut) {
    if (!timeIn || !timeOut) return 0;
    
    try {
      let diff = new Date(timeOut) - new Date(timeIn);
      let hours = diff / (1000 * 60 * 60);
      
      // Round to 2 decimal places
      return Math.round(hours * 100) / 100;
    } catch (error) {
      console.error('Error calculating hours:', error);
      return 0;
    }
  },


    // Calculate default statutory deductions
    calculateDefaultDeductions() {
      if (!this.employeeDetails) return;

      const baseSalary = this.employeeDetails.baseSalary;
      
      // Update statutory deductions based on base salary
      this.statutoryDeductions.forEach(deduction => {
        switch(deduction.name) {
          case 'Income Tax':
            // Progressive tax calculation
            if (baseSalary <= 2500) {
              deduction.rate = 0;
            } else if (baseSalary <= 3500) {
              deduction.rate = 15;
            } else if (baseSalary <= 5000) {
              deduction.rate = 20;
            } else {
              deduction.rate = 25;
            }
            break;
          
          case 'Social Security':
            // Cap SSS contribution at maximum salary base
            const maxSalaryBase = 5000;
            deduction.amount = Math.min(baseSalary, maxSalaryBase) * (deduction.rate / 100);
            break;
          
          case 'PhilHealth':
            // Premium rate based on salary range
            if (baseSalary <= 3000) {
              deduction.rate = 2;
            } else if (baseSalary <= 4000) {
              deduction.rate = 2.5;
            } else {
              deduction.rate = 2.75;
            }
            break;
          
          // Other deductions maintain their default rates
          default:
            break;
        }
      });
    },

    // Generate sample attendance records
    generateSampleRecords() {
      const records = [];
      const statuses = ['Present', 'Late', 'Absent'];
      const startDate = new Date();
      startDate.setDate(1); // Start from beginning of current month

      // Generate records for current month
      const daysInMonth = new Date(
        startDate.getFullYear(),
        startDate.getMonth() + 1,
        0
      ).getDate();

      for (let i = 0; i < daysInMonth; i++) {
        const currentDate = new Date(startDate);
        currentDate.setDate(startDate.getDate() + i);
        
        // Skip weekends
        if (currentDate.getDay() === 0 || currentDate.getDay() === 6) {
          continue;
        }

        // Generate random status with weighted probability
        const rand = Math.random();
        let status;
        if (rand < 0.7) status = 'Present';
        else if (rand < 0.85) status = 'Late';
        else status = 'Absent';

        let timeIn = '08:00 AM';
        let timeOut = '05:00 PM';
        let hoursWorked = 8;

        // Adjust times based on status
        switch(status) {
          case 'Late':
            const lateMinutes = Math.floor(Math.random() * 60) + 1;
            timeIn = `${8 + Math.floor(lateMinutes/60)}:${String(lateMinutes % 60).padStart(2, '0')} AM`;
            hoursWorked = 8 - (lateMinutes/60);
            break;
          
          case 'Absent':
            timeIn = '--';
            timeOut = '--';
            hoursWorked = 0;
            break;
          
         
        }

        records.push({
          date: currentDate.toISOString().split('T')[0],
          timeIn,
          timeOut,
          status,
          hoursWorked: hoursWorked.toFixed(2)
        });
      }

      return records.sort((a, b) => new Date(b.date) - new Date(a.date));
    },

    // Reset all selections
    resetSelections() {
      [...this.performanceIncreases, ...this.incentivesAndBonuses].forEach(item => {
        item.selected = false;
        item.amount = item.defaultAmount || 0;
      });

      this.otherDeductions.forEach(item => {
        item.selected = false;
        item.amount = 0;
      });
    },

    // Generate final payroll
    async generatePayroll() {
      try {
        this.isLoading = true;
        this.errorMessage = '';
        
        // Calculate first and last day of current month
        const today = new Date();
        const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        const lastDayOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);
        
        const increases = {
            merit_raise: 0,
            promotion_raise: 0,
            performance_bonus: 0,
            attendance_bonus: 0,
            thirteenth_month: 0,
            overtime_pay: 0,
            holiday_pay: 0,
            other_increase: 0
        };

        // Add logging for performance increases
        console.log('Performance Increases before mapping:', this.performanceIncreases);
        this.performanceIncreases.forEach(item => {
            if (item.selected) {
                const calculatedAmount = this.calculateIncrease(item);
                console.log(`Calculating ${item.name}:`, {
                    baseSalary: this.employeeDetails.baseSalary,
                    amount: item.amount,
                    type: item.type,
                    calculated: calculatedAmount
                });
                
                switch(item.name) {
                    case 'Merit Raise':
                        increases.merit_raise = calculatedAmount;
                        console.log('Set merit_raise to:', calculatedAmount);
                        break;
                    case 'Promotion Raise':
                        increases.promotion_raise = calculatedAmount;
                        console.log('Set promotion_raise to:', calculatedAmount);
                        break;
                }
            }
        });

        // Add logging for incentives and bonuses
        console.log('Incentives and Bonuses before mapping:', this.incentivesAndBonuses);
        this.incentivesAndBonuses.forEach(item => {
            if (item.selected) {
                const calculatedAmount = this.calculateIncrease(item);
                console.log(`Calculating ${item.name}:`, {
                    baseSalary: this.employeeDetails.baseSalary,
                    amount: item.amount,
                    type: item.type,
                    calculated: calculatedAmount
                });
                
                switch(item.name) {
                    case 'Performance Bonus':
                        increases.performance_bonus = calculatedAmount;
                        console.log('Set performance_bonus to:', calculatedAmount);
                        break;
                    case 'Attendance Bonus':
                        increases.attendance_bonus = calculatedAmount;
                        console.log('Set attendance_bonus to:', calculatedAmount);
                        break;
                    case '13th Month Pay':
                        increases.thirteenth_month = calculatedAmount;
                        console.log('Set thirteenth_month to:', calculatedAmount);
                        break;
                    // Add new cases
                    case 'Overtime Pay':
                        increases.overtime_pay = calculatedAmount;
                        console.log('Set overtime_pay to:', calculatedAmount);
                        break;
                    case 'Holiday Pay':
                        increases.holiday_pay = calculatedAmount;
                        console.log('Set holiday_pay to:', calculatedAmount);
                        break;
                    case 'Other Increase':
                        increases.other_increase = calculatedAmount;
                        console.log('Set other_increase to:', calculatedAmount);
                        break;
                }
            }
        });

        const deductions = {
            income_tax: 0,
            social_security: 0,
            medicare: 0,
            philhealth: 0,
            pagibig: 0,
            health_insurance: 0,
            life_insurance: 0,
            loan: 0,
            other_deduction: 0
        };

        // Add logging for statutory deductions
        console.log('Statutory Deductions before mapping:', this.statutoryDeductions);
        this.statutoryDeductions.forEach(item => {
            const calculatedAmount = this.calculateDeduction(item);
            console.log(`Calculating ${item.name}:`, {
                baseSalary: this.employeeDetails.baseSalary,
                rate: item.rate,
                amount: item.amount,
                calculated: calculatedAmount
            });
            
            switch(item.name) {
                case 'Income Tax':
                    deductions.income_tax = calculatedAmount;
                    console.log('Set income_tax to:', calculatedAmount);
                    break;
                case 'Social Security':
                    deductions.social_security = calculatedAmount;
                    console.log('Set social_security to:', calculatedAmount);
                    break;
                case 'Medicare':
                    deductions.medicare = calculatedAmount;
                    console.log('Set medicare to:', calculatedAmount);
                    break;
                case 'PhilHealth':
                    deductions.philhealth = calculatedAmount;
                    console.log('Set philhealth to:', calculatedAmount);
                    break;
                case 'Pag-IBIG':
                    deductions.pagibig = calculatedAmount;
                    console.log('Set pagibig to:', calculatedAmount);
                    break;
            }
        });

        // Add logging for other deductions
        console.log('Other Deductions before mapping:', this.otherDeductions);
        this.otherDeductions.forEach(item => {
            if (item.selected) {
                const calculatedAmount = this.calculateDeduction(item);
                console.log(`Calculating ${item.name}:`, {
                    amount: item.amount,
                    type: item.type,
                    calculated: calculatedAmount
                });
                
                switch(item.name) {
                    case 'Health Insurance':
                        deductions.health_insurance = calculatedAmount;
                        console.log('Set health_insurance to:', calculatedAmount);
                        break;
                    case 'Life Insurance':
                        deductions.life_insurance = calculatedAmount;
                        console.log('Set life_insurance to:', calculatedAmount);
                        break;
                }
            }
        });

        console.log('Final increases object:', increases);
        console.log('Final deductions object:', deductions);

        const payrollData = {
            employee_id: this.selectedEmployee,
            period_start: firstDayOfMonth.toISOString().split('T')[0],
            period_end: lastDayOfMonth.toISOString().split('T')[0],
            base_salary: this.employeeDetails.baseSalary,
            total_increases: this.totalIncreases,
            total_deductions: this.totalDeductions,
            net_salary: this.netSalary,
            attendance_summary: {
                present_days: this.presentDays,
                late_days: this.lateDays,
                absent_days: this.absentDays,
                total_hours: this.totalHours
            },
            increases,
            deductions
        };

        console.log('Sending payroll data:', payrollData);

        const response = await axios.post('/api/payroll/generate', payrollData);
        console.log('Server response:', response.data);
        this.successMessage = response.data.message;

    } catch (error) {
        console.error('Payroll generation error:', error);
        console.error('Error response:', error.response?.data);
        this.errorMessage = error.response?.data?.message || 
            'Failed to generate payroll. Please try again.';
    } finally {
        this.isLoading = false;
    }
},

    // Export payroll data
    async exportPayroll(data) {
      try {
        // Implementation for PDF/Excel export would go here
        console.log('Exporting payroll data:', data);
        
        // Simulate export delay
        await new Promise(resolve => setTimeout(resolve, 1000));
        
      } catch (error) {
        console.error('Export error:', error);
        throw new Error('Failed to export payroll data');
      }
    },

    async fetchAttendanceHistory() {
    try {
        this.isLoading = true;
        
        if (!this.selectedEmployee) {
            console.log('No employee selected');
            return;
        }

        // Use the correct endpoint from your routes
        const response = await axios.get('/api/attendance/getAttendanceHistory', {
            params: {
                employee_id: this.selectedEmployee,
                year: this.selectedYear,
                month: this.selectedMonth
            }
        });


        if (response.data.status === 'success') {
            this.attendanceRecords = response.data.data.map(record => ({
                id: record.id,
                date: this.formatDate(record.date),
                timeIn: this.formatTime(record.time_in),
                timeOut: this.formatTime(record.time_out),
                status: record.status,
                hoursWorked: this.calculateHoursWorked(
                    new Date(record.time_in), 
                    new Date(record.time_out)
                ),
                isNightShift: record.is_night_shift
            }));
        }
    } catch (error) {
        console.error('Error fetching attendance:', error);
        this.showError('Failed to fetch attendance records');
    } finally {
        this.isLoading = false;
    }
},


    selectEmployee(employee) {
      this.selectedEmployee = employee.id;
      this.searchQuery = employee.name;
      this.showDropdown = false;
      this.loadEmployeeData();
    },

    async refreshAttendance() {
      await this.fetchAttendanceHistory();
    },

    toggleShowAll() {
      this.showingAll = !this.showingAll;
      this.fetchAttendanceHistory();
    },

    sortBy(column) {
      if (this.sortColumn === column) {
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
      } else {
        this.sortColumn = column;
        this.sortDirection = 'asc';
      }
    },

    getSortIcon(column) {
      if (this.sortColumn !== column) return '⇅';
      return this.sortDirection === 'asc' ? '↑' : '↓';
    },

    isToday(dateString) {
      const today = new Date().toISOString().split('T')[0];
      return dateString.includes(today);
    },

    getEmptyStateMessage() {
      if (this.dateFilter || this.statusFilter) {
        return 'Try adjusting your filters';
      }
      return this.showingAll ? 
        'No attendance records exist for this employee' : 
        'No recent attendance records found';
    },

    showError(message) {
      this.errorMessage = message;
      setTimeout(() => {
        this.errorMessage = '';
      }, 3000);
    },

    // Add helper method for time formatting
    formatTime(date) {
    if (!date) return '-';
    try {
      return new Date(date).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      });
    } catch (error) {
      console.error('Error formatting time:', error);
      return '-';
    }
  },

    // Add helper method for calculating hours worked
    calculateHoursWorked(timeIn, timeOut) {
      if (!timeIn || !timeOut) return 0;
      const diff = timeOut.getTime() - timeIn.getTime();
      return Math.round((diff / (1000 * 60 * 60)) * 100) / 100;
    },

    // Add method to fetch available years
    async fetchAvailableYears() {
    try {
        const response = await axios.get('/api/attendance/available-years');
        this.availableYears = response.data;
        
        // Set default year if current year isn't in the list
        if (!this.availableYears.includes(this.selectedYear)) {
            this.selectedYear = this.availableYears[this.availableYears.length - 1];
        }
    } catch (error) {
        console.error('Error fetching available years:', error);
        this.showError('Failed to load available years');
    }
  },

    // Move watchForChanges inside methods
    watchForChanges() {
      this.$watch('selectedYear', () => {
        this.fetchAttendanceHistory();
      });
      
      this.$watch('selectedMonth', () => {
        this.fetchAttendanceHistory();
      });
    },

    // Update the summary display
    updateSummarySection() {
      return {
        // ... other summary items
        baseSalary: {
          label: 'Total Hours Pay',
          value: `₱${this.formatCurrency(this.baseSalaryWithHours)}`,
          tooltip: `${this.totalHours} hours × ₱${this.formatCurrency(this.employeeDetails.baseSalary)}/hour`
        }
      };
    },

    calculateAttendanceSummary(records) {
      const summary = {
        present: 0,
        absent: 0,
        late: 0,
        on_leave: 0
      };

      records.forEach(record => {
        switch(record.status) {
          case 'present':
            summary.present++;
            break;
          case 'absent':
            summary.absent++;
            break;
          case 'late':
            summary.late++;
            break;
          case 'on_leave':
            summary.on_leave++;
            break;
        }
      });

      this.attendanceSummary = summary;
    },

    calculateDeductions() {
      let deductions = 0;
      const baseRate = this.selectedEmployee?.base_salary / this.workingDays;

      // Deductions for absences
      deductions += this.attendanceSummary.absent * baseRate;

      // Deductions for late arrivals (e.g., 10% of daily rate)
      deductions += (this.attendanceSummary.late * baseRate * 0.1);

      // Handle leave days based on leave type (you might want to adjust this logic)
      // For example, paid leaves won't have deductions
      // this.attendanceSummary.on_leave * baseRate * leaveDeductionRate

      return deductions;
    },

    formatStatus(status) {
      switch(status) {
        case 'present': return 'Present';
        case 'absent': return 'Absent';
        case 'late': return 'Late';
        case 'on_leave': return 'On Leave';
        default: return status;
      }
    },

    filterByStatus(records) {
      if (!this.statusFilter) return records;
      return records.filter(record => record.status === this.statusFilter);
    }
  },

  // Lifecycle hooks
  mounted() {
    this.fetchEmployees();
    this.fetchDepartments();
    this.generateAvailableYears();
    this.watchForChanges();
    
    // Close dropdown when clicking outside
    document.addEventListener('click', (e) => {
      if (!e.target.closest('.search-dropdown')) {
        this.showDropdown = false;
      }
    });
  },

  watch: {
    // Reset page when search changes
    searchQuery() {
      this.currentPage = 1;
    },
    dateFilter() {
      this.currentPage = 1;
    },
    statusFilter() {
      this.currentPage = 1;
    }
  }
}
</script>
<style scoped>
/* Base Styles */

.refresh-btn, .show-all-btn {
   padding: 8px 16px;
   border-radius: 20px;
    font-weight: 500;
   cursor: pointer;
   transition: all 0.3s ease;
   border: none;
   display: flex;
   align-items: center;
   gap: 8px;
   font-size: 0.9em;
 }
 .refresh-btn {
  background: white;
  color: #660066;
  border: 2px solid #e6ccff;
}

.refresh-btn .icon {
  font-size: 1.2em;
  transition: transform 0.3s ease;
}

.refresh-btn:hover:not(:disabled) {
  background: #f2e6ff;
  border-color: #cc66ff;
  transform: translateY(-1px);
}

.refresh-btn:hover:not(:disabled) .icon {
  transform: rotate(180deg);
}

.show-all-btn {
  background: linear-gradient(135deg, #9966ff, #660099);
  color: white;
  box-shadow: 0 2px 4px rgba(102, 0, 102, 0.2);
}

.show-all-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(102, 0, 102, 0.3);
  background: linear-gradient(135deg, #aa77ff, #770088);
}

.show-all-btn.active {
  background: white;
  color: #660066;
  border: 2px solid #cc66ff;
}
.th-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 4px;
}

.sort-btn {
  background: none;
  border: none;
  color: #660066;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.2s ease;
  font-size: 1.1em;
  opacity: 0.6;
  display: flex;
  align-items: center;
  justify-content: center;
}

.sort-btn:hover {
  background: rgba(102, 0, 102, 0.1);
  opacity: 1;
}

/* Filter Controls */
.filter-group {
  position: relative;
  display: flex;
  align-items: center;
}

.clear-filter {
  position: absolute;
  right: 8px;
  background: none;
  border: none;
  color: #660066;
  cursor: pointer;
  padding: 2px 6px;
  border-radius: 50%;
  font-size: 1.2em;
  opacity: 0.6;
  transition: all 0.2s ease;
}

.clear-filter:hover {
  opacity: 1;
  background: rgba(102, 0, 102, 0.1);
}

/* Controls Layout */
.attendance-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  gap: 16px;
}

.controls-left, .controls-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

/* Table Styles Enhancement */
.attendance-table {
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(102, 0, 102, 0.08);
}

table {
  border-collapse: separate;
  border-spacing: 0;
  width: 100%;
}

th {
  background: linear-gradient(135deg, #f2e6ff, #e6ccff);
  padding: 16px;
  font-weight: 600;
  color: #660066;
  text-transform: uppercase;
  font-size: 0.9em;
  letter-spacing: 0.5px;
}

td {
  padding: 12px 16px;
  background: white;
  transition: all 0.2s ease;
}

tr:hover td {
  background: #f8f4ff;
}

tr.highlight td {
  background: #fff3e6;
}

/* Empty State Enhancement */
.empty-state {
  padding: 40px;
  text-align: center;
  color: #660066;
}

.empty-state .icon {
  font-size: 2.5em;
  margin-bottom: 16px;
  opacity: 0.5;
}

.empty-state p {
  font-size: 1.2em;
  margin-bottom: 8px;
}

.empty-state small {
  color: #a880c7;
}

/* Update existing status badge styles */
.status-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.9em;
  font-weight: 500;
  text-transform: capitalize;
}

.status-badge.present {
  background: linear-gradient(135deg, #4CAF50, #45a049);
  color: white;
}

.status-badge.absent {
  background: linear-gradient(135deg, #f44336, #e53935);
  color: white;
}

.status-badge.late {
  background: linear-gradient(135deg, #ff9800, #f57c00);
  color: white;
}

.status-badge.on_leave {
  background: linear-gradient(135deg, #2196F3, #1976D2);
  color: white;
}

body {
  margin: 0;
  padding: 0;
  min-height: 100vh;
  background: linear-gradient(135deg, #f2e6ff 0%, #ffffff 100%);
}
.deduction-name{
    color: #660066;
}
.deduction-details{
    color: #660066;
}
/* Layout Container */
.payroll-container {
    min-height: 100vh;
  padding: 0;
  background: linear-gradient(135deg, #f2e6ff 0%, #ffffff 100%);
  position: relative;
  overflow-x: hidden;
  animation: fadeIn 0.5s ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.calculated-amount{
    font-size: 1sem;
    font-weight: 600;
    color: #660066;
}
/* Header and Wave Background */
.wave-bg {
    position: absolute;
  top: 0;
  left: -10%; /* Extend beyond the edges */
  right: -10%;
  height: 200px; /* Make it slightly taller */
  background: linear-gradient(135deg, #9966ff, #660099);
  box-shadow: 0 4px 20px rgba(102, 0, 102, 0.2);
  border-radius: 0 0 50% 50%;
  z-index: 0;
  animation: waveAnimation 15s infinite linear;
}

@keyframes waveAnimation {
  0% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
  100% { transform: translateY(0); }
}

/* Typography */
h1 {
    padding-top: 40px; /* Add space from top */
    margin-top: 0;
  color: #660066;
  text-align: center;
  position: relative;
  z-index: 1;
  margin-bottom: 40px;
  font-size: 2.5em;
  font-weight: 600;
  text-shadow: 0 2px 4px rgba(204, 102, 255, 0.2);
}

h2 {
  color: #660066;
  margin-bottom: 20px;
  font-size: 1.8em;
  font-weight: 600;
}

h3 {
  color: #660066;
  margin-bottom: 15px;
  font-size: 1.3em;
  font-weight: 500;
}

/* Section Containers  */
.section {
  margin: 20px;
  background: white;
  border-radius: 12px;
  padding: 25px;
  margin-bottom: 25px;
  box-shadow: 0 8px 16px rgba(102, 0, 102, 0.08);
  position: relative;
  z-index: 1;
  border: 2px solid rgba(230, 204, 255, 0.5);
  backdrop-filter: blur(10px);
  background: rgba(255, 255, 255, 0.95);
  transition: all 0.3s ease;
}

.section:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 24px rgba(102, 0, 102, 0.12);
  border-color: #cc66ff;
}

/* Alert Messages */
.alert {
  padding: 15px 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  position: relative;
  animation: slideIn 0.3s ease;
}

.alert-error {
  background-color: #fad8dd;
  color: #dc3545;
  border: 1px solid #ffcdd2;
}

.alert-success {
  background-color: #d7fada;
  color: #28a745;
  border: 1px solid #c8e6c9;
}

.close-btn {
  position: absolute;
  right: 15px;
  top: 50%;
  transform: translateY(-50%);
  cursor: pointer;
  opacity: 0.7;
  transition: opacity 0.3s ease;
}

.close-btn:hover {
  opacity: 1;
}

/* Employee Section */
.employee-section {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
  margin-top: 20px;
}

.employee-search-container {
  position: relative;
  margin-bottom: 1.5rem;
}

.search-dropdown {
  position: relative;
}

.dropdown-list {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  max-height: 300px;
  overflow-y: auto;
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(10px);
  border: 2px solid rgba(204, 102, 255, 0.3);
  box-shadow: 0 12px 24px rgba(102, 0, 102, 0.15);
  z-index: 1000;
  animation: dropdownFadeIn 0.2s ease-out;
}

@keyframes dropdownFadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.dropdown-item {
  padding: 12px 16px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.dropdown-item:hover {
  background-color: #f8f4fb;
}

.employee-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.employee-name {
  font-weight: 500;
  color: #660066;
}

.employee-dept {
  color: #666;
  font-size: 0.9em;
}

/* Scrollbar styles for dropdown */
.dropdown-list::-webkit-scrollbar {
  width: 8px;
}

.dropdown-list::-webkit-scrollbar-track {
  background: #f0f0f0;
  border-radius: 4px;
}

.dropdown-list::-webkit-scrollbar-thumb {
  background: #cc66ff;
  border-radius: 4px;
}

.dropdown-list::-webkit-scrollbar-thumb:hover {
  background: #660066;
}

.employee-details {
  flex: 2;
  min-width: 300px;
  background: white;
  padding: 20px;
  border-radius: 8px;
  border: 1px solid #e6ccff;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  color: #660066;
  font-weight: 500;
  border-bottom: 1px solid #e6ccff;
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-item .value {
  color: #cc66ff;
  font-weight: 600;
}

/* Attendance Controls */
.attendance-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  margin-bottom: 20px;
}

.records-per-page {
  display: flex;
  align-items: center;
  gap: 10px;
}

.records-per-page label {
  color: #660066;
  white-space: nowrap;
}

.records-per-page select {
  min-width: 80px;
}

.date-filter {
  flex: 1;
  max-width: 200px;
}

/* Attendance Table */
.attendance-table {
  overflow-x: auto;
  margin-bottom: 20px;
}

table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  width: 100%;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(102, 0, 102, 0.08);
  color: #660066;
}

th, td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #e6ccff;
  transition: all 0.2s ease;
  background: white;
}

th {
  background: linear-gradient(135deg, #f2e6ff, #e6ccff);
  padding: 15px;
  font-weight: 600;
  color: #660066;
  text-transform: uppercase;
  font-size: 0.9em;
  letter-spacing: 0.5px;
  position: relative;
  padding-bottom: 45px; /* Make room for filters */
}

.th-content {
  position: absolute;
  bottom: 8px;
  left: 0;
  right: 0;
  padding: 0 8px;
}

.th-filter {
  width: 100%;
  padding: 6px 10px;
  border: 2px solid #e6ccff;
  border-radius: 6px;
  font-size: 0.85em;
  color: #660066;
  background: rgba(255, 255, 255, 0.9);
  transition: all 0.3s ease;
  cursor: pointer;
}

.th-filter:hover, .th-filter:focus {
  border-color: #cc66ff;
  box-shadow: 0 2px 8px rgba(102, 0, 102, 0.1);
  background: white;
}

/* Style the date input type="month" */
input[type="month"].purple-input {
  padding: 8px 12px;
  color: #660066;
  cursor: pointer;
}

/* Style the date input calendar icon */
input[type="date"].th-filter::-webkit-calendar-picker-indicator,
input[type="month"].purple-input::-webkit-calendar-picker-indicator {
  filter: invert(24%) sepia(90%) saturate(1800%) hue-rotate(270deg) brightness(75%);
  cursor: pointer;
  opacity: 0.7;
  transition: opacity 0.2s;
}

input[type="date"].th-filter::-webkit-calendar-picker-indicator:hover,
input[type="month"].purple-input::-webkit-calendar-picker-indicator:hover {
  opacity: 1;
}

/* Style the select dropdown arrow */
select.th-filter {
  appearance: none;
  background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23660066' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
  background-repeat: no-repeat;
  background-position: right 8px center;
  background-size: 16px;
  padding-right: 32px;
}

tr:hover td {
  background-color: #f8f4ff;
}

/* Status Badges */
.status-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.9em;
  font-weight: 500;
  text-transform: capitalize;
}

.status-badge.present {
  background: linear-gradient(135deg, #4CAF50, #45a049);
  color: white;
}

.status-badge.absent {
  background: linear-gradient(135deg, #f44336, #e53935);
  color: white;
}

.status-badge.late {
  background: linear-gradient(135deg, #ff9800, #f57c00);
  color: white;
}

.status-badge.on_leave {
  background: linear-gradient(135deg, #2196F3, #1976D2);
  color: white;
}

.status-badge:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

/* Attendance Summary */
.attendance-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-top: 30px;
}

.stat-card {
  background: white;
  border-radius: 15px;
  padding: 25px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 4px 15px rgba(102, 0, 102, 0.1);
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(102, 0, 102, 0.15);
}

.stat-card .label {
  font-size: 1.1em;
  color: #666;
  margin-bottom: 10px;
  z-index: 1;
}

.stat-card .value {
  font-size: 2em;
  font-weight: 700;
  z-index: 1;
}

.stat-card .icon {
  position: absolute;
  right: 20px;
  bottom: 20px;
  font-size: 3em;
  opacity: 0.1;
  transform: rotate(-15deg);
}

.stat-card.present {
  background: linear-gradient(135deg, #ffffff, #e6ffea);
  border: 2px solid #28a745;
}

.stat-card.present .value {
  color: #28a745;
}

.stat-card.late {
  background: linear-gradient(135deg, #ffffff, #fff3e6);
  border: 2px solid #ffa500;
}

.stat-card.late .value {
  color: #ffa500;
}

.stat-card.absent {
  background: linear-gradient(135deg, #ffffff, #ffe6e6);
  border: 2px solid #dc3545;
}

.stat-card.absent .value {
  color: #dc3545;
}

.stat-card.hours {
  background: linear-gradient(135deg, #ffffff, #e6e6ff);
  border: 2px solid #660066;
}

.stat-card.hours .value {
  color: #660066;
}

/* Table Filters */
.th-content {
  margin-top: 8px;
}

.th-filter {
  width: 100%;
  padding: 4px 8px;
  border: 1px solid #e6ccff;
  border-radius: 4px;
  font-size: 0.9em;
  color: #660066;
}

/* Pagination Controls */
.pagination-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  margin-top: 20px;
}

.pagination-btn {
  background: linear-gradient(135deg, #9966ff, #660099);
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
}

.pagination-btn:disabled {
  background: #cccccc;
  cursor: not-allowed;
}

.pagination-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(102, 0, 102, 0.2);
}

.page-info {
  color: #660066;
  font-weight: 500;
}

/* Increases and Deductions */
.increases-grid,
.deductions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.increase-item,
.deduction-item {
  background: #f2e6ff;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 10px;
}

.increase-header,
.deduction-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #660066;
  cursor: pointer;
}

.tooltip {
  color: #660066;
  cursor: help;
  position: relative;
}

/* Summary Section */
.summary-section {
  background: white;
  padding: 30px;
  border-radius: 15px;
  border: 2px solid #e6ccff;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.summary-item {
  padding: 20px;
  background: #f2e6ff;
  border-radius: 10px;
  text-align: center;
  transition: all 0.3s ease;
  min-height: 120px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  box-shadow: 0 2px 4px rgba(102, 0, 102, 0.1);
  background: linear-gradient(135deg, #ffffff, #f8f4ff);
  border: 2px solid rgba(204, 102, 255, 0.2);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.summary-item:hover {
  transform: translateY(-3px) scale(1.02);
  border-color: #cc66ff;
  box-shadow: 0 8px 16px rgba(102, 0, 102, 0.15);
}

.summary-item .label {
  color: #660066;
  font-size: 0.9em;
  margin-bottom: 10px;
}

.summary-item .amount {
  font-size: 1.4em;
  font-weight: 600;
  color: #660066;
}

.summary-item .amount.positive {
  color: #28a745;
}

.summary-item .amount.negative {
  color: #dc3545;
}

.summary-item.total {
  background: linear-gradient(135deg, #9966ff, #660099);
  border: none;
  box-shadow: 0 8px 16px rgba(102, 0, 102, 0.2);
}

.summary-item.total .label,
.summary-item.total .amount {
  color: #ffffff;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
}

/* Form Controls */
.purple-input,
.purple-select {
  width: 100%;
  padding: 12px;
  border: 2px solid #e6ccff;
  border-radius: 8px;
  font-size: 1em;
  color: #660066;
  background-color: white;
  transition: all 0.3s ease;
}

.purple-input:focus,
.purple-select:focus {
  border-color: #cc66ff;
  outline: none;
  box-shadow: 0 0 0 3px rgba(204, 102, 255, 0.2);
  background-color: #f2e6ff;
}

.purple-input::placeholder {
  color: #a880c7;
}

/* Generate Button */
.generate-section {
  margin-top: 30px;
  text-align: center;
}

.generate-btn {
  background: linear-gradient(135deg, #9966ff, #660099);
  color: #ffffff;
  border: none;
  padding: 15px 50px;
  border-radius: 30px;
  font-size: 1.2em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 6px 12px rgba(102, 0, 102, 0.2);
  letter-spacing: 0.5px;
  text-transform: uppercase;
}

.generate-btn:hover:not(:disabled) {
  transform: translateY(-3px) scale(1.02);
  box-shadow: 0 8px 16px rgba(102, 0, 102, 0.3);
  background: linear-gradient(135deg, #aa77ff, #770088);
}

.generate-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

/* Loading Overlay */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(242, 230, 255, 0.9);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

/* Responsive Design */
@media (max-width: 768px) {
  .section {
    margin: 10px;
    padding: 15px;  }

  .summary-grid {
    grid-template-columns: 1fr;
  }
  .wave-bg {
    height: 150px;
  }
  .employee-section {
    flex-direction: column;
  }
  h1 {
    padding-top: 30px;
  }
  .employee-select,
  .employee-details {
    width: 100%;
  }

  .increases-grid,
  .deductions-grid {
    grid-template-columns: 1fr;
  }

  .attendance-controls {
    flex-direction: column;
  }

  .search-filter,
  .records-per-page {
    width: 100%;
  }
}

/* Enhanced Section Headers */
.section h2 {
  color: #660066;
  font-size: 1.5em;
  margin-bottom: 24px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.section h2::before {
  content: '';
  width: 4px;
  height: 24px;
  background: linear-gradient(to bottom, #9966ff, #660099);
  border-radius: 2px;
}

/* Increases and Deductions Enhancement */
.increases-grid,
.deductions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 24px;
  margin-bottom: 30px;
}

.increase-category,
.deduction-category {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 12px rgba(102, 0, 102, 0.08);
  border: 2px solid #e6ccff;
}

.increase-category h3,
.deduction-category h3 {
  color: #660066;
  font-size: 1.2em;
  margin-bottom: 16px;
  padding-bottom: 8px;
  border-bottom: 2px solid #f2e6ff;
}

.increase-item,
.deduction-item {
  background: linear-gradient(135deg, #ffffff, #f8f4ff);
  padding: 16px;
  border-radius: 10px;
  margin-bottom: 12px;
  border: 1px solid #e6ccff;
  transition: all 0.3s ease;
}

.increase-item:hover,
.deduction-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(102, 0, 102, 0.1);
  border-color: #cc66ff;
}

/* Checkbox Enhancement */
.checkbox-label input[type="checkbox"] {
  appearance: none;
  width: 20px;
  height: 20px;
  border: 2px solid #cc66ff;
  border-radius: 6px;
  margin-right: 8px;
  position: relative;
  cursor: pointer;
  transition: all 0.2s ease;
}

.checkbox-label input[type="checkbox"]:checked {
  background: #660066;
  border-color: #660066;
}

.checkbox-label input[type="checkbox"]:checked::after {
  content: '✓';
  color: white;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 12px;
}

/* Amount Inputs Enhancement */
.increase-inputs,
.deduction-inputs {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px dashed #e6ccff;
}

.unit {
  color: #660066;
  font-weight: 600;
}

.calculated-amount {
  margin-left: auto;
  color: #660066;
  font-weight: 600;
  font-size: 1.1em;
  padding: 4px 12px;
  background: #f2e6ff;
  border-radius: 20px;
}

/* Tooltip Enhancement */
.tooltip {
  position: relative;
  cursor: help;
}

.tooltip::after {
  content: attr(data-tooltip);
  position: absolute;
  bottom: 100%;
  right: 0;
  background: #660066;
  color: white;
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 0.9em;
  width: max-content;
  max-width: 250px;
  opacity: 0;
  visibility: hidden;
  transform: translateY(10px);
  transition: all 0.3s ease;
  z-index: 10;
}

.tooltip:hover::after {
   opacity: 1;
   visibility: visible;
   transform: translateY(0);
 }
 
 /* Payroll Summary Enhancement */
 .summary-section {
   background: white;
   padding: 30px;
   border-radius: 15px;
   border: 2px solid #e6ccff;
   margin-top: 30px;
 }
 
 .summary-grid {
   display: grid;
   grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
   gap: 20px;
 }
 
 .summary-item {
   padding: 24px;
   border-radius: 12px;
   text-align: center;
   position: relative;
   overflow: hidden;
 }
 
.summary-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(to right, #9966ff, #660099);
}

.summary-item.total {
  grid-column: 1 / -1;
  background: linear-gradient(135deg, #9966ff, #660099);
   color: white;
   transform: scale(1.02);
 }

/* Add these styles to your existing styles */
.year-selector,
.month-selector {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-left: 20px;
}

.controls-left {
  display: flex;
  align-items: center;
  gap: 20px;
}

.purple-select {
  padding: 8px;
  border: 2px solid #e6ccff;
  border-radius: 6px;
  color: #660066;
  background: white;
  min-width: 100px;
}

.attendance-summary {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
  margin: 1.5rem 0;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(102, 0, 102, 0.1);
}

.summary-item {
  padding: 1rem;
  background: white;
  border-radius: 8px;
  border: 1px solid #e6ccff;
  text-align: center;
  transition: all 0.3s ease;
}

.summary-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(102, 0, 102, 0.1);
}

/* Add specific color for leave status */
.summary-item .value.on-leave {
  color: #2196F3;
}

@media (max-width: 768px) {
  .attendance-summary {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 480px) {
  .attendance-summary {
    grid-template-columns: 1fr;
  }
}
</style>
