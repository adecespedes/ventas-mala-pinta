<!-- src/components/VentasTable.vue -->
<template>
  <q-card flat bordered class="q-mt-md">
    <q-card-section class="row items-center justify-between">
      <div class="text-h6">Ventas Registradas</div>
      <q-btn label="Adicionar" icon="add" color="primary" @click="abrirDialogo()" />
    </q-card-section>

    <q-card-section>
      <q-table
        :rows="ventas"
        :columns="columns"
        row-key="id"
        flat
        bordered
        dense
        :loading="loading"
      >
        <template v-slot:body-cell-acciones="props">
          <q-td align="center">
            <q-btn size="sm" flat icon="edit" color="primary" @click="abrirDialogo(props.row)" />
            <q-btn size="sm" flat icon="delete" color="negative" @click="eliminar(props.row.id)" />
          </q-td>
        </template>
      </q-table>
    </q-card-section>

    <venta-form v-model="dialogo" :formData="form" :editando="editando" @save="guardar" />
  </q-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { api } from 'boot/axios'
import { useQuasar } from 'quasar'
import VentaForm from './VentaForm.vue'

const $q = useQuasar()
const ventas = ref([])
const loading = ref(false)
const dialogo = ref(false)
const form = ref({ id: null, total: 0, items: '[]' })
const editando = ref(false)

const columns = [
  {
    name: 'fecha',
    label: 'Fecha',
    field: 'fecha',
    align: 'left',
    format: (val) => new Date(val).toLocaleDateString(),
  },
  { name: 'total', label: 'Total', field: 'total', align: 'right' },
  { name: 'acciones', label: 'Acciones', field: 'acciones', align: 'center' },
]

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
    form.value = {
      id: venta.id,
      total: venta.total,
      items: JSON.stringify(venta.items, null, 2),
    }
    editando.value = true
  } else {
    form.value = { id: null, total: 0, items: '[]' }
    editando.value = false
  }
  dialogo.value = true
}

const guardar = async (datos) => {
  try {
    const payload = { ...datos, items: JSON.parse(datos.items) }
    if (editando.value) {
      await api.put(`/ventas/${datos.id}`, payload)
      $q.notify({ type: 'positive', message: 'Venta actualizada' })
    } else {
      await api.post('/ventas', payload)
      $q.notify({ type: 'positive', message: 'Venta registrada' })
    }
    dialogo.value = false
    await cargarVentas()
  } catch (err) {
    $q.notify({ type: 'negative', message: `Error al guardar: ${err}` })
  }
}

const eliminar = async (id) => {
  $q.dialog({
    title: 'Confirmar',
    message: '¿Eliminar esta venta?',
    cancel: true,
    persistent: true,
  }).onOk(async () => {
    try {
      await api.delete(`/ventas/${id}`)
      $q.notify({ type: 'positive', message: 'Venta eliminada' })
      await cargarVentas()
    } catch (err) {
      $q.notify({ type: 'negative', message: `Error al eliminar: ${err}` })
    }
  })
}

onMounted(cargarVentas)
</script>
