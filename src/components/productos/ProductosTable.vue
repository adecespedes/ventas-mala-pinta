<template>
  <q-card flat bordered class="q-mt-md">
    <q-card-section class="row items-center">
      <div class="text-h6">Nomenclador Productos</div>
      <div class="q-gutter-sm" style="flex-grow: 1"></div>
      <q-btn color="primary" icon="add" label="Adicionar" @click="abrirForm()" />
      <q-btn
        color="primary"
        icon="update"
        label="Actualizar"
        :loading="loading"
        class="q-ml-sm"
        @click="cargarProductos()"
      />
    </q-card-section>

    <q-card-section
      ><q-table
        :rows="productos"
        :columns="columns"
        row-key="id"
        :loading="loading"
        class="q-mt-md my-sticky-header-table"
      >
        <template v-slot:body-cell-actions="props">
          <q-td align="right">
            <q-btn flat icon="edit" color="primary" @click="abrirForm(props.row)">
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

    <q-dialog v-model="dialogOpen" persistent>
      <q-card style="min-width: 400px; max-height: 90vh" class="column no-wrap">
        <q-card-section
          class="bg-primary text-white text-h6"
          style="position: sticky; top: 0; z-index: 1"
        >
          <div class="text-h6">{{ editando ? 'Editar Producto' : 'Agregar Producto' }}</div>
        </q-card-section>

        <q-card-section class="q-gutter-md" style="overflow-y: auto; max-height: 65vh">
          <q-input
            v-model="form.nombre"
            label="Nombre del Producto"
            dense
            outlined
            autofocus
            :rules="[(val) => !!val || 'El nombre es requerido']"
          />
        </q-card-section>

        <q-card-actions
          align="right"
          class="bg-grey-1"
          style="position: sticky; bottom: 0; z-index: 1"
        >
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
import { useQuasar } from 'quasar'

const $q = useQuasar()

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
  { name: 'id', label: 'ID', field: 'id', align: 'center' },
  { name: 'nombre', label: 'Nombre', field: 'nombre', align: 'center' },
  { name: 'actions', label: '', field: 'actions', align: 'right' },
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
    return
  }
  try {
    if (editando.value) {
      await api.patch(`/productos/${form.value.id}`, { nombre: form.value.nombre })
      $q.notify({ type: 'positive', message: 'Producto editado correctamente' })
    } else {
      await api.post('/productos', { nombre: form.value.nombre })
      $q.notify({ type: 'positive', message: 'Producto añadido correctamente' })
    }
    await cargarProductos()
    cerrarForm()
  } catch (error) {
    $q.notify({ type: 'negative', message: 'Error guardando el producto' })
    console.error(error)
  }
}

async function eliminarProducto() {
  try {
    await api.delete(`/productos/${productoSeleccionado.value}`)
    dialogEliminar.value = false
    $q.notify({ type: 'positive', message: 'Producto eliminado' })
    await cargarProductos()
  } catch (error) {
    if (error.response?.data?.message) {
      $q.notify({ type: 'negative', message: error.response.data.message })
    } else {
      $q.notify({ type: 'negative', message: 'Error al eliminar el producto' })
    }
    console.error(error)
  }
}
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
