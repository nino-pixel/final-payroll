import axios from 'axios';

// Configure axios defaults
axios.defaults.baseURL = 'http://localhost:8000';
axios.defaults.headers.common['Accept'] = 'application/json';
axios.defaults.withCredentials = true;

// Add a request interceptor to include the authentication token
axios.interceptors.request.use(config => {
  const token = localStorage.getItem('auth_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
}, error => {
  return Promise.reject(error);
});

// Add a response interceptor to handle authentication errors
axios.interceptors.response.use(response => {
  return response;
}, error => {
  if (error.response.status === 401) {
    // Handle unauthorized access
    // Optionally, redirect to login page
  }
  return Promise.reject(error);
});

export const authService = {
  async register(userData) {
    try {
      // Validate name
      const nameRegex = /^[a-zA-Z\s'-]+$/;
      if (!nameRegex.test(userData.name)) {
        throw new Error('Name can only contain letters, spaces, hyphens, and apostrophes');
      }
      if (userData.name.length < 2) {
        throw new Error('Name must be at least 2 characters long');
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(userData.email)) {
        throw new Error('Please enter a valid email address');
      }

      // Validate password strength
      const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/;
      if (!passwordRegex.test(userData.password)) {
        throw new Error('Password must be at least 8 characters long and contain letters, numbers, and special characters');
      }

      // Check password confirmation
      if (userData.password !== userData.password_confirmation) {
        throw new Error('Passwords do not match');
      }

      const response = await axios.post('/api/auth/register', userData);

      if (response.data.status === 'success') {
        localStorage.setItem('token', response.data.data.token);
        localStorage.setItem('user', JSON.stringify(response.data.data.user));
        axios.defaults.headers.common['Authorization'] = `Bearer ${response.data.data.token}`;
        return {
          success: true,
          data: response.data.data
        };
      }

      return {
        success: false,
        error: response.data.message
      };
    } catch (error) {
      // Handle server-side errors
      if (error.response?.status === 422) {
        const errors = error.response.data.errors;

        // Check for email already exists
        if (errors?.email?.[0]?.includes('already been taken')) {
          throw new Error('Email address is already registered');
        }

        // Check for other validation errors
        const firstError = Object.values(errors)[0]?.[0];
        if (firstError) {
          throw new Error(firstError);
        }
      }

      // If it's one of our custom validation errors, throw it directly
      if (error.message.includes('Password') || 
          error.message.includes('Name') || 
          error.message.includes('email')) {
        throw error;
      }

      console.error('Registration error:', error);
      throw new Error(error.response?.data?.message || 'Registration failed');
    }
  },

  async login(credentials) {
    try {
      const response = await axios.post('/api/auth/login', credentials);
      if (response.data.token) {
        localStorage.setItem('token', response.data.token);
        axios.defaults.headers.common['Authorization'] = `Bearer ${response.data.token}`;
      }
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  async logout() {
    try {
      await axios.post('http://localhost:8000/api/auth/logout', {}, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      })
      localStorage.removeItem('token')
      delete axios.defaults.headers.common['Authorization']
    } catch (error) {
      console.error('Logout error:', error)
      localStorage.removeItem('token')
      delete axios.defaults.headers.common['Authorization']
    }
  }
};