<!-- src/components/PacaForm.vue -->
<template>
  <q-dialog v-model="modelValue" persistent>
    <q-card style="min-width: 300px">
      <q-card-section>
        <div class="text-h6">{{ editando ? 'Editar Paca' : 'Adicionar Paca' }}</div>
      </q-card-section>

      <q-card-section>
        <q-form @submit.prevent="submitForm" class="q-gutter-md">
          <q-input
            v-model="localForm.nombre"
            label="Nombre"
            type="text"
            required
            autofocus
            :rules="[(val) => !!val || 'El nombre es requerido']"
          />
          <q-select
            v-model="localForm.productoId"
            :options="productos"
            option-label="nombre"
            option-value="id"
            label="Tipo de paca"
            emit-value
            map-options
            dense
            required
            :rules="[(val) => !!val || 'El tipo de paca es requerido']"
          />

          <q-input
            v-model.number="localForm.cantidad"
            label="Cantidad de piezas"
            type="number"
            min="1"
            required
            :rules="[(val) => !!val || 'La cantidad es requerida']"
          />

          <q-input
            v-model.number="localForm.precio"
            label="Precio (USD)"
            type="number"
            min="1"
            required
            :rules="[(val) => !!val || 'El precio es requerido']"
          />

          <q-input
            v-model.number="localForm.cambio"
            label="Cambio del dia"
            type="number"
            min="1"
            required
            :rules="[(val) => !!val || 'El cambio es requerido']"
          />

          <q-input
            v-model="localForm.fecha"
            label="Fecha de registro"
            readonly
            dense
            :rules="[(val) => !!val || 'Campo requerido']"
          >
            <template #append>
              <q-icon name="event" class="cursor-pointer" @click="mostrarFecha = true" />
            </template>

            <q-popup-proxy v-model="mostrarFecha" transition-show="scale" transition-hide="scale">
              <q-date
                v-model="localForm.fecha"
                mask="YYYY-MM-DD"
                minimal
                today-btn
                @update:model-value="mostrarFecha = false"
              />
            </q-popup-proxy>
          </q-input>
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

const mostrarFecha = ref(false)

const props = defineProps({
  modelValue: Boolean,
  formData: {
    type: Object,
    default: () => ({
      id: null,
      nombre: '',
      productoId: '',
      cantidad: 0,
      precio: 0,
      cambio: 0,
      fecha: new Date().toISOString().substring(0, 10),
    }),
  },
  editando: Boolean,
})

const emit = defineEmits(['update:modelValue', 'save'])

const { modelValue, formData, editando } = toRefs(props)

const localForm = ref({ ...formData.value })

watch(
  () => formData.value,
  (newVal) => {
    localForm.value = {
      ...newVal,
      fecha: (newVal.fecha ?? new Date().toISOString().substring(0, 10)).substring(0, 10),
    }
  }
)

const submitForm = () => {
  const payload = { ...localForm.value }
  delete payload.producto // eliminar si existe
  // Validación sencilla antes de emitir
  if (
    !payload.nombre ||
    !payload.productoId ||
    payload.cantidad <= 0 ||
    payload.precio <= 0 ||
    payload.cambio <= 0 ||
    !payload.fecha
  ) {
    return
  }
  emit('save', { payload })
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
