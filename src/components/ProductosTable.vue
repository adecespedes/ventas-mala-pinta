<template>
  <q-card flat bordered>
    <q-card-section class="row items-center">
      <div class="text-h6">Nomenclador de Productos</div>
      <div class="q-gutter-sm" style="flex-grow: 1"></div>
      <q-btn color="primary" icon="add" label="Agregar Producto" @click="abrirForm()" />
      <q-btn
        color="primary"
        icon="update"
        label="Actualizar"
        :loading="loading"
        class="q-ml-sm"
        @click="cargarProductos()"
      />
    </q-card-section>

    <q-table
      :rows="productos"
      :columns="columns"
      row-key="id"
      flat
      bordered
      dense
      :loading="loading"
      class="q-mt-md"
    >
      <template v-slot:body-cell-actions="props">
        <q-td align="right">
          <q-btn dense flat icon="edit" color="primary" @click="abrirForm(props.row)" />
          <q-btn
            dense
            flat
            icon="delete"
            color="negative"
            @click="confirmarEliminar(props.row.id)"
          />
        </q-td>
      </template>
    </q-table>

    <q-dialog v-model="dialogOpen" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">{{ editando ? 'Editar Producto' : 'Agregar Producto' }}</div>
        </q-card-section>

        <q-card-section>
          <q-input
            v-model="form.nombre"
            label="Nombre del Producto"
            dense
            autofocus
            :rules="[(val) => !!val || 'El nombre es requerido']"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="primary" v-close-popup @click="cerrarForm" />
          <q-btn flat label="Guardar" color="primary" @click="guardarProducto" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="dialogEliminar">
      <q-card>
        <q-card-section class="text-h6">¿Eliminar producto?</q-card-section>
        <q-card-section> Esta acción no se puede deshacer. </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="primary" v-close-popup />
          <q-btn flat label="Eliminar" color="red" @click="eliminarProducto" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { api } from 'boot/axios'

const productos = ref([])
const loading = ref(false)
const productoSeleccionado = ref(null)
const dialogEliminar = ref(false)

const confirmarEliminar = (id) => {
  productoSeleccionado.value = id
  dialogEliminar.value = true
}

const dialogOpen = ref(false)
const editando = ref(false)

const form = ref({
  id: null,
  nombre: '',
})

const columns = [
  { name: 'id', label: 'ID', field: 'id', align: 'left' },
  { name: 'nombre', label: 'Nombre', field: 'nombre', align: 'left' },
  { name: 'actions', label: 'Acciones', field: 'actions', align: 'right' },
]

const cargarProductos = async () => {
  loading.value = true
  try {
    const res = await api.get('/productos')
    productos.value = res.data
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

onMounted(cargarProductos)

function abrirForm(producto = null) {
  if (producto) {
    form.value = { ...producto }
    editando.value = true
  } else {
    form.value = { id: null, nombre: '' }
    editando.value = false
  }
  dialogOpen.value = true
}

function cerrarForm() {
  dialogOpen.value = false
}

async function guardarProducto() {
  if (!form.value.nombre.trim()) {
    alert('El nombre es requerido')
    return
  }
  try {
    if (editando.value) {
      await api.patch(`/productos/${form.value.id}`, { nombre: form.value.nombre })
    } else {
      await api.post('/productos', { nombre: form.value.nombre })
    }
    await cargarProductos()
    cerrarForm()
  } catch (error) {
    alert('Error guardando el producto')
    console.error(error)
  }
}

async function eliminarProducto() {
  try {
    await api.delete(`/productos/${productoSeleccionado.value}`)
    dialogEliminar.value = false
    await cargarProductos()
  } catch (error) {
    alert('Error eliminando el producto')
    console.error(error)
  }
}
</script>
