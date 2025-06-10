<!-- src/components/VentaForm.vue -->
<template>
  <q-dialog v-model="modelValue" persistent>
    <q-card style="min-width: 400px; max-width: 600px">
      <q-card-section>
        <div class="text-h6">{{ editando ? 'Editar Venta' : 'Adicionar Venta' }}</div>
      </q-card-section>

      <q-card-section>
        <q-form @submit.prevent="submitForm">
          <div
            v-for="(item, index) in localForm.items"
            :key="index"
            class="row q-gutter-md items-center"
          >
            <q-select
              v-model="localForm.nombre"
              :options="productos"
              option-label="nombre"
              option-value="nombre"
              label="Producto"
              emit-value
              map-options
              dense
              required
            />
            <q-input
              v-model.number="item.cantidadPiezas"
              label="Piezas Vendidas"
              type="number"
              dense
              class="col-3"
              min="1"
              required
            />
            <q-btn
              icon="remove_circle"
              color="negative"
              flat
              round
              dense
              @click="removerItem(index)"
            />
          </div>

          <q-btn
            label="Agregar Producto"
            color="primary"
            flat
            @click="agregarItem"
            class="q-mt-md"
          />

          <q-input
            v-model.number="localForm.total"
            label="Total"
            type="number"
            required
            class="q-mt-md"
          />
        </q-form>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn flat label="Cancelar" @click="cancelar" />
        <q-btn flat label="Guardar" color="primary" @click="submitForm" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup>
import { api } from 'src/boot/axios'
import { ref, watch, toRefs, onMounted } from 'vue'

const props = defineProps({
  modelValue: Boolean,
  formData: {
    type: Object,
    default: () => ({
      id: null,
      total: 0,
      items: [{ nombre: '', cantidadPiezas: 1 }],
    }),
  },
  editando: Boolean,
})

const emit = defineEmits(['update:modelValue', 'save'])

const { modelValue, formData, editando } = toRefs(props)

const localForm = ref({ ...formData.value })

// Para que items reactive correctamente
if (!localForm.value.items || !Array.isArray(localForm.value.items)) {
  localForm.value.items = []
}

watch(
  () => formData.value,
  (newVal) => {
    localForm.value = { ...newVal }
    if (!localForm.value.items || !Array.isArray(localForm.value.items)) {
      localForm.value.items = []
    }
  }
)

const agregarItem = () => {
  localForm.value.items.push({ nombre: '', cantidadPiezas: 1 })
}

const removerItem = (index) => {
  localForm.value.items.splice(index, 1)
}

const submitForm = () => {
  // Validar que todos los items tengan nombre y cantidad válida
  for (const item of localForm.value.items) {
    if (!item.nombre || item.cantidadPiezas <= 0) {
      alert('Complete todos los productos y cantidades correctamente')
      return
    }
  }
  emit('save', { ...localForm.value })
}

const cancelar = () => {
  emit('update:modelValue', false)
}

const productos = ref([])

const cargarProductos = async () => {
  try {
    const res = await api.get('/productos')
    productos.value = res.data
  } catch (error) {
    console.error(error)
  }
}

onMounted(cargarProductos)
</script>
