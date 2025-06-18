<template>
  <q-card class="my-card">
    <q-card-section>
      <h6>Top 10 Productos Más Vendidos</h6>

      <div v-if="loading" class="text-center q-pa-md">
        <q-spinner-dots size="40" />
      </div>

      <div style="height: 320px" v-else-if="chartData">
        <Bar :data="chartData" :options="chartOptions" style="height: 280px" />
      </div>

      <div v-else>No hay datos para mostrar.</div>
    </q-card-section>
  </q-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Bar } from 'vue-chartjs'
import { Chart as ChartJS, BarElement, CategoryScale, LinearScale, Tooltip, Legend } from 'chart.js'
import { api } from 'src/boot/axios'

ChartJS.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend)

const loading = ref(false)
const chartData = ref(null)
const chartOptions = {
  // responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
    tooltip: { enabled: true },
  },
  scales: {
    y: {
      beginAtZero: true,
      ticks: { stepSize: 1 },
    },
  },
}

const colorPalette = [
  '#F44336',
  '#E91E63',
  '#9C27B0',
  '#673AB7',
  '#3F51B5',
  '#2196F3',
  '#03A9F4',
  '#00BCD4',
  '#009688',
  '#4CAF50',
]

onMounted(async () => {
  loading.value = true
  try {
    const res = await api.get('/estadisticas/productos-mas-vendidos')
    const data = res.data

    chartData.value = {
      labels: data.map((e) => e.producto),
      datasets: [
        {
          label: 'Cantidad Vendida',
          data: data.map((e) => Number(e.total)),
          backgroundColor: data.map((_, i) => colorPalette[i % colorPalette.length]),
        },
      ],
    }
  } catch (error) {
    console.error('Error cargando datos:', error)
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.my-card {
  height: 450px; /* Ajusta según prefieras */
}
</style>
