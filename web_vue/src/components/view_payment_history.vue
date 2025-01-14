backup/LOGIN DESIGN/web_vue/src/components/view_payment_history.vue
<template>
  <div class="payment-container">
    <div class="wave-bg"></div>
    
    <div class="content-wrapper">
      <!-- Header Section -->
      <div class="header-section">
        <h1>Payment History</h1>
        <button class="generate-btn" @click="openPayslipModal">
          <span>+</span> Generate Payslip
        </button>
      </div>

      <!-- Search and Filter Section -->
      <div class="search-section">
        <div class="search-box">
          <input 
            type="text" 
            v-model="searchQuery" 
            placeholder="Search by name..."
            class="purple-input"
          >
        </div>
        <div class="filter-box">
          <select v-model="departmentFilter" class="purple-select">
            <option value="">All Departments</option>
            <option v-for="department in departments" :key="department.id" :value="department.name">
              {{ department.name }}
            </option>
          </select>
        </div>
        <div class="date-filter">
          <input 
            type="month" 
            v-model="dateFilter"
            class="purple-input"
          >
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="isLoading" class="loading-state">
        <div class="spinner"></div>
        <p>Loading payments...</p>
      </div>

      <!-- Error State -->
      <div v-if="error" class="error-message">
        {{ error }}
      </div>

      <!-- Payment Table -->
      <div class="table-container">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Department</th>
              <th>Amount</th>
              <th>Date</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="!isLoading && payments.length === 0">
              <td colspan="5" class="no-data">No payment records found</td>
            </tr>
            <tr v-for="payment in filteredPayments" :key="payment.id">
              <td>{{ payment.name }}</td>
              <td>{{ payment.department }}</td>
              <td>₱{{ formatCurrency(payment.amount) }}</td>
              <td>{{ formatDate(payment.date) }}</td>
              <td>
                <span 
                  :class="['status', payment.status.toLowerCase()]"
                  @click="showDetails(payment)"
                  :style="{ cursor: isClickableStatus(payment.status) ? 'pointer' : 'default' }"
                >
                  {{ payment.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Payment Details Modal -->
    <div class="modal" v-if="showDetailsModal">
      <div class="modal-content">
        <h2>Payment Details</h2>
        <div class="payment-details">
          <div class="detail-row">
            <span class="label">Employee:</span>
            <span class="value">{{ selectedPayment.name }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Amount:</span>
            <span class="value">₱{{ formatCurrency(selectedPayment.amount) }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Date:</span>
            <span class="value">{{ formatDate(selectedPayment.date) }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Status:</span>
            <span :class="['status', selectedPayment.status.toLowerCase()]">
              {{ selectedPayment.status }}
            </span>
          </div>
          <div class="summary-section">
            <h3>Summary</h3>
            <p>{{ selectedPayment.summary }}</p>
          </div>
          <div class="form-buttons">
            <button 
              class="submit-btn" 
              @click="resendPayment"
              v-if="isClickableStatus(selectedPayment.status)"
            >
              Resend Payment
            </button>
            <button class="cancel-btn" @click="closeDetailsModal">Cancel</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Payslip Generation Modal -->
    <div class="modal" v-if="showPayslipModal">
      <div class="modal-content payslip-modal">
        <div class="modal-header">
          <h2>Generate Payslip</h2>
          <button class="close-btn" @click="closePayslipModal">&times;</button>
        </div>

        <!-- Employee Search -->
        <div class="form-group">
          <label>Employee Name</label>
          <input 
            type="text" 
            v-model="payslipName"
            @input="searchEmployee"
            placeholder="Enter employee name"
            class="purple-input"
          >
          <!-- Employee Suggestions -->
          <div class="suggestions" v-if="showSuggestions">
            <div 
              v-for="emp in employeeSuggestions" 
              :key="emp.id"
              class="suggestion-item"
              @click="selectEmployee(emp)"
            >
              {{ emp.name }} - {{ emp.department }}
            </div>
          </div>
        </div>

        <!-- Payslip Preview -->
        <div class="payslip-preview" v-if="selectedPayslipEmployee" ref="payslipContent">
          <div class="payslip-header">
            <div class="company-info">
              <h2>Company Name</h2>
              <p>123 Company Road, Manila, Philippines</p>
              <p>Phone: +63 123 456 7890, Email: hr@company.com</p>
            </div>
            <div class="payslip-title">
              <h1>PAYSLIP</h1>
            </div>
          </div>

          <div class="payslip-grid">
            <!-- Employee Info -->
            <div class="info-section">
              <h3>Employee Information</h3>
              <div class="info-row">
                <span class="label">Name:</span>
                <span class="value">{{ selectedPayslipEmployee.name }}</span>
              </div>
              <div class="info-row">
                <span class="label">ID:</span>
                <span class="value">{{ selectedPayslipEmployee.id }}</span>
              </div>
              <div class="info-row">
                <span class="label">Department:</span>
                <span class="value">{{ selectedPayslipEmployee.department }}</span>
              </div>
            </div>

            <!-- Payment Info -->
            <div class="info-section">
              <h3>Payment Information</h3>
              <div class="info-row">
                <span class="label">Pay Period:</span>
                <span class="value">{{ getCurrentPayPeriod() }}</span>
              </div>
              <div class="info-row">
                <span class="label">Pay Date:</span>
                <span class="value">{{ formatDate(new Date()) }}</span>
              </div>
            </div>
          </div>

          <!-- Earnings Section -->
          <div class="payslip-section">
            <h3>Earnings</h3>
            <table class="payslip-table">
              <thead>
                <tr>
                  <th>Description</th>
                  <th>Amount</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Basic Salary</td>
                  <td>₱{{ formatCurrency(selectedPayslipEmployee.amount) }}</td>
                </tr>
                <!-- Add more earnings rows as needed -->
              </tbody>
              <tfoot>
                <tr>
                  <td><strong>Gross Pay</strong></td>
                  <td><strong>₱{{ formatCurrency(selectedPayslipEmployee.amount) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Deductions Section -->
          <div class="payslip-section">
            <h3>Deductions</h3>
            <table class="payslip-table">
              <thead>
                <tr>
                  <th>Description</th>
                  <th>Amount</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>SSS</td>
                  <td>₱{{ formatCurrency(calculateSSS()) }}</td>
                </tr>
                <tr>
                  <td>PhilHealth</td>
                  <td>₱{{ formatCurrency(calculatePhilHealth()) }}</td>
                </tr>
                <tr>
                  <td>Pag-IBIG</td>
                  <td>₱{{ formatCurrency(calculatePagIbig()) }}</td>
                </tr>
                <tr>
                  <td>Withholding Tax</td>
                  <td>₱{{ formatCurrency(calculateTax()) }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr>
                  <td><strong>Total Deductions</strong></td>
                  <td><strong>₱{{ formatCurrency(totalDeductions) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Net Pay Section -->
          <div class="payslip-section net-pay">
            <table class="payslip-table">
              <tbody>
                <tr>
                  <td><strong>NET PAY</strong></td>
                  <td><strong>₱{{ formatCurrency(netPay) }}</strong></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="form-buttons">
          <button 
            class="print-btn" 
            @click="printPayslipToPDF"
            :disabled="!selectedPayslipEmployee"
          >
            <i class="fas fa-print"></i> Print PDF
          </button>
          <button class="cancel-btn" @click="closePayslipModal">Cancel</button>
        </div>
      </div>
    </div>
  </div>
</template>
  <script>
  import { jsPDF } from 'jspdf';
  import html2canvas from 'html2canvas';
  import axios from 'axios';

  export default {
    name: 'ViewPaymentHistory',
    data() {
      return {
        // Search and Filter
        searchQuery: '',
        departmentFilter: '',
        dateFilter: '',
        
        // Modals
        showDetailsModal: false,
        showPayslipModal: false,
        
        // Selected Items
        selectedPayment: null,
        selectedPayslipEmployee: null,
        
        // Payslip Generation
        payslipName: '',
        showSuggestions: false,
        employeeSuggestions: [],
        
        // Sample Data (Replace with API calls)
        payments: [],
        departments: [],
        isLoading: true,
        error: null,
        searchTimeout: null
      }
    },
  
    computed: {
      filteredPayments() {
        return this.payments;
      },
  
      totalDeductions() {
        if (!this.selectedPayslipEmployee) return 0
        return this.calculateSSS() + 
               this.calculatePhilHealth() + 
               this.calculatePagIbig() + 
               this.calculateTax()
      },
  
      netPay() {
        if (!this.selectedPayslipEmployee) return 0
        return this.selectedPayslipEmployee.amount - this.totalDeductions
      }
    },
  
    methods: {
      async fetchPayments() {
        try {
          const response = await axios.get('/api/payroll/history', {
            params: {
              search: this.searchQuery,
              department: this.departmentFilter,
              date: this.dateFilter
            }
          });
          this.payments = response.data.data || [];
        } catch (error) {
          console.error('Error fetching payments:', error);
          this.error = 'Failed to load payments';
        } finally {
          this.isLoading = false;
        }
      },
  
      async fetchDepartments() {
        try {
          const response = await axios.get('/api/departments');
          this.departments = response.data;
        } catch (error) {
          console.error('Error fetching departments:', error);
        }
      },
  
      // Formatting Methods
      formatCurrency(value) {
        if (value === undefined || value === null) return '0.00';
        return parseFloat(value).toLocaleString('en-PH', {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2
        });
      },
  
      formatDate(date) {
        return new Date(date).toLocaleDateString('en-PH', {
          year: 'numeric',
          month: 'long',
          day: 'numeric'
        })
      },
  
      getCurrentPayPeriod() {
        const date = new Date()
        return `${date.toLocaleString('default', { month: 'long' })} ${date.getFullYear()}`
      },
  
      // Status Methods
      isClickableStatus(status) {
        return ['Failed', 'Returned'].includes(status)
      },
  
      // Modal Methods
      showDetails(payment) {
        if (this.isClickableStatus(payment.status)) {
          this.selectedPayment = payment
          this.showDetailsModal = true
        }
      },
  
      closeDetailsModal() {
        this.showDetailsModal = false
        this.selectedPayment = null
      },
  
      // Payslip Methods
      openPayslipModal() {
        this.showPayslipModal = true
        this.payslipName = ''
        this.selectedPayslipEmployee = null
        this.showSuggestions = false
      },
  
      closePayslipModal() {
        this.showPayslipModal = false
        this.payslipName = ''
        this.selectedPayslipEmployee = null
      },
  
      searchEmployee() {
        if (this.payslipName.length < 2) {
          this.showSuggestions = false
          return
        }
        
        this.employeeSuggestions = this.payments
    .filter(emp => emp.name.toLowerCase().includes(this.payslipName.toLowerCase()))
  
  this.showSuggestions = this.employeeSuggestions.length > 0
      },
  
      selectEmployee(employee) {
        this.selectedPayslipEmployee = employee
        this.payslipName = employee.name
        this.showSuggestions = false
      },
  
      // Calculation Methods
      calculateSSS() {
        return this.selectedPayslipEmployee.amount * 0.045 // 4.5% of salary
      },
  
      calculatePhilHealth() {
        return this.selectedPayslipEmployee.amount * 0.03 // 3% of salary
      },
  
      calculatePagIbig() {
        return 100 // Fixed amount
      },
  
      calculateTax() {
        return this.selectedPayslipEmployee.amount * 0.15 // 15% of salary
      },
  
      // PDF Generation
      async printPayslipToPDF() {
        try {
          const element = this.$refs.payslipContent;
          const canvas = await html2canvas(element, {
            scale: 2,
            logging: false,
            useCORS: true
          });
          
          const imgData = canvas.toDataURL('image/jpeg', 1.0);
          const pdf = new jsPDF('p', 'mm', 'a4');
          const pdfWidth = pdf.internal.pageSize.getWidth();
          const pdfHeight = (canvas.height * pdfWidth) / canvas.width;
          
          pdf.addImage(imgData, 'JPEG', 0, 0, pdfWidth, pdfHeight);
          pdf.save(`payslip_${this.selectedPayslipEmployee.name}_${new Date().toISOString().slice(0,10)}.pdf`);
          
        } catch (error) {
          console.error('Error generating PDF:', error);
        }
      },
  
      // Payment Actions
      resendPayment() {
        // Implement resend logic here
        alert('Payment resend initiated')
        this.closeDetailsModal()
      }
    },
    watch: {
      searchQuery() {
        if (this.searchTimeout) {
          clearTimeout(this.searchTimeout);
        }
        this.searchTimeout = setTimeout(() => {
          this.fetchPayments();
        }, 300);
      },
      departmentFilter() {
        this.fetchPayments();
      },
      dateFilter() {
        this.fetchPayments();
      }
    },
    async mounted() {
      try {
        await this.fetchPayments();
        await this.fetchDepartments();
      } catch (error) {
        console.error('Error in mounted:', error);
      }
    },
    beforeUnmount() {
      // Cleanup any event listeners or subscriptions
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout);
      }
    }
  }
  </script>
  <style scoped>
  /* Base Container Styles */
  .payment-container {
    min-height: 100vh;
    width: 100%;
    padding: 0;
    margin: 0;
    background: linear-gradient(135deg, #f8f9ff 0%, #f1f4ff 100%);
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
    background: linear-gradient(135deg, #6366f1, #8b5cf6);
    border-radius: 0 0 50% 50%;
    z-index: 0;
    box-shadow: 0 4px 15px rgba(99, 102, 241, 0.1);
  }
  
  .content-wrapper {
    position: relative;
    z-index: 1;
    width: 100%;
    min-height: 100vh;
    padding: 20px;
    box-sizing: border-box;
  }
  
  /* Header Styles */
  .header-section {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1.5rem 2rem;
    margin-bottom: 2rem;
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.1);
  }
  
  .header-section h1 {
    color: #1e293b;
    font-size: 1.8rem;
    margin: 0;
    font-weight: 700;
    background: linear-gradient(to right, #1e293b, #4f46e5);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }
  
  .suggestion-item{
    color: #660066;
  }
  /* Search and Filter Styles */
  .search-section {
    display: flex;
    gap: 1.5rem;
    padding: 1.5rem 2rem;
    background: white;
    margin: 0 1rem 2rem 1rem;
    border-radius: 12px;
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.1);
    border: 1px solid rgba(99, 102, 241, 0.1);
  }
  
  .search-box,
  .filter-box,
  .date-filter {
    flex: 1;
    min-width: 200px;
  }
  
  .purple-input,
  .purple-select {
    width: 100%;
    padding: 0.8rem 1rem;
    border: 1px solid rgba(99, 102, 241, 0.2);
    border-radius: 8px;
    font-size: 1em;
    color: #1e293b;
    background-color: white;
    transition: all 0.3s ease;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  }
  
  .purple-input:focus,
  .purple-select:focus {
    border-color: #6366f1;
    outline: none;
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
  }
  
  /* Table Styles */
  .table-container {
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.1);
    margin: 0 1rem;
    overflow-x: auto;
    border: 1px solid rgba(99, 102, 241, 0.1);
  }
  
  table {
    width: 100%;
    border-collapse: collapse;
  }
  
  th, td {
    padding: 1rem;
    text-align: left;
    border-bottom: 1px solid #e1e4e8;
    color: #660066;
  }
  
  th {
    background: linear-gradient(to right, #f8fafc, #f1f5f9);
    font-weight: 600;
    color: #1e293b;
    text-transform: uppercase;
    font-size: 0.875rem;
    letter-spacing: 0.05em;
  }
  
  /* Status Badge Styles */
  .status {
    padding: 0.5rem 1rem;
    border-radius: 20px;
    font-size: 0.875rem;
    font-weight: 500;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
  }
  
  .status.sent {
    background: linear-gradient(to right, rgba(16, 185, 129, 0.1), rgba(16, 185, 129, 0.2));
    color: #059669;
  }
  
  .status.failed {
    background: linear-gradient(to right, rgba(239, 68, 68, 0.1), rgba(239, 68, 68, 0.2));
    color: #dc2626;
  }
  
  .status.returned {
    background: #fff3cd;
    color: #856404;
  }
  
  .status.pending {
    background: #e8eaed;
    color: #636363;
  }
  
  /* Modal Styles */
  .modal {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
  }
  
  .modal-content {
    background: white;
    padding: 2rem;
    border-radius: 10px;
    width: 500px;
    max-width: 90%;
    max-height: 90vh;
    overflow-y: auto;
  }
  
  /* Payslip Styles */
  .payslip-modal {
    width: 800px;
    max-width: 95%;
    background: white;
    border-radius: 16px;
    box-shadow: 0 10px 25px rgba(99, 102, 241, 0.2);
  }
  
  .payslip-preview {
    background: white;
    padding: 2rem;
    margin: 1rem 0;
    border-radius: 12px;
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.1);
    border: 1px solid rgba(99, 102, 241, 0.1);
  }
  
  .payslip-header {
    text-align: center;
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 2px solid #660066;
    color:#660066;
  }
  
  .payslip-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
    margin-bottom: 2rem;
  }
  h3, h2, span.label, span.value, p{
    color:#660066
  }
  .info-section h3 {
    color: #660066;
    margin-bottom: 1rem;
  }
  
  .info-row {
    display: flex;
    margin-bottom: 0.5rem;
    color:#660066;
  }
  
  .info-row .label {
    font-weight: 500;
    width: 120px;
  }
  
  .payslip-section {
    margin-bottom: 2rem;
  }
  
  .payslip-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 0.5rem;
  }
  
  .payslip-table th,
  .payslip-table td {
    padding: 0.75rem;
    border: 1px solid #e1e4e8;
    color: #660066;
  }
  
  .net-pay {
    background: #f8fafc;
    padding: 1rem;
    border-radius: 8px;
  }
  
  /* Button Styles */
  .generate-btn,
  .print-btn {
    background: linear-gradient(135deg, #6366f1, #4f46e5);
    color: white;
    border: none;
    padding: 0.8rem 1.5rem;
    border-radius: 8px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-weight: 500;
    transition: all 0.3s ease;
    box-shadow: 0 2px 4px rgba(99, 102, 241, 0.2);
  }
  
  .generate-btn:hover,
  .print-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(99, 102, 241, 0.3);
  }
  
  .form-buttons {
    display: flex;
    gap: 1rem;
    margin-top: 1.5rem;
  }
  
  .submit-btn,
  .cancel-btn {
    padding: 0.6rem 1.2rem;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-weight: 500;
    transition: all 0.2s ease;
  }
  
  .submit-btn {
    background: #6b2c91;
    color: white;
    flex: 2;
  }
  
  .cancel-btn {
    background: #dc3545;
    color: white;
    flex: 1;
  }
  
  /* Responsive Styles */
  @media (max-width: 768px) {
    .content-wrapper {
      padding: 10px;
    }
  
    .search-section {
      flex-direction: column;
      padding: 1rem;
    }
  
    .search-box,
    .filter-box,
    .date-filter {
      width: 100%;
      min-width: unset;
    }
  
    .payslip-grid {
      grid-template-columns: 1fr;
    }
  
    .header-section {
      flex-direction: column;
      gap: 1rem;
      text-align: center;
    }
  
    .generate-btn {
      width: 100%;
    }
  }

  .loading-state {
    text-align: center;
    padding: 3rem;
    color: #6366f1;
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.1);
    margin: 1rem;
  }

  .spinner {
    border: 4px solid rgba(99, 102, 241, 0.1);
    border-top: 4px solid #6366f1;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    animation: spin 1s linear infinite;
    margin: 0 auto 1rem;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  .error-message {
    background: #feeced;
    color: #dc3545;
    padding: 1rem;
    margin: 1rem;
    border-radius: 8px;
    text-align: center;
  }

  .no-data {
    text-align: center;
    color: #666;
    padding: 2rem !important;
  }
  </style>