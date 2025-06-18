<template>
  <q-page class="q-pa-md">
    <!-- FILTRO GLOBAL -->
    <div class="row justify-end q-mb-md">
      <q-select
        v-model="periodo"
        :options="periodos"
        label="Periodo"
        outlined
        dense
        style="width: 150px"
      />
    </div>

    <q-card class="my-card q-pa-md q-mb-md">
      <div class="text-h6 q-mb-sm">Resumen General</div>
      <div class="row q-col-gutter-md text-center">
        <q-card-section class="col">
          <div class="text-subtitle1">Ingresos Totales</div>
          <div class="text-h4 text-positive">{{ formatCurrency(resumen.ingresos) }}</div>
        </q-card-section>
        <q-card-section class="col">
          <div class="text-subtitle1">Gastos Totales</div>
          <div class="text-h4 text-negative">{{ formatCurrency(resumen.gastos) }}</div>
        </q-card-section>
        <q-card-section class="col">
          <div class="text-subtitle1">Balance</div>
          <div
            class="text-h4"
            :class="resumen.ingresos - resumen.gastos >= 0 ? 'text-positive' : 'text-negative'"
          >
            {{ formatCurrency(resumen.balance) }}
          </div>
        </q-card-section>
      </div>
    </q-card>

    <!-- RESUMEN RÁPIDO -->
    <q-card flat bordered class="q-pa-md q-mb-md">
      <!-- <div class="text-h6 q-mb-md">📌 Resumen del Periodo</div> -->
      <q-row class="q-col-gutter-md">
        <q-col xs="12" sm="6" md="4">
          <Ingresos :periodo="periodo" />
        </q-col>
        <q-col xs="12" sm="6" md="4">
          <VentasTotales :periodo="periodo" />
        </q-col>
        <!-- <q-col xs="12" sm="6" md="4">
          <PiezasVendidas :periodo="periodo" />
        </q-col> -->
      </q-row>
    </q-card>

    <!-- ANÁLISIS DE DATOS -->
    <q-card flat bordered class="q-pa-md q-mb-md">
      <div class="text-h6 q-mb-md">📈 Análisis de Ventas</div>
      <ProductosMasVendidos />
    </q-card>

    <!-- MES MÁS VENDIDO -->
    <q-card flat bordered class="q-pa-md">
      <div class="text-h6">🏅 Mes Más Vendido</div>
      <MesMasVendido />
    </q-card>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { api } from 'src/boot/axios'

import VentasTotales from '../components/charts/VentasTotales.vue'
// import PiezasVendidas from '../components/PiezasVendidas.vue'
import Ingresos from '../components/charts/Ingresos.vue'
// import VentasPorTipo from '../components/VentasPorTipo.vue'
import ProductosMasVendidos from '../components/charts/ProductosMasVendidos.vue'
import MesMasVendido from '../components/charts/MesMasVendido.vue'

const periodo = ref({ label: 'Día', value: 'dia' })
const periodos = [
  { label: 'Día', value: 'dia' },
  { label: 'Semana', value: 'semana' },
  { label: 'Mes', value: 'mes' },
  { label: 'Año', value: 'anio' },
]

const resumen = ref({ ingresos: 0, gastos: 0 })

const formatCurrency = (value) =>
  new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    minimumFractionDigits: 0,
  }).format(value)

onMounted(async () => {
  const res = await api.get('/estadisticas/resumen-financiero')
  resumen.value = res.data
})
</script>
