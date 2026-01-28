import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '../stores/auth';

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'Dashboard',
      component: () => import('../views/DashboardView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/servers',
      name: 'Servers',
      component: () => import('../views/ServersView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/servers/new',
      name: 'NewServer',
      component: () => import('../views/ServerFormView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/users',
      name: 'Users',
      component: () => import('../views/UsersView.vue'),
      meta: { requiresAuth: true, requiresAdmin: true }
    },
    {
      path: '/account',
      name: 'MyAccount',
      component: () => import('../views/MyAccountView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/login',
      name: 'Login',
      component: () => import('../views/LoginView.vue'),
      meta: { requiresGuest: true }
    },
    {
      path: '/register',
      name: 'Register', 
      component: () => import('../views/RegisterView.vue'),
      meta: { requiresGuest: true }
    }
  ],
});

// Navigation guards
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore();
  
  // Check authentication status
  await authStore.checkAuth();
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login');
  } else if (to.meta.requiresGuest && authStore.isAuthenticated) {
    next('/');
  } else if (to.meta.requiresAdmin && (!authStore.user || !authStore.user.is_admin)) {
    next('/');
  } else {
    next();
  }
});

export default router;
