<template>
  <q-card class="my-card">
    <q-card-section>
      <h6>Ventas por Tipo de Paca</h6>
      <Bar v-if="chartData" :chart-data="chartData" :chart-options="chartOptions" />
    </q-card-section>
  </q-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Bar } from 'vue-chartjs'
import { Chart as ChartJS, BarElement, CategoryScale, LinearScale, Tooltip, Legend } from 'chart.js'

ChartJS.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend)

const chartData = ref(null)
const chartOptions = {
  responsive: true,
  plugins: {
    legend: { display: false },
  },
}

onMounted(async () => {
  const res = await fetch('/api/estadisticas/ventas-por-tipo')
  const data = await res.json()
  chartData.value = {
    labels: data.map((e) => e.tipo),
    datasets: [
      {
        label: 'Cantidad',
        data: data.map((e) => Number(e.cantidad)),
        backgroundColor: '#42A5F5',
      },
    ],
  }
})
</script>
