import { createRouter, createWebHistory } from 'vue-router'
import login_page from '../components/login_page.vue'
import SignupPage from '../components/sign_up.vue'
import Dashboard from '../components/dashboard.vue'
import EmployeeManagement from '../components/employee_management.vue'
import AttendanceManagement from '../components/attendance_management.vue'
import GeneratePayroll from '../components/generate_payroll.vue'
import MarkAttendanceManually from '../components/mark_attendance_manually.vue'
import ViewPaymentHistory from '../components/view_payment_history.vue'
import SalaryAdjustment from '../components/salary_adjustment.vue'
import DepartmentsList from '../components/DepartmentsList.vue';
import DepartmentForm from '../components/DepartmentForm.vue';

import reports_and_analytics from '../components/reports_and_analytics.vue'
import test from '../components/test.vue'

const routes = [
  {
    path: '/',
    name: 'LoginPage',
    component: login_page
  },
  {
    path: '/login',
    redirect: '/'
  },
  {
    path: '/signup',
    name: 'Signup',
    component: SignupPage, 
    meta: { 
      requiresGuest: true,
      layout: 'no-sidebar'
    }
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard,
    meta: { 
      requiresAuth: true,
      title: 'Dashboard'
    }
  },
  {
    path: '/employees',
    name: 'Employees',
    component: EmployeeManagement,
    meta: { requiresAuth: true }
  },
  {
    path: '/attendance',
    name: 'Attendance',
    component: AttendanceManagement,
    meta: { requiresAuth: true }
  },
  {
    path: '/generate_payroll',
    name: 'GeneratePayroll',
    component: GeneratePayroll
  },
  {
    path: '/mark_attendance_manually',
    name: 'MarkAttendanceManually',
    component: MarkAttendanceManually
  },
  {
    path: '/view_payment_history',
    name: 'ViewPaymentHistory',
    component: ViewPaymentHistory
  },
  {
    path: '/salary_adjustment',
    name: 'SalaryAdjustment',
    component: SalaryAdjustment
  },
  {
    path: '/reports_and_analytics',
    name: 'ReportsAndAnalytics',
    component: reports_and_analytics
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/dashboard'
  },
  {
    path: '/departments',
    name: 'DepartmentsList',
    component: DepartmentsList
  },
  {
    path: '/departments/create',
    name: 'DepartmentCreate',
    component: DepartmentForm
  },
  {
    path: '/departments/:id/edit',
    name: 'DepartmentEdit',
    component: DepartmentForm
  },
  {
    path:'/testing',
    name: 'Testing',
    component: test

  },
  // Add other routes here as needed
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

// Navigation Guards
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  
  if (to.meta.requiresAuth && !token) {
    next({ name: 'LoginPage' })
  } else if ((to.name === 'LoginPage' || to.name === 'Signup') && token) {
    next({ name: 'Dashboard' })
  } else {
    next()
  }
})

// Handle navigation errors
router.onError((error) => {
  console.error('Navigation error:', error)
  router.push('/dashboard')
})

// Add this to handle logout redirects
router.afterEach((to) => {
  if (to.name === 'LoginPage' && !localStorage.getItem('token')) {
    // Clear any remaining session data
    localStorage.clear()
  }
})

export default router