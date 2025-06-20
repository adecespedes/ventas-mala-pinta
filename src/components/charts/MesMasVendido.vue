<template>
  <q-card class="my-card q-pa-md bg-indigo-1 text-indigo-10">
    <q-card-section class="q-gutter-sm row items-center justify-between">
      <div class="row items-center">
        <q-avatar color="indigo-5" text-color="white" icon="event" />
        <div class="q-ml-sm">
          <div class="text-caption">Mes más vendido</div>
          <div class="text-h6">{{ mesFormateado }}</div>
        </div>
      </div>
      <div class="text-right">
        <div class="text-h5 text-weight-bold">🧺 {{ mesMasVendido?.totalPiezas }} piezas</div>
        <div class="text-h5 text-weight-bold">
          💵 {{ formatCurrency(mesMasVendido?.totalPrecio) }}
        </div>
      </div>
    </q-card-section>

    <q-inner-loading :showing="loading" />
  </q-card>
</template>




<script setup>
import { ref, computed, onMounted } from 'vue'
import { api } from 'src/boot/axios'

const mesMasVendido = ref(null)
const loading = ref(false)

const fetchMesMasVendido = async () => {
  loading.value = true
  try {
    const res = await api.get('/estadisticas/mes-mas-vendido')
    mesMasVendido.value = res.data
  } catch (err) {
    console.error('Error al cargar mes más vendido:', err)
  } finally {
    loading.value = false
  }
}

const formatCurrency = (value) =>
  new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    minimumFractionDigits: 0,
  }).format(value)

onMounted(fetchMesMasVendido)

const mesFormateado = computed(() => {
  if (!mesMasVendido.value?.mes) return ''
  const [year, month] = mesMasVendido.value.mes.split('-')
  const meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ]
  return `${meses[parseInt(month) - 1]} ${year}`
})
</script>
<style scoped>
.my-card {
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  min-height: 120px;
}
</style>


