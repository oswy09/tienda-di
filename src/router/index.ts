import { createRouter, createWebHistory } from 'vue-router';
import Catalog from '../views/Catalog.vue';
import AdminProducts from '../views/AdminProducts.vue';
import AdminOrders from '../views/AdminOrders.vue';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'Catalog',
      component: Catalog,
    },
    {
      path: '/di-admin',
      name: 'AdminProducts',
      component: AdminProducts,
    },
    {
      path: '/di-cotizaciones',
      name: 'AdminOrders',
      component: AdminOrders,
    },
  ],
});

export default router;
