<template>
  <q-dialog v-model="modelValue" persistent>
    <q-card style="width: 600px; max-height: 90vh" class="column no-wrap">
      <q-card-section
        class="bg-primary text-white text-h6"
        style="position: sticky; top: 0; z-index: 1"
      >
        {{ editando ? 'Editar Venta' : 'Adicionar venta' }}
      </q-card-section>

      <q-card-section class="q-pa-md" style="overflow-y: auto; max-height: 65vh">
        <q-form @submit.prevent="submitForm" class="q-gutter-md">
          <div
            v-for="(detalle, index) in detallesProducto"
            :key="index"
            class="row q-col-gutter-sm q-mb-sm items-center"
          >
            <div class="col-7">
              <q-select
                v-model="detalle.productoId"
                :options="productos"
                option-label="nombre"
                option-value="id"
                label="Producto"
                stack-label
                emit-value
                map-options
                dense
                outlined
                required
              />
            </div>

            <div class="col-4">
              <q-input
                v-model.number="detalle.cantidad"
                label="Cantidad"
                type="number"
                min="1"
                dense
                outlined
              />
            </div>

            <div class="col-1">
              <q-btn icon="delete" color="negative" flat round @click="eliminarDetalle(index)" />
            </div>
          </div>

          <q-btn icon="add" label="Agregar producto" color="primary" flat @click="agregarDetalle" />

          <div class="text-subtitle2 text-primary">Detalles</div>
          <div class="row q-col-gutter-md q-mt-xs">
            <div class="col-4">
              <q-input
                v-model.number="localForm.totalPiezas"
                label="Cantidad de piezas"
                type="number"
                dense
                outlined
                min="1"
                required
                class="q-ml-md"
                :readonly="esSoloLecturaCantidad"
              />
            </div>
            <div class="col-4">
              <q-input
                v-model.number="localForm.totalPrecio"
                label="Monto total"
                type="number"
                dense
                outlined
                min="1"
                required
              />
            </div>
            <div class="col-4">
              <q-input
                label="Fecha de registro"
                dense
                outlined
                :model-value="localForm.fecha"
                readonly
              >
                <template #append>
                  <q-icon name="event" class="cursor-pointer" @click="mostrarFecha = true" />
                </template>
                <q-popup-proxy
                  v-model="mostrarFecha"
                  transition-show="scale"
                  transition-hide="scale"
                >
                  <q-date v-model="localForm.fecha" mask="YYYY-MM-DD" minimal today-btn />
                </q-popup-proxy>
              </q-input>
            </div>
          </div>
        </q-form>
      </q-card-section>

      <q-card-actions
        align="right"
        class="bg-grey-2"
        style="position: sticky; bottom: 0; z-index: 1"
      >
        <q-btn flat label="Cancelar" color="primary" @click="cancelar" />
        <q-btn flat label="Guardar" color="primary" @click="submitForm" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup>
import { api } from 'src/boot/axios'
import { ref, watch, toRefs, onMounted, computed } from 'vue'

const getFechaHoy = () => {
  const hoy = new Date()
  return `${hoy.getFullYear()}-${String(hoy.getMonth() + 1).padStart(2, '0')}-${String(
    hoy.getDate()
  ).padStart(2, '0')}`
}

const mostrarFecha = ref(false)
const mostrarDetallesProducto = ref(true)
const detallesProducto = ref([])

const esSoloLecturaCantidad = computed(
  () => mostrarDetallesProducto.value && detallesProducto.value.length > 0
)

watch(
  detallesProducto,
  (nuevosDetalles) => {
    const total = nuevosDetalles.reduce((acc, detalle) => acc + (detalle.cantidad || 0), 0)
    localForm.value.totalPiezas = total
  },
  { deep: true }
)

const agregarDetalle = () => {
  detallesProducto.value.push({ productoId: null, cantidad: 1 })
}

const eliminarDetalle = (index) => {
  detallesProducto.value.splice(index, 1)
}

const props = defineProps({
  modelValue: Boolean,
  formData: {
    type: Object,
    default: () => ({
      id: null,
      totalPiezas: 0,
      totalPrecio: 0,
      fecha: '',
      productoId: null,
      detalles: [],
    }),
  },
  editando: Boolean,
})

const emit = defineEmits(['update:modelValue', 'save'])

const { modelValue, formData, editando } = toRefs(props)

const localForm = ref({ ...formData.value })

watch(modelValue, (val) => {
  if (val) {
    localForm.value = {
      ...formData.value,
      fecha: formData.value.fecha ?? getFechaHoy(),
    }

    detallesProducto.value =
      formData.value.detalles?.map((d) => ({
        productoId: Number(d.producto.id), // <- fuerza a número
        cantidad: d.cantidad,
      })) || []
  }
})

const submitForm = () => {
  const payload = {
    ...localForm.value,
    detalles: mostrarDetallesProducto.value ? detallesProducto.value : [],
  }

  if (payload.totalPiezas <= 0 || payload.totalPrecio <= 0 || !payload.fecha) {
    return
  }

  emit('save', { payload })
}

const cancelar = () => {
  emit('update:modelValue', false)
}

const productos = ref([])
const tipos = ref([])

const cargarTipos = async () => {
  try {
    const res = await api.get('/tipos')
    tipos.value = res.data
  } catch (error) {
    console.error(error)
  }
}

const cargarProductos = async () => {
  try {
    const res = await api.get('/productos')
    productos.value = res.data
  } catch (error) {
    console.error(error)
  }
}

onMounted(() => {
  cargarProductos()
  cargarTipos()
})
</script>

