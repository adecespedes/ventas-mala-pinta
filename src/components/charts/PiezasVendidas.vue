<template>
  <q-card class="my-card">
    <q-card-section>
      <h6>Piezas Vendidas ({{ periodo.label }})</h6>
      <div v-if="loading" class="q-pa-md text-center">
        <q-spinner-dots size="40" />
      </div>
      <div style="height: 320px" v-else-if="chartData">
        <Line :data="chartData" :options="chartOptions" style="height: 280px" />
      </div>

      <div v-else>No hay datos.</div>
    </q-card-section>
  </q-card>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { Line } from 'vue-chartjs'
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
}

const fetchData = async () => {
  loading.value = true
  try {
    const res = await api.get(`/estadisticas/piezas-vendidas?periodo=${props.periodo.value}`)
    const data = res.data

    // data is a number, show in a simple bar chart
    chartData.value = {
      labels: [props.periodo.label],
      datasets: [
        {
          label: 'Total Piezas Vendidas',
          backgroundColor: 'rgba(255,159,64,0.6)',
          borderColor: 'rgba(255,159,64,1)',
          data: [data],
        },
      ],
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
  height: 480px;
}
</style>
