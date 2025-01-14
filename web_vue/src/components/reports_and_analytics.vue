<template>
    <div class="reports-container">
      <div class="wave-bg"></div>
      
      <div class="content-wrapper">
        <!-- Error Message -->
        <div v-if="errorMessage" class="error-message">
          {{ errorMessage }}
        </div>
        <!-- Header Section -->
        <div class="header-section">
        <h1>Reports & Analytics</h1>
          <div class="header-actions">
            <button class="download-report-btn" @click="downloadFullReport">
              <i class="fas fa-file-download"></i>
              Download Full Report
            </button>
          </div>
        <div class="date-filter">
            <div class="filter-group">
              <label class="filter-label">Select Year</label>
          <select v-model="selectedYear" class="purple-select">
            <option v-for="year in years" :key="year" :value="year">
              {{ year }}
            </option>
          </select>
            </div>
          </div>
        </div>
      </div>
  <!-- Department Filter -->
  <div class="department-filter">
        <div class="filter-group">
          <label class="filter-label">Department</label>
        <select v-model="selectedDepartment" class="purple-select">
          <option value="">All Departments</option>
          <option v-for="department in departments" :key="department.id" :value="department.name">
            {{ department.name }}
          </option>
        </select>
        </div>

        <!-- Employee Filter -->
        <div class="filter-group">
          <label class="filter-label">Employee</label>
          <select v-model="selectedEmployee" class="purple-select">
            <option value="">All Employees</option>
            <option v-for="employee in employees" :key="employee.id" :value="employee.id">
              {{ employee.name }}
            </option>
          </select>
        </div>
      </div>
       <!-- Payroll Overview Card -->
       <div class="overview-card">
        <h2>Payroll Overview</h2>
        <div v-if="isLoading.dashboard" class="loading-spinner"></div>
        <div v-else class="overview-grid">
          <div class="overview-item">
            <span class="label">Total Monthly Payroll</span>
            <span class="value">₱{{ formatCurrency(payrollData.totalPayroll) }}</span>
            <small class="period-indicator">{{ payrollData.month }}/{{ payrollData.year }}</small>
            <div class="trend-indicator" :class="payrollData.trend > 0 ? 'up' : 'down'" v-if="payrollData.trend">
              <i :class="payrollData.trend > 0 ? 'fas fa-arrow-up' : 'fas fa-arrow-down'"></i>
              {{ Math.abs(payrollData.trend).toFixed(1) }}% from last month
            </div>
          </div>
          <div class="overview-item">
            <span class="label">Total Employees</span>
            <span class="value">{{ payrollData.totalEmployees }}
              <small class="employee-breakdown">
                (Active {{ payrollData.activeEmployees }},
                Inactive {{ payrollData.inactiveEmployees }},
                On Leave {{ payrollData.onLeaveEmployees }})
              </small>
            </span>
          </div>
          <div class="overview-item">
            <span class="label">Average Salary</span>
            <span class="value">₱{{ formatCurrency(payrollData.averageSalary) }}</span>
          </div>
          <div class="overview-item">
            <span class="label">Total Deductions</span>
            <span class="value">₱{{ formatCurrency(payrollData.totalDeductions) }}</span>
          </div>
        </div>
      </div>
  
       <!-- Reports Grid -->
      <div class="reports-grid">
        <!-- Attendance Report -->
        <div class="report-card">
          <h3>Attendance Report</h3>
          <div class="chart-actions">
            <button class="chart-btn" @click="downloadChart('attendance', 'png')">
              <i class="fas fa-download"></i> PNG
            </button>
            <button class="chart-btn" @click="downloadChart('attendance', 'pdf')">
              <i class="fas fa-file-pdf"></i> PDF
            </button>
          </div>
          <div class="chart-container">
          <canvas ref="attendanceChart"></canvas>
          </div>
          <div class="attendance-stats">
            <div class="stat-item">
              <span class="label">Present</span>
              <span class="value">{{ attendanceData.presentPercentage }}%</span>
            </div>
            <div class="stat-item">
              <span class="label">Absent</span>
              <span class="value">{{ attendanceData.absentPercentage }}%</span>
            </div>
            <div class="stat-item">
              <span class="label">Leave</span>
              <span class="value">{{ attendanceData.leavePercentage }}%</span>
            </div>
          </div>
        </div>
  
          <!-- Employee Performance -->
          <div class="report-card">
          <h3>Employee Performance</h3>
          <div class="performance-metrics">
            <div class="metric">
              <div class="metric-header">
                <span>Attendance Compliance</span>
                <span>{{ performanceData.attendanceCompliance }}%</span>
              </div>
              <div class="progress-bar">
                <div 
                  class="progress" 
                  :style="{ width: performanceData.attendanceCompliance + '%' }"
                ></div>
              </div>
            </div>
            <div class="metric">
              <div class="metric-header">
                <span>Punctuality</span>
                <span>{{ performanceData.punctuality }}%</span>
              </div>
              <div class="progress-bar">
                <div 
                  class="progress" 
                  :style="{ width: performanceData.punctuality + '%' }"
                ></div>
              </div>
            </div>
            <div class="metric">
              <div class="metric-header">
                <span>Efficiency</span>
                <span>{{ performanceData.efficiency }}%</span>
              </div>
              <div class="progress-bar">
                <div 
                  class="progress" 
                  :style="{ width: performanceData.efficiency + '%' }"
                ></div>
              </div>
            </div>
          </div>
        </div>
      </div>
  
       <!-- Tax Report -->
       <div class="tax-report-card">
        <h3>Tax Report</h3>
        <div class="tax-grid">
          <!-- Income Tax Brackets -->
          <div class="tax-section">
            <h4>Income Tax Brackets</h4>
            <div class="tax-table">
              <table>
                <thead>
                  <tr>
                    <th>Bracket</th>
                    <th>Range</th>
                    <th>Employees</th>
                    <th>Percentage</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="bracket in taxData.brackets" :key="bracket.name">
                    <td>{{ bracket.name }}</td>
                    <td>{{ bracket.range }}</td>
                    <td>{{ bracket.employees }}</td>
                    <td>{{ bracket.percentage.toFixed(2) }}%</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
  
            <!-- Statutory Deductions -->
            <div class="tax-section">
            <h4>Statutory Deductions</h4>
            <div class="chart-actions">
              <button class="chart-btn" @click="downloadChart('deductions', 'png')">
                <i class="fas fa-download"></i> PNG
              </button>
              <button class="chart-btn" @click="downloadChart('deductions', 'pdf')">
                <i class="fas fa-file-pdf"></i> PDF
              </button>
            </div>
            <div class="chart-container">
              <canvas ref="deductionsChart"></canvas>
            </div>
            <div class="deductions-summary">
              <div class="deduction-item" v-for="item in taxData.deductions" :key="item.type">
                <span class="label">{{ item.type }}</span>
                <span class="value">₱{{ formatCurrency(item.amount) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
  
       <!-- Salary Trends Analysis -->
       <div class="report-card salary-trends">
         <h3>Salary Trends Analysis</h3>
         <div class="chart-actions">
           <button class="chart-btn" @click="downloadChart('salaryTrends', 'png')">
             <i class="fas fa-download"></i> PNG
           </button>
           <button class="chart-btn" @click="downloadChart('salaryTrends', 'pdf')">
             <i class="fas fa-file-pdf"></i> PDF
           </button>
         </div>
         
         <!-- Growth Rate Card -->
         <div class="growth-rate-card">
           <div class="growth-indicator" :class="salaryTrends.growthRate >= 0 ? 'positive' : 'negative'">
             <i :class="salaryTrends.growthRate >= 0 ? 'fas fa-arrow-up' : 'fas fa-arrow-down'"></i>
             <span>{{ Math.abs(salaryTrends.growthRate) }}% YoY Growth</span>
           </div>
           <div class="year-comparison">
             <div class="year-stat">
               <span class="label">Current Year Avg</span>
               <span class="value">₱{{ formatCurrency(salaryTrends.statistics?.currentYearAvg) }}</span>
             </div>
             <div class="year-stat">
               <span class="label">Previous Year Avg</span>
               <span class="value">₱{{ formatCurrency(salaryTrends.statistics?.lastYearAvg) }}</span>
             </div>
           </div>
         </div>
         
         <!-- Monthly Trends Chart -->
         <div class="chart-container">
           <canvas ref="salaryTrendsChart"></canvas>
         </div>
         
         <!-- Department Comparison -->
         <div class="department-salary-comparison">
           <h4>Department Salary Distribution</h4>
           <div class="comparison-table">
             <table>
               <thead>
                 <tr>
                   <th>Department</th>
                   <th>Average Salary</th>
                   <th>Range</th>
                   <th>Employees</th>
                 </tr>
               </thead>
               <tbody>
                 <tr v-for="dept in salaryTrends.departmentComparisons" :key="dept.department">
                   <td>{{ dept.department }}</td>
                   <td>₱{{ formatCurrency(dept.average_salary) }}</td>
                   <td>₱{{ formatCurrency(dept.min_salary) }} - ₱{{ formatCurrency(dept.max_salary) }}</td>
                   <td>{{ dept.employee_count }}</td>
                 </tr>
               </tbody>
             </table>
           </div>
         </div>
    </div>
  </div>
  </template>
  <script>
  import axios from 'axios';

  import { Chart, registerables } from 'chart.js'
  Chart.register(...registerables)
  
  export default {
    name: 'ReportsAndAnalytics',
  data() {
    return {
      selectedYear: new Date().getFullYear(),
      selectedDepartment: '',
      selectedEmployee: '',
      departments: [],
      employees: [],
      years: [],
        payrollData: {
        totalPayroll: 0,
        totalEmployees: 0,
        averageSalary: 0,
        totalDeductions: 0
      },
        attendanceData: {
        presentPercentage: 0,
        absentPercentage: 0,
        leavePercentage: 0,
        labels: [],
        presentData: [],
        absentData: [],
        leaveData: []
      },
      performanceData: {
        attendanceCompliance: 0,
        punctuality: 0,
        efficiency: 0
      },
      taxData: {
        brackets: [],
        deductions: []
      },
      errorMessage: '',
      isLoading: {
        dashboard: false,
        attendance: false,
        performance: false,
        tax: false
      },
      charts: {
        attendance: null,
        deductions: null
      },
      chartIds: {
        attendance: 'attendance-chart',
        deductions: 'deductions-chart'
      },
      chartOptions: {
        line: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              position: 'bottom'
            },
            tooltip: {
              mode: 'index',
              intersect: false,
              callbacks: {
                label: function(context) {
                  return context.dataset.label + ': ' + context.parsed.y.toFixed(1) + '%';
                }
              }
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              max: 100
            }
          },
          interaction: {
            mode: 'nearest',
            axis: 'x',
            intersect: false
          },
          animations: {
            tension: {
              duration: 1000,
              easing: 'linear'
            }
          }
        },
        pie: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              position: 'bottom'
            },
            tooltip: {
              callbacks: {
                label: function(context) {
                  const label = context.label || '';
                  const value = context.parsed || 0;
                  const total = context.dataset.data.reduce((a, b) => a + b, 0);
                  const percentage = ((value / total) * 100).toFixed(1);
                  return `${label}: ₱${value.toLocaleString()} (${percentage}%)`;
                }
              }
            }
          },
          animation: {
            animateRotate: true,
            animateScale: true
          }
        }
      },
      salaryTrends: {
        monthlyAverages: [],
        departmentComparisons: [],
        growthRate: 0
      },
      overtimeAnalysis: {
        totalHours: 0,
        costImpact: 0,
        departmentDistribution: [],
        monthlyTrends: []
      },
      leavePatterns: {
        typeDistribution: [],
        seasonalTrends: [],
        departmentComparison: [],
        averageDuration: 0
      },
      departmentCosts: {
        breakdown: [],
        yearlyTrend: [],
        headcountImpact: [],
        costPerEmployee: {}
      },
      turnoverMetrics: {
        rate: 0,
        reasons: [],
        departmentRates: [],
        historicalTrend: []
      },
      industryComparison: {
        salaryBenchmarks: [],
        turnoverBenchmark: 0,
        benefitsComparison: [],
        marketPosition: ''
      }
    }
  },
  
  
    methods: {
      initializeYears() {
        const currentYear = new Date().getFullYear();
        const startYear = 2024; // Or get the earliest year from your attendance records
        this.years = [];
        for (let year = startYear; year <= currentYear; year++) {
          this.years.push(year);
        }
      },
      async fetchDepartments() {
      try {
        const response = await axios.get('/api/departments');
        this.departments = response.data.data;
      } catch (error) {
        console.error('Error fetching departments:', error);
      }
    },
    formatCurrency(value) {
      return Number(value).toLocaleString('en-PH', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      });
    },
    async fetchAllData() {
      try {
        await Promise.all([
          this.fetchDashboardStats(),
          this.fetchAttendanceStats(),
          this.fetchPerformanceMetrics(),
          this.fetchTaxReport(),
          this.fetchSalaryTrends()
        ]);
        this.updateCharts();
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    },
    updateCharts() {
      this.$nextTick(() => {
        try {
          // Clean up existing charts first
          this.destroyCharts();
          
          // Destroy and recreate attendance chart
          if (this.attendanceData.labels?.length) {
            if (this.$refs.attendanceChart) {
              const ctx = this.$refs.attendanceChart.getContext('2d');
              this.charts.attendance = new Chart(ctx, {
                id: this.chartIds.attendance,
        type: 'line',
                data: {
                  labels: this.attendanceData.labels,
                  datasets: [
                    {
                      label: 'Present',
                      data: this.attendanceData.presentData,
                      borderColor: '#4CAF50',
                      tension: 0.4,
                      fill: false
                    },
                    {
                      label: 'Absent',
                      data: this.attendanceData.absentData,
                      borderColor: '#f44336',
                      tension: 0.4,
                      fill: false
                    },
                    {
                      label: 'Late/Half-day',
                      data: this.attendanceData.leaveData,
                      borderColor: '#2196F3',
                      tension: 0.4,
                      fill: false
                    }
                  ]
                },
                options: this.chartOptions.line
              });
            }
          }

          // Destroy and recreate deductions chart
          if (this.taxData.deductions?.length) {
            if (this.$refs.deductionsChart) {
              const ctx = this.$refs.deductionsChart.getContext('2d');
              this.charts.deductions = new Chart(ctx, {
                id: this.chartIds.deductions,
        type: 'pie',
        data: {
          labels: this.taxData.deductions.map(d => d.type),
          datasets: [{
                    data: this.taxData.deductions.map(d => d.amount),
            backgroundColor: [
              '#4CAF50',
                      '#f44336',
              '#2196F3',
                      '#FFC107'
            ]
          }]
        },
                options: this.chartOptions.pie
              });
            }
          }
        } catch (error) {
          console.error('Error updating charts:', error);
        }
      });
    },
    destroyCharts() {
      if (this.charts.attendance) {
        this.charts.attendance.destroy();
        this.charts.attendance = null;
      }
      if (this.charts.deductions) {
        this.charts.deductions.destroy();
        this.charts.deductions = null;
      }
    },
    updateReports() {
      // Method to update reports when year/month/department changes
      // You would typically make an API call here
      console.log('Updating reports for:', this.selectedMonth, this.selectedYear, this.selectedDepartment);
    },
    async fetchDashboardStats() {
      this.isLoading.dashboard = true;
      try {
        const response = await axios.get('/api/reports/dashboard-stats', {
          params: {
            year: this.selectedYear,
            department: this.selectedDepartment,
            employee_id: this.selectedEmployee
          }
        });
        if (response.data) {
          this.payrollData = {
            totalPayroll: response.data.totalPayroll || 0,
            totalEmployees: response.data.totalEmployees || 0,
            averageSalary: response.data.averageSalary || 0,
            totalDeductions: response.data.totalDeductions || 0
          };
        }
      } catch (error) {
        console.error('Error fetching dashboard stats:', error.response?.data?.message || error.message);
        this.errorMessage = 'Failed to fetch dashboard statistics. Please try again.';
      } finally {
        this.isLoading.dashboard = false;
      }
    },
    async fetchAttendanceStats() {
      this.isLoading.attendance = true;
      try {
        const response = await axios.get('/api/reports/attendance-stats', {
          params: {
            year: this.selectedYear,
            department: this.selectedDepartment,
            employee_id: this.selectedEmployee
          }
        });
        if (response.data) {
          this.attendanceData = response.data;
        }
      } catch (error) {
        console.error('Error fetching attendance stats:', error);
        this.errorMessage = 'Failed to fetch attendance statistics';
      } finally {
        this.isLoading.attendance = false;
      }
    },
    async fetchPerformanceMetrics() {
      this.isLoading.performance = true;
      try {
        const response = await axios.get('/api/reports/performance-metrics', {
          params: {
            department: this.selectedDepartment,
            employee_id: this.selectedEmployee
          }
        });
        this.performanceData = response.data;
      } catch (error) {
        console.error('Error fetching performance metrics:', error);
      } finally {
        this.isLoading.performance = false;
      }
    },
    async fetchTaxReport() {
      this.isLoading.tax = true;
      try {
        const response = await axios.get('/api/reports/tax-report', {
          params: {
            year: this.selectedYear,
            department: this.selectedDepartment,
            employee_id: this.selectedEmployee
          }
        });
        if (response.data) {
          this.taxData = response.data;
        }
      } catch (error) {
        console.error('Error fetching tax report:', error);
        this.errorMessage = 'Failed to fetch tax report';
      } finally {
        this.isLoading.tax = false;
      }
    },
    async fetchEmployees() {
      try {
        const response = await axios.get('/api/reports/employees', {
          params: {
            department: this.selectedDepartment
          }
        });
        if (response.data && response.data.data) {
          console.log('Employees fetched:', response.data.data.length);
          this.employees = response.data.data;
        } else {
          console.error('Invalid employee data format:', response.data);
          this.employees = [];
        }
      } catch (error) {
        console.error('Error fetching employees:', error);
        this.employees = [];
        this.errorMessage = 'Failed to fetch employees';
      }
    },
    async downloadChart(chartId, format) {
      const chart = this.charts[chartId];
      if (!chart) return;
      
      // Get current date and time for filename
      const timestamp = new Date().toLocaleString('en-PH').replace(/[/:]/g, '-');
      const filename = `${chartId}-report-${timestamp}`;
      
      // Prepare report metadata
      const metadata = {
        generatedDate: new Date().toLocaleString('en-PH'),
        department: this.selectedDepartment || 'All Departments',
        employee: this.selectedEmployee || 'All Employees',
        period: `${this.payrollData.month}/${this.payrollData.year}`,
        reportType: chartId === 'attendance' ? 'Attendance Report' : 'Deductions Report'
      };
      
      if (format === 'png') {
        this.downloadPNG(chart, filename, metadata);
      } else if (format === 'pdf') {
        await this.downloadPDF(chart, filename, metadata, chartId);
      }
    },
    downloadPNG(chart, filename, metadata) {
      // Create a temporary canvas for the complete image
      const tempCanvas = document.createElement('canvas');
      const ctx = tempCanvas.getContext('2d');
      
      // Set canvas size to accommodate metadata
      tempCanvas.width = chart.canvas.width;
      tempCanvas.height = chart.canvas.height + 100;
      
      // Fill background
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(0, 0, tempCanvas.width, tempCanvas.height);
      
      // Add metadata
      ctx.fillStyle = '#1e293b';
      ctx.font = '14px Arial';
      let y = 30;
      Object.entries(metadata).forEach(([key, value]) => {
        ctx.fillText(`${key}: ${value}`, 20, y);
        y += 20;
      });
      
      // Add chart
      ctx.drawImage(chart.canvas, 0, 100);
      
      // Create download link
      const link = document.createElement('a');
      link.download = `${filename}.png`;
      link.href = tempCanvas.toDataURL('image/png');
      link.click();
    },
    async downloadPDF(chart, filename, metadata, chartId) {
      const { default: jsPDF } = await import('jspdf');
      const pdf = new jsPDF();
      
      // Add title
      pdf.setFontSize(18);
      pdf.setTextColor(30, 41, 59);
      pdf.text(metadata.reportType, 20, 20);
      
      // Add metadata
      pdf.setFontSize(12);
      let y = 40;
      Object.entries(metadata).forEach(([key, value]) => {
        pdf.text(`${key}: ${value}`, 20, y);
        y += 10;
      });
      
      // Add chart
      const imgData = chart.canvas.toDataURL('image/png');
      pdf.addImage(imgData, 'PNG', 20, y, 170, 100);
      
      // Add summary data if available
      y += 110;
      if (chartId === 'attendance') {
        pdf.text('Attendance Summary:', 20, y);
        y += 10;
        pdf.text(`Present: ${this.attendanceData.presentPercentage}%`, 30, y);
        y += 10;
        pdf.text(`Absent: ${this.attendanceData.absentPercentage}%`, 30, y);
        y += 10;
        pdf.text(`Leave: ${this.attendanceData.leavePercentage}%`, 30, y);
      } else if (chartId === 'deductions') {
        pdf.text('Deductions Summary:', 20, y);
        y += 10;
        this.taxData.deductions.forEach(deduction => {
          pdf.text(`${deduction.type}: ₱${this.formatCurrency(deduction.amount)}`, 30, y);
          y += 10;
        });
      }
      
      pdf.save(`${filename}.pdf`);
    },
    async downloadFullReport() {
      try {
        const timestamp = new Date().toLocaleString('en-PH').replace(/[/:]/g, '-');
        const filename = `complete-report-${timestamp}`;
        
        const { default: jsPDF } = await import('jspdf');
        const pdf = new jsPDF();
        let y = 20;
        
        // Company Header
        pdf.setFontSize(24);
        pdf.setTextColor(99, 102, 241);
        pdf.text('Company Name', 105, y, { align: 'center' });
        y += 15;
        
        // Report Title with Styling
        pdf.setFontSize(20);
        pdf.setTextColor(30, 41, 59);
        pdf.text('Complete Analytics Report', 105, y, { align: 'center' });
        
        // Add Report Metadata
        y += 20;
        pdf.setFontSize(12);
        pdf.setTextColor(100, 116, 139);
        const reportPeriod = `${this.payrollData.month}/${this.payrollData.year}`;
        
        // Create metadata box
        pdf.setDrawColor(99, 102, 241);
        pdf.setFillColor(248, 250, 252);
        pdf.roundedRect(20, y, 170, 40, 3, 3, 'FD');
        y += 10;
        
        pdf.text(`Generated: ${new Date().toLocaleString('en-PH')}`, 30, y);
        y += 10;
        pdf.text(`Department: ${this.selectedDepartment || 'All Departments'}`, 30, y);
        y += 10;
        pdf.text(`Reporting Period: ${reportPeriod}`, 30, y);
        
        // Salary Trends Section
        y += 25;
        pdf.setFontSize(16);
        pdf.setTextColor(99, 102, 241);
        pdf.line(20, y-5, 190, y-5);
        pdf.text('Salary Trends Analysis', 20, y);
        y += 15;
        
        // Add salary trends summary
        pdf.setFontSize(12);
        pdf.setTextColor(30, 41, 59);
        pdf.text(`Year-over-Year Growth: ${this.salaryTrends.growthRate}%`, 30, y);
        y += 10;
        pdf.text(`Current Year Average: ₱${this.formatCurrency(this.salaryTrends.statistics?.currentYearAvg)}`, 30, y);
        y += 10;
        pdf.text(`Previous Year Average: ₱${this.formatCurrency(this.salaryTrends.statistics?.lastYearAvg)}`, 30, y);
        y += 20;
        
        // Department Salary Distribution
        pdf.text('Department Salary Distribution', 30, y);
        y += 10;
        
        // Create department salary table
        const deptHeaders = ['Department', 'Avg Salary', 'Range', 'Employees'];
        const deptData = this.salaryTrends.departmentComparisons.map(dept => [
          dept.department,
          `₱${this.formatCurrency(dept.average_salary)}`,
          `₱${this.formatCurrency(dept.min_salary)} - ₱${this.formatCurrency(dept.max_salary)}`,
          dept.employee_count.toString()
        ]);
        
        this.createTable(pdf, [deptHeaders, ...deptData], y);
        y += (deptData.length + 1) * 10 + 15;

        // Payroll Overview Section
        pdf.addPage();
        y = 20;
        pdf.setFontSize(16);
        pdf.setTextColor(99, 102, 241);
        pdf.text('Payroll Overview', 20, y);
        
        // Add summary box
        y += 15;
        pdf.setFillColor(255, 255, 255);
        pdf.roundedRect(20, y, 170, 50, 3, 3, 'FD');
        y += 10;
        
        // Format currency values with proper alignment
        pdf.setFontSize(12);
        pdf.setTextColor(30, 41, 59);
        const currencyX = 140;
        
        // Total Monthly Payroll
        pdf.text('Total Monthly Payroll:', 30, y);
        pdf.text(`₱${this.formatCurrency(this.payrollData.totalPayroll)}`, currencyX, y, { align: 'right' });
        y += 10;
        
        // Employee Breakdown
        pdf.text('Total Employees:', 30, y);
        pdf.text(`${this.payrollData.totalEmployees}`, currencyX, y, { align: 'right' });
        y += 5;
        
        // Employee Status Breakdown
        pdf.setFontSize(10);
        pdf.text(`Active: ${this.payrollData.activeEmployees}`, 40, y);
        pdf.text(`Inactive: ${this.payrollData.inactiveEmployees}`, 90, y);
        pdf.text(`On Leave: ${this.payrollData.onLeaveEmployees}`, 140, y);
        y += 10;
        
        // Average Salary and Deductions
        pdf.setFontSize(12);
        pdf.text('Average Salary:', 30, y);
        pdf.text(`₱${this.formatCurrency(this.payrollData.averageSalary)}`, currencyX, y, { align: 'right' });
        y += 10;
        pdf.text('Total Deductions:', 30, y);
        pdf.text(`₱${this.formatCurrency(this.payrollData.totalDeductions)}`, currencyX, y, { align: 'right' });
        y += 20;
        
        // Performance Metrics
        pdf.setFontSize(16);
        pdf.setTextColor(99, 102, 241);
        pdf.text('Performance Summary', 20, y);
        y += 15;
        
        // Create performance metrics table
        const metrics = [
          ['Metric', 'Current', 'Target', 'Status'],
          ['Attendance', `${this.performanceData.attendanceCompliance}%`, '95%', this.getPerformanceStatus(this.performanceData.attendanceCompliance, 95)],
          ['Punctuality', `${this.performanceData.punctuality}%`, '90%', this.getPerformanceStatus(this.performanceData.punctuality, 90)],
          ['Efficiency', `${this.performanceData.efficiency}%`, '85%', this.getPerformanceStatus(this.performanceData.efficiency, 85)]
        ];
        
        this.createTable(pdf, metrics, y);
        y += (metrics.length + 1) * 10 + 15;

        // Attendance Analysis Section
        pdf.addPage();
        y = 20;
        pdf.setFontSize(16);
        pdf.setTextColor(99, 102, 241);
        pdf.text('Attendance Analysis', 105, y, { align: 'center' });
        y += 20;
        
        // Attendance Statistics
        pdf.setFontSize(12);
        pdf.setTextColor(30, 41, 59);
        
        const attendanceStats = [
          ['Present', `${this.attendanceData.presentPercentage}%`],
          ['Absent', `${this.attendanceData.absentPercentage}%`],
          ['Late/Half-day', `${this.attendanceData.latePercentage}%`]
        ];
        
        attendanceStats.forEach(([label, value]) => {
          pdf.text(label + ':', 30, y);
          pdf.text(value, 140, y, { align: 'right' });
          y += 10;
        });
        
        y += 10;
        
        // Add attendance chart
        if (this.charts.attendance) {
          const attendanceChart = this.charts.attendance.canvas.toDataURL('image/png');
          pdf.addImage(attendanceChart, 'PNG', 20, y, 170, 100, '', 'FAST');
          y += 110;
        }

        // Tax Report Section
        pdf.addPage();
        y = 20;
        pdf.setFontSize(16);
        pdf.setTextColor(99, 102, 241);
        pdf.text('Tax Analysis', 105, y, { align: 'center' });
        y += 20;
        
        // Income Tax Brackets
        pdf.setFontSize(14);
        pdf.text('Income Tax Brackets', 20, y);
        y += 15;
        
        // Create tax brackets table
        const taxHeaders = ['Bracket', 'Range', 'Employees', 'Percentage'];
        const taxData = this.taxData.brackets.map(bracket => [
          bracket.name,
          bracket.range,
          bracket.employees.toString(),
          `${bracket.percentage.toFixed(2)}%`
        ]);
        
        this.createTable(pdf, [taxHeaders, ...taxData], y);
        y += (taxData.length + 1) * 10 + 20;
        
        // Statutory Deductions Summary
        pdf.setFontSize(14);
        pdf.text('Statutory Deductions', 20, y);
        y += 15;
        
        // Create deductions table
        const deductionHeaders = ['Type', 'Amount', 'Percentage'];
        const deductionData = this.taxData.deductions.map(deduction => [
          deduction.type,
          `₱${this.formatCurrency(deduction.amount)}`,
          `${deduction.percentage.toFixed(2)}%`
        ]);
        
        this.createTable(pdf, [deductionHeaders, ...deductionData], y);
        y += (deductionData.length + 1) * 10 + 15;
        
        // Add Deductions Chart
        if (this.charts.deductions) {
          y += 10;
          const deductionsChart = this.charts.deductions.canvas.toDataURL('image/png');
          pdf.addImage(deductionsChart, 'PNG', 20, y, 170, 100, '', 'FAST');
          y += 110;
        }

        // Add charts with better formatting
        if (this.charts.attendance) {
          pdf.addPage();
          y = 20;
          pdf.setFontSize(16);
          pdf.text('Attendance Trends', 105, y, { align: 'center' });
          y += 10;
          const attendanceChart = this.charts.attendance.canvas.toDataURL('image/png');
          pdf.addImage(attendanceChart, 'PNG', 20, y, 170, 100, '', 'FAST');
          y += 110;
        }

        // Add Salary Trends Chart
        if (this.charts.salaryTrends) {
          pdf.addPage();
          y = 20;
          pdf.setFontSize(16);
          pdf.text('Salary Trends', 105, y, { align: 'center' });
          y += 10;
          const salaryChart = this.charts.salaryTrends.canvas.toDataURL('image/png');
          pdf.addImage(salaryChart, 'PNG', 20, y, 170, 100, '', 'FAST');
          y += 110;
        }

        // Add footer to each page
        const pageCount = pdf.internal.getNumberOfPages();
        for(let i = 1; i <= pageCount; i++) {
          pdf.setPage(i);
          pdf.setFontSize(10);
          pdf.setTextColor(156, 163, 175);
          pdf.text(`Generated on: ${new Date().toLocaleString('en-PH')} - Page ${i} of ${pageCount}`, 105, 287, { align: 'center' });
        }

        pdf.save(`${filename}.pdf`);
      } catch (error) {
        console.error('Error generating full report:', error);
        this.errorMessage = 'Failed to generate full report';
      }
    },
    // Helper method for performance status
    getPerformanceStatus(current, target) {
      const percentage = (current / target) * 100;
      if (percentage >= 100) return 'Excellent';
      if (percentage >= 90) return 'Good';
      if (percentage >= 75) return 'Fair';
      return 'Needs Improvement';
    },
    // Helper method to create tables
    createTable(pdf, data, startY) {
      const cellPadding = 5;
      const cellWidth = 40;
      const cellHeight = 10;
      
      data.forEach((row, i) => {
        row.forEach((cell, j) => {
          // Header row styling
          if (i === 0) {
            pdf.setFillColor(99, 102, 241);
            pdf.setTextColor(255, 255, 255);
          } else {
            pdf.setFillColor(i % 2 === 0 ? 248 : 255, 250, 252);
            pdf.setTextColor(30, 41, 59);
          }
          
          pdf.rect(20 + (j * cellWidth), startY + (i * cellHeight), cellWidth, cellHeight, 'F');
          pdf.text(cell.toString(), 20 + (j * cellWidth) + cellPadding, startY + (i * cellHeight) + 7);
        });
      });
    },
    async fetchSalaryTrends() {
      try {
        const response = await axios.get('/api/reports/salary-trends', {
          params: {
            year: this.selectedYear,
            department: this.selectedDepartment
          }
        });
        this.salaryTrends = response.data;
        this.$nextTick(() => {
          this.updateSalaryTrendsChart();
        });
      } catch (error) {
        console.error('Error fetching salary trends:', error);
        this.errorMessage = 'Failed to fetch salary trends';
      }
    },
    updateSalaryTrendsChart() {
      if (!this.$refs.salaryTrendsChart) {
        console.warn('Salary trends chart element not found');
        return;
      }

      if (this.charts.salaryTrends) {
        this.charts.salaryTrends.destroy();
      }
      
      const ctx = this.$refs.salaryTrendsChart.getContext('2d');
      if (!ctx) {
        console.warn('Could not get chart context');
        return;
      }

      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      if (!this.salaryTrends?.monthlyAverages?.length) {
        console.warn('No salary trends data available');
        return;
      }

      this.charts.salaryTrends = new Chart(ctx, {
        type: 'line',
        data: {
          labels: this.salaryTrends.monthlyAverages.map(item => monthNames[item.month - 1]),
          datasets: [{
            label: 'Average Salary',
            data: this.salaryTrends.monthlyAverages.map(item => item.average_salary),
            borderColor: '#6366f1',
            backgroundColor: 'rgba(99, 102, 241, 0.1)',
            fill: true,
            tension: 0.4
          }]
        },
        options: {
          ...this.chartOptions.line,
          scales: {
            y: {
              beginAtZero: true,
              ticks: {
                callback: value => '₱' + this.formatCurrency(value)
              }
            }
          }
        }
      });
    },
    async fetchOvertimeAnalysis() {
      // Similar implementation for overtime
    },
    async fetchLeavePatterns() {
      // Similar implementation for leave patterns
    },
    async fetchDepartmentCosts() {
      // Similar implementation for department costs
    },
    async fetchTurnoverMetrics() {
      // Similar implementation for turnover
    },
    async fetchIndustryComparison() {
      // Similar implementation for industry comparison
    }
  },
  async mounted() {
    this.initializeYears();
    this.$nextTick(async () => {
      try {
        await this.fetchDepartments();
        await this.fetchEmployees();
        await this.fetchAllData();
      } catch (error) {
        console.error('Error in mounted:', error);
      }
    });
    },
    watch: {
      selectedYear() {
      this.fetchAllData();
    },
    selectedDepartment: {
      immediate: true,
      handler() {
        this.fetchEmployees();
        this.selectedEmployee = '';
        this.$nextTick(() => {
          this.fetchAllData();
        });
      }
    },
    selectedEmployee() {
      this.fetchAllData();
    }
  },
  beforeUnmount() {
    this.destroyCharts();
    }
  }
  </script>
  <style scoped>
  .reports-container {
    min-height: 100vh;
    padding: 0;
    margin: 0;
    background: #f8fafc;
    position: relative;
    overflow-x: hidden;
  }
  
  .wave-bg {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    width: 100%;
    height: 150px;
    background: linear-gradient(to right, #6366f1, #8b5cf6);
    border-radius: 0 0 50% 50%;
    z-index: 1;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}
  
  .content-wrapper {
    position: relative;
    z-index: 2;
    padding: 20px;
    max-width: 1400px;
    margin: 0 auto;
  }
  
  /* Header Styles */
  .header-section {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    padding: 1rem 1.5rem;
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
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
  
  .date-filter {
    display: flex;
    gap: 1rem;
    align-items: center;
  }
  
  .purple-select {
    padding: 0.75rem 1rem;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    background: white;
    color: #1e293b;
    cursor: pointer;
    transition: all 0.2s;
    font-weight: 500;
    min-width: 150px;
    appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%236366f1'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 0.75rem center;
    background-size: 1rem;
    padding-right: 2.5rem;
  }
  
  .purple-select:hover {
    border-color: #6366f1;
    background: #f8fafc;
    transform: translateY(-1px);
    box-shadow: 0 2px 4px rgba(99, 102, 241, 0.1);
  }
  
  .purple-select:focus {
    outline: none;
    border-color: #6366f1;
    box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.2);
    background-color: white;
  }
  
  /* Filter Labels */
  .filter-label {
    font-size: 0.875rem;
    color: #4b5563;
    margin-bottom: 0.5rem;
    font-weight: 500;
  }
  
  /* Filter Groups */
  .filter-group {
    display: flex;
    flex-direction: column;
    flex: 1;
    min-width: 200px;
  }
  
  /* Overview Card Styles */
  .overview-card {
    background: white;
    border-radius: 12px;
    padding: 1.5rem;
    margin-bottom: 2rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    transition: all 0.2s;
  }
  
  .overview-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  }
  
  .overview-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1.5rem;
    margin-top: 1rem;
  }
  
  .overview-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    padding: 1rem;
    background: #f1f5f9;
    border-radius: 8px;
  }
  
  .overview-item .label {
    color: #000000;
    font-size: 0.9rem;
    margin-bottom: 0.3rem;
  }
  
  .overview-item .value {
    color: #1e293b;
    font-size: 1.5rem;
    font-weight: bold;
  }
  
  /* Reports Grid Styles */
  .reports-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 2rem;
    margin: 2rem 0;
  }
  
  .report-card {
    background: white;
    border-radius: 12px;
    padding: 1.5rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    transition: all 0.2s;
  }
  
  .report-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  }
  
  .report-card h3 {
    color: #660066;
    margin-bottom: 1.5rem;
  }
  
  /* Attendance Stats */
  .attendance-stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1rem;
    margin-top: 1rem;
  }
  
  .stat-item {
    text-align: center;
    padding: 0.5rem;
  }
  
  .stat-item .label {
    color: #000000;
    font-size: 0.9rem;
  }
  
  .stat-item .value {
    color: #1e293b;
    font-weight: bold;
  }
  
  /* Performance Metrics */
  .performance-metrics {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }
  
  .metric {
    background: #f8f9ff;
    padding: 1rem;
    border-radius: 12px;
    margin-bottom: 1rem;
    border: 1px solid rgba(124, 58, 237, 0.1);
  }
  
  .metric-header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 0.75rem;
    font-weight: 500;
  }
  
  .progress-bar {
    background: #e9ecef;
    height: 8px;
    border-radius: 4px;
    overflow: hidden;
    margin-top: 0.5rem;
  }
  
  .progress {
    background: #6366f1;
    height: 100%;
    transition: width 0.5s ease-in-out;
  }
  
  /* Tax Report Styles */
  .tax-report-card {
    background: white;
    border-radius: 12px;
    padding: 1.5rem;
    margin-top: 2rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    transition: all 0.2s;
  }
  
  .tax-report-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  }
  
  .tax-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: 2rem;
    margin-top: 1.5rem;
  }
  
  .tax-section h4 {
    color: #660066;
    margin-bottom: 1rem;
  }
  
  /* Tax Table Styles */
  .tax-table table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    margin: 1rem 0;
  }
  
  .tax-table th,
  .tax-table td {
    padding: 1rem;
    text-align: left;
    border-bottom: 1px solid rgba(124, 58, 237, 0.1);
    color: #000000;
  }
  
  .tax-table th {
    background: #f8fafc;
    font-weight: 600;
    color: #000000;
  }
  
  .tax-table tr:hover td {
    background: #f8f9ff;
    color: #000000;
  }
  
  /* Deductions Summary */
  .deductions-summary {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 1rem;
    margin-top: 1rem;
  }
  
  .deduction-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    padding: 0.8rem;
    background: #f8f4ff;
    border-radius: 8px;
  }
  
  .deduction-item .label {
    color: #000000;
    font-size: 0.9rem;
    margin-bottom: 0.3rem;
  }
  
  .deduction-item .value {
    color: #1e293b;
    font-weight: bold;
  }
  
  /* Responsive Styles */
  @media (max-width: 768px) {
    .content-wrapper {
      padding: 1rem;
    }
  
    .header-section {
      flex-direction: column;
      gap: 1rem;
      text-align: center;
      padding: 1rem;
    }
  
    .reports-grid,
    .tax-grid {
      grid-template-columns: 1fr;
    }
  
    .overview-grid {
      grid-template-columns: repeat(2, 1fr);
    }
  
    .attendance-stats {
      grid-template-columns: 1fr;
    }
  
    .deductions-summary {
      grid-template-columns: repeat(2, 1fr);
    }
  
    .department-filter {
      flex-direction: column;
      padding: 1rem;
    }
  
    .filter-group {
      width: 100%;
    }
  
    .purple-select {
      width: 100%;
      min-width: unset;
    }
  }
  
  /* Chart Container Styles */
  .chart-container {
    position: relative;
    height: 300px;
    width: 100%;
    margin: 1rem 0;
    background: white;
    padding: 1rem;
    border-radius: 12px;
    transition: all 0.3s ease;
    box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.05);
  }
  
  .chart-container:hover {
    box-shadow: inset 0 2px 8px rgba(0, 0, 0, 0.1);
  }
  
  canvas {
    width: 100%;
    height: 100%;
    margin: 1rem 0;
  }
  h1, h2, h3, h4 {
    color: #1e293b;
    font-weight: 600;
    letter-spacing: -0.025em;
  }
  .loading-spinner {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 200px;
  }

  .loading-spinner::after {
    content: '';
    width: 40px;
    height: 40px;
    border: 3px solid #e2e8f0;
    border-top: 3px solid #6366f1;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  .error-message {
    background: linear-gradient(to right, rgba(220, 53, 69, 0.05), rgba(220, 53, 69, 0.1));
    color: #dc3545;
    padding: 1rem;
    border-radius: 8px;
    margin: 1rem 0;
    text-align: center;
    font-size: 0.9rem;
    border-left: 4px solid #dc3545;
    box-shadow: 0 2px 4px rgba(220, 53, 69, 0.1);
  }

  .employee-breakdown {
    display: block;
    font-size: 0.8rem;
    color: #000000;
    margin-top: 0.25rem;
  }

  /* Animations */
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .overview-card, .report-card, .tax-report-card {
    animation: fadeIn 0.5s ease-out forwards;
  }

  /* Responsive Design */
  @media (max-width: 480px) {
    .overview-grid {
      grid-template-columns: 1fr;
    }

    .purple-select {
      width: 100%;
      margin-bottom: 0.5rem;
    }
  }

  /* Chart Actions */
  .chart-actions {
    display: flex;
    gap: 0.5rem;
    justify-content: flex-end;
    margin-bottom: 1rem;
  }

  .chart-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 6px;
    background: white;
    color: #6366f1;
    font-size: 0.875rem;
    cursor: pointer;
    transition: all 0.2s ease;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .chart-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 2px 4px rgba(99, 102, 241, 0.2);
    background: #f8fafc;
  }

  .chart-btn i {
    font-size: 1rem;
  }

  /* Trend Indicator Styles */
  .trend-indicator {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.875rem;
    margin-top: 0.5rem;
    padding: 0.25rem 0.75rem;
    border-radius: 20px;
    width: fit-content;
  }

  .trend-indicator.up {
    background: rgba(76, 175, 80, 0.1);
    color: #2e7d32;
  }

  .trend-indicator.down {
    background: rgba(244, 67, 54, 0.1);
    color: #d32f2f;
  }

  .trend-indicator i {
    font-size: 0.75rem;
  }

  .header-actions {
    display: flex;
    align-items: center;
    gap: 1.5rem;
  }

  .download-report-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1.5rem;
    background: linear-gradient(to right, #6366f1, #8b5cf6);
    color: white;
    border: none;
    border-radius: 8px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
    box-shadow: 0 2px 4px rgba(99, 102, 241, 0.2);
  }

  .download-report-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.3);
  }

  .download-report-btn i {
    font-size: 1.1rem;
  }

  /* Enhanced Card Styles */
  .report-card, .tax-report-card {
    background: white;
    border-radius: 16px;
    padding: 2rem;
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.1);
    transition: all 0.3s ease;
    border: 1px solid rgba(99, 102, 241, 0.1);
  }
  
  .report-card:hover, .tax-report-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 15px rgba(99, 102, 241, 0.15);
    border-color: rgba(99, 102, 241, 0.2);
  }
  
  /* Enhanced Progress Bar Styles */
  .progress-bar {
    background: #f1f5f9;
    height: 12px;
    border-radius: 6px;
    overflow: hidden;
    box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.05);
  }
  
  .progress {
    height: 100%;
    background: linear-gradient(to right, #6366f1, #8b5cf6);
    border-radius: 6px;
    transition: width 1s ease-in-out;
    box-shadow: 0 2px 4px rgba(99, 102, 241, 0.2);
  }
  
  /* Enhanced Metric Header Styles */
  .metric-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.75rem;
    font-weight: 500;
  }
  
  .metric-header span:last-child {
    color: #6366f1;
    font-weight: 600;
    background: rgba(99, 102, 241, 0.1);
    padding: 0.25rem 0.75rem;
    border-radius: 15px;
  }
  
  /* Enhanced Table Styles */
  .tax-table {
    overflow: hidden;
    border-radius: 12px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  }
  
  .tax-table table {
    border-collapse: separate;
    border-spacing: 0;
    width: 100%;
  }
  
  .tax-table th {
    background: linear-gradient(to right, #f8fafc, #f1f5f9);
    padding: 1.25rem 1rem;
    font-weight: 600;
    text-transform: uppercase;
    font-size: 0.875rem;
    letter-spacing: 0.05em;
  }
  
  .tax-table td {
    padding: 1.25rem 1rem;
    background: white;
    transition: all 0.2s ease;
  }
  
  .tax-table tr:hover td {
    background: rgba(99, 102, 241, 0.05);
  }
  
  /* Enhanced Overview Item Styles */
  .overview-item {
    background: white;
    border-radius: 16px;
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.1);
    transition: all 0.3s ease;
    border: 1px solid rgba(99, 102, 241, 0.1);
  }
  
  .overview-item:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 15px rgba(99, 102, 241, 0.15);
  }
  
  .overview-item .label {
    color: #64748b;
    font-size: 0.875rem;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }
  
  .overview-item .value {
    color: #1e293b;
    font-size: 1.5rem;
    font-weight: 600;
    line-height: 1.2;
  }
  
  /* Enhanced Chart Container */
  .chart-container {
    background: white;
    border-radius: 16px;
    padding: 1.5rem;
    margin: 1.5rem 0;
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.1);
    transition: all 0.3s ease;
    border: 1px solid rgba(99, 102, 241, 0.1);
  }
  
  /* Enhanced Loading Animation */
  @keyframes pulse {
    0%, 100% { transform: scale(1); opacity: 1; }
    50% { transform: scale(0.9); opacity: 0.5; }
  }
  
  .loading-spinner::after {
    animation: spin 1s linear infinite, pulse 2s ease-in-out infinite;
  }
  
  /* Enhanced Filter Styles */
  .department-filter {
    background: white;
    border-radius: 16px;
    padding: 1.5rem;
    margin-bottom: 2rem;
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.1);
    border: 1px solid rgba(99, 102, 241, 0.1);
  }
  
  .filter-group label {
    color: #64748b;
    font-size: 0.875rem;
    font-weight: 500;
    margin-bottom: 0.5rem;
    display: block;
  }
  
  /* Enhanced Button Styles */
  .download-report-btn, .chart-btn {
    position: relative;
    overflow: hidden;
  }
  
  .download-report-btn::after, .chart-btn::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    width: 120%;
    height: 120%;
    background: rgba(255, 255, 255, 0.2);
    transform: translate(-50%, -50%) scale(0);
    border-radius: 50%;
    transition: transform 0.5s ease;
  }
  
  .download-report-btn:active::after, .chart-btn:active::after {
    transform: translate(-50%, -50%) scale(1);
    opacity: 0;
  }

  /* Salary Trends Styles */
  .salary-trends {
    margin-top: 2rem;
  }

  .growth-rate-card {
    background: white;
    border-radius: 12px;
    padding: 1.5rem;
    margin: 1.5rem 0;
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.1);
    border: 1px solid rgba(99, 102, 241, 0.1);
  }

  .growth-indicator {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    font-size: 1.25rem;
    font-weight: 600;
    padding: 0.75rem 1.5rem;
    border-radius: 12px;
    margin-bottom: 1rem;
  }

  .growth-indicator.positive {
    background: linear-gradient(to right, rgba(16, 185, 129, 0.1), rgba(16, 185, 129, 0.2));
    color: #059669;
  }

  .growth-indicator.negative {
    background: linear-gradient(to right, rgba(239, 68, 68, 0.1), rgba(239, 68, 68, 0.2));
    color: #dc2626;
  }

  .year-comparison {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin-top: 1rem;
  }

  .year-stat {
    background: #f8fafc;
    padding: 1rem;
    border-radius: 8px;
    border: 1px solid rgba(99, 102, 241, 0.1);
  }

  .year-stat .label {
    color: #64748b;
    font-size: 0.875rem;
    font-weight: 500;
    margin-bottom: 0.5rem;
    display: block;
  }

  .year-stat .value {
    color: #1e293b;
    font-size: 1.5rem;
    font-weight: 600;
  }

  /* Department Salary Comparison Styles */
  .department-salary-comparison {
    margin-top: 2rem;
  }

  .department-salary-comparison h4 {
    color: #1e293b;
    margin-bottom: 1rem;
    font-size: 1.25rem;
  }

  .comparison-table {
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 6px rgba(99, 102, 241, 0.1);
  }

  .comparison-table table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
  }

  .comparison-table th {
    background: linear-gradient(to right, #f8fafc, #f1f5f9);
    color: #1e293b;
    font-weight: 600;
    text-transform: uppercase;
    font-size: 0.75rem;
    letter-spacing: 0.05em;
    padding: 1rem;
    text-align: left;
  }

  .comparison-table td {
    padding: 1rem;
    border-bottom: 1px solid rgba(99, 102, 241, 0.1);
    color: #1e293b;
  }

  .comparison-table tr:last-child td {
    border-bottom: none;
  }

  .comparison-table tr:hover td {
    background: rgba(99, 102, 241, 0.05);
  }

  /* Responsive adjustments */
  @media (max-width: 768px) {
    .year-comparison {
      grid-template-columns: 1fr;
    }
    
    .comparison-table {
      overflow-x: auto;
    }
    
    .growth-indicator {
      font-size: 1rem;
      padding: 0.5rem 1rem;
    }
  }
  </style>