<template>
  <q-card class="my-card">
    <q-card-section>
      <h6>Ventas Totales ({{ periodo.label }})</h6>
      <div v-if="loading" class="q-pa-md text-center">
        <q-spinner-dots size="40" />
      </div>
      <div style="height: 300px" v-else-if="chartData">
        <Bar :data="chartData" :options="chartOptions" />
      </div>

      <div v-else>No hay datos.</div>
    </q-card-section>
  </q-card>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { Bar } from 'vue-chartjs'
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
} from 'chart.js'
import { api } from 'boot/axios'

ChartJS.register(Title, Tooltip, Legend, LineElement, CategoryScale, LinearScale, PointElement)

const props = defineProps({
  periodo: { type: String, default: 'dia' },
})

const loading = ref(false)
const chartData = ref(null)
const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  scales: {
    y: {
      type: 'linear',
      position: 'left',
      beginAtZero: true,
      title: { display: true, text: 'Ingresos ($)' },
    },
    y1: {
      type: 'linear',
      position: 'right',
      beginAtZero: true,
      grid: { drawOnChartArea: false },
      title: { display: true, text: 'Piezas Vendidas' },
    },
  },
  plugins: {
    legend: { display: true },
    tooltip: {
      callbacks: {
        title: (tooltipItems) => {
          const item = tooltipItems[0]
          const dataIndex = item.dataIndex
          // const dataset = item.chart.data.datasets[0]
          const dataItem = chartData.value.customData[dataIndex] // Asumiendo que guardás los datos raw aquí

          if (dataItem.semana_inicio && dataItem.semana_fin) {
            const inicio = new Date(dataItem.semana_inicio)
            const fin = new Date(dataItem.semana_fin)

            const options = { day: '2-digit', month: 'short' }
            return `${inicio.toLocaleDateString('es-ES', options)} - ${fin.toLocaleDateString(
              'es-ES',
              options
            )}`
          }
          return tooltipItems[0].label
        },
        label: (tooltipItem) => {
          return [
            `Total: ${tooltipItem.parsed.y}`,
            // `Piezas: ${tooltipItem.chart.data.datasets[1].data[tooltipItem.dataIndex]}`,
          ]
        },
      },
    },
  },
}

// const formatCurrency = (value) =>
//   new Intl.NumberFormat('es-CO', {
//     style: 'currency',
//     currency: 'COP',
//     minimumFractionDigits: 0,
//   }).format(value)

const generarLabels = (data, tipoPeriodo) => {
  switch (tipoPeriodo) {
    case 'dia':
      return data.map((e) =>
        new Date(e.periodo).toLocaleDateString('es-ES', {
          day: '2-digit',
          month: 'short',
        })
      )
    case 'semana':
      return data.map((_, i) => `Semana ${i + 1}`)
    case 'mes':
      return data.map((e) => e.periodo.trim()) // ya viene como 'Enero', 'Febrero', etc.
    case 'anio':
      return data.map((e) => e.periodo)
    default:
      return data.map((e) => e.periodo)
  }
}

const fetchData = async () => {
  loading.value = true
  try {
    const res = await api.get(`/estadisticas/ventas-totales?periodo=${props.periodo.value}`)
    const data = res.data

    const labels = generarLabels(data, props.periodo.value)

    chartData.value = {
      labels: labels,
      datasets: [
        {
          label: 'Ingresos ($)',
          data: data.map((e) => Number(e.total)),
          backgroundColor: '#42A5F5',
          yAxisID: 'y',
        },
        {
          label: 'Piezas Vendidas',
          data: data.map((e) => Number(e.piezas)),
          backgroundColor: '#66BB6A',
          yAxisID: 'y1',
        },
      ],
      customData: res.data,
    }
  } finally {
    loading.value = false
  }
}

onMounted(fetchData)
watch(() => props.periodo, fetchData)
</script>

<style scoped>
.my-card {
  margin-bottom: 20px;
  height: 470px;
}
</style>
