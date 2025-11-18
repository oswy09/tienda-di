<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { supabase } from '../lib/supabase';
import { useRouter } from 'vue-router';

interface Order {
  id: string;
  customer_name: string;
  customer_phone: string;
  customer_email: string | null;
  items: any[];
  total: number;
  installments: number;
  status: string;
  created_at: string;
}

const router = useRouter();
const orders = ref<Order[]>([]);
const loading = ref(true);
const selectedOrder = ref<Order | null>(null);
const statusFilter = ref<string>('all');

const filteredOrders = computed(() => {
  if (statusFilter.value === 'all') {
    return orders.value;
  }
  return orders.value.filter(o => o.status === statusFilter.value);
});

const fetchOrders = async () => {
  loading.value = true;
  const { data, error } = await supabase
    .from('orders')
    .select('*')
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching orders:', error);
  } else {
    orders.value = data || [];
  }
  loading.value = false;
};

const viewOrder = (order: Order) => {
  selectedOrder.value = order;
};

const closeModal = () => {
  selectedOrder.value = null;
};

const updateOrderStatus = async (orderId: string, status: string) => {
  const { error } = await supabase
    .from('orders')
    .update({ status })
    .eq('id', orderId);

  if (error) {
    console.error('Error updating order:', error);
    alert('Error al actualizar el estado');
  } else {
    fetchOrders();
    if (selectedOrder.value?.id === orderId) {
      closeModal();
    }
  }
};

const formatDate = (date: string) => {
  return new Date(date).toLocaleString('es-CO', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
};

const formatPrice = (price: number) => {
  return price.toLocaleString('es-CO');
};

const getStatusColor = (status: string) => {
  const colors: { [key: string]: string } = {
    pending: '#ea580c',
    completed: '#16a34a',
    cancelled: '#dc2626',
  };
  return colors[status] || '#000';
};

const getStatusLabel = (status: string) => {
  const labels: { [key: string]: string } = {
    pending: 'Pendiente',
    completed: 'Completado',
    cancelled: 'Cancelado',
  };
  return labels[status] || status;
};

const goToProducts = () => {
  router.push('/admin/products');
};

const goToCatalog = () => {
  router.push('/');
};

onMounted(() => {
  fetchOrders();
});
</script>

<template>
  <div class="admin-orders">
    <header class="admin-header">
      <div class="header-content">
        <h1>PEDIDOS</h1>
        <div class="header-actions">
          <button class="btn-secondary" @click="goToProducts">Administrar Productos</button>
          <button class="btn-secondary" @click="goToCatalog">Ver Catálogo</button>
        </div>
      </div>
    </header>

    <div class="filters">
      <div class="container">
        <div class="filter-group">
          <label>Estado:</label>
          <select v-model="statusFilter">
            <option value="all">Todos</option>
            <option value="pending">Pendientes</option>
            <option value="completed">Completados</option>
            <option value="cancelled">Cancelados</option>
          </select>
        </div>
      </div>
    </div>

    <main class="main-content">
      <div class="container">
        <div v-if="loading" class="loading">
          <div class="loader"></div>
          <p>CARGANDO PEDIDOS...</p>
        </div>

        <div v-else-if="filteredOrders.length === 0" class="no-orders">
          <p>NO HAY PEDIDOS</p>
        </div>

        <div v-else class="orders-list">
          <div v-for="order in filteredOrders" :key="order.id" class="order-card">
            <div class="order-header">
              <div class="order-info">
                <h3>{{ order.customer_name }}</h3>
                <p class="order-date">{{ formatDate(order.created_at) }}</p>
              </div>
              <div class="order-status" :style="{ backgroundColor: getStatusColor(order.status) }">
                {{ getStatusLabel(order.status) }}
              </div>
            </div>

            <div class="order-body">
              <div class="customer-info">
                <div class="info-item">
                  <span class="label">Celular:</span>
                  <span>{{ order.customer_phone }}</span>
                </div>
                <div class="info-item" v-if="order.customer_email">
                  <span class="label">Email:</span>
                  <span>{{ order.customer_email }}</span>
                </div>
                <div class="info-item">
                  <span class="label">Productos:</span>
                  <span>{{ order.items.length }} items</span>
                </div>
                <div class="info-item">
                  <span class="label">Total:</span>
                  <span class="total">${{ formatPrice(order.total) }}</span>
                </div>
                <div class="info-item">
                  <span class="label">Pago:</span>
                  <span>{{ order.installments }} cuota{{ order.installments > 1 ? 's' : '' }}</span>
                </div>
              </div>
            </div>

            <div class="order-actions">
              <button class="btn-view" @click="viewOrder(order)">Ver Detalles</button>
              <button
                v-if="order.status === 'pending'"
                class="btn-complete"
                @click="updateOrderStatus(order.id, 'completed')"
              >
                Marcar Completado
              </button>
              <button
                v-if="order.status === 'pending'"
                class="btn-cancel"
                @click="updateOrderStatus(order.id, 'cancelled')"
              >
                Cancelar
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>

    <div v-if="selectedOrder" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>DETALLES DEL PEDIDO</h2>
          <button class="close-btn" @click="closeModal">✕</button>
        </div>

        <div class="modal-body">
          <div class="detail-section">
            <h3>INFORMACIÓN DEL CLIENTE</h3>
            <div class="detail-grid">
              <div class="detail-item">
                <span class="label">Nombre:</span>
                <span>{{ selectedOrder.customer_name }}</span>
              </div>
              <div class="detail-item">
                <span class="label">Celular:</span>
                <span>{{ selectedOrder.customer_phone }}</span>
              </div>
              <div class="detail-item" v-if="selectedOrder.customer_email">
                <span class="label">Email:</span>
                <span>{{ selectedOrder.customer_email }}</span>
              </div>
              <div class="detail-item">
                <span class="label">Fecha:</span>
                <span>{{ formatDate(selectedOrder.created_at) }}</span>
              </div>
            </div>
          </div>

          <div class="detail-section">
            <h3>PRODUCTOS</h3>
            <div class="products-list">
              <div v-for="(item, index) in selectedOrder.items" :key="index" class="product-item">
                <div class="product-details">
                  <p class="product-name">{{ item.product.name }}</p>
                  <p class="product-meta">
                    {{ item.product.category }} | Talla: {{ item.selectedSize }}
                  </p>
                </div>
                <div class="product-price">
                  ${{ formatPrice(item.product.price) }}
                </div>
              </div>
            </div>
          </div>

          <div class="detail-section">
            <div class="order-summary">
              <div class="summary-row">
                <span class="label">TOTAL:</span>
                <span class="value">${{ formatPrice(selectedOrder.total) }}</span>
              </div>
              <div class="summary-row">
                <span class="label">Forma de pago:</span>
                <span>{{ selectedOrder.installments }} cuota{{ selectedOrder.installments > 1 ? 's' : '' }}</span>
              </div>
              <div v-if="selectedOrder.installments === 2" class="summary-row">
                <span class="label">Valor por cuota:</span>
                <span>${{ formatPrice(selectedOrder.total / 2) }}</span>
              </div>
            </div>
          </div>

          <div class="modal-actions" v-if="selectedOrder.status === 'pending'">
            <button class="btn-complete" @click="updateOrderStatus(selectedOrder.id, 'completed')">
              Marcar como Completado
            </button>
            <button class="btn-cancel" @click="updateOrderStatus(selectedOrder.id, 'cancelled')">
              Cancelar Pedido
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-orders {
  min-height: 100vh;
  background: #f5f5f5;
}

.admin-header {
  background: #000;
  color: #fff;
  padding: 24px 20px;
  border-bottom: 4px solid #fff;
}

.header-content {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}

.header-content h1 {
  font-size: 28px;
  font-weight: 900;
  letter-spacing: 2px;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.btn-secondary {
  padding: 12px 24px;
  background: transparent;
  color: #fff;
  border: 2px solid #fff;
  cursor: pointer;
  font-weight: 700;
  font-size: 13px;
  letter-spacing: 1px;
  transition: all 0.2s ease;
  font-family: inherit;
}

.btn-secondary:hover {
  background: #fff;
  color: #000;
}

.filters {
  background: #fff;
  border-bottom: 2px solid #000;
  padding: 20px;
}

.filters .container {
  max-width: 1400px;
  margin: 0 auto;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 12px;
}

.filter-group label {
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 1px;
  text-transform: uppercase;
}

.filter-group select {
  padding: 10px 16px;
  border: 2px solid #000;
  background: #fff;
  font-size: 14px;
  font-family: inherit;
  font-weight: 600;
}

.main-content {
  padding: 40px 20px;
}

.container {
  max-width: 1400px;
  margin: 0 auto;
}

.loading {
  text-align: center;
  padding: 80px 20px;
}

.loader {
  width: 50px;
  height: 50px;
  border: 4px solid #ddd;
  border-top: 4px solid #000;
  border-radius: 50%;
  margin: 0 auto 20px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.no-orders {
  text-align: center;
  padding: 80px 20px;
  color: #999;
}

.no-orders p {
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 2px;
}

.orders-list {
  display: grid;
  gap: 24px;
}

.order-card {
  background: #fff;
  border: 2px solid #000;
  transition: all 0.2s ease;
}

.order-card:hover {
  box-shadow: 4px 4px 0 #000;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 2px solid #000;
  background: #f9f9f9;
}

.order-info h3 {
  margin: 0 0 4px 0;
  font-size: 18px;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.order-date {
  margin: 0;
  font-size: 13px;
  color: #666;
  font-weight: 600;
}

.order-status {
  padding: 6px 16px;
  color: #fff;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1px;
  text-transform: uppercase;
}

.order-body {
  padding: 20px;
}

.customer-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.info-item .label {
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
  color: #666;
}

.info-item span:not(.label) {
  font-size: 14px;
  font-weight: 600;
}

.info-item .total {
  font-size: 18px;
  font-weight: 700;
}

.order-actions {
  display: flex;
  gap: 12px;
  padding: 20px;
  border-top: 2px solid #000;
  background: #f9f9f9;
}

.btn-view,
.btn-complete,
.btn-cancel {
  padding: 10px 20px;
  border: 2px solid #000;
  cursor: pointer;
  font-weight: 700;
  font-size: 12px;
  letter-spacing: 1px;
  transition: all 0.2s ease;
  font-family: inherit;
}

.btn-view {
  background: #fff;
  color: #000;
}

.btn-view:hover {
  background: #000;
  color: #fff;
}

.btn-complete {
  background: #16a34a;
  color: #fff;
  border-color: #16a34a;
}

.btn-complete:hover {
  background: #15803d;
}

.btn-cancel {
  background: #dc2626;
  color: #fff;
  border-color: #dc2626;
}

.btn-cancel:hover {
  background: #b91c1c;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 20px;
}

.modal-content {
  background: #fff;
  width: 100%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  border: 3px solid #000;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 2px solid #000;
  background: #000;
  color: #fff;
}

.modal-header h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 700;
  letter-spacing: 2px;
}

.close-btn {
  width: 36px;
  height: 36px;
  background: #fff;
  color: #000;
  border: none;
  cursor: pointer;
  font-size: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-body {
  padding: 28px;
}

.detail-section {
  margin-bottom: 32px;
}

.detail-section h3 {
  margin: 0 0 16px 0;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 1.5px;
  padding-bottom: 8px;
  border-bottom: 2px solid #000;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.detail-item .label {
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
  color: #666;
}

.products-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.product-item {
  display: flex;
  justify-content: space-between;
  padding: 16px;
  border: 2px solid #000;
  background: #f9f9f9;
}

.product-name {
  margin: 0 0 4px 0;
  font-weight: 700;
  font-size: 14px;
}

.product-meta {
  margin: 0;
  font-size: 12px;
  color: #666;
  font-weight: 600;
}

.product-price {
  font-size: 16px;
  font-weight: 700;
}

.order-summary {
  background: #f9f9f9;
  border: 2px solid #000;
  padding: 20px;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  font-size: 14px;
}

.summary-row .label {
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
  font-size: 12px;
}

.summary-row .value {
  font-size: 24px;
  font-weight: 700;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 24px;
  padding-top: 24px;
  border-top: 2px solid #ddd;
}

@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    align-items: flex-start;
  }

  .order-actions {
    flex-direction: column;
  }

  .detail-grid {
    grid-template-columns: 1fr;
  }

  .modal-actions {
    flex-direction: column;
  }
}
</style>
