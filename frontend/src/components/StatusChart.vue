<script>
import { ref, onMounted, watch } from 'vue';
import { Doughnut } from 'vue-chartjs';
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  CategoryScale,
  LinearScale
} from 'chart.js';

ChartJS.register(Title, Tooltip, Legend, ArcElement, CategoryScale, LinearScale);

export default {
  name: 'StatusChart',
  components: {
    Doughnut
  },
  props: {
    data: {
      type: Object,
      default: () => ({})
    }
  },
  setup(props) {
    const chartData = ref({
      labels: ['Online', 'Offline', 'Maintenance', 'Error'],
      datasets: [
        {
          data: [0, 0, 0, 0],
          backgroundColor: [
            '#34D399', // Muted green for online
            '#F87171', // Muted red for offline
            '#FBBF24', // Muted yellow for maintenance
            '#EF4444' // Muted red for error
          ],
          borderWidth: 2,
          borderColor: '#ffffff'
        }
      ]
    });

    const chartOptions = ref({
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'bottom',
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              const label = context.label || '';
              const value = context.parsed;
              const total = context.dataset.data.reduce((a, b) => a + b, 0);
              const percentage = total > 0 ? Math.round((value / total) * 100) : 0;
              return `${label}: ${value} (${percentage}%)`;
            }
          }
        }
      }
    });

    const updateChart = () => {
      if (props.data && typeof props.data === 'object') {
        const newData = [
          props.data.online || 0,
          props.data.offline || 0,
          props.data.maintenance || 0,
          props.data.error || 0
        ];
        
        // Create a new chartData object to trigger reactivity
        chartData.value = {
          ...chartData.value,
          datasets: [{
            ...chartData.value.datasets[0],
            data: newData
          }]
        };
      }
    };

    watch(() => props.data, updateChart, { deep: true, immediate: true });

    onMounted(() => {
      updateChart();
    });

    return {
      chartData,
      chartOptions
    };
  }
};
</script>

<template>
  <div class="relative h-64">
    <Doughnut
      :data="chartData"
      :options="chartOptions"
    />
  </div>
</template>
