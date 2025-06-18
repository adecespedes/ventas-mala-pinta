<template>
  <q-dialog v-model="modelValue" persistent>
    <q-card style="min-width: 300px">
      <q-card-section>
        <div class="text-h6">{{ editando ? 'Editar Producto' : 'Agregar Producto' }}</div>
      </q-card-section>

      <q-card-section>
        <q-form @submit.prevent="submitForm" class="q-gutter-md">
          <q-input v-model="localForm.nombre" label="Nombre" required />
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
import { ref, watch, toRefs } from 'vue'

const props = defineProps({
  modelValue: Boolean,
  formData: {
    type: Object,
    default: () => ({ id: null, nombre: '' }),
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
  if (!localForm.value.nombre) {
    alert('Complete todos los campos')
    return
  }
  emit('save', { ...localForm.value })
}

const cancelar = () => {
  emit('update:modelValue', false)
}
</script>
