<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-btn flat @click="drawer = !drawer" round dense icon="menu" />
        <q-toolbar-title> Gestión de Ventas </q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-drawer show-if-above v-model="drawer" side="left" bordered>
      <q-list>
        <q-item clickable v-ripple to="/" exact>
          <q-item-section avatar><q-icon name="dashboard" /></q-item-section>
          <q-item-section>Dashboard</q-item-section>
        </q-item>

        <q-item clickable v-ripple to="/ventas">
          <q-item-section avatar><q-icon name="point_of_sale" /></q-item-section>
          <q-item-section>Ventas</q-item-section>
        </q-item>

        <q-item clickable v-ripple to="/pacas">
          <q-item-section avatar><q-icon name="inventory" /></q-item-section>
          <q-item-section>Pacas</q-item-section>
        </q-item>

        <q-item clickable v-ripple to="/productos">
          <q-item-section avatar><q-icon name="category" /></q-item-section>
          <q-item-section>Productos</q-item-section>
        </q-item>
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
