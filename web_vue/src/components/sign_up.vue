<template>
  <div class="signup-container">
    <div class="wave-bg"></div>
    <h1>PayrollEmp</h1>
    
    <div class="signup-form">
      <h2>Register</h2>
      <form @submit.prevent="handleSignup">
        <input 
          type="text" 
          v-model="userData.name" 
          placeholder="Full Name"
          required
          :disabled="loading"
        >
        <input 
          type="email" 
          v-model="userData.email" 
          placeholder="Email"
          required
          :disabled="loading"
        >
        <input 
          type="password" 
          v-model="userData.password" 
          placeholder="Password"
          required
          :disabled="loading"
        >
        <input 
          type="password" 
          v-model="userData.password_confirmation" 
          placeholder="Confirm Password"
          required
          :disabled="loading"
        >

        <!-- Error message display -->
        <div v-if="error" class="error-message">
          {{ error }}
        </div>

        <button 
          type="submit" 
          class="sign-up"
          :disabled="loading || !isFormValid"
        >
          {{ loading ? 'Creating Account...' : 'Sign Up' }}
        </button>
      </form>
      
      <div class="divider">
        <span>Or</span>
      </div>
      
      <div class="social-signup">
        <button class="google" @click="handleGoogleSignup" :disabled="loading">
          <img src="../assets/google-icon.png" alt="Google">
        </button>
        <button class="facebook" @click="handleFacebookSignup" :disabled="loading">
          <img src="../assets/facebook-icon.png" alt="Facebook">
        </button>
      </div>
      
      <p class="signup-link">
        Already have an account? 
        <router-link :to="{path: '/'}">Login</router-link>
      </p>
    </div>
  </div>
</template>

<script>
import { authService } from '../services/auth'
import axios from 'axios'

export default {
  name: 'SignupPage',
  data() {
    return {
      userData: {
        name: '',
        email: '',
        password: '',
        password_confirmation: ''
      },
      error: null,
      loading: false
    }
  },
  computed: {
    isFormValid() {
      return (
        this.userData.name &&
        this.userData.email &&
        this.userData.password &&
        this.userData.password_confirmation
      )
    }
  },
  methods: {
    async handleSignup() {
      try {
        this.error = '';
        this.loading = true;

        if (this.userData.password !== this.userData.password_confirmation) {
          this.error = 'Passwords do not match';
          return;
        }

        const response = await axios.post('/api/auth/register', {
          name: this.userData.name,
          email: this.userData.email,
          password: this.userData.password,
          password_confirmation: this.userData.password_confirmation
        });

        console.log('Registration successful:', response.data);
        
        // Store the token
        localStorage.setItem('token', response.data.token);
        
        // Redirect to dashboard
        this.$router.push('/dashboard');

      } catch (error) {
        console.error('Registration error:', error.response?.data);
        
        if (error.response?.status === 422) {
          // Handle validation errors
          const errors = error.response.data.errors;
          this.error = Object.values(errors)[0][0] || 'Validation failed';
        } else {
          this.error = error.response?.data?.message || 'Registration failed';
        }
      } finally {
        this.loading = false;
      }
    },

    async handleGoogleSignup() {
      try {
        this.loading = true
        this.error = ''
        console.log('Google signup clicked')
      } catch (error) {
        this.error = 'Google signup failed'
        console.error('Google signup error:', error)
      } finally {
        this.loading = false
      }
    },

    async handleFacebookSignup() {
      try {
        this.loading = true
        this.error = ''
        console.log('Facebook signup clicked')
      } catch (error) {
        this.error = 'Facebook signup failed'
        console.error('Facebook signup error:', error)
      } finally {
        this.loading = false
      }
    }
  }
}

</script>

<!-- Add this new style for error message -->
<style scoped>
.error-message {
  background-color: rgba(220, 53, 69, 0.1);
  color: #dc3545;
  padding: 10px;
  border-radius: 8px;
  margin: 10px 0;
  text-align: center;
  font-size: 0.9rem;
}


h2{
  color: #4a1f64;
  font-size: 1.8rem;
  text-align: center;
  margin-bottom: 25px;
  font-weight: 600;
}
/* Your existing CSS remains the same */
body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #f5f5f5;
    overflow: hidden;
}

.signup-container {
  width: 100%;
    position: relative;
    min-height: 100vh;  /* Changed from max-width to min-height */
    margin: 20px auto;
    padding: 20px;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(107, 44, 145, 0.15);
    display: flex;      /* Added for better centering */
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
}

.signup-form {
    padding: 30px;
    margin-top: 60px;
    background: rgba(255, 255, 255, 0.9);
    border-radius: 15px;
    box-shadow: 0 8px 32px rgba(107, 44, 145, 0.1);
    backdrop-filter: blur(8px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    width: 100%;
    max-width: 400px;
}

input {
    width: 100%;
    padding: 12px;
    margin: 10px 0;
    border: 1px solid #ddd;
    border-radius: 8px;
    box-sizing: border-box;
    color: rgb(165, 9, 185);
    background-color: rgb(216, 185, 228);
}

.sign-up {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, #8a37b8, #4a1f64);
    color: white;
    border: none;
    border-radius: 10px;
    margin: 20px 0;
    cursor: pointer;
    font-size: 1.1rem;
    font-weight: 600;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    transition: all 0.3s ease;
}

.sign-up:hover:not(:disabled) {
    background: linear-gradient(135deg, #9645c4, #5a2574);
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(107, 44, 145, 0.2);
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
    
    color: #6b2c91;
}

.divider::before { left: 0; }
.divider::after { right: 0; }

.social-signup {
    display: flex;
    justify-content: center;
    gap: 20px;
}

.social-signup button {
    width: 45px;
    height: 45px;
    border-radius: 50%;
    border: 1px solid #ddd;
    background: white;
    cursor: pointer;
    padding: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.social-signup button:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(107, 44, 145, 0.15);
}

.social-signup img {
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
}

/* Add smooth transitions for interactive elements */
.signup-form input,
.signup-form button,
.social-signup button {
    transition: all 0.3s ease;
}
</style> 