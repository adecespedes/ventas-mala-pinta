<!-- src/components/PacaForm.vue -->
<template>
  <q-dialog v-model="modelValue" persistent>
    <q-card style="min-width: 300px">
      <q-card-section>
        <div class="text-h6">{{ editando ? 'Editar Paca' : 'Adicionar Paca' }}</div>
      </q-card-section>

      <q-card-section>
        <q-form @submit.prevent="submitForm" class="q-gutter-md">
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
            v-model.number="localForm.cantidad"
            label="Cantidad"
            type="number"
            min="1"
            required
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
    default: () => ({ id: null, nombre: '', tipo: '', talla: '', cantidad: 0 }),
  },
  editando: Boolean,
})

const emit = defineEmits(['update:modelValue', 'save'])

const { modelValue, formData, editando } = toRefs(props)

const localForm = ref({ ...formData.value })

watch(
  () => formData.value,
  (newVal) => {
    localForm.value = { ...newVal }
  }
)

const submitForm = () => {
  // Validación sencilla antes de emitir
  if (
    !localForm.value.nombre ||
    !localForm.value.tipo ||
    !localForm.value.talla ||
    localForm.value.cantidad <= 0
  ) {
    alert('Por favor complete todos los campos correctamente')
    return
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
