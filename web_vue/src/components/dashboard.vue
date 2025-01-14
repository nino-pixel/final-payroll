<template>
  <div class="dashboard-container">
    <div class="dashboard-header">
    <h1>Payroll Admin Dashboard</h1>
      <div class="header-stats">
        <div class="stat-card">
          <i class="fas fa-users"></i>
          <div class="stat-info">
            <span class="stat-value">{{ totalEmployees }}</span>
            <span class="stat-label">Total Employees</span>
          </div>
          </div>
        <div class="stat-card">
          <i class="fas fa-building"></i>
          <div class="stat-info">
            <span class="stat-value">{{ totalDepartments }}</span>
            <span class="stat-label">Departments</span>
          </div>
        </div>
        <div class="stat-card">
          <i class="fas fa-briefcase"></i>
          <div class="stat-info">
            <span class="stat-value">{{ totalPositions }}</span>
            <span class="stat-label">Positions</span>
      </div>
          </div>
        <div class="stat-card">
          <i class="fas fa-clock"></i>
          <div class="stat-info">
            <span class="stat-value">{{ currentMonthAttendance }}%</span>
            <span class="stat-label">Current Month Attendance</span>
          </div>
          </div>
        <div class="stat-card">
          <i class="fas fa-money-bill-wave"></i>
          <div class="stat-info">
            <span class="stat-value">₱{{ formatCurrency(totalMonthlySalary) }}</span>
            <span class="stat-label">Monthly Salary Distribution</span>
        </div>
      </div>
        <div class="stat-card highlight">
          <i class="fas fa-trophy"></i>
          <div class="stat-info">
            <div class="employee-details">
              <span class="employee-name-large">{{ highestPaidEmployee.name }}</span>
              <span class="employee-dept">{{ highestPaidEmployee.department }}</span>
            </div>
            <div class="salary-details">
              <span class="salary-value">₱{{ formatCurrency(highestPaidEmployee.salary) }}</span>
              <span class="stat-label">Highest Salary</span>
            </div>
          </div>
        </div>
      </div>
        </div>
    <div class="charts-grid">
      <!-- Employee Population Bar Graph -->
      <div class="chart-card wide">
        <h2>Employee Population by Department</h2>
        <div class="chart-container">
          <v-chart :option="departmentBarOption" autoresize />
        </div>
        <div class="total-employees">
          <span>Total Employees: {{ totalEmployees }}</span>
        </div>
      </div>

      <!-- Attendance Line Chart -->
      <div class="chart-card wide attendance-chart">
        <div class="chart-header">
          <h2>Monthly Attendance Summary</h2>
          <div class="chart-controls">
            <select 
              v-model="selectedYear" 
              class="year-select"
              @change="fetchAttendanceRates"
            >
              <option v-for="year in availableYears" :key="year" :value="year">
                {{ year }}
              </option>
            </select>
            <label class="toggle-label">
              <input 
                type="checkbox" 
                v-model="showPredictions" 
                @change="updateChartData"
              >
              <span>Show Predictions</span>
            </label>
          </div>
        </div>
        <div class="chart-container">
          <v-chart :option="attendanceLineOption" autoresize />
        </div>
        <div class="prediction-legend" v-if="showPredictions">
          <span class="prediction-dot actual"></span> Actual Data
          <span class="prediction-dot predicted"></span> Predicted Data
        </div>
      </div>

      <!-- Salary Distribution Pie Chart -->
      <div class="chart-card">
        <div class="chart-header">
        <h2>Salary Distribution</h2>
    <div class="chart-controls">
      <select v-model="selectedYearForSalary" class="year-select" @change="fetchDepartmentSalaries">
        <option v-for="year in availableYears" :key="year" :value="year">
          {{ year }}
        </option>
      </select>
      <select v-model="selectedMonthForSalary" class="month-select" @change="fetchDepartmentSalaries">
        <option v-for="(month, index) in months" :key="index" :value="index + 1">
          {{ month }}
        </option>
      </select>
    </div>
  </div>
        <div class="chart-container">
          <v-chart :option="salaryPieOption" autoresize />
        </div>
      </div>

      <!-- Payroll Countdown Card -->
      <div class="chart-card">
        <div class="payroll-countdown">
          <h2>Next Payroll</h2>
          <div class="countdown-container">
            <div class="countdown-timer">
              <div class="time-block">
                <span class="time-value">{{ countdown.days }}</span>
                <span class="time-label">Days</span>
        </div>
              <div class="time-separator">:</div>
              <div class="time-block">
                <span class="time-value">{{ countdown.hours }}</span>
                <span class="time-label">Hours</span>
              </div>
              <div class="time-separator">:</div>
              <div class="time-block">
                <span class="time-value">{{ countdown.minutes }}</span>
                <span class="time-label">Minutes</span>
              </div>
            </div>
            <div class="next-payroll-date">
              {{ formatNextPayrollDate }}
            </div>
            <div class="progress-bar">
              <div class="progress" :style="{ width: payrollProgress + '%' }"></div>
            </div>
            <div class="payroll-status">
              <i class="fas" :class="payrollStatusIcon"></i>
              {{ payrollStatusText }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { use } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { LineChart } from 'echarts/charts';
import {
  GridComponent,
  TooltipComponent,
  LegendComponent,
  TitleComponent
} from 'echarts/components';
import VChart from 'vue-echarts';
import axios from 'axios';
import EmployeeManagement from './employee_management.vue';
import { emitter } from '../eventBus';

use([
  CanvasRenderer,
  LineChart,
  GridComponent,
  TooltipComponent,
  LegendComponent,
  TitleComponent
]);

export default {
  name: 'Dashboard',
  components: {
    EmployeeManagement
  },
  computed: {
    totalEmployees() {
      if (!this.departmentBarOption.series[0].data.length) return 0;
      return this.departmentBarOption.series.reduce((total, series) => {
        return total + series.data.reduce((sum, count) => sum + count, 0);
      }, 0);
    },
    formatNextPayrollDate() {
      const nextPayday = this.getNextPayday();
      return nextPayday.toLocaleDateString('en-US', { 
        weekday: 'long',
        month: 'long', 
        day: 'numeric'
      });
    },
    payrollStatusIcon() {
      if (this.countdown.days <= 2) return 'fa-clock text-warning';
      if (this.countdown.days <= 5) return 'fa-hourglass-half text-info';
      return 'fa-calendar-check text-success';
    },
    payrollStatusText() {
      if (this.countdown.days <= 2) return 'Payroll Processing Soon';
      if (this.countdown.days <= 5) return 'Preparing for Payroll';
      return 'On Track';
    }
  },
  data() {
    return {
      departments: [],
      employees: [],
      refreshInterval: null,
      departmentBarOption: {
        title: {
          text: 'Employee Count by Department',
          left: 'center',
        },
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          }
        },
        legend: {
          data: ['Active', 'Inactive', 'On Leave'],
          bottom: '0%'
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '15%',
          top: '15%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: [],
          axisLabel: {
            interval: 0,
            rotate: 30,
            width: 100,
            overflow: 'break'
          },
          axisTick: {
            alignWithLabel: true
          }
        },
        yAxis: {
          type: 'value'
        },
        series: [
          {
            name: 'Active',
            type: 'bar',
            stack: 'total',
            barWidth: '40%',
            data: [],
            itemStyle: {
              color: '#1e7e34'
            }
          },
          {
            name: 'Inactive',
            type: 'bar',
            stack: 'total',
          data: [],
            itemStyle: {
              color: '#dc3545'
            }
          },
          {
            name: 'On Leave',
          type: 'bar',
            stack: 'total',
            data: [],
          itemStyle: {
              color: '#856404'
            }
          }
        ]
      },
      salaryPieOption: {
        title: {
          text: 'Salary Distribution by Department',
          top: 0,
          left: 'center',
          textStyle: {
            fontSize: 16,
            fontWeight: 600
          }
        },
        tooltip: {
          trigger: 'item',
          formatter: '{b}: ₱{c} ({d}%)'
        },
        legend: {
          orient: 'horizontal',
          top: 'bottom',
          type: 'scroll',
          padding: [0, 20],
          textStyle: {
            fontSize: 12
          }
        },
        series: [{
          name: 'Salary Distribution',
          type: 'pie',
          radius: ['30%', '70%'],
          center: ['50%', '50%'],
          avoidLabelOverlap: true,
          label: {
            show: true,
            position: 'outside',
            formatter: '{b}\n{d}%'
          },
          emphasis: {
            label: {
              show: true,
              fontSize: '14',
              fontWeight: 'bold'
            }
          },
          data: []
        }]
      },
      months: [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ],
      departmentColors: {
        'HR': {
          primary: '#FF6B6B',
          secondary: '#FFB6B6'
        },
        'IT': {
          primary: '#4ECDC4',
          secondary: '#A8E6E2'
        },
        'Finance': {
          primary: '#FFB347',
          secondary: '#FFD7A8'
        },
        'Marketing': {
          primary: '#9B59B6',
          secondary: '#D2B4DE'
        },
        'Operations': {
          primary: '#3498DB',
          secondary: '#A9CCE3'
        },
        'Sales': {
          primary: '#2ECC71',
          secondary: '#A3E4B5'
        },
        'Research': {
          primary: '#F1C40F',
          secondary: '#F9E79F'
        },
        'Legal': {
          primary: '#E74C3C',
          secondary: '#F5B7B1'
        },
        'Customer Service': {
          primary: '#1ABC9C',
          secondary: '#A3E4D7'
        }
      },
      attendanceLineOption: {
        title: {
          text: 'Monthly Attendance Rate',
          left: 'center'
        },
        tooltip: {
          trigger: 'axis',
          formatter: function(params) {
            let tooltip = `
              <div style="margin-bottom:10px;font-weight:600;color:#2d3748">
                ${params[0].axisValue}
              </div>
            `;
            
            params.sort((a, b) => b.value - a.value);
            
            params.forEach(param => {
              const value = param.data.value;
              const isPredicted = param.data.isPredicted;
              const color = param.color;
              
              tooltip += `
                <div style="display:flex;justify-content:space-between;align-items:center;margin:6px 0">
                  <div style="display:flex;align-items:center;gap:8px">
                    <span style="
                      display:inline-block;
                      width:8px;
                      height:8px;
                      border-radius:50%;
                      background:${color};
                      ${isPredicted ? 'border: 1px dashed #666' : ''}
                    "></span>
                    <span style="color:#4a5568">${param.seriesName}</span>
                  </div>
                  <span style="
                    font-weight:600;
                    color:${color};
                    ${isPredicted ? 'font-style:italic' : ''}
                  ">
                    ${parseFloat(value).toFixed(1)}% Attendance
                    ${isPredicted ? '<span style="color:#666;font-size:11px">(Predicted)</span>' : ''}
                  </span>
                </div>
              `;
            });

            if (params.some(p => p.data.isPredicted)) {
              tooltip += `
                <div style="
                  margin-top:8px;
                  padding-top:8px;
                  border-top:1px dashed #ddd;
                  font-size:11px;
                  color:#666;
                  font-style:italic
                ">
                  * Predicted values are estimates
                </div>
              `;
            }
            
            return tooltip;
          }
        },
        legend: {
          type: 'scroll',
          top: 25,
          left: 50,
          right: 50
        },
        grid: {
          top: 60,
          bottom: 60,
          left: 80,
          right: 50,
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
          boundaryGap: true,
          axisLabel: {
            interval: 0,
            rotate: 30
          }
        },
        yAxis: {
          type: 'value',
          min: 0,
          max: 100,
          interval: 10,
          axisLabel: {
            formatter: '{value}%'
          }
        },
        series: []
      },
      payrollBatteryOption: {
        title: {
          text: 'Days Until Next Payroll',
          left: 'center',
          textStyle: {
            fontSize: 16,
            fontWeight: 'bold',
            color: '#333'
          }
        },
        tooltip: {
          formatter: '{b}: {c} days',
          backgroundColor: 'rgba(255, 255, 255, 0.9)',
          borderRadius: 8,
          textStyle: {
            color: '#333'
          }
        },
        series: [{
          type: 'gauge',
          startAngle: 180,
          endAngle: 0,
          min: 0,
          max: 15,
          splitNumber: 5,
          radius: '90%',
          center: ['50%', '70%'],
          axisLine: {
            lineStyle: {
              width: 20,
              color: [
                [0.3, '#6bcb77'],  // Green for safe (0-30%)
                [0.7, '#ffd93d'],  // Yellow for warning (30-70%)
                [1, '#ff6b6b']     // Red for urgent (70-100%)
              ]
            }
          },
          pointer: {
            icon: 'path://M12.8,0.7l12,40.1H0.7L12.8,0.7z',
            length: '12%',
            width: 6,
            offsetCenter: [0, '-60%'],
            itemStyle: {
              color: '#6b2c91'
            }
          },
          axisTick: {
            length: 6,
            lineStyle: {
              color: 'inherit',
              width: 2
            }
          },
          splitLine: {
            length: 12,
            lineStyle: {
              color: 'inherit',
              width: 3
            }
          },
          axisLabel: {
            color: '#666',
            fontSize: 12,
            distance: -40
          },
          title: {
            offsetCenter: [0, '-20%'],
            fontSize: 20
          },
          detail: {
            fontSize: 30,
            offsetCenter: [0, '0%'],
            valueAnimation: true,
            formatter: function (value) {
              return Math.round(value) + ' days';
            },
                color: '#333'
          },
          data: [{
            value: 0,
            name: 'Days Left'
          }]
        }]
      },
      isLoading: false,
      showErrorModal: false,
      showSuccessModal: false,
      errorMessage: '',
      modalMessage: '',
      showPredictions: true,
      actualData: {},
      predictedData: {},
      selectedYear: new Date().getFullYear(),
      availableYears: [],
      chart: null,
       selectedYearForSalary: new Date().getFullYear(),
    selectedMonthForSalary: new Date().getMonth() + 1,
    months: [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ],
    totalPositions: 0,
    currentMonthAttendance: 0,
    totalMonthlySalary: 0,
    totalDepartments: 0,
    countdown: {
      days: 0,
      hours: 0,
      minutes: 0
    },
    countdownInterval: null,
    payrollProgress: 0,
    highestPaidEmployee: {
      name: 'N/A',
      department: 'N/A',
      salary: 0
    }
    };
    
  },
  async mounted() {
    this.fetchInitialData();
    // Set up event listener for dashboard refresh
    emitter.on('refresh-dashboard', this.fetchInitialData);
    
    // Set up refresh interval for real-time updates
    this.refreshInterval = setInterval(() => {
      this.fetchDepartmentData();
    }, 3000000); // Refresh every 30 seconds
    
    // Listen for employee changes
    emitter.on('refresh-dashboard', () => {
      this.fetchDepartmentData();
    });
    
    this.updatePayrollCountdown(); // Initial update
    
    // Update countdown every hour
    setInterval(() => {
      this.updatePayrollCountdown();
    }, 3600000); // 1 hour in milliseconds

    this.initializeYears();
    this.fetchDepartmentSalaries();
    this.fetchDashboardStats();
    this.updateCountdown();
    this.countdownInterval = setInterval(this.updateCountdown, 60000); // Update every minute
  },
  beforeUnmount() {
    // Clear interval when component is destroyed
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
    }
    // Remove event listener
    emitter.off('refresh-dashboard');
    if (this.countdownInterval) {
      clearInterval(this.countdownInterval);
    }
  },
  methods: {
    calculatePredictions(historicalData) {
      return historicalData.map(value => {
        const randomVariation = (Math.random() - 0.5) * 5;
        return Math.min(100, Math.max(0, value + randomVariation));
      });
    },
    async fetchData() {
      this.isLoading = true;
      try {
        const [employeesResponse, departmentsResponse] = await Promise.all([
          axios.get('/api/employees'),
          axios.get('/api/departments')
        ]);

        this.employees = Array.isArray(employeesResponse.data) ? employeesResponse.data : [];
        this.departments = Array.isArray(departmentsResponse.data.data) ? departmentsResponse.data.data : [];

        // Update bar chart
        if (this.departments.length > 0) {
          this.departmentBarOption.xAxis.data = this.departments.map(dept => dept.name);
          this.departmentBarOption.series[0].data = this.departments.map(dept => 
            dept.employee_count || 0
          );

          // Update pie chart
          this.salaryPieOption.series[0].data = this.departments.map(dept => ({
            value: (dept.employees || []).reduce((sum, emp) => sum + (Number(emp.base_salary) || 0), 0),
            name: dept.name
          }));
        }
      } catch (error) {
        console.error('Error fetching data:', error);
        this.errorMessage = 'Failed to load dashboard data';
        this.showErrorModal = true;
      } finally {
        this.isLoading = false;
      }
    },
    async fetchDepartmentData() {
      this.isLoading = true;
      try {
        const response = await axios.get('/api/departments/employee-counts');
        
        // Sort departments by name for consistent display
        const sortedData = response.data.sort((a, b) => a.name.localeCompare(b.name));
        
        // Update the bar chart data
        this.departmentBarOption.xAxis.data = sortedData.map(dept => dept.name);
        this.departmentBarOption.series[0].data = sortedData.map(dept => dept.active_count);
        this.departmentBarOption.series[1].data = sortedData.map(dept => dept.inactive_count);
        this.departmentBarOption.series[2].data = sortedData.map(dept => dept.on_leave_count);
        
        console.log('Department counts updated:', sortedData);
        
      } catch (error) {
        console.error('Error fetching department data:', error);
        this.errorMessage = 'Failed to load department statistics';
        this.showErrorModal = true;
      } finally {
        this.isLoading = false;
      }
    },
    async fetchAttendanceRates() {
      try {
        const attendanceResponse = await axios.get('/api/attendance/monthly-rates', {
          params: { year: this.selectedYear }
        });

        console.log('Raw attendance data:', attendanceResponse.data);

        if (!attendanceResponse.data || !attendanceResponse.data.actual) {
          console.error('Invalid data structure received:', attendanceResponse.data);
          this.errorMessage = 'Invalid data received from server';
          this.showErrorModal = true;
          return;
        }

        const processedData = {
          actual: {},
          predicted: {}
        };

        // Process the data...
        this.actualData = attendanceResponse.data.actual;
        this.predictedData = attendanceResponse.data.predicted;
        
        if (Object.keys(this.actualData).length > 0) {
        this.updateAttendanceChart();
        } else {
          console.log('No attendance data available');
        }
      } catch (error) {
        console.error('Error fetching attendance rates:', error);
        this.errorMessage = error.response?.data?.message || 'Failed to load attendance data';
        this.showErrorModal = true;
      }
    },
    closeModals() {
      this.showSuccessModal = false;
      this.showErrorModal = false;
      this.isLoading = false;
      this.errorMessage = '';
      this.modalMessage = '';
    },
    updatePayrollCountdown() {
      const daysLeft = this.getDaysUntilNextPayroll();
      if (this.payrollBatteryOption && this.payrollBatteryOption.series) {
        this.payrollBatteryOption.series[0].data = [{
          value: daysLeft,
          name: 'Days Left'
        }];
      }
    },
    getOrdinalSuffix(number) {
      const j = number % 10,
            k = number % 100;
      if (j == 1 && k != 11) return 'st';
      if (j == 2 && k != 12) return 'nd';
      if (j == 3 && k != 13) return 'rd';
      return 'th';
    },
    getPayrollColor(days) {
      if (days <= 2) return '#dc3545'; // Red for urgent
      if (days <= 5) return '#ffc107'; // Yellow for warning
      return '#28a745'; // Green for normal
    },
    togglePrediction() {
      console.log('Toggling prediction, current state:', this.showPredictions); // Debug log
      this.showPredictions = !this.showPredictions;
      console.log('New prediction state:', this.showPredictions); // Debug log
      this.updateAttendanceChart();
    },
    updateAttendanceChart() {
      if (!this.actualData || Object.keys(this.actualData).length === 0) {
        console.log('No data available for chart');
        return;
      }

      const currentMonth = new Date().getMonth();
      
      try {
        const series = Object.entries(this.actualData).map(([department, rates], index) => {
        const colors = this.departmentColors[department] || {
          primary: `hsl(${index * 40}, 70%, 50%)`,
          secondary: `hsl(${index * 40}, 70%, 80%)`
        };

          // Ensure rates is properly formatted as an array
          const actualValues = Array.isArray(rates) ? rates : Object.values(rates);
          
          let seriesData = actualValues.map((value, i) => {
            const baseData = {
              value: parseFloat(value) || 0,
            itemStyle: { color: colors.primary }
            };

            if (this.showPredictions && this.predictedData[department] && i > currentMonth) {
              const predictedValues = Array.isArray(this.predictedData[department]) 
                ? this.predictedData[department] 
                : Object.values(this.predictedData[department]);
              
              baseData.value = parseFloat(predictedValues[i]) || 0;
              baseData.itemStyle.color = colors.secondary;
              baseData.isPredicted = true;
            }

            return baseData;
          });

        return {
          name: department,
          type: 'line',
          smooth: true,
          showSymbol: true,
          symbolSize: 6,
          data: seriesData,
          lineStyle: {
              width: 2,
              color: colors.primary
          },
          emphasis: {
            focus: 'series',
              scale: true,
              itemStyle: {
                borderWidth: 2,
                shadowBlur: 10,
                shadowColor: colors.primary
              }
            }
        };
      });

        // Update the chart options
        this.attendanceLineOption = {
          ...this.attendanceLineOption,
          series: series
        };

        console.log('Updated chart series:', series); // Debug log
      } catch (error) {
        console.error('Error updating attendance chart:', error);
      }
    },
    async fetchInitialData() {
      try {
        await Promise.all([
          this.fetchDepartmentData(),
          this.fetchAttendanceRates()
        ]);
      } catch (error) {
        console.error('Error fetching initial data:', error);
      }
    },
    getDepartmentColor(department, index) {
      const defaultColors = {
        primary: `hsl(${index * 40}, 70%, 50%)`,
        secondary: `hsl(${index * 40}, 70%, 80%)`
      };

      return this.departmentColors[department] || defaultColors;
    },
    async initializeYears() {
      try {
        const response = await axios.get('/api/attendance/available-years');
        this.availableYears = response.data;
        if (!this.availableYears.includes(this.selectedYear)) {
          this.selectedYear = Math.max(...this.availableYears);
        }
      } catch (error) {
        console.error('Error fetching available years:', error);
        // Fallback to recent years if API fails
        const currentYear = new Date().getFullYear();
        this.availableYears = [currentYear - 1, currentYear, currentYear + 1];
      }
    },
    updateChartData() {
      if (!this.chart) return;

      // Update series visibility
      this.chart.series.forEach(series => {
        if (series.name.includes('Predicted')) {
          series.setVisible(this.showPredictions, false);
        }
      });
      
      // Redraw the chart
      this.chart.redraw();
    },
    createChart() {
      // Your existing chart creation code...
      this.chart = Highcharts.chart('attendance-chart', {
        // ... other chart options
        series: this.departments.map(dept => ([
          {
            name: dept,
            data: this.actualData[dept],
            type: 'line',
            zIndex: 2
          },
          {
            name: `Predicted ${dept}`,
            data: this.predictedData[dept],
            dashStyle: 'shortdot',
            visible: this.showPredictions,
            zIndex: 1
          }
        ])).flat()
      });
    },
    async fetchDepartmentSalaries() {
  try {
    console.log('Fetching department salaries...');
    const response = await axios.get('/api/departments/salary-distribution', {
      params: {
        year: this.selectedYearForSalary,
        month: this.selectedMonthForSalary
      }
    });
    console.log('Response:', response.data);
    
    // Format the data for the pie chart
    const chartData = response.data.map((dept, index) => ({
      name: dept.name,
      value: parseFloat(dept.total_salary),
      itemStyle: {
        color: `hsl(${index * 30}, 70%, 50%)`
      }
    }));

    // Update the pie chart
    this.salaryPieOption.series[0].data = chartData;
  } catch (error) {
    console.error('Error fetching department salaries:', error);
  }
},
    formatCurrency(value) {
      return parseFloat(value).toLocaleString('en-PH', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      });
    },
    getDaysUntilNextPayroll() {
      const today = new Date();
      const currentDay = today.getDate();
      const daysInMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate();
      
      // Assuming payroll is on the 15th and last day of month
      if (currentDay < 15) {
        return 15 - currentDay;
      } else if (currentDay < daysInMonth) {
        return daysInMonth - currentDay;
      } else {
        return 15; // Reset to 15 days when it's the last day of month
      }
    },
    async fetchDashboardStats() {
      try {
        const response = await axios.get('/api/dashboard/stats');
        this.totalPositions = response.data.total_positions;
        this.currentMonthAttendance = response.data.current_month_attendance;
        this.totalMonthlySalary = response.data.total_monthly_salary;
        this.totalDepartments = response.data.total_departments;
        this.highestPaidEmployee = response.data.highest_paid_employee;
      } catch (error) {
        console.error('Error fetching dashboard stats:', error);
      }
    },
    getNextPayday() {
      const today = new Date();
      const nextPayday = new Date();
      
      // Assuming paydays are on the 15th and last day of each month
      if (today.getDate() < 15) {
        nextPayday.setDate(15);
      } else if (today.getDate() < this.getLastDayOfMonth(today)) {
        nextPayday.setDate(this.getLastDayOfMonth(today));
      } else {
        nextPayday.setMonth(nextPayday.getMonth() + 1);
        nextPayday.setDate(15);
      }
      
      return nextPayday;
    },
    getLastDayOfMonth(date) {
      return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
    },
    updateCountdown() {
      const now = new Date();
      const nextPayday = this.getNextPayday();
      const diff = nextPayday - now;
      
      const days = Math.floor(diff / (1000 * 60 * 60 * 24));
      const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
      
      this.countdown = { days, hours, minutes };
      
      // Calculate progress
      const totalDays = 15; // Assuming 15 days between payrolls
      this.payrollProgress = Math.max(0, Math.min(100, ((totalDays - days) / totalDays) * 100));
    }
  },
  watch: {
    showPredictions() {
      this.updateAttendanceChart();
    }
  }
}
</script>


  <style scoped>
  .dashboard-container {
    padding: 2rem;
    background: linear-gradient(135deg, #f0f2f5 0%, #e6e8eb 100%);
    min-height: 100vh;
    font-family: 'Inter', sans-serif;
  }

  .dashboard-header {
    background: linear-gradient(135deg, #6b2c91, #4a1f64);
    padding: 2rem;
    border-radius: 15px;
      color: white;
    margin-bottom: 2rem;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  }

  .header-stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 1.5rem;
    margin-top: 1.5rem;
  }

  .stat-card {
    background: rgba(255, 255, 255, 0.1);
    padding: 1rem 1.25rem;
    border-radius: 10px;
    display: flex;
    justify-content: center;
    align-items: flex-start;
    gap: 0.75rem;
    backdrop-filter: blur(5px);
    transition: transform 0.3s ease;
    min-width: 0;
    height: fit-content;
  }

  .stat-card:hover {
    transform: translateY(-3px);
    background: rgba(255, 255, 255, 0.15);
  }

  .stat-card i {
    font-size: 1.5rem;
    opacity: 0.9;
    flex-shrink: 0;
    margin: 0 auto;
    display: block;
  }

  .stat-info {
    flex: 1;
    min-width: 0;
    text-align: center;
  }

  .stat-value {
    font-size: 1.25rem;
    font-weight: bold;
    line-height: 1.2;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    display: block;
    text-align: center;
    width: 100%;
  }

  .stat-label {
    font-size: 0.8rem;
    opacity: 0.9;
    white-space: normal;
    line-height: 1.2;
    display: block;
    text-align: center;
    width: 100%;
  }

  .charts-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 2rem;
    margin-top: 2rem;
  }

  .chart-card {
    background: rgba(255, 255, 255, 0.7);
    backdrop-filter: blur(10px);
    border-radius: 15px;
    padding: 1.5rem;
    box-shadow: 0 4px 20px rgba(107, 44, 145, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.3);
    transition: all 0.3s ease;
  }

  .chart-card:hover {
    background: rgba(255, 255, 255, 0.8);
    box-shadow: 0 6px 24px rgba(107, 44, 145, 0.15);
    transform: translateY(-2px);
  }

  .chart-card.wide {
    grid-column: span 2;
  }

  .chart-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    padding-bottom: 1rem;
    border-bottom: 2px solid rgba(107, 44, 145, 0.1);
  }

  .chart-header h2 {
    color: #2d3748;
    font-weight: 600;
    margin-bottom: 2rem;
    font-size: 1.25rem;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  }

  .chart-controls {
    display: flex;
    gap: 1rem;
    align-items: center;
  }

  .year-select, .month-select {
    padding: 0.5rem 1rem;
    border: 1px solid #ddd;
    border-radius: 8px;
    background-color: #f8fafc;
    color: #333;
    font-size: 0.875rem;
    cursor: pointer;
    transition: all 0.3s ease;
    outline: none;
  }

  .year-select:hover, .month-select:hover {
    border-color: #6b2c91;
    background-color: #fcfaff;
  }

  .chart-container {
    position: relative;
    height: 400px;
    width: 100%;
    background: rgba(255, 255, 255, 0.5);
    border-radius: 10px;
    padding: 1.5rem;
    margin-top: 2rem;
    border: 1px solid rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(5px);
  }

  /* Custom scrollbar */
  ::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }

  ::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
  }

  ::-webkit-scrollbar-thumb {
    background: #6b2c91;
    border-radius: 4px;
  }

  ::-webkit-scrollbar-thumb:hover {
    background: #4a1f64;
  }

  /* Prediction legend styling */
  .prediction-legend {
    margin-top: 1rem;
    padding: 1rem;
    background: rgba(107, 44, 145, 0.05);
    border-radius: 8px;
    display: flex;
    gap: 1.5rem;
    justify-content: center;
    font-size: 0.875rem;
    color: #2d3748;
    font-weight: 500;
  }

  .prediction-dot {
    display: inline-block;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    margin-right: 8px;
    vertical-align: middle;
  }

  .prediction-dot.actual {
    background: linear-gradient(135deg, #6b2c91, #4a1f64);
    box-shadow: 0 2px 4px rgba(107, 44, 145, 0.2);
  }

  .prediction-dot.predicted {
    background: linear-gradient(135deg, #e6ccff, #d4b3ff);
    box-shadow: 0 2px 4px rgba(230, 204, 255, 0.3);
  }

  /* Animation for chart loading */
  @keyframes chartFadeIn {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .chart-container {
    animation: chartFadeIn 0.5s ease-out;
  }

  /* Chart title and text styles */
  .chart-card h2 {
    color: #2d3748;
    font-weight: 600;
    margin-bottom: 2rem;
    font-size: 1.25rem;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  }

  /* Legend text color */
  .chart-container :deep(.echarts-legend-text) {
    color: #2d3748 !important;
  }

  @media (max-width: 1400px) {
    .header-stats {
      grid-template-columns: repeat(3, 1fr);
    }
  }

  @media (max-width: 1024px) {
    .header-stats {
      grid-template-columns: repeat(2, 1fr);
    }
  }

  @media (max-width: 640px) {
    .header-stats {
      grid-template-columns: 1fr;
    }
    
    .stat-card {
      padding: 1rem;
    }
    
    .stat-value {
      font-size: 1.1rem;
    }
  }

  .payroll-countdown {
    padding: 1.5rem;
  }

  .countdown-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1.5rem;
    margin-top: 1rem;
  }

  .countdown-timer {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .time-block {
    display: flex;
    flex-direction: column;
    align-items: center;
    background: linear-gradient(135deg, #6b2c91, #4a1f64);
    padding: 1rem;
    border-radius: 12px;
    min-width: 80px;
  }

  .time-value {
    font-size: 2rem;
    font-weight: bold;
    color: white;
  }

  .time-label {
    font-size: 0.8rem;
    color: rgba(255, 255, 255, 0.8);
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .time-separator {
    font-size: 2rem;
    font-weight: bold;
    color: #6b2c91;
  }

  .next-payroll-date {
    font-size: 1.1rem;
    color: #2d3748;
    font-weight: 500;
  }

  .progress-bar {
    width: 100%;
    height: 8px;
    background: #e2e8f0;
    border-radius: 4px;
    overflow: hidden;
  }

  .progress {
    height: 100%;
    background: linear-gradient(to right, #6b2c91, #9f7aea);
    transition: width 0.3s ease;
  }

  .payroll-status {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.9rem;
    color: #4a5568;
  }

  .payroll-status i {
    font-size: 1.1rem;
  }

  .text-warning {
    color: #eab308;
  }

  .text-info {
    color: #3b82f6;
  }

  .text-success {
    color: #10b981;
  }

  .stat-card.highlight {
    background: rgba(255, 215, 0, 0.15);
    border: 1px solid rgba(255, 215, 0, 0.3);
    padding: 1rem 1.25rem;
    width: auto;
    min-width: 200px;
    text-align: center;
  }

  .stat-card.highlight i {
    color: #ffd700;
    font-size: 1.75rem;
    margin: 0.25rem 0;
  }

  .employee-details {
    margin-bottom: 0.75rem;
    font-size: 0.85rem;
    line-height: 1.2;
    text-align: center;
  }

  .employee-name-large {
    display: block;
    font-weight: 600;
    color: #ffd700;
    font-size: 1.3rem;
    margin-bottom: 0.25rem;
    letter-spacing: 0.5px;
    line-height: 1.3;
    text-align: center;
  }

  .employee-dept {
    display: block;
    opacity: 0.8;
    font-size: 0.9rem;
    color: rgba(255, 255, 255, 0.8);
  }

  .salary-details {
    border-top: 1px solid rgba(255, 215, 0, 0.2);
    padding-top: 0.75rem;
    margin-top: 0.5rem;
    text-align: center;
  }

  .salary-value {
    display: block;
    font-size: 1rem;
    font-weight: 600;
    color: #10b981;  /* Green color */
    margin-bottom: 0.25rem;
  }

  .stat-card.highlight:hover {
    background: rgba(255, 215, 0, 0.2);
    transform: translateY(-3px);
    box-shadow: 0 4px 12px rgba(255, 215, 0, 0.15);
  }

  @media (max-width: 1400px) {
    .stat-card.highlight {
      min-width: 180px;
    }
    
    .employee-name-large {
      font-size: 1.1rem;
    }
    
    .salary-value {
      font-size: 0.95rem;
    }
  }

  /* Specific styling for Monthly Salary Distribution card */
  .stat-card:has(.fa-money-bill-wave) {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 1.5rem 1rem;
  }

  .stat-card:has(.fa-money-bill-wave) .stat-info {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .stat-card:has(.fa-money-bill-wave) .stat-value {
    font-size: 1.4rem;
    line-height: 1.2;
    margin-bottom: 0.25rem;
  }

  .stat-card:has(.fa-money-bill-wave) .stat-label {
    font-size: 0.85rem;
    white-space: normal;
    max-width: 150px;
    margin: 0 auto;
  }

  .stat-card:has(.fa-money-bill-wave) i {
    margin-bottom: 0.75rem;
    font-size: 1.6rem;
  }

  /* Update total employees text */
  .total-employees {
    margin-top: 1rem;
    padding: 0.75rem;
    background: rgba(107, 44, 145, 0.1);
    border-radius: 8px;
    text-align: center;
    color: #4a1f64;
    font-weight: 500;
  }

  /* Add specific spacing for pie chart container */
  .chart-card:has(.salary-distribution) {
    padding-top: 2rem;
  }

  .chart-card:has(.salary-distribution) h2 {
    margin-bottom: 2.5rem;
  }

  /* Specific styling for pie chart */
  .chart-card .salary-distribution {
    height: 500px;  /* Increase height to accommodate legend */
    padding-bottom: 3rem;  /* Add space for legend at bottom */
  }
  </style>