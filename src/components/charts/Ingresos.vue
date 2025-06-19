<template>
  <q-card class="my-card bg-primary text-white">
    <q-card-section>
      <div class="text-h6 text-center">Ingresos ({{ periodoLabel }})</div>

      <div v-if="loading" class="q-mt-md text-center">
        <q-spinner-dots size="40" />
      </div>

      <div v-else class="text-h4 q-mt-md text-center">
        {{ formatCurrency(ingresos) }}
      </div>
    </q-card-section>
  </q-card>
</template>

<script setup>
defineOptions({ name: 'IngresosCard' })
import { ref, onMounted, watch, computed } from 'vue'
import { api } from 'src/boot/axios'

const props = defineProps({
  periodo: { type: String, default: 'dia' }, // 'dia' | 'semana' | 'mes'
})

const loading = ref(false)
const ingresos = ref(0)

const periodoLabel = computed(() => {
  switch (props.periodo.value) {
    case 'semana':
      return 'última semana'
    case 'mes':
      return 'último mes'
    case 'anio':
      return 'último año'
    default:
      return 'hoy'
  }
})

const fetchData = async () => {
  loading.value = true
  try {
    const res = await api.get(`/estadisticas/ingresos?periodo=${props.periodo.value}`)
    ingresos.value = res.data.local ?? 0
  } catch (error) {
    console.error('Error cargando ingresos:', error)
  } finally {
    loading.value = false
  }
}

onMounted(fetchData)
watch(() => props.periodo, fetchData)

const formatCurrency = (value) =>
  new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    minimumFractionDigits: 0,
  }).format(value)
</script>

<style scoped>
.my-card {
  height: 150px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
</style>
