<!-- src/components/PacasTable.vue -->
<template>
  <q-card flat bordered class="q-mt-md">
    <q-card-section class="row items-center justify-between">
      <div class="text-h6">Pacas Registradas</div>
      <q-btn label="Adicionar" icon="add" color="primary" @click="abrirDialogo()" />
    </q-card-section>

    <q-card-section>
      <q-table :rows="pacas" :columns="columns" row-key="id" flat bordered dense :loading="loading">
        <template v-slot:body-cell-acciones="props">
          <q-td align="center">
            <q-btn size="sm" flat icon="edit" color="primary" @click="abrirDialogo(props.row)" />
            <q-btn size="sm" flat icon="delete" color="negative" @click="eliminar(props.row.id)" />
          </q-td>
        </template>
      </q-table>
    </q-card-section>

    <paca-form v-model="dialogo" :formData="form" :editando="editando" @save="guardar" />
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
const form = ref({ id: null, nombre: '', tipo: '', talla: '', cantidad: 0 })
const editando = ref(false)

const columns = [
  { name: 'nombre', label: 'Nombre', field: 'nombre', align: 'left' },
  { name: 'tipo', label: 'Tipo', field: 'tipo', align: 'left' },
  { name: 'talla', label: 'Talla', field: 'talla', align: 'left' },
  { name: 'cantidad', label: 'Cantidad', field: 'cantidad', align: 'right' },
  { name: 'acciones', label: 'Acciones', field: 'acciones', align: 'center' },
]

const cargarPacas = async () => {
  loading.value = true
  try {
    const res = await api.get('/productos')
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
    form.value = { id: null, nombre: '', tipo: '', talla: '', cantidad: 0 }
    editando.value = false
  }
  dialogo.value = true
}

const guardar = async (datos) => {
  try {
    if (editando.value) {
      await api.put(`/productos/${datos.id}`, datos)
      $q.notify({ type: 'positive', message: 'Paca actualizada' })
    } else {
      await api.post('/productos', datos)
      $q.notify({ type: 'positive', message: 'Paca registrada' })
    }
    dialogo.value = false
    await cargarPacas()
  } catch (err) {
    $q.notify({ type: 'negative', message: `Error al guardar: ${err}` })
  }
}

const eliminar = async (id) => {
  $q.dialog({
    title: 'Confirmar',
    message: '¿Eliminar esta paca?',
    cancel: true,
    persistent: true,
  }).onOk(async () => {
    try {
      await api.delete(`/productos/${id}`)
      $q.notify({ type: 'positive', message: 'Paca eliminada' })
      await cargarPacas()
    } catch (err) {
      $q.notify({ type: 'negative', message: `Error al eliminar: ${err}` })
    }
  })
}

onMounted(cargarPacas)
</script>
