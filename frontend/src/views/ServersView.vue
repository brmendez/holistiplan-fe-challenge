<script>
import { ref, onMounted, computed } from 'vue';
import { useServersStore } from '../stores/servers';
import EditServerModal from '../components/EditServerModal.vue';
import filterMethods from '../helpers/filterMethods';

import { toast } from 'vue-sonner';

const STATUS_ORDER = { online: 0, maintenance: 1, error: 2, offline: 3 };

export default {
  name: 'ServersView',
  components: {
    EditServerModal
  },
  setup() {
    const serversStore = useServersStore();
    const servers = computed(() => serversStore.serversWithHealth);
    const loading = computed(() => serversStore.isLoading);
    const error = computed(() => serversStore.error);
    const showDeleteModal = ref(false);
    const serverToDelete = ref(null);
    const showEditModal = ref(false);
    const serverToEdit = ref(null);

    // Filter state
    const filterName = ref('');
    const filterIP = ref('');
    const filterStatus = ref('');
    const filterLocation = ref('');

    // Sort state
    const sortField = ref('name');
    const sortDirection = ref('asc');

    const uniqueLocations = computed(() => {
      const locs = new Set(servers.value.map(s => s.location).filter(Boolean));
      return [...locs].sort();
    });

    const isFiltered = computed(() =>
      filterName.value !== '' || filterIP.value !== '' ||
      filterStatus.value !== '' || filterLocation.value !== ''
    );

    const filteredAndSortedServers = computed(() => {
      let result = servers.value;

      const nameTerm = filterName.value.trim().toLowerCase();
      if (nameTerm) result = result.filter(s => s.name.toLowerCase().includes(nameTerm));

      const ipTerm = filterIP.value.trim();
      if (ipTerm) result = result.filter(s => s.ip_address.includes(ipTerm));

      if (filterStatus.value) result = result.filter(s => s.status === filterStatus.value);
      if (filterLocation.value) result = result.filter(s => s.location === filterLocation.value);

      const comparators = {
        name: (a, b) => a.name.localeCompare(b.name),
        status: (a, b) => STATUS_ORDER[a.status] - STATUS_ORDER[b.status],
        location: (a, b) => a.location.localeCompare(b.location),
        uptime: (a, b) => a.uptime - b.uptime,
      };

      const dir = sortDirection.value === 'asc' ? 1 : -1;
      return [...result].sort((a, b) => {
        const compare = comparators[sortField.value];
        return compare ? dir * compare(a, b) : 0;
      });
    });

    const clearFilters = () => {
      filterName.value = '';
      filterIP.value = '';
      filterStatus.value = '';
      filterLocation.value = '';
    };

    const setSort = (field) => {
      if (sortField.value === field) {
        sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc';
      } else {
        sortField.value = field;
        sortDirection.value = 'asc';
      }
    };

    const getStatusColor = (status) => {
      const colors = {
        online: 'text-green-700 bg-green-100 dark:text-green-400 dark:bg-green-900/30',
        offline: 'text-red-700 bg-red-100 dark:text-red-400 dark:bg-red-900/30',
        maintenance: 'text-yellow-700 bg-yellow-100 dark:text-yellow-400 dark:bg-yellow-900/30',
        error: 'text-red-700 bg-red-100 dark:text-red-400 dark:bg-red-900/30'
      };
      return colors[status] || 'text-gray-700 bg-gray-100 dark:text-gray-400 dark:bg-gray-800';
    };

    const confirmDelete = (server) => {
      serverToDelete.value = server;
      showDeleteModal.value = true;
    };

    const deleteServer = async () => {
      if (serverToDelete.value) {
        try {
          await serversStore.deleteServer(serverToDelete.value.id);

          toast.success(`${serverToDelete.value.name} deleted`);

          showDeleteModal.value = false;
          serverToDelete.value = null;
        } catch (error) {
          console.error('Failed to delete server:', error);
          toast.error('Failed to delete server. Please try again.');
        }
      }
    };

    const editServer = (server) => {
      serverToEdit.value = server;
      showEditModal.value = true;
    };

    const handleEditClose = () => {
      showEditModal.value = false;
      serverToEdit.value = null;
    };

    const handleEditSaved = (updatedServer) => {
      // The store will automatically update the servers list
      // but we can add any additional logic here if needed
      console.warn('Server updated:', updatedServer);
    };

    const formatUptime = (seconds) => {
      const days = Math.floor(seconds / 86400);
      const hours = Math.floor((seconds % 86400) / 3600);
      if (days > 0) return `${days}d ${hours}h`;
      if (hours > 0) return `${hours}h`;
      return `${Math.floor(seconds / 60)}m`;
    };

    onMounted(() => {
      serversStore.fetchServers();
    });

    return {
      clearFilters,
      confirmDelete,
      deleteServer,
      editServer,
      error,
      filterIP,
      filterLocation,
      filterName,
      filterStatus,
      filteredAndSortedServers,
      formatUptime,
      getStatusColor,
      handleEditClose,
      handleEditSaved,
      isFiltered,
      loading,
      servers,
      serverToDelete,
      serverToEdit,
      setSort,
      showDeleteModal,
      showEditModal,
      sortDirection,
      sortField,
      uniqueLocations,
      ...filterMethods,
    };
  }
};
</script>

<template>
  <div class="px-6 py-8">
    <div class="mb-8">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-3xl font-bold text-gray-900 dark:text-gray-100">Servers</h1>
          <p class="text-gray-600 dark:text-gray-400">Manage your server infrastructure</p>
        </div>
        <RouterLink
          to="/servers/new"
          class="btn btn-primary"
        >
          Add Server
        </RouterLink>
      </div>
    </div>

    <!-- Error state -->
    <div
      v-if="error"
      class="bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 text-red-700 dark:text-red-400 px-4 py-3 rounded mb-6"
    >
      {{ error }}
    </div>

    <!-- Servers Table -->
    <div class="card overflow-hidden">
      <!-- Filter Bar -->
      <div class="p-4 border-b border-gray-200 dark:border-gray-700">
        <div class="flex flex-col gap-3 sm:flex-row sm:flex-wrap sm:items-end">
          <div class="flex-1 min-w-[180px]">
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Server Name</label>
            <input
              v-model="filterName"
              type="text"
              placeholder="Search by name..."
              class="form-input"
            />
          </div>
          <div class="flex-1 min-w-[140px]">
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">IP Address</label>
            <input
              v-model="filterIP"
              type="text"
              placeholder="e.g. 192.168"
              class="form-input"
            />
          </div>
          <div class="min-w-[140px]">
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Status</label>
            <select
              v-model="filterStatus"
              class="form-input"
            >
              <option value="">All statuses</option>
              <option value="online">Online</option>
              <option value="offline">Offline</option>
              <option value="maintenance">Maintenance</option>
              <option value="error">Error</option>
            </select>
          </div>
          <div class="min-w-[150px]">
            <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Location</label>
            <select
              v-model="filterLocation"
              class="form-input"
            >
              <option value="">All locations</option>
              <option
                v-for="loc in uniqueLocations"
                :key="loc"
                :value="loc"
              >
                {{ loc }}
              </option>
            </select>
          </div>
          <div class="flex items-end">
            <button
              v-if="isFiltered"
              @click="clearFilters"
              class="btn btn-secondary whitespace-nowrap"
            >
              Clear Filters
            </button>
          </div>
        </div>
      </div>

      <!-- Loading state -->
      <div
        v-if="loading"
        class="text-center py-12"
      >
        <p class="text-gray-500 dark:text-gray-400">Loading servers...</p>
      </div>

      <div
        v-else
        class="overflow-x-auto"
      >
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                <button
                  @click="setSort('name')"
                  class="flex items-center gap-1 hover:text-gray-700 dark:hover:text-gray-200 focus:outline-none"
                >
                  Server
                  <span class="text-gray-400 dark:text-gray-500">
                    <template v-if="sortField === 'name'">{{ sortDirection === 'asc' ? '↑' : '↓' }}</template>
                    <template v-else>↕</template>
                  </span>
                </button>
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                <button
                  @click="setSort('status')"
                  class="flex items-center gap-1 hover:text-gray-700 dark:hover:text-gray-200 focus:outline-none"
                >
                  Status
                  <span class="text-gray-400 dark:text-gray-500">
                    <template v-if="sortField === 'status'">{{ sortDirection === 'asc' ? '↑' : '↓' }}</template>
                    <template v-else>↕</template>
                  </span>
                </button>
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                <button
                  @click="setSort('location')"
                  class="flex items-center gap-1 hover:text-gray-700 dark:hover:text-gray-200 focus:outline-none"
                >
                  Location
                  <span class="text-gray-400 dark:text-gray-500">
                    <template v-if="sortField === 'location'">{{ sortDirection === 'asc' ? '↑' : '↓' }}</template>
                    <template v-else>↕</template>
                  </span>
                </button>
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Usage
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Health
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                <button
                  @click="setSort('uptime')"
                  class="flex items-center gap-1 hover:text-gray-700 dark:hover:text-gray-200 focus:outline-none"
                >
                  Uptime
                  <span class="text-gray-400 dark:text-gray-500">
                    <template v-if="sortField === 'uptime'">{{ sortDirection === 'asc' ? '↑' : '↓' }}</template>
                    <template v-else>↕</template>
                  </span>
                </button>
              </th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr
              v-for="server in filteredAndSortedServers"
              :key="server.id"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div>
                  <div class="text-sm font-medium text-gray-900 dark:text-gray-100">{{ server.name }}</div>
                  <div class="text-sm text-gray-500 dark:text-gray-400">{{ server.hostname }}</div>
                  <div class="text-sm text-gray-500 dark:text-gray-400">{{ server.ip_address }}</div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="inline-flex px-2 text-xs font-semibold rounded-full"
                  :class="getStatusColor(server.status)"
                >
                  {{ server.status }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-900 dark:text-gray-100">{{ server.location }}</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">{{ server.os }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-900 dark:text-gray-100">
                  CPU: {{ formatPercent(server.cpu_usage) }}%
                </div>
                <div class="text-sm text-gray-900 dark:text-gray-100">
                  Memory: {{ formatPercent(server.memory_usage) }}%
                </div>
                <div class="text-sm text-gray-900 dark:text-gray-100">
                  Disk: {{ formatPercent(server.disk_usage) }}%
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                {{ server.health_score }}%
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                {{ formatUptime(server.uptime) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <button
                  @click="editServer(server)"
                  class="text-indigo-600 dark:text-indigo-400 hover:text-indigo-900 dark:hover:text-indigo-300 mr-3"
                >
                  Edit
                </button>
                <button
                  @click="confirmDelete(server)"
                  class="text-red-600 dark:text-red-400 hover:text-red-900 dark:hover:text-red-300"
                >
                  Delete
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div
        v-if="!loading && filteredAndSortedServers.length === 0"
        class="text-center py-12"
      >
        <p class="text-gray-500 dark:text-gray-400">
          <template v-if="isFiltered">No servers match the current filters.</template>
          <template v-else>No servers found.</template>
        </p>
        <button
          v-if="isFiltered"
          @click="clearFilters"
          class="btn btn-secondary mt-3"
        >
          Clear Filters
        </button>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div
      v-if="showDeleteModal"
      class="fixed inset-0 bg-gray-600 dark:bg-gray-900 bg-opacity-50 dark:bg-opacity-75 overflow-y-auto h-full w-full z-50"
    >
      <div class="relative top-20 mx-auto p-5 border dark:border-gray-600 w-96 shadow-lg rounded-md bg-white dark:bg-gray-800">
        <div class="mt-3 text-center">
          <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">Delete Server</h3>
          <div class="mt-2 px-7 py-3">
            <p class="text-sm text-gray-500 dark:text-gray-400">
              Are you sure you want to delete <strong class="text-gray-900 dark:text-gray-100">{{ serverToDelete?.name }}</strong>?
              This action cannot be undone.
            </p>
          </div>
          <div class="flex justify-center space-x-4 mt-4">
            <button
              @click="showDeleteModal = false"
              class="btn btn-secondary"
            >
              Cancel
            </button>
            <button
              @click="deleteServer"
              :disabled="loading"
              class="btn btn-danger"
            >
              {{ loading ? 'Deleting...' : 'Delete' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Edit Server Modal -->
    <EditServerModal
      v-if="serverToEdit"
      :server="serverToEdit"
      :is-visible="showEditModal"
      @close="handleEditClose"
      @saved="handleEditSaved"
    />
  </div>
</template>
