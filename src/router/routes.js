const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', component: () => import('pages/DashboardPage.vue') },
      { path: '/ventas', component: () => import('pages/VentasPage.vue') },
      { path: '/pacas', component: () => import('pages/PacasPage.vue') },
      { path: '/productos', component: () => import('pages/ProductosPage.vue') },
    ],
  },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue'),
  },
]

export default routes
