<template>
  <div class="login-container">
    <div class="wave-bg"></div>
    <h1>Payroll Admin</h1>
    
    <div class="login-form">
      <h2>Login</h2>
      <form @submit.prevent="handleLogin">
        <input 
          type="email" 
          v-model="formData.email" 
          placeholder="Email"
          required
          :disabled="loading"
        >
        <input 
          type="password" 
          v-model="formData.password" 
          placeholder="Password"
          required
          :disabled="loading"
        >
        
        <!-- Error message display -->
        <div v-if="error" class="error-message">
          {{ error }}
        </div>

        <button 
          type="submit" 
          class="sign-in"
          :disabled="loading || !isFormValid"
        >
          <span v-if="loading" class="loading-spinner"></span>
          {{ loading ? 'Signing in...' : 'Sign In' }}
        </button>
      </form>
      
      <div class="divider">
        <span>Or</span>
      </div>
      
      <div class="social-login">
        <button 
          class="google" 
          @click="handleGoogleLogin" 
          :disabled="loading"
          title="Sign in with Google"
        >
          <img src="../assets/google-icon.png" alt="Google">
        </button>
        <button 
          class="facebook" 
          @click="handleFacebookLogin" 
          :disabled="loading"
          title="Sign in with Facebook"
        >
          <img src="../assets/facebook-icon.png" alt="Facebook">
        </button>
      </div>
      
      <p class="signup-link">
        Don't have an account?
        <router-link :to="{ path: '/signup' }">Create</router-link>
      </p>
    </div>
  </div>
</template>

<script>
import { authService } from '../services/auth'

export default {
  name: 'LoginPage',
  data() {
    return {
      formData: {
        email: '',
        password: ''
      },
      error: '',
      loading: false
    }
  },
  computed: {
    isFormValid() {
      return this.formData.email && this.formData.password;
    }
  },
  methods: {
    async handleLogin() {
      try {
        this.loading = true
        this.error = null
        const response = await authService.login(this.formData)
        if (response.token) {
          console.log('Login successful, redirecting...')
          await this.$router.push('/dashboard')
        }
      } catch (error) {
        this.error = error.response?.data?.message || 'Login failed'
      } finally {
        this.loading = false
      }
    },

    async handleGoogleLogin() {
      try {
        this.loading = true;
        this.error = '';
        // Implement Google OAuth logic here
        console.log('Google login clicked');
      } catch (error) {
        this.error = 'Google login failed';
        console.error('Google login error:', error);
      } finally {
        this.loading = false;
      }
    },

    async handleFacebookLogin() {
      try {
        this.loading = true;
        this.error = '';
        // Implement Facebook OAuth logic here
        console.log('Facebook login clicked');
      } catch (error) {
        this.error = 'Facebook login failed';
        console.error('Facebook login error:', error);
      } finally {
        this.loading = false;
      }
    }
  },
  // Clear error when component is destroyed
  beforeUnmount() {
    this.error = '';
  }
}
</script>

<style scoped>
.login-container {
  width: 100%;
  position: relative;
  min-height: 100vh;
  margin: 20px auto;
  padding: 20px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  box-shadow: 0 8px 32px rgba(107, 44, 145, 0.15);
  display: flex;
  flex-direction: column;
  align-items: center;
}

.wave-bg {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 200px;
  background: linear-gradient(135deg, #8a37b8, #4a1f64);
  animation: waveAnimation 8s ease-in-out infinite;
  border-radius: 20px 20px 50% 50%;
  box-shadow: 0 4px 15px rgba(107, 44, 145, 0.2);
}

@keyframes waveAnimation {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

h1 {
  color: white;
  position: relative;
  margin: 20px;
  font-size: 2.5rem;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
  letter-spacing: 1px;
}

.login-form {
  padding: 30px;
  margin-top: 60px;
  width: 100%;
  max-width: 400px;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 15px;
  box-shadow: 0 8px 32px rgba(107, 44, 145, 0.1);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

input {
  width: 100%;
  padding: 12px 15px;
  margin: 12px 0;
  border: 2px solid rgba(107, 44, 145, 0.2);
  border-radius: 10px;
  box-sizing: border-box;
  color: #4a1f64;
  background-color: rgba(216, 185, 228, 0.3);
  font-size: 1rem;
  transition: all 0.3s ease;
}

input:focus {
  outline: none;
  border-color: #8a37b8;
  background-color: rgba(216, 185, 228, 0.4);
  box-shadow: 0 0 0 3px rgba(107, 44, 145, 0.1);
  transform: translateY(-1px);
}

input:disabled {
  background-color: #f5f5f5;
  cursor: not-allowed;
}

.sign-in {
  width: 100%;
  padding: 14px;
  background: linear-gradient(135deg, #8a37b8, #4a1f64);
  color: white;
  border: none;
  border-radius: 10px;
  margin: 20px 0;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 1.1rem;
  font-weight: 600;
  letter-spacing: 0.5px;
  text-transform: uppercase;
}

.sign-in:hover:not(:disabled) {
  background: linear-gradient(135deg, #9645c4, #5a2574);
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(107, 44, 145, 0.2);
}

.sign-in:disabled {
  background: #9c9c9c;
  cursor: not-allowed;
}

.loading-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid #ffffff;
  border-top: 2px solid transparent;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-message {
  background-color: rgba(220, 53, 69, 0.1);
  color: #dc3545;
  padding: 10px;
  border-radius: 8px;
  margin: 10px 0;
  text-align: center;
  font-size: 0.9rem;
}

.divider {
  text-align: center;
  margin: 20px 0;
  position: relative;
  color: #6b2c91;
}

.divider::before,
.divider::after {
  content: "";
  position: absolute;
  top: 50%;
  width: 45%;
  height: 1px;
  background: #ddd;
}

.divider::before { left: 0; }
.divider::after { right: 0; }

.social-login {
  display: flex;
  justify-content: center;
  gap: 20px;
}

.social-login button {
  width: 45px;
  height: 45px;
  background: white;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border-radius: 50%;
  border: 1px solid #ddd;
  cursor: pointer;
  padding: 8px;
}

.social-login button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(107, 44, 145, 0.15);
}

.social-login button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.social-login img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.signup-link {
  text-align: center;
  margin-top: 20px;
  color: #6b2c91;
}

.signup-link a {
  color: #6b2c91;
  text-decoration: none;
  font-weight: bold;
  transition: color 0.3s ease;
}

.signup-link a:hover {
  color: #4a1f64;
}

@media (max-width: 768px) {
  .login-container {
    margin: 0;
    border-radius: 0;
  }
  
  .wave-bg {
    border-radius: 0 0 50% 50%;
  }
  
  .login-form {
    padding: 15px;
  }
}
</style>