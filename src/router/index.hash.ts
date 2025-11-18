import { createRouter, createWebHashHistory } from 'vue-router';
import Catalog from '../views/Catalog.vue';
import AdminProducts from '../views/AdminProducts.vue';
import AdminOrders from '../views/AdminOrders.vue';

const router = createRouter({
  // Using hash history for compatibility with static hosting
  // URLs will be: /#/di-admin and /#/di-cotizaciones
  history: createWebHashHistory(),
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
