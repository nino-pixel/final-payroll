<template>
  <div class="app">
    <!-- Only show Sidebar if not on login or signup page -->
    <Sidebar v-if="!isAuthPage" />
    
    <div class="main-content" :class="{ 'with-sidebar': !isAuthPage }">
      <router-view></router-view>
    </div>
  </div>
</template>

<script>
import Sidebar from './components/Sidebar.vue'

export default {
  components: {
    Sidebar
  },
  computed: {
    isAuthPage() {
      return ['LoginPage', 'Signup'].includes(this.$route.name)
    }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  margin: 0;
  padding: 0;
  width: 100vw;
  height: 100vh;
  overflow-x: hidden;
}

.app {
  display: flex;
  min-height: 100vh;
  width: 100%;
}

.main-content {
  flex: 1;
  width: 100%;
  min-height: 100vh;
}

.with-sidebar {
  margin-left: 250px; /* Adjust based on your sidebar width */
  width: calc(100% - 250px);
}

/* Ensure router-view takes full width */
.main-content > * {
  width: 100%;
  min-height: 100vh;
}
</style>
