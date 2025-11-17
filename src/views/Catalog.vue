<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { supabase } from '../lib/supabase';
import type { Product, CartItem, ProductColor } from '../lib/supabase';
import ProductCard from '../components/ProductCard.vue';
import ShoppingCart from '../components/ShoppingCart.vue';
import CheckoutModal from '../components/CheckoutModal.vue';
import Footer from '../components/Footer.vue';

const products = ref<Product[]>([]);
const selectedGender = ref<'dama' | 'hombre' | 'all'>('all');
const cartItems = ref<CartItem[]>([]);
const isCartOpen = ref(false);
const isCheckoutOpen = ref(false);
const loading = ref(true);

const filteredProducts = computed(() => {
  if (selectedGender.value === 'all') {
    return products.value;
  }
  return products.value.filter(p => p.gender === selectedGender.value);
});

const cartTotal = computed(() => {
  return cartItems.value.reduce((sum, item) => sum + item.product.price, 0);
});

const fetchProducts = async () => {
  loading.value = true;
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching products:', error);
  } else {
    products.value = data || [];
  }
  loading.value = false;
};

const addToCart = (product: Product, size: string, color: ProductColor | null) => {
  const existingIndex = cartItems.value.findIndex(
    item => item.product.id === product.id && item.selectedSize === size && item.selectedColor?.name === color?.name
  );

  if (existingIndex === -1) {
    cartItems.value.push({
      product,
      selectedSize: size,
      selectedColor: color,
      quantity: 1,
    });
  }
};

const removeFromCart = (index: number) => {
  cartItems.value.splice(index, 1);
};

const isProductInCart = (productId: string): boolean => {
  return cartItems.value.some(item => item.product.id === productId);
};

const toggleCart = () => {
  isCartOpen.value = !isCartOpen.value;
};

const openCheckout = () => {
  isCheckoutOpen.value = true;
  isCartOpen.value = false;
};

const closeCheckout = () => {
  isCheckoutOpen.value = false;
};

const handleOrderComplete = () => {
  cartItems.value = [];
};

onMounted(() => {
  fetchProducts();
});
</script>

<template>
  <div class="catalog">
    <header class="header">
      <div class="header-content">
        <h1 class="brand">STYLE STORE</h1>
        <p class="tagline">PREMIUM CLOTHING COLLECTION</p>
        <div class="how-it-works">
          <p>Selecciona los productos que te gustan, agrégalos al carrito y envía tu cotización directamente por WhatsApp. ¡Es rápido y fácil!</p>
        </div>
      </div>
    </header>

    <nav class="gender-nav">
      <button
        :class="['nav-btn', { active: selectedGender === 'all' }]"
        @click="selectedGender = 'all'"
      >
        TODOS
      </button>
      <button
        :class="['nav-btn', { active: selectedGender === 'dama' }]"
        @click="selectedGender = 'dama'"
      >
        DAMA
      </button>
      <button
        :class="['nav-btn', { active: selectedGender === 'hombre' }]"
        @click="selectedGender = 'hombre'"
      >
        HOMBRE
      </button>
    </nav>

    <main class="main-content">
      <div class="container">
        <div v-if="loading" class="loading">
          <div class="loader"></div>
          <p>CARGANDO PRODUCTOS...</p>
        </div>

        <div v-else class="products-grid">
          <ProductCard
            v-for="product in filteredProducts"
            :key="product.id"
            :product="product"
            :isSelected="isProductInCart(product.id)"
            @addToCart="addToCart"
          />
        </div>

        <div v-if="!loading && filteredProducts.length === 0" class="no-products">
          <p>NO HAY PRODUCTOS DISPONIBLES</p>
        </div>
      </div>
    </main>

    <ShoppingCart
      :items="cartItems"
      :isOpen="isCartOpen"
      @toggle="toggleCart"
      @removeItem="removeFromCart"
      @checkout="openCheckout"
    />

    <CheckoutModal
      :isOpen="isCheckoutOpen"
      :items="cartItems"
      :total="cartTotal"
      @close="closeCheckout"
      @orderComplete="handleOrderComplete"
    />

    <Footer />
  </div>
</template>

<style scoped>
.catalog {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.header {
  background: #fff;
  color: #000;
  padding: 40px 20px;
  text-align: center;
  border-bottom: 4px solid #000;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
}

.brand {
  font-size: 48px;
  font-weight: 900;
  letter-spacing: 8px;
  margin-bottom: 8px;
}

.tagline {
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 3px;
  opacity: 0.8;
}

.how-it-works {
  margin-top: 24px;
  padding: 16px 24px;
  background: #f5f5f5;
  border: 2px solid #000;
  max-width: 700px;
  margin-left: auto;
  margin-right: auto;
}

.how-it-works p {
  margin: 0;
  color: #000;
  font-size: 14px;
  line-height: 1.6;
  font-weight: 500;
  letter-spacing: 0.3px;
}

.gender-nav {
  display: flex;
  justify-content: center;
  gap: 0;
  padding: 0;
  background: #fff;
  border-bottom: 3px solid #000;
  position: sticky;
  top: 0;
  z-index: 100;
}

.nav-btn {
  flex: 1;
  max-width: 200px;
  padding: 18px 32px;
  background: #fff;
  color: #000;
  border: none;
  border-right: 2px solid #000;
  cursor: pointer;
  font-weight: 700;
  font-size: 14px;
  letter-spacing: 2px;
  transition: all 0.2s ease;
  font-family: inherit;
}

.nav-btn:last-child {
  border-right: none;
}

.nav-btn:hover {
  background: #f0f0f0;
}

.nav-btn.active {
  background: #000;
  color: #fff;
}

.main-content {
  flex: 1;
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
  border: 4px solid #f0f0f0;
  border-top: 4px solid #000;
  border-radius: 50%;
  margin: 0 auto 20px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading p {
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 2px;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 32px;
}

.no-products {
  text-align: center;
  padding: 80px 20px;
  color: #999;
}

.no-products p {
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 2px;
}

@media (max-width: 768px) {
  .brand {
    font-size: 32px;
    letter-spacing: 4px;
  }

  .tagline {
    font-size: 10px;
    letter-spacing: 2px;
  }

  .products-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
  }

  .nav-btn {
    font-size: 12px;
    padding: 16px 20px;
  }
}

@media (max-width: 480px) {
  .products-grid {
    grid-template-columns: 1fr;
  }

  .brand {
    font-size: 28px;
    letter-spacing: 3px;
  }
}
</style>
