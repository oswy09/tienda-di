<template>
  <div class="cart-container" :class="{ 'open': isOpen }">
    <button class="cart-toggle" @click="toggleCart">
      <span class="cart-icon">🛒</span>
      <span class="cart-count" v-if="totalItems > 0">{{ totalItems }}</span>
    </button>

    <div class="cart-panel" v-if="isOpen">
      <div class="cart-header">
        <h2>CARRITO</h2>
        <button class="close-btn" @click="toggleCart">✕</button>
      </div>

      <div class="cart-content">
        <div v-if="items.length === 0" class="empty-cart">
          <p>TU CARRITO ESTÁ VACÍO</p>
        </div>

        <div v-else class="cart-items">
          <div v-for="(item, index) in items" :key="index" class="cart-item">
            <img :src="item.product.image_url" :alt="item.product.name" class="item-image" />
            <div class="item-details">
              <h4>{{ item.product.name }}</h4>
              <p class="item-size">Talla: {{ item.selectedSize }}</p>
              <div class="item-color" v-if="item.selectedColor">
                <span class="color-label">Color:</span>
                <span class="color-preview" :style="{ backgroundColor: item.selectedColor.hex }"></span>
                <span class="color-name">{{ item.selectedColor.name }}</span>
              </div>
              <p class="item-price">${{ formatPrice(item.product.price) }}</p>
            </div>
            <button class="remove-btn" @click="removeItem(index)">✕</button>
          </div>
        </div>
      </div>

      <div class="cart-footer" v-if="items.length > 0">
        <div class="total-section">
          <span class="total-label">TOTAL:</span>
          <span class="total-price">${{ formatPrice(total) }}</span>
        </div>
        <button class="checkout-btn" @click="$emit('checkout')">
          HACER PEDIDO POR WHATSAPP
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import type { CartItem } from '../lib/supabase';

const props = defineProps<{
  items: CartItem[];
  isOpen: boolean;
}>();

const emit = defineEmits<{
  toggle: [];
  removeItem: [index: number];
  checkout: [];
}>();

const toggleCart = () => {
  emit('toggle');
};

const removeItem = (index: number) => {
  emit('removeItem', index);
};

const totalItems = computed(() => props.items.length);

const total = computed(() => {
  return props.items.reduce((sum, item) => sum + item.product.price, 0);
});

const formatPrice = (price: number) => {
  return price.toLocaleString('es-CO');
};
</script>

<style scoped>
.cart-container {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 1000;
}

.cart-toggle {
  position: relative;
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(118, 75, 162, 0.4);
}

.cart-toggle:hover {
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
  transform: scale(1.05);
  box-shadow: 0 6px 20px rgba(118, 75, 162, 0.6);
}

.cart-icon {
  font-size: 24px;
}

.cart-count {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #fff;
  color: #764ba2;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  border: 2px solid #764ba2;
}

.cart-panel {
  position: fixed;
  top: 0;
  right: 0;
  width: 400px;
  height: 100vh;
  background: #fff;
  border-left: 2px solid #000;
  display: flex;
  flex-direction: column;
  animation: slideIn 0.3s ease;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
  }
  to {
    transform: translateX(0);
  }
}

.cart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 2px solid #000;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
}

.cart-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 700;
  letter-spacing: 2px;
}

.close-btn {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.2);
  border: 2px solid #fff;
  color: #fff;
  cursor: pointer;
  font-size: 24px;
  font-weight: 300;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: #fff;
  color: #764ba2;
}

.cart-content {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

.empty-cart {
  text-align: center;
  padding: 60px 20px;
  color: #999;
}

.empty-cart p {
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 1px;
}

.cart-items {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.cart-item {
  display: flex;
  gap: 12px;
  padding: 16px;
  border: 2px solid #000;
  position: relative;
  background: #fff;
}

.item-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border: 1px solid #ddd;
}

.item-details {
  flex: 1;
}

.item-details h4 {
  margin: 0 0 6px 0;
  font-size: 14px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.item-size {
  margin: 0 0 8px 0;
  font-size: 12px;
  color: #666;
  font-weight: 600;
}

.item-color {
  display: flex;
  align-items: center;
  gap: 6px;
  margin: 0 0 8px 0;
  font-size: 12px;
}

.color-label {
  font-weight: 600;
  color: #666;
}

.color-preview {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  border: 2px solid #000;
}

.color-name {
  font-size: 12px;
  color: #333;
  font-weight: 600;
}

.item-price {
  margin: 0;
  font-size: 16px;
  font-weight: 700;
}

.remove-btn {
  position: absolute;
  top: 8px;
  right: 8px;
  width: 28px;
  height: 28px;
  background: #fff;
  border: 2px solid #000;
  cursor: pointer;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.remove-btn:hover {
  background: #000;
  color: #fff;
}

.cart-footer {
  border-top: 2px solid #000;
  padding: 24px;
}

.total-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.total-label {
  font-size: 18px;
  font-weight: 700;
  letter-spacing: 2px;
}

.total-price {
  font-size: 28px;
  font-weight: 700;
  letter-spacing: -0.5px;
}

.checkout-btn {
  width: 100%;
  padding: 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  border: none;
  cursor: pointer;
  font-weight: 700;
  font-size: 13px;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  transition: all 0.3s ease;
  font-family: inherit;
  box-shadow: 0 4px 15px rgba(118, 75, 162, 0.4);
}

.checkout-btn:hover {
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(118, 75, 162, 0.6);
}

@media (max-width: 480px) {
  .cart-panel {
    width: 100%;
  }
}
</style>
