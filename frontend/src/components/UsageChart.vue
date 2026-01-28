<script>
import { ref, onMounted, watch } from 'vue';
import { Bar } from 'vue-chartjs';
import filterMethods from '../helpers/filterMethods';
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale
} from 'chart.js';

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale);

export default {
  name: 'UsageChart',
  components: {
    Bar
  },
  props: {
    data: {
      type: Object,
      default: () => ({})
    }
  },
  setup(props) {
    const chartData = ref({
      labels: ['CPU', 'Memory', 'Disk'],
      datasets: [
        {
          label: 'Average Usage (%)',
          data: [0, 0, 0],
          backgroundColor: [
            '#60A5FA', // Muted blue
            '#34D399', // Muted green
            '#FBBF24' // Muted yellow
          ],
          borderColor: [
            '#3B82F6',
            '#10B981',
            '#F59E0B'
          ],
          borderWidth: 1,
          borderRadius: 4
        }
      ]
    });

    const chartOptions = ref({
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              return `${context.parsed.y.toFixed(1)}%`;
            }
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          max: 100,
          ticks: {
            callback: function(value) {
              return value + '%';
            }
          }
        }
      }
    });

    const updateChart = () => {
      if (props.data && typeof props.data === 'object') {
        const newData = [
          filterMethods.formatPercent(props.data.cpu) || 0,
          filterMethods.formatPercent(props.data.memory) || 0,
          filterMethods.formatPercent(props.data.disk) || 0
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
    <Bar
      :data="chartData"
      :options="chartOptions"
    />
  </div>
</template>
