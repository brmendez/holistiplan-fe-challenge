<script>
import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { useRouter } from 'vue-router';

export default {
  name: 'LoginView',
  setup() {
    const authStore = useAuthStore();
    const router = useRouter();

    const form = ref({
      username: '',
      password: ''
    });

    const login = async () => {
      try {
        await authStore.login(form.value);
        router.push('/');
      } catch (error) {
        console.error('Login failed:', error);
        // Error is handled in the store
      }
    };

    return {
      authStore,
      form,
      login
    };
  }
};
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900 dark:text-gray-100">
          Sign in to your account
        </h2>
        <p class="mt-2 text-center text-sm text-gray-600 dark:text-gray-400">
          Or
          <RouterLink 
            to="/register" 
            class="font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-500 dark:hover:text-indigo-300"
          >
            register a new account
          </RouterLink>
        </p>
      </div>
      
      <form
        @submit.prevent="login"
        class="mt-8 space-y-6"
      >
        <div class="rounded-md shadow-sm -space-y-px">
          <div>
            <label
              for="username"
              class="sr-only"
            >Username</label>
            <input
              v-model="form.username"
              id="username"
              name="username"
              type="text"
              required
              class="relative block w-full appearance-none rounded-none rounded-t-md border border-gray-300 dark:border-gray-600 placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-gray-100 bg-white dark:bg-gray-700 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm px-3 py-2"
              placeholder="Username"
            />
          </div>
          <div>
            <label
              for="password"
              class="sr-only"
            >Password</label>
            <input
              v-model="form.password"
              id="password"
              name="password"
              type="password"
              required
              class="relative block w-full appearance-none rounded-none rounded-b-md border border-gray-300 dark:border-gray-600 placeholder-gray-500 dark:placeholder-gray-400 text-gray-900 dark:text-gray-100 bg-white dark:bg-gray-700 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm px-3 py-2"
              placeholder="Password"
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
            {{ authStore.isLoading ? 'Signing in...' : 'Sign in' }}
          </button>
        </div>

        <div class="text-center">
          <p class="text-sm text-gray-600 dark:text-gray-400">
            Demo accounts: <strong class="text-gray-900 dark:text-gray-100">admin/admin123</strong> or <strong class="text-gray-900 dark:text-gray-100">demo/demo123</strong>
          </p>
        </div>
      </form>
    </div>
  </div>
</template>
