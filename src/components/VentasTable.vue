<!-- src/components/PacasTable.vue -->
<template>
  <q-card flat bordered class="q-mt-md">
    <q-card-section class="row items-center">
      <div class="text-h6">Ventas diarias</div>
      <div class="q-gutter-sm" style="flex-grow: 1"></div>
      <q-btn label="Adicionar" icon="add" color="primary" @click="abrirDialogo()" />
      <q-btn
        color="primary"
        icon="update"
        label="Actualizar"
        @click="cargarVentas()"
        :loading="loading"
        class="q-ml-sm"
      />
    </q-card-section>

    <q-card-section>
      <q-input filled v-model="fechaFiltroTexto" label="Filtrar por fecha o rango" dense readonly>
        <template #append>
          <q-icon name="event" class="cursor-pointer" @click="mostrarCalendario = true" />
        </template>
        <q-popup-proxy v-model="mostrarCalendario" transition-show="scale" transition-hide="scale">
          <q-date
            v-model="filtroFecha"
            mask="YYYY-MM-DD"
            today-btn
            range
            @update:model-value="actualizarTextoFiltro"
          />
        </q-popup-proxy>
      </q-input>
    </q-card-section>

    <q-card-section>
      <q-table
        class="my-sticky-header-table"
        :rows="filtradas"
        :columns="columns"
        row-key="id"
        :loading="loading"
        v-model:expanded="expanded"
      >
        <template v-slot:body="props">
          <!-- Fila principal -->
          <q-tr :props="props">
            <q-td auto-width>
              <q-btn
                v-if="props.row.detalles && props.row.detalles.length"
                size="sm"
                color="primary"
                round
                dense
                :icon="props.expand ? 'remove' : 'add'"
                @click="props.expand = !props.expand"
              />
            </q-td>
            <q-td key="fecha" :props="props">{{
              dayjs(props.row.fecha).format('DD-MM-YYYY')
            }}</q-td>
            <q-td key="totalPiezas" :props="props">{{ props.row.totalPiezas }}</q-td>
            <q-td key="totalPrecio" :props="props">${{ props.row.totalPrecio }}</q-td>

            <q-td key="acciones" :props="props" align="right">
              <q-btn flat icon="edit" color="primary" @click="abrirDialogo(props.row)">
                <q-tooltip>Editar</q-tooltip>
              </q-btn>
              <q-btn flat icon="delete" color="negative" @click="confirmarEliminar(props.row.id)">
                <q-tooltip>Eliminar</q-tooltip>
              </q-btn>
            </q-td>
            <!-- Resto de columnas igual -->
          </q-tr>

          <!-- Fila expandida -->
          <q-tr v-show="props.expand" :props="props">
            <q-td colspan="100%">
              <div><strong>Productos asociados:</strong></div>
              <q-list dense bordered class="q-pa-sm">
                <q-item v-for="(detalle, idx) in props.row.detalles" :key="idx">
                  <q-item-section>{{ detalle.producto?.nombre }}</q-item-section>
                  <q-item-section side>{{ detalle.cantidad }}</q-item-section>
                </q-item>
              </q-list>
            </q-td>
          </q-tr>
        </template>
        <template v-slot:body-cell-acciones="props">
          <q-td align="right">
            <!-- <q-btn
              v-if="props.row.detalles && props.row.detalles.length > 0"
              flat
              icon="visibility"
              color="secondary"
              @click="verDetalles(props.row)"
            >
              <q-tooltip anchor="top middle" self="bottom middle" class="bg-secondary"
                >Ver detalles</q-tooltip
              ></q-btn
            > -->
            <q-btn flat icon="edit" color="primary" @click="abrirDialogo(props.row)">
              <q-tooltip anchor="top middle" self="bottom middle" class="bg-primary"
                >Editar</q-tooltip
              >
            </q-btn>
            <q-btn flat icon="delete" color="negative" @click="confirmarEliminar(props.row.id)">
              <q-tooltip anchor="top middle" self="bottom middle" class="bg-negative"
                >Eliminar</q-tooltip
              >
            </q-btn>
          </q-td>
        </template>
      </q-table>
    </q-card-section>

    <venta-form v-model="dialogo" :formData="form" :editando="editando" @save="guardar" />

    <q-dialog v-model="dialogEliminar">
      <q-card>
        <q-card-section class="text-h6">¿Eliminar paca?</q-card-section>
        <q-card-section> Esta acción no se puede deshacer. </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="primary" v-close-popup />
          <q-btn flat label="Eliminar" color="red" @click="eliminar" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-card>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { api } from 'boot/axios'
import { useQuasar } from 'quasar'
import dayjs from 'dayjs'
import VentaForm from './VentaForm.vue'

const $q = useQuasar()
const ventas = ref([])
const loading = ref(false)
const dialogo = ref(false)

const hoy = new Date()
const yyyy = hoy.getFullYear()
const mm = String(hoy.getMonth() + 1).padStart(2, '0')
const dd = String(hoy.getDate()).padStart(2, '0')

const form = ref({
  id: null,
  totalPiezas: 0,
  totalPrecio: 0,
  fecha: `${yyyy}-${mm}-${dd}`,
  productoId: null,
})

const editando = ref(false)

const ventaSeleccionada = ref(null)
const dialogEliminar = ref(false)

const confirmarEliminar = (id) => {
  ventaSeleccionada.value = id
  dialogEliminar.value = true
}

const columns = [
  { name: 'expander', label: '', field: 'expander' },
  {
    name: 'fecha',
    label: 'Fecha de registro',
    field: 'fecha',
    align: 'center',
    sortable: true,
    format: (val) => dayjs(val).format('DD/MM/YYYY'),
  },

  { name: 'totalPiezas', label: 'Cantidad de piezas', field: 'totalPiezas', align: 'center' },
  { name: 'totalPrecio', label: 'Monto Total', field: 'totalPrecio', align: 'center' },

  { name: 'acciones', label: '', field: 'acciones', align: 'right' },
]

const filtroFecha = ref(null) // puede ser string o { from, to }
const fechaFiltroTexto = ref('')
const mostrarCalendario = ref(false)
const expanded = ref([])

const actualizarTextoFiltro = () => {
  if (typeof filtroFecha.value === 'string') {
    fechaFiltroTexto.value = filtroFecha.value
  } else if (filtroFecha.value?.from && filtroFecha.value?.to) {
    fechaFiltroTexto.value = `${filtroFecha.value.from} - ${filtroFecha.value.to}`
  } else {
    fechaFiltroTexto.value = ''
  }
}

const filtradas = computed(() => {
  return ventas.value.filter((paca) => {
    const fecha = paca.fecha?.substring(0, 10)

    if (!filtroFecha.value) return true

    if (typeof filtroFecha.value === 'string') {
      return fecha === filtroFecha.value
    } else if (filtroFecha.value.from && filtroFecha.value.to) {
      return fecha >= filtroFecha.value.from && fecha <= filtroFecha.value.to
    }

    return true
  })
})

const cargarVentas = async () => {
  loading.value = true
  try {
    const res = await api.get('/ventas')
    ventas.value = res.data
  } catch (err) {
    console.error('Error cargando ventas', err)
  } finally {
    loading.value = false
  }
}

const abrirDialogo = (venta = null) => {
  if (venta) {
    form.value = { ...venta, detalles: venta.detalles ?? [] }
    editando.value = true
  } else {
    form.value = {
      id: null,
      totalPiezas: 0,
      totalPrecio: 0,
      fecha: `${yyyy}-${mm}-${dd}`,
      productoId: null,
      detalles: [],
    }
    editando.value = false
  }
  dialogo.value = true
}

const guardar = async (datos) => {
  try {
    if (editando.value) {
      await api.put(`/ventas/${datos.payload.id}`, datos.payload)
      $q.notify({ type: 'positive', message: 'Venta actualizada' })
    } else {
      await api.post('/ventas', datos.payload)
      $q.notify({ type: 'positive', message: 'Venta registrada' })
    }
    dialogo.value = false
    await cargarVentas()
  } catch (err) {
    $q.notify({ type: 'negative', message: `Error al guardar: ${err}` })
  }
}

async function eliminar() {
  try {
    await api.delete(`/ventas/${ventaSeleccionada.value}`)
    dialogEliminar.value = false
    $q.notify({ type: 'positive', message: 'Venta eliminada' })
    await cargarVentas()
  } catch (error) {
    alert('Error eliminando la venta')
    console.error(error)
  }
}

onMounted(cargarVentas)
</script>
<style lang="sass">
.my-sticky-header-table
  /* height or max-height is important */
  height: 400px

  .q-table__top,
  .q-table__bottom,
  thead tr:first-child th
    /* bg color is important for th; just specify one */
    background-color: #ADD8E6

  thead tr th
    position: sticky
    z-index: 1
  thead tr:first-child th
    top: 0

  /* this is when the loading indicator appears */
  &.q-table--loading thead tr:last-child th
    /* height of all previous header rows */
    top: 48px

  /* prevent scrolling behind sticky top row on focus */
  tbody
    /* height of all previous header rows */
    scroll-margin-top: 48px
</style>
