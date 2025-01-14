<template>
  <div
    class="sidebar"
    :class="{ collapsed: isCollapsed }"
    :style="{ left: isSidebarVisible ? '0' : '-250px' }"
  >
    <div class="sidebar-header">
      <img src="../assets/payroll_logo.png" alt="PayrollEmp" class="logo" />
    </div>

    <nav class="sidebar-nav">
      <router-link to="/dashboard" class="nav-item">
        <i class="fas fa-chart-line"></i>
        <span v-if="!isCollapsed">Dashboard</span>
      </router-link>

      <div class="nav-group">
        <div class="nav-group-title" v-if="!isCollapsed">Employee Management</div>
        <router-link to="/employees" class="nav-item">
          <i class="fas fa-users"></i>
          <span v-if="!isCollapsed">Employees</span>
        </router-link>
        <router-link to="/salary_adjustment" class="nav-item">
          <i class="fas fa-money-bill-wave"></i>
          <span v-if="!isCollapsed">Salary Adjustment</span>
        </router-link>
      </div>

      <div class="nav-group">
        <div class="nav-group-title" v-if="!isCollapsed">Attendance</div>
        <router-link to="/attendance" class="nav-item">
          <i class="fas fa-calendar-check"></i>
          <span v-if="!isCollapsed">Attendance Management</span>
        </router-link>
        <router-link to="/mark_attendance_manually" class="nav-item">
          <i class="fas fa-clock"></i>
          <span v-if="!isCollapsed">Mark Attendance</span>
        </router-link>
      </div>

      <div class="nav-group">
        <div class="nav-group-title" v-if="!isCollapsed">Payroll</div>
        <router-link to="/generate_payroll" class="nav-item">
          <i class="fas fa-file-invoice-dollar"></i>
          <span v-if="!isCollapsed">Generate Payroll</span>
        </router-link>
        <router-link to="/view_payment_history" class="nav-item">
          <i class="fas fa-history"></i>
          <span v-if="!isCollapsed">Payment History</span>
        </router-link>
      </div>

      <router-link to="/reports_and_analytics" class="nav-item">
        <i class="fas fa-chart-bar"></i>
        <span v-if="!isCollapsed">Reports & Analytics</span>
      </router-link>
    </nav>

    <div class="sidebar-footer">
      <div class="minimize-btn-container">
        <!-- <button class="collapse-btn" @click="toggleSidebar">
          <i :class="isCollapsed ? 'fas fa-chevron-right' : 'fas fa-chevron-left'"></i>
        </button> -->
      </div>

      <div class="logout-container">
        <button class="logout-btn" @click="confirmLogout">
          <i class="fas fa-sign-out-alt"></i>
          <span v-if="!isCollapsed">Logout</span>
        </button>
      </div>
    </div>

    <!-- Add the confirmation modal -->
    <div v-if="showLogoutConfirm" class="modal-overlay">
      <div class="modal-content">
        <h3>Confirm Logout</h3>
        <p>Are you sure you want to log out?</p>
        <div class="modal-buttons">
          <button class="cancel-btn" @click="showLogoutConfirm = false">Cancel</button>
          <button class="confirm-btn" @click="handleLogout">Logout</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { authService } from '../services/auth'

export default {
  name: "Sidebar",
  data() {
    return {
      isCollapsed: false,
      isSidebarVisible: true,
      showLogoutConfirm: false
    };
  },
  watch: {
    $route(to) {
      const noSidebarRoutes = ["/login", "/signup"];
      this.isSidebarVisible = !noSidebarRoutes.includes(to.path);
    },
  },
  methods: {
    toggleSidebar() {
      this.isCollapsed = !this.isCollapsed;
    },
    confirmLogout() {
      this.showLogoutConfirm = true
    },
    async handleLogout() {
      try {
        await authService.logout()
        localStorage.removeItem('token')
        this.$router.push('/')
      } catch (error) {
        console.error('Logout failed:', error)
        localStorage.removeItem('token')
        this.$router.push('/')
      }
      this.showLogoutConfirm = false
    }
  },
  mounted() {
    const noSidebarRoutes = ["/login", "/signup"];
    this.isSidebarVisible = !noSidebarRoutes.includes(this.$route.path);
  },
};
</script>

<style scoped>
.sidebar {
  width: 250px;
  height: 100vh;
  background: linear-gradient(165deg, #6b2c91 0%, #4a1f64 100%);
  color: white;
  position: fixed;
  top: 0;
  transition: width 0.3s ease, left 0.3s ease;
  z-index: 100;
  display: flex;
  flex-direction: column;
  box-shadow: 4px 0 15px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.sidebar.collapsed {
  width: 60px; /* Minimized width */
}

.sidebar-header {
  padding: 1.25rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.15);
  min-height: 50px;
  background: rgba(255, 255, 255, 0.05);
}
.content {
  flex: 1;
  margin-left: 250px;
  padding: 1rem;
  transition: margin-left 0.3s ease;
}.content.expanded {
  margin-left: 60px;
}
.logo {
  height: 45px;
  width: 45px;
  border-radius: 360%;
  box-shadow: 0 0 15px rgba(255, 255, 255, 0.2);
  transition: transform 0.3s ease;
}

.logo:hover {
  transform: scale(1.05);
}

.sidebar-nav {
  padding: 1rem 0;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 0.75rem 1.5rem;
  color: white;
  text-decoration: none;
  transition: all 0.3s ease;
  gap: 0.75rem;
  font-size: 0.85rem;
  position: relative;
  overflow: hidden;
}
.nav-item:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateX(5px);
}
.nav-item.router-link-active {
  background: rgba(255, 255, 255, 0.15);
  font-weight: 600;
}
.nav-item.router-link-active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  height: 100%;
  width: 3px;
  background: #fff;
}
.nav-item i {
  width: 20px;
  text-align: center;
  font-size: 0.9rem;
  opacity: 0.9;
  transition: transform 0.3s ease;
}
.nav-item:hover i {
  transform: scale(1.1);
}

.sidebar-footer {
  border-top: 1px solid rgba(255, 255, 255, 0.15);
  margin-top: auto;
  padding: 1rem;
  background: rgba(0, 0, 0, 0.1);
}

.minimize-btn-container {
  height: 32px;
  padding: 0.3rem;
  display: flex;
  justify-content: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}
.collapse-btn {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  width: 100%;
  height: 32px;
  transition: all 0.3s ease;
}
.layout {
  display: flex;
  width: 100%;
  height: 100vh;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(5px);
}

.modal-content {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  width: 300px;
  text-align: center;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  transform: scale(0.9);
  animation: modalPop 0.3s ease forwards;
}

@keyframes modalPop {
  to {
    transform: scale(1);
  }
}

.modal-content h3 {
  color: #4a1f64;
  margin-bottom: 15px;
  font-size: 1.25rem;
}

.modal-content p {
  color: #333;
  margin-bottom: 20px;
  font-size: 0.95rem;
}

.modal-buttons {
  display: flex;
  justify-content: center;
  gap: 10px;
}

.cancel-btn, .confirm-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}

.cancel-btn {
  background: #f0f2f5;
  color: #333;
}

.confirm-btn {
  background: #6b2c91;
  color: white;
}

.cancel-btn:hover {
  background: #e5e7eb;
  transform: translateY(-2px);
}

.confirm-btn:hover {
  background: #4a1f64;
  transform: translateY(-2px);
}

/* Collapsed state improvements */
.sidebar.collapsed .nav-item {
  justify-content: center;
  padding: 0.75rem 0;
}

.sidebar.collapsed .nav-item i {
  margin: 0;
  font-size: 1.1rem;
}

.sidebar.collapsed .logo {
  transform: scale(0.9);
}

</style>
