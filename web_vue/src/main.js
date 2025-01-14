import axios from 'axios'
import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import router from './router'
import html2pdf from 'html2pdf.js'

// ECharts imports
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart, LineChart, BarChart, GaugeChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  GraphicComponent // Add GraphicComponent
} from 'echarts/components'

// Set default axios settings
axios.defaults.withCredentials = true
axios.defaults.baseURL = 'http://localhost:8000'

// Add request interceptor to include token
axios.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// Add response interceptor to handle 401 errors
axios.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      // Redirect to login page
      router.push('/login')
    }
    return Promise.reject(error)
  }
)

// Register ECharts components
use([
  CanvasRenderer,
  PieChart,
  LineChart,
  BarChart,
  GaugeChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  GraphicComponent // Register GraphicComponent
])

const app = createApp(App)

// Enable Vue DevTools
app.config.devtools = true

// Global error handler
app.config.errorHandler = (err, vm, info) => {
  console.error('Global error:', err)
  console.error('Component:', vm)
  console.error('Info:', info)
}

app.component('v-chart', VChart)
app.use(router)
app.mount('#app')

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  
  if (to.matched.some(record => record.meta.requiresAuth) && !token) {
    next({ name: 'LoginPage' })
  } else {
    next()
  }
})
