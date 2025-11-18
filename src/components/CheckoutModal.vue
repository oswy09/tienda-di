<template>
  <div class="modal-overlay" v-if="isOpen" @click="closeModal">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h2>FINALIZAR PEDIDO</h2>
        <button class="close-btn" @click="closeModal">✕</button>
      </div>

      <div class="modal-body">
        <form @submit.prevent="submitOrder">
          <div class="form-group">
            <label for="name">Nombre completo *</label>
            <input
              type="text"
              id="name"
              v-model="formData.name"
              required
              placeholder="Ingresa tu nombre"
            />
            <span class="error" v-if="errors.name">{{ errors.name }}</span>
          </div>

          <div class="form-group">
            <label for="phone">Celular *</label>
            <input
              type="tel"
              id="phone"
              v-model="formData.phone"
              required
              placeholder="3001234567"
              pattern="[0-9]{10}"
            />
            <span class="error" v-if="errors.phone">{{ errors.phone }}</span>
          </div>

          <div class="form-group">
            <label for="email">Correo electrónico (opcional)</label>
            <input
              type="email"
              id="email"
              v-model="formData.email"
              placeholder="correo@ejemplo.com"
            />
          </div>

          <div class="form-group">
            <label>Forma de pago</label>
            <div class="payment-options">
              <label class="radio-option">
                <input
                  type="radio"
                  name="payment"
                  value="1"
                  v-model="formData.installments"
                  checked
                />
                <span>1 cuota</span>
              </label>
              <label class="radio-option">
                <input
                  type="radio"
                  name="payment"
                  value="2"
                  v-model="formData.installments"
                />
                <span>2 cuotas</span>
              </label>
            </div>
          </div>

          <div class="order-summary">
            <h3>RESUMEN DEL PEDIDO</h3>
            <div class="summary-items">
              <div v-for="(item, index) in items" :key="index" class="summary-item">
                <div class="item-info">
                  <span>{{ item.product.name }}</span>
                  <div class="item-attributes">
                    <span class="attribute">Talla: {{ item.selectedSize }}</span>
                    <span v-if="item.selectedColor" class="attribute">
                      <span class="color-dot" :style="{ backgroundColor: item.selectedColor.hex }"></span>
                      {{ item.selectedColor.name }}
                    </span>
                  </div>
                </div>
                <span class="item-price-summary">${{ formatPrice(item.product.price) }}</span>
              </div>
            </div>
            <div class="summary-total">
              <span>TOTAL:</span>
              <span>${{ formatPrice(total) }}</span>
            </div>
            <div v-if="formData.installments === '2'" class="installment-info">
              2 cuotas de ${{ formatPrice(total / 2) }}
            </div>
          </div>

          <button type="submit" class="submit-btn">
            ENVIAR PEDIDO POR WHATSAPP
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue';
import { supabase } from '../lib/supabase';
import type { CartItem } from '../lib/supabase';

const props = defineProps<{
  isOpen: boolean;
  items: CartItem[];
  total: number;
}>();

const emit = defineEmits<{
  close: [];
  orderComplete: [];
}>();

const formData = reactive({
  name: '',
  phone: '',
  email: '',
  installments: '1',
});

const errors = reactive({
  name: '',
  phone: '',
});

const closeModal = () => {
  emit('close');
  resetForm();
};

const resetForm = () => {
  formData.name = '';
  formData.phone = '';
  formData.email = '';
  formData.installments = '1';
  errors.name = '';
  errors.phone = '';
};

const validateForm = (): boolean => {
  errors.name = '';
  errors.phone = '';

  if (!formData.name.trim()) {
    errors.name = 'El nombre es obligatorio';
    return false;
  }

  if (!formData.phone.trim()) {
    errors.phone = 'El celular es obligatorio';
    return false;
  }

  if (!/^[0-9]{10}$/.test(formData.phone)) {
    errors.phone = 'Ingresa un número válido de 10 dígitos';
    return false;
  }

  return true;
};

const submitOrder = async () => {
  if (!validateForm()) return;

  const orderData = {
    customer_name: formData.name,
    customer_phone: formData.phone,
    customer_email: formData.email || null,
    items: props.items.map(item => ({
      product: {
        id: item.product.id,
        name: item.product.name,
        category: item.product.category,
        price: item.product.price,
      },
      selectedSize: item.selectedSize,
      selectedColor: item.selectedColor,
      quantity: item.quantity,
    })),
    total: props.total,
    installments: parseInt(formData.installments),
    status: 'pending',
  };

  const { error } = await supabase
    .from('orders')
    .insert([orderData]);

  if (error) {
    console.error('Error saving order:', error);
    alert('Error al guardar el pedido. Por favor intenta nuevamente.');
    return;
  }

  const message = buildWhatsAppMessage();
  const phoneNumber = '573138227132';
  const whatsappUrl = `https://api.whatsapp.com/send?phone=${phoneNumber}&text=${encodeURIComponent(message)}`;

  window.open(whatsappUrl, '_blank');
  emit('orderComplete');
  closeModal();
};

const buildWhatsAppMessage = (): string => {
  let message = '🛍️ *NUEVO PEDIDO*\n\n';
  message += `👤 *Nombre:* ${formData.name}\n`;
  message += `📱 *Celular:* ${formData.phone}\n`;

  if (formData.email) {
    message += `📧 *Correo:* ${formData.email}\n`;
  }

  message += '\n📦 *PRODUCTOS:*\n';

  props.items.forEach((item, index) => {
    message += `${index + 1}. ${item.product.name}\n`;
    message += `   • Categoría: ${item.product.category}\n`;
    message += `   • Talla: ${item.selectedSize}\n`;
    if (item.selectedColor) {
      message += `   • Color: ${item.selectedColor.name}\n`;
    }
    message += `   • Precio: $${formatPrice(item.product.price)}\n\n`;
  });

  message += `💰 *TOTAL: $${formatPrice(props.total)}*\n`;

  if (formData.installments === '2') {
    message += `💳 *Pago en 2 cuotas de $${formatPrice(props.total / 2)}*\n`;
  } else {
    message += `💳 *Pago en 1 cuota*\n`;
  }

  return message;
};

const formatPrice = (price: number) => {
  return price.toLocaleString('es-CO');
};
</script>

<style scoped>
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
  max-width: 540px;
  max-height: 90vh;
  overflow-y: auto;
  border: 3px solid #000;
  animation: modalSlide 0.3s ease;
}

@keyframes modalSlide {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
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
  font-size: 22px;
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
  font-weight: 300;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: #f0f0f0;
}

.modal-body {
  padding: 28px;
}

.form-group {
  margin-bottom: 24px;
}

.form-group label {
  display: block;
  font-size: 12px;
  font-weight: 700;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.form-group input[type="text"],
.form-group input[type="tel"],
.form-group input[type="email"] {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #000;
  background: #fff;
  font-size: 14px;
  font-family: inherit;
  transition: all 0.2s ease;
}

.form-group input:focus {
  outline: none;
  background: #f9f9f9;
}

.error {
  display: block;
  color: #c00;
  font-size: 12px;
  margin-top: 4px;
  font-weight: 600;
}

.payment-options {
  display: flex;
  gap: 16px;
}

.radio-option {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  border: 2px solid #000;
  cursor: pointer;
  transition: all 0.2s ease;
  background: #fff;
}

.radio-option:hover {
  background: #f5f5f5;
}

.radio-option input[type="radio"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.radio-option span {
  font-weight: 600;
  font-size: 14px;
}

.order-summary {
  margin: 32px 0 24px 0;
  padding: 20px;
  background: #f9f9f9;
  border: 2px solid #000;
}

.order-summary h3 {
  margin: 0 0 16px 0;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 1.5px;
}

.summary-items {
  margin-bottom: 16px;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 12px 0;
  font-size: 13px;
  border-bottom: 1px solid #ddd;
}

.summary-item:last-child {
  border-bottom: none;
}

.item-info {
  flex: 1;
}

.item-attributes {
  display: flex;
  gap: 12px;
  margin-top: 4px;
  font-size: 11px;
  color: #666;
}

.attribute {
  display: flex;
  align-items: center;
  gap: 4px;
}

.color-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  border: 1px solid #000;
  display: inline-block;
}

.item-price-summary {
  font-weight: 700;
  white-space: nowrap;
}

.summary-total {
  display: flex;
  justify-content: space-between;
  padding-top: 16px;
  border-top: 2px solid #000;
  font-size: 18px;
  font-weight: 700;
  margin-top: 16px;
}

.installment-info {
  text-align: center;
  margin-top: 12px;
  font-size: 13px;
  font-weight: 600;
  color: #666;
}

.submit-btn {
  width: 100%;
  padding: 16px;
  background: #000;
  color: #fff;
  border: 2px solid #000;
  cursor: pointer;
  font-weight: 700;
  font-size: 14px;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  transition: all 0.3s ease;
  font-family: inherit;
}

.submit-btn:hover {
  background: #fff;
  color: #000;
}

@media (max-width: 480px) {
  .modal-content {
    max-height: 100vh;
    border: none;
  }

  .modal-body {
    padding: 20px;
  }

  .payment-options {
    flex-direction: column;
  }
}
</style>
