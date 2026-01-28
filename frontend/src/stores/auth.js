import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { authAPI } from '../services/api';

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null);
  const isLoading = ref(false);
  const error = ref(null);

  const isAuthenticated = computed(() => !!user.value);

  const login = async (credentials) => {
    isLoading.value = true;
    error.value = null;
    
    try {
      const response = await authAPI.login(credentials);
      user.value = response.data.user;
      localStorage.setItem('user', JSON.stringify(response.data.user));
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.error || 'Login failed';
      throw err;
    } finally {
      isLoading.value = false;
    }
  };

  const register = async (userData) => {
    isLoading.value = true;
    error.value = null;
    
    try {
      const response = await authAPI.register(userData);
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.error || 'Registration failed';
      throw err;
    } finally {
      isLoading.value = false;
    }
  };

  const logout = async () => {
    isLoading.value = true;
    
    try {
      await authAPI.logout();
    } catch (err) {
      console.error('Logout error:', err);
    } finally {
      user.value = null;
      localStorage.removeItem('user');
      isLoading.value = false;
    }
  };

  const checkAuth = async () => {
    // Check localStorage first
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      try {
        user.value = JSON.parse(storedUser);
        // Verify with backend
        const response = await authAPI.getCurrentUser();
        user.value = response.data.user;
      } catch (err) {
        // If verification fails, clear local storage
        console.error('Auth check failed:', err);
        user.value = null;
        localStorage.removeItem('user');
      }
    }
  };

  const clearError = () => {
    error.value = null;
  };

  return {
    user,
    isLoading,
    error,
    isAuthenticated,
    login,
    register,
    logout,
    checkAuth,
    clearError
  };
});
