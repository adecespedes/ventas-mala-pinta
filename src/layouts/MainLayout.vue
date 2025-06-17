<template>
  <q-layout view="hHh lpR fFf">
    <q-header elevated>
      <q-toolbar class="bg-primary glossy text-white">
        <q-btn flat dense round icon="menu" @click="drawer = !drawer" />
        <q-avatar>
          <img
            src="~assets/mala_pinta.jpeg"
            alt="Mala Pinta Logo"
            style="width: 40px; height: 40px"
          />
        </q-avatar>
        <q-toolbar-title>Gestión de Ventas</q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-drawer show-if-above v-model="drawer" side="left" bordered>
      <q-list>
        <q-item-label header>Menú</q-item-label>
        <q-item clickable v-ripple to="/dashboard" exact>
          <q-item-section avatar><q-icon name="dashboard" /></q-item-section>
          <q-item-section>Dashboard</q-item-section>
        </q-item>

        <q-item clickable v-ripple to="/ventas">
          <q-item-section avatar><q-icon name="point_of_sale" /></q-item-section>
          <q-item-section>Ventas diarias</q-item-section>
        </q-item>

        <q-item clickable v-ripple to="/pacas">
          <q-item-section avatar><q-icon name="inventory" /></q-item-section>
          <q-item-section>Pacas</q-item-section>
        </q-item>

        <q-expansion-item
          icon="category"
          label="Nomencladores"
          group="nomencladores"
          expand-separator
          :content-inset-level="1"
        >
          <q-item clickable to="/nomencladores/productos" exact>
            <q-item-section avatar><q-icon name="inventory_2" /></q-item-section>
            <q-item-section>Productos</q-item-section>
          </q-item>

          <q-item clickable to="/nomencladores/tipo-paca" exact>
            <q-item-section avatar><q-icon name="style" /></q-item-section>
            <q-item-section>Tipo de Paca</q-item-section>
          </q-item>
        </q-expansion-item>
      </q-list>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>


<script setup>
import { ref } from 'vue'

const drawer = ref(true)
</script>
