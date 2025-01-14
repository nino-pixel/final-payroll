<template>
 <div class="attendance-container">
    <div class="wave-bg"></div>
    
    <div>
      <!-- Loading Modal -->
      <div v-if="isLoading" class="modal">
        <div class="modal-content loading">
          <div class="modal-body">
            <div class="loader"></div>
            <p>Loading attendance records...</p>
          </div>
        </div>
      </div>

      <!-- Success Modal -->
      <div v-if="showSuccessModal" class="modal">
        <div class="modal-content success">
          <div class="modal-header">
            <i class="fas fa-check-circle success-icon"></i>
            <h2>Success</h2>
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
    </div>
    
    <div class="content-wrapper">
      <!-- Header Section -->
      <div class="header-section">
        <h1>Attendance Management</h1>
      </div>

      <!-- Error Message -->
      <div v-if="errorMessage" class="error-message">
        {{ errorMessage }}
      </div>

      <!-- Search and Filter Section -->
      <div class="search-section">
        <div class="search-box">
          <input class="purple-input"
            type="text" 
            v-model="searchQuery" 
            placeholder="Search employee..."
          >
        </div>
        <div class="filter-box">
          <select v-model="selectedYear">
            <option v-for="year in years" :key="year" :value="year.toString()">
              {{ year }}
            </option>
          </select>
        </div>
      </div>

      <!-- Months Grid -->
      <div class="months-grid" v-if="!showRecords">
        <div class="month-row">
          <button 
            v-for="month in months.slice(0, 6)" 
            :key="month.id"
            class="month-btn"
            :class="{ active: selectedMonth === month.id }"
            @click="selectMonth(month)"
          >
            <div class="month-content">
              <span class="month-name">{{ month.name }}</span>
              <span class="attendance-count">
                {{ month.attendanceCount }} Records
                <!-- Debug output -->
                <small v-if="false">{{ month.id }}: {{ month.attendanceCount }}</small>
              </span>
            </div>
          </button>
        </div>
        
        <div class="month-row">
          <button 
            v-for="month in months.slice(6)" 
            :key="month.id"
            class="month-btn"
            :class="{ active: selectedMonth === month.id }"
            @click="selectMonth(month)"
          >
            <div class="month-content">
              <span class="month-name">{{ month.name }}</span>
              <span class="attendance-count">
                {{ month.attendanceCount }} Records
                <!-- Debug output -->
                <small v-if="false">{{ month.id }}: {{ month.attendanceCount }}</small>
              </span>
            </div>
          </button>
        </div>
      </div>

      <!-- Attendance Records Table -->
      <div class="records-section" v-if="showRecords">
        <div class="records-header">
          <button class="back-btn" @click="goBackToMonths">
            <span>←</span> Back to Months
          </button>
          <h2>{{ selectedMonthName }} {{ selectedYear }} Attendance Records</h2>
          <button style="color:white"class="report-btn" @click="showReportModal = true">
            <i class="fas fa-file-alt"></i> Generate Report
          </button>
        </div>

        <div class="records-table">
          <table class="attendance-table">
            <thead>
              <tr>
                <th>Employee ID</th>
                <th>Name</th>
                <th>
                  Department
                  <select 
                    v-model="selectedDepartment" 
                    class="column-filter"
                    @change="filterByDepartment"
                  >
                    <option value="">All Departments</option>
                    <option v-for="dept in departments" :key="dept.id" :value="dept.id">
                      {{ dept.name }}
                    </option>
                  </select>
                </th>
                <th>Date</th>
                <th>Time In</th>
                <th>Time Out</th>
                <th>
                  Status
                  <select v-model="statusFilter" class="column-filter">
                    <option value="">All</option>
                    <option value="present">Present</option>
                    <option value="absent">Absent</option>
                    <option value="late">Late</option>
                    <option value="on_leave">On Leave</option>
                  </select>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="record in filteredRecords" :key="record.id">
                <td>{{ record.employeeId }}</td>
                <td>{{ record.name }}</td>
                <td>{{ record.department }}</td>
                <td>{{ formatDate(record.date) }}</td>
                <td>{{ record.timeIn }}</td>
                <td>{{ record.timeOut }}</td>
                <td>
                  <span :class="['status', record.status.toLowerCase()]">
                    {{ record.status }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Report Generation Modal -->
      <div class="modal" v-if="showReportModal">
        <div class="modal-content">
          <h2>Generate Attendance Report</h2>
          
          <div class="report-options">
            <div class="form-group">
              <label>Report Type</label>
              <select v-model="reportSettings.type">
                <option value="monthly">Monthly Report</option>
                <option value="status">Status Report</option>
                <option value="employee">Employee Report</option>
              </select>
            </div>

            <!-- Monthly Report Options -->
            <div class="form-group" v-if="reportSettings.type === 'monthly'">
              <label>Select Month</label>
              <select v-model="reportSettings.month">
                <option v-for="month in months" :key="month.id" :value="month.id">
                  {{ month.name }}
                </option>
              </select>
            </div>

            <!-- Status Report Options -->
            <div class="form-group" v-if="reportSettings.type === 'status'">
              <label>Select Status</label>
              <select v-model="reportSettings.status">
                <option value="present">Present</option>
                <option value="absent">Absent</option>
                <option value="late">Late</option>
                <option value="all">All Statuses</option>
              </select>
            </div>

            <!-- Employee Report Options -->
            <div class="form-group" v-if="reportSettings.type === 'employee'">
              <label>Select Employee</label>
              <select v-model="reportSettings.employeeId" class="employee-select">
                <option value="">Select an employee</option>
                <option v-for="emp in employees" 
                        :key="emp.id" 
                        :value="emp.id"
                        style="color: #4a5568;">
                  {{ emp.name }}
                </option>
              </select>
            </div>

            <div class="form-group" v-if="reportSettings.type !== 'monthly'">
              <label>Date Range</label>
              <div class="date-range">
                <input class="purple-input" type="date" v-model="reportSettings.startDate">
                <span>to</span>
                <input class="purple-input" type="date" v-model="reportSettings.endDate">
              </div>
            </div>

            <div class="form-group">
              <label>File Format</label>
              <select v-model="reportSettings.format">
                <option value="pdf">PDF</option>
                <option value="excel">Excel</option>
                <option value="csv">CSV</option>
              </select>
            </div>
          </div>

          <div class="form-buttons">
            <button 
                class="cancel-btn" 
                @click="showReportModal = false"
            >
                Cancel
            </button>
            <button 
                class="generate-btn" 
                @click="generateReport"
                :disabled="isLoading"
            >
                {{ isLoading ? 'Generating...' : 'Generate Report' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
  <script>
  import axios from 'axios';

  export default {
    name: 'AttendanceManagement',
    data() {
      const currentYear = new Date().getFullYear();
      const years = [];
      for (let i = 0; i < 5; i++) {
        years.push(currentYear - i);
      }

      return {
        searchQuery: '',
        selectedYear: currentYear.toString(),
        years: years,
        selectedMonth: new Date().getMonth() + 1,
        selectedMonthName: '',
        showRecords: false,
        showReportModal: false,
        months: [
          { id: 1, name: 'January', attendanceCount: 0 },
          { id: 2, name: 'February', attendanceCount: 0 },
          { id: 3, name: 'March', attendanceCount: 0 },
          { id: 4, name: 'April', attendanceCount: 0 },
          { id: 5, name: 'May', attendanceCount: 0 },
          { id: 6, name: 'June', attendanceCount: 0 },
          { id: 7, name: 'July', attendanceCount: 0 },
          { id: 8, name: 'August', attendanceCount: 0 },
          { id: 9, name: 'September', attendanceCount: 0 },
          { id: 10, name: 'October', attendanceCount: 0 },
          { id: 11, name: 'November', attendanceCount: 0 },
          { id: 12, name: 'December', attendanceCount: 0 }
        ],
        attendanceRecords: [],
        errorMessage: '',
        statusFilter: '',
        departments: [],
        selectedDepartment: null,
        isLoading: false,
        reportSettings: {
          type: 'monthly',
          month: new Date().getMonth() + 1,
          status: 'all',
          employeeId: null,
          startDate: '',
          endDate: '',
          format: 'pdf'
        },
        employees: [],
        showSuccessModal: false,
        showErrorModal: false,
        successMessage: ''
      }
    },
    computed: {
      filteredRecords() {
        let records = [...this.attendanceRecords];
        
        if (this.searchQuery) {
          const query = this.searchQuery.toLowerCase();
          records = records.filter(record => 
            record.name.toLowerCase().includes(query) ||
            record.employeeId.toString().includes(query)
          );
        }

        if (this.statusFilter) {
          records = records.filter(record => 
            record.status.toLowerCase() === this.statusFilter.toLowerCase()
          );
        }

        return records;
      }
    },
    methods: {
      async fetchEmployeeAttendance() {
        try {
          this.isLoading = true;
          const response = await axios.get('/api/attendance/getHistory', {
            params: {
              year: this.selectedYear,
              month: this.selectedMonth,
              department_id: this.selectedDepartment || ''  // Send empty string if no department selected
            }
          });

          if (response.data.status === 'success') {
            // Map the response data to your records
            this.attendanceRecords = response.data.data;
          } else {
            throw new Error(response.data.message || 'Failed to fetch attendance');
          }
        } catch (error) {
          console.error('Error fetching attendance:', error);
          this.errorMessage = error.response?.data?.message || 'Failed to fetch attendance records';
        } finally {
          this.isLoading = false;
        }
      },

      async selectMonth(month) {
        try {
          this.isLoading = true;
          this.selectedMonth = month.id;
          this.selectedMonthName = month.name;
          
          await this.fetchEmployeeAttendance();
          await this.fetchMonthlyCount();
          
          // Set showRecords to true after successful data fetch
          this.showRecords = true;
        } catch (error) {
          console.error('Error selecting month:', error);
          this.showError('Failed to load attendance records for ' + month.name);
        } finally {
          this.isLoading = false;
        }
      },

      async handleYearChange() {
        if (this.selectedMonth) {
          await this.fetchEmployeeAttendance();
          await this.fetchMonthlyCount();
        }
      },

      formatDate(dateString) {
        return new Date(dateString).toLocaleDateString();
      },

      async fetchEmployees() {
        try {
          const response = await axios.get('/api/employees');
          this.employees = response.data.map(emp => ({
            id: emp.id,
            name: `${emp.first_name} ${emp.last_name}`
          }));
        } catch (error) {
          console.error('Error fetching employees:', error);
          this.showError('Failed to load employees');
        }
      },

      async fetchDepartments() {
        try {
          const response = await axios.get('/api/departments');
          this.departments = response.data;
        } catch (error) {
          console.error('Error fetching departments:', error);
          this.errorMessage = 'Failed to load departments';
        }
      },

      async generateReport() {
        try {
            // Add validation
            if (this.reportSettings.type === 'employee' && !this.reportSettings.employeeId) {
                this.showError('Please select an employee');
                return;
            }

            this.isLoading = true;

            // Format dates based on report type
            let startDate, endDate;
            if (this.reportSettings.type === 'monthly') {
                // For monthly reports, set start and end dates of the selected month
                const year = this.selectedYear;
                const month = this.reportSettings.month;
                startDate = `${year}-${month.toString().padStart(2, '0')}-01`;
                // Get last day of month
                const lastDay = new Date(year, month, 0).getDate();
                endDate = `${year}-${month.toString().padStart(2, '0')}-${lastDay}`;
                // Force status to 'all' for monthly reports
                this.reportSettings.status = 'all';
            } else {
                // Validate date range for non-monthly reports
                if (!this.reportSettings.startDate || !this.reportSettings.endDate) {
                    this.showError('Please select a date range');
                    return;
                }
                startDate = this.reportSettings.startDate;
                endDate = this.reportSettings.endDate;
            }

            const response = await axios.post('/api/attendance/report', {
                type: this.reportSettings.type,
                month: this.reportSettings.month,
                status: this.reportSettings.status,
                employeeId: this.reportSettings.employeeId,
                startDate: startDate,
                endDate: endDate,
                format: this.reportSettings.format
            }, {
                responseType: 'blob'
            });

            // Create blob link to download
            const url = window.URL.createObjectURL(new Blob([response.data]));
            const link = document.createElement('a');
            link.href = url;
            
            // Set filename based on report type
            let filename;
            if (this.reportSettings.type === 'monthly') {
                const monthName = this.months.find(m => m.id === this.reportSettings.month)?.name;
                filename = `attendance_report_${monthName}_${this.selectedYear}`;
            } else {
                filename = `attendance_report_${startDate}_to_${endDate}`;
            }
            filename += `.${this.reportSettings.format}`;
            
            link.setAttribute('download', filename);
            document.body.appendChild(link);
            link.click();
            link.remove();
            window.URL.revokeObjectURL(url);

            this.showSuccessModal = true;
            this.successMessage = 'Report generated successfully';
            this.showReportModal = false;
        } catch (error) {
            console.error('Error generating report:', error);
            const errorMessage = error.response?.data?.message || 'Failed to generate report';
            this.showErrorModal = true;
            this.errorMessage = errorMessage;
        } finally {
            this.isLoading = false;
        }
      },

      async fetchMonthlyCount() {
        try {
          const response = await axios.get('/api/attendance/monthly-counts', {
            params: {
              year: this.selectedYear
            }
          });
          
          const counts = response.data;
          
          // Update the attendance counts for each month
          this.months = this.months.map(month => ({
            ...month,
            attendanceCount: counts[month.id] || 0
          }));
          
          // Debug log
          console.log('Monthly counts updated:', this.months);
        } catch (error) {
          console.error('Error fetching monthly counts:', error);
          this.errorMessage = 'Failed to load attendance counts';
        }
      },

      showSuccess(message) {
        this.successMessage = message;
        this.showSuccessModal = true;
      },

      showError(message) {
        this.errorMessage = message;
        this.showErrorModal = true;
      },

      closeSuccessModal() {
        this.showSuccessModal = false;
        this.successMessage = '';
      },

      closeErrorModal() {
        this.showErrorModal = false;
        this.errorMessage = '';
      },

      goBackToMonths() {
        this.showRecords = false;
        this.attendanceRecords = [];
      }
    },
    watch: {
      selectedMonth(newVal) {
        if (newVal) {
          this.fetchEmployeeAttendance();
        }
      },
      selectedYear(newVal) {
        if (newVal) {
          this.fetchEmployeeAttendance();
        }
      },
      selectedDepartment(newVal) {
        this.fetchEmployeeAttendance();
      }
    },
    mounted() {
      this.fetchMonthlyCount();
      this.fetchEmployees();
      this.fetchDepartments();
    },
  };
  
  
  </script>
  <style scoped>

  .attendance-container {
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
  left: -10%;
  right: -10%;
  width: 120%;
  height: 200px;
  background: linear-gradient(135deg, #cc66ff, #660066);
  border-radius: 0 0 50% 50%;
  z-index: 0;
}
.content-wrapper {
  position: relative;
  z-index: 1;
  width: 100%;
  min-height: 100vh;
  padding: 20px;
  box-sizing: border-box;
  }
  
  .header-section {
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    padding: 1.5rem 2rem;
    margin-bottom: 2rem;
    box-shadow: 0 4px 6px rgba(102, 0, 102, 0.1);
    text-align: center;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  h1 {
  padding-top: 40px;
  margin-top: 0;
  color: #660066;
  text-align: center;
  position: relative;
  z-index: 1;
  margin-bottom: 40px;
  font-size: 2.5em;
  font-weight: 600;
  text-shadow: 0 2px 4px rgba(204, 102, 255, 0.2);
  margin: 0;
  background: linear-gradient(135deg, #cc66ff, #660066);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.section {
  margin: 20px;
  background: white;
  border-radius: 12px;
  padding: 25px;
  margin-bottom: 25px;
  box-shadow: 0 4px 6px rgba(102, 0, 102, 0.1);
  position: relative;
  z-index: 1;
  border: 1px solid #e6ccff;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}
select {
  color: #660066;
  background-color: white;
  transition: all 0.3s ease;
  border: 1px solid #e6ccff;
  border-radius: 8px;
  font-size: 1em;
  padding: 0.5em;
  outline: none;
  appearance: none;
  cursor: pointer;
}
  .header-section h1 {
    color: white;
    font-size: 1.8rem;
    margin: 0;
  }
  body {
  margin: 0;
  padding: 0;
  min-height: 100vh;
  background: #f2e6ff;
}
  .search-section {
    display: flex;
    gap: 1rem;
    padding: 1.5rem;
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    margin-bottom: 2rem;
    box-shadow: 0 4px 6px rgba(102, 0, 102, 0.1);
    transition: all 0.3s ease;
  }
  
  .search-box input,
  .filter-box select {
    width: 100%;
  padding: 12px;
  border: 2px solid #e6ccff;
  border-radius: 8px;
  font-size: 1em;
  color: #660066;
  background-color: white;
  transition: all 0.3s ease;
  }
  
  .search-box input:focus,
  .filter-box select:focus {
    border-color: #cc66ff;
  outline: none;
  box-shadow: 0 0 0 3px rgba(204, 102, 255, 0.2);
  background-color: #f2e6ff;
}
  
  .months-grid {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    padding: 1rem;
  }
  
  
  .month-row {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    gap: 1.5rem;
  }
  
  .month-btn {
    background: white;
    border: none;
    border-radius: 12px;
    padding: 1.5rem;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 4px 6px rgba(102, 0, 102, 0.1);
    text-align: left;
    height: 100px;
    color: #6b2c91;
    position: relative;
    overflow: hidden;
  }
  
  .month-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 15px rgba(102, 0, 102, 0.2);
    background: #9f6bbe;
    color: white;
  }
  
  .month-btn::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: linear-gradient(135deg, rgba(204, 102, 255, 0.1), rgba(102, 0, 102, 0.1));
    opacity: 0;
    transition: opacity 0.3s ease;
  }
  
  .month-btn:hover::before {
    opacity: 1;
  }
  
  .month-btn.active {
    background: linear-gradient(135deg, #cc66ff, #660066);
    color: white;
    transform: translateY(-3px);
    box-shadow: 0 8px 15px rgba(102, 0, 102, 0.2);
  }
  
  .month-content {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .month-name {
    font-size: 1.2rem;
    font-weight: 500;
  }
  
  .attendance-count {
    font-size: 0.9rem;
    opacity: 0.8;
  }
  
  .month-btn.active .attendance-count {
    color: rgba(255, 255, 255, 0.9);
  }
  
  /* Responsive adjustments */
  @media (max-width: 1200px) {
    .month-row {
      grid-template-columns: repeat(3, 1fr);
    }
  }
  
  @media (max-width: 768px) {
    .month-row {
      grid-template-columns: repeat(2, 1fr);
    }
    
    .search-section {
      flex-direction: column;
    }
    
    .search-box input,
    .filter-box select {
      width: 100%;
    }

    .date-range {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .date-range span {
    text-align: center;
    }
  }

  
.records-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 2rem;
  margin: 1rem;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(102, 0, 102, 0.1);
}

.records-header {
  display: flex;
  align-items: center;
  gap: 2rem;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid rgba(102, 0, 102, 0.1);
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, #cc66ff, #660066);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.back-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(102, 0, 102, 0.2);
}

.records-header h2 {
  color: #2d3748;
  margin: 0;
}

.table-container {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(102, 0, 102, 0.1);
}

th, td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid rgba(102, 0, 102, 0.1);
}

th {
  background: linear-gradient(135deg, rgba(204, 102, 255, 0.1), rgba(102, 0, 102, 0.1));
  color: #6b2c91;
  font-weight: 600;
  padding: 1rem;
  text-align: left;
}

td {
  color: #4a5568;
}

.status {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 500;
  display: inline-block;
  min-width: 100px;
  text-align: center;
}

.status.present {
  background: linear-gradient(135deg, #4CAF50, #45a049);
  color: white;
}

.status.absent {
  background: linear-gradient(135deg, #f44336, #e53935);
  color: white;
}

.status.late {
  background: linear-gradient(135deg, #ff9800, #f57c00);
  color: white;
}

.status.on_leave {
  background: linear-gradient(135deg, #2196F3, #1976D2);
  color: white;
}

.actions {
  display: flex;
  gap: 0.5rem;
}

.edit-btn {
  padding: 0.25rem 0.5rem;
  background: #28a745;
  color: white;
  border: none;
  border-radius: 3px;
  cursor: pointer;
}

.edit-btn:hover {
  background: #218838;
}

.report-section {
  padding: 0 2rem;
  margin-bottom: 1rem;
}

.report-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.report-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, #6b2c91, #4a1f64);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.report-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(102, 0, 102, 0.2);
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 2rem;
  border-radius: 10px;
  width: 400px;
  max-width: 90%;
  position: relative;
}

.modal-content h2 {
  color: #333;
  margin-bottom: 1rem;
}

.modal-content label {
  color: #4a5568;
  display: block;
  margin-bottom: 0.5rem;
}

.modal-content select,
.modal-content input {
  color: #2d3748;
}

.report-options {
  margin: 1.5rem 0;
  color: #4a5568;
}

.modal-content.success h2 {
  color: #28a745;
}

.modal-content.error h2 {
  color: #dc3545;
}

.modal-content.loading p {
  color: #4a5568;
}

.modal-body {
  margin-bottom: 1.5rem;
  text-align: center;
  color: #4a5568;
}

.success-message {
  color: #28a745;
}

.error-message {
  color: #dc3545;
}

.generate-btn {
  color: white;
}

.cancel-btn {
  color: #4a5568;
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

/* Modal animations */
.modal-enter-active, .modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from, .modal-leave-to {
  opacity: 0;
}

option{
  color: #660066;
  background-color: white;
  transition: all 0.3s ease;
  border: 1px solid #e6ccff;
  border-radius: 8px;
  font-size: 1em;
  
}
.report-options {
  margin: 1.5rem 0;
}

.form-group {
  margin-bottom: 1.2rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #660066;
}

.form-group select,
.form-group input {
    width: 100%;
  padding: 12px;
  border: 2px solid #e6ccff;
  border-radius: 8px;
  font-size: 1em;
  color: #660066;
  background-color: white;
  transition: all 0.3s ease;
}
.form-group select:focus,
.form-group input:focus {
    border-color: #cc66ff;
  outline: none;
  box-shadow: 0 0 0 3px rgba(204, 102, 255, 0.2);
  background-color: #f2e6ff;
}
.form-group::placeholder {
  color: #a880c7;
}
.date-range {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.date-range input {
  flex: 1;
}

.date-range span {
  color: #4a5568;
}

.form-buttons {
  display: flex;
  gap: 1rem;
  margin-top: 2rem;
}

.generate-btn,
.cancel-btn {
  padding: 0.6rem 1.2rem;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s ease;
}

.generate-btn {
  background: #6b2c91;
  color: white;
  flex: 2;
}

.cancel-btn {
  background: #dc3545;
  color: white;
  flex: 1;
}

.generate-btn:hover,
.cancel-btn:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}

@media (max-width: 768px) {
  .date-range {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .date-range span {
    text-align: center;
  }
}
.employee-select {
  background-color: #f8f9fa;
  color: #4a5568 !important;
  border: 1px solid #e6ccff;
  padding: 8px;
  border-radius: 4px;
  width: 100%;
  font-size: 16px;
}

.employee-select option {
  background-color: #ffffff;
  color: #4a5568 !important;
  padding: 8px;
}

.filter-box {
  margin-left: 1rem;
}

.purple-select {
  padding: 0.5rem;
  border: 1px solid #6b2c91;
  border-radius: 4px;
  color: #6b2c91;
  background-color: white;
  min-width: 150px;
}

.purple-select:focus {
  outline: none;
  box-shadow: 0 0 0 2px rgba(107, 44, 145, 0.2);
}

.column-filter {
  display: block;
  width: 100%;
  padding: 4px;
  margin-top: 4px;
  border: 1px solid #e6ccff;
  border-radius: 4px;
  font-size: 0.9em;
  color: #6b2c91;
  background-color: white;
}

.column-filter:focus {
  outline: none;
  border-color: #6b2c91;
  box-shadow: 0 0 0 2px rgba(107, 44, 145, 0.1);
}

/* Update table header styles */
th {
  padding: 12px;
  text-align: left;
  background-color: #f8f4fb;
  color: #6b2c91;
  font-weight: 600;
  border-bottom: 2px solid #e6ccff;
}

.modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
    margin-top: 2rem;
}

.cancel-btn, .generate-btn {
    padding: 0.8rem 1.5rem;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
}

.cancel-btn {
    background: #f8f9fa;
    border: 1px solid #ddd;
    color: #666;
}

.generate-btn {
    background: linear-gradient(135deg, #6b2c91, #4a1f64);
    border: none;
    color: white;
}

.generate-btn:disabled {
    opacity: 0.7;
    cursor: not-allowed;
}

.cancel-btn:hover {
    background: #e9ecef;
}

.generate-btn:hover:not(:disabled) {
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(107, 44, 145, 0.2);
}

/* Update form group styles for report modal */
.report-options .form-group select {
  color: #4a5568 !important;
  background-color: white;
}

.report-options .form-group option {
  color: #4a5568 !important;
  background-color: white;
  padding: 8px;
}

/* Specific styles for the employee select in report modal */
.report-options .form-group .employee-select,
.report-options .form-group .employee-select option {
  color: #4a5568 !important;
  background-color: white !important;
}

/* Style all selects in the report modal */
.report-options select,
.report-options select option {
  color: #4a5568 !important;
  background-color: white !important;
}

/* Override any conflicting styles */
.modal-content select,
.modal-content select option,
.modal-content .employee-select,
.modal-content .employee-select option {
  color: #4a5568 !important;
  background-color: white !important;
}

/* Additional specificity for the employee dropdown */
.form-group[v-if="reportSettings.type === 'employee'"] select,
.form-group[v-if="reportSettings.type === 'employee'"] select option {
  color: #4a5568 !important;
  background-color: white !important;
}

/* Responsive Design */
@media (max-width: 768px) {
  .records-header {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }
}
  </style>