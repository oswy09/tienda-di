<template>
  <div class="product-card" :class="{ 'selected': isSelected }">
    <div class="product-image">
      <img :src="displayImage" :alt="product.name" />
      <div class="product-badge" :style="{ backgroundColor: getCategoryColor(product.category) }">{{ product.category }}</div>
    </div>

    <div class="product-info">
      <h3 class="product-name">{{ product.name }}</h3>
      <p class="product-description">{{ product.description }}</p>
      <div class="product-price">${{ formatPrice(product.price) }}</div>

      <div class="size-selector" v-if="product.size_type === 'tallas_disponibles'">
        <label>Talla:</label>
        <div class="size-options">
          <button
            v-for="size in product.available_sizes"
            :key="size"
            class="size-btn"
            :class="{ 'active': selectedSize === size }"
            @click="selectSize(size)"
          >
            {{ size }}
          </button>
        </div>
      </div>

      <div class="size-info" v-else>
        <span class="size-unique">TALLA ÚNICA</span>
      </div>

      <div class="color-selector" v-if="product.available_colors && product.available_colors.length > 0">
        <label>Color:</label>
        <div class="color-options">
          <button
            v-for="(color, index) in product.available_colors"
            :key="index"
            class="color-btn"
            :class="{ 'active': selectedColor?.name === color.name }"
            :style="{ backgroundColor: color.hex }"
            @click="selectColor(color)"
            :title="color.name"
          >
            <span v-if="selectedColor?.name === color.name" class="check-mark">✓</span>
          </button>
        </div>
        <div class="selected-color-name" v-if="selectedColor">
          {{ selectedColor.name }}
        </div>
      </div>

      <button
        class="add-btn"
        @click="addToCart"
        :disabled="(product.size_type === 'tallas_disponibles' && !selectedSize) || (product.available_colors && product.available_colors.length > 0 && !selectedColor)"
      >
        {{ isSelected ? 'AGREGADO' : 'AGREGAR' }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import type { Product, ProductColor } from '../lib/supabase';

const props = defineProps<{
  product: Product;
  isSelected: boolean;
}>();

const emit = defineEmits<{
  addToCart: [product: Product, size: string, color: ProductColor | null];
}>();

const selectedSize = ref<string>('');
const selectedColor = ref<ProductColor | null>(null);

const displayImage = computed(() => {
  if (selectedColor.value && selectedColor.value.image_url) {
    return selectedColor.value.image_url;
  }
  return props.product.image_url;
});

const selectSize = (size: string) => {
  selectedSize.value = size;
};

const selectColor = (color: ProductColor) => {
  selectedColor.value = color;
};

const addToCart = () => {
  const size = props.product.size_type === 'talla_unica' ? 'Talla Única' : selectedSize.value;
  if (size && (props.product.available_colors?.length === 0 || selectedColor.value)) {
    emit('addToCart', props.product, size, selectedColor.value);
  }
};

const formatPrice = (price: number) => {
  return price.toLocaleString('es-CO');
};

const getCategoryColor = (category: string) => {
  const colors: { [key: string]: string } = {
    'Buso': '#2563eb',
    'Abrigo': '#dc2626',
    'Chaqueta': '#16a34a',
    'Gorra': '#ea580c',
    'Pantalón': '#9333ea',
    'Zapatos': '#0891b2'
  };
  return colors[category] || '#000';
};
</script>

<style scoped>
.product-card {
  background: #fff;
  border: 2px solid #000;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.product-card:hover {
  transform: translateY(-4px);
  box-shadow: 4px 4px 0 #000;
}

.product-card.selected {
  border-color: #000;
  background: #f5f5f5;
}

.product-card.selected::before {
  content: '✓';
  position: absolute;
  top: 10px;
  right: 10px;
  width: 30px;
  height: 30px;
  background: #000;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 18px;
  z-index: 10;
}

.product-image {
  position: relative;
  width: 100%;
  height: 280px;
  overflow: hidden;
  background: #f0f0f0;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.product-card:hover .product-image img {
  transform: scale(1.05);
}

.product-badge {
  position: absolute;
  top: 10px;
  left: 10px;
  color: #fff;
  padding: 4px 12px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1px;
  text-transform: uppercase;
}

.product-info {
  padding: 20px;
}

.product-name {
  font-size: 18px;
  font-weight: 700;
  margin: 0 0 8px 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.product-description {
  font-size: 13px;
  color: #666;
  margin: 0 0 12px 0;
  line-height: 1.4;
}

.product-price {
  font-size: 22px;
  font-weight: 700;
  margin-bottom: 16px;
  letter-spacing: -0.5px;
}

.size-selector {
  margin-bottom: 16px;
}

.size-selector label {
  display: block;
  font-size: 12px;
  font-weight: 700;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.size-options {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.size-btn {
  padding: 8px 16px;
  border: 2px solid #000;
  background: #fff;
  cursor: pointer;
  font-weight: 700;
  font-size: 13px;
  transition: all 0.2s ease;
  text-transform: uppercase;
  font-family: inherit;
}

.size-btn:hover {
  background: #000;
  color: #fff;
}

.size-btn.active {
  background: #000;
  color: #fff;
}

.size-info {
  margin-bottom: 16px;
}

.size-unique {
  display: inline-block;
  font-size: 12px;
  font-weight: 700;
  padding: 6px 12px;
  background: #000;
  color: #fff;
  letter-spacing: 1px;
}

.add-btn {
  width: 100%;
  padding: 14px;
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

.add-btn:hover:not(:disabled) {
  background: #fff;
  color: #000;
}

.add-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.color-selector {
  margin-bottom: 16px;
}

.color-selector label {
  display: block;
  font-size: 12px;
  font-weight: 700;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.color-options {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.color-btn {
  width: 40px;
  height: 40px;
  border: 3px solid #000;
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.color-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.color-btn.active {
  border-width: 4px;
  transform: scale(1.15);
}

.check-mark {
  color: #fff;
  font-size: 20px;
  font-weight: bold;
  text-shadow: 0 0 3px rgba(0, 0, 0, 0.8);
}

.selected-color-name {
  margin-top: 8px;
  font-size: 13px;
  font-weight: 600;
  text-align: center;
  color: #333;
}
</style>
