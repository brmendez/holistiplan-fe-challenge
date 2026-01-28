<script>
import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { useRouter } from 'vue-router';

export default {
  name: 'RegisterView',
  setup() {
    const authStore = useAuthStore();
    const router = useRouter();

    const form = ref({
      username: '',
      email: '',
      password: '',
      confirmPassword: ''
    });

    const register = async () => {
      if (form.value.password !== form.value.confirmPassword) {
        authStore.error = 'Passwords do not match';
        return;
      }

      try {
        await authStore.register({
          username: form.value.username,
          email: form.value.email,
          password: form.value.password
        });
        router.push('/login');
      } catch (error) {
        console.error('Registration failed:', error);
        // Error is handled in the store
      }
    };

    return {
      authStore,
      form,
      register
    };
  }
};
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900 dark:text-gray-100">
          Create your account
        </h2>
        <p class="mt-2 text-center text-sm text-gray-600 dark:text-gray-400">
          Or
          <RouterLink 
            to="/login" 
            class="font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-500 dark:hover:text-indigo-300"
          >
            sign in to your existing account
          </RouterLink>
        </p>
      </div>
      
      <form
        @submit.prevent="register"
        class="mt-8 space-y-6"
      >
        <div class="space-y-4">
          <div>
            <label
              for="username"
              class="block text-sm font-medium text-gray-700 dark:text-gray-300"
            >Username</label>
            <input
              v-model="form.username"
              id="username"
              name="username"
              type="text"
              required
              class="form-input"
              placeholder="Username"
            />
          </div>
          
          <div>
            <label
              for="email"
              class="block text-sm font-medium text-gray-700 dark:text-gray-300"
            >Email</label>
            <input
              v-model="form.email"
              id="email"
              name="email"
              type="email"
              required
              class="form-input"
              placeholder="Email address"
            />
          </div>
          
          <div>
            <label
              for="password"
              class="block text-sm font-medium text-gray-700 dark:text-gray-300"
            >Password</label>
            <input
              v-model="form.password"
              id="password"
              name="password"
              type="password"
              required
              class="form-input"
              placeholder="Password"
            />
          </div>
          
          <div>
            <label
              for="confirmPassword"
              class="block text-sm font-medium text-gray-700 dark:text-gray-300"
            >Confirm Password</label>
            <input
              v-model="form.confirmPassword"
              id="confirmPassword"
              name="confirmPassword"
              type="password"
              required
              class="form-input"
              placeholder="Confirm Password"
            />
          </div>
        </div>

        <div
          v-if="authStore.error"
          class="text-red-600 dark:text-red-400 text-sm text-center"
        >
          {{ authStore.error }}
        </div>

        <div>
          <button
            type="submit"
            :disabled="authStore.isLoading"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 dark:focus:ring-offset-gray-900 focus:ring-indigo-500 disabled:opacity-50"
          >
            {{ authStore.isLoading ? 'Creating account...' : 'Create account' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>
