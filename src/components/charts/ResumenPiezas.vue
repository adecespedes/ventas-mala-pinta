<template>
  <q-card class="my-card q-pa-md q-mb-md">
    <div class="text-h6 q-mb-sm">Resumen Piezas</div>
    <div class="row q-col-gutter-md text-center">
      <q-card-section class="col">
        <div class="text-subtitle1">Piezas vendidas</div>
        <div class="text-h4 text-positive">{{ piezas.piezasVendidas }}</div>
      </q-card-section>
      <q-card-section class="col">
        <div class="text-subtitle1">Piezas restantes</div>
        <div class="text-h4 text-negative">{{ piezas.piezasRestantes }}</div>
      </q-card-section>
    </div>
  </q-card>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { api } from 'src/boot/axios'

const loading = ref(false)
const piezas = ref({})

const fetchData = async () => {
  loading.value = true
  try {
    const res = await api.get(`/estadisticas/resumen-piezas`)
    piezas.value = res.data
  } catch (error) {
    console.error('Error cargando ingresos:', error)
  } finally {
    loading.value = false
  }
}

onMounted(fetchData)
watch(() => fetchData)
</script>

<style scoped>
.my-card {
  height: 150px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
</style>
