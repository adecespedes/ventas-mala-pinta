<!-- src/components/PacasTable.vue -->
<template>
  <q-card flat bordered class="q-mt-md">
    <q-card-section class="row items-center">
      <div class="text-h6">Pacas Registradas</div>
      <div class="q-gutter-sm" style="flex-grow: 1"></div>
      <q-btn label="Adicionar" icon="add" color="primary" @click="abrirDialogo()" />
      <q-btn
        color="primary"
        icon="update"
        label="Actualizar"
        @click="cargarPacas()"
        :loading="loading"
        class="q-ml-sm"
      />
    </q-card-section>

    <q-card-section>
      <q-table :rows="pacas" :columns="columns" row-key="id" :loading="loading">
        <template v-slot:body-cell-acciones="props">
          <q-td align="right">
            <q-btn flat icon="edit" color="primary" @click="abrirDialogo(props.row)" />
            <q-btn flat icon="delete" color="negative" @click="confirmarEliminar(props.row.id)" />
          </q-td>
        </template>
      </q-table>
    </q-card-section>

    <paca-form v-model="dialogo" :formData="form" :editando="editando" @save="guardar" />

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
import { ref, onMounted } from 'vue'
import { api } from 'boot/axios'
import { useQuasar } from 'quasar'
import PacaForm from './PacaForm.vue'

const $q = useQuasar()
const pacas = ref([])
const loading = ref(false)
const dialogo = ref(false)
const form = ref({
  id: null,
  nombre: '',
  productoId: '',
  cantidad: 0,
  precio: 0,
  cambio: 0,
  fecha: new Date().toISOString().substring(0, 10),
})
const editando = ref(false)

const pacaSeleccionada = ref(null)
const dialogEliminar = ref(false)

const confirmarEliminar = (id) => {
  pacaSeleccionada.value = id
  dialogEliminar.value = true
}

const columns = [
  { name: 'nombre', label: 'Nombre', field: 'nombre', align: 'center' },
  {
    name: 'productoId',
    label: 'Tipo de paca',
    field: (row) => row.producto?.nombre ?? '',
    align: 'center',
  },
  { name: 'cantidad', label: 'Cantidad de piezas', field: 'cantidad', align: 'center' },
  { name: 'precio', label: 'Precio (USD)', field: (row) => `$${row.precio}`, align: 'center' },
  { name: 'cambio', label: 'Cambio del dia (ElToque)', field: 'cambio', align: 'center' },
  {
    name: 'precioMN',
    label: 'Precio (MN)',
    field: (row) => `$${row.precio * row.cambio}`,
    align: 'center',
  },
  {
    name: 'precioMin',
    label: 'Precio mínimo pieza',
    field: (row) => `$${Math.floor((row.precio * row.cambio) / row.cantidad)}`,
    align: 'center',
  },
  {
    name: 'fecha',
    label: 'Fecha de registro',
    field: 'fecha',
    align: 'center',
    sortable: true,
    format: (val) =>
      new Date(val).toLocaleDateString('es-ES', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
      }),
  },
  { name: 'acciones', label: '', field: 'acciones', align: 'right' },
]

const cargarPacas = async () => {
  loading.value = true
  try {
    const res = await api.get('/pacas')
    pacas.value = res.data
  } catch (err) {
    console.error('Error cargando pacas', err)
  } finally {
    loading.value = false
  }
}

const abrirDialogo = (paca = null) => {
  if (paca) {
    form.value = { ...paca }
    editando.value = true
  } else {
    form.value = {
      id: null,
      nombre: '',
      productoId: '',
      cantidad: 0,
      precio: 0,
      cambio: 0,
      fecha: new Date().toISOString().substring(0, 10),
    }
    editando.value = false
  }
  dialogo.value = true
}

const guardar = async (datos) => {
  try {
    if (editando.value) {
      await api.put(`/pacas/${datos.payload.id}`, datos.payload)
      $q.notify({ type: 'positive', message: 'Paca actualizada' })
    } else {
      await api.post('/pacas', datos.payload)
      $q.notify({ type: 'positive', message: 'Paca registrada' })
    }
    dialogo.value = false
    await cargarPacas()
  } catch (err) {
    $q.notify({ type: 'negative', message: `Error al guardar: ${err}` })
  }
}

async function eliminar() {
  try {
    await api.delete(`/pacas/${pacaSeleccionada.value}`)
    dialogEliminar.value = false
    $q.notify({ type: 'positive', message: 'Paca eliminada' })
    await cargarPacas()
  } catch (error) {
    alert('Error eliminando la paca')
    console.error(error)
  }
}

onMounted(cargarPacas)
</script>
