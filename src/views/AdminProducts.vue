<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { supabase } from '../lib/supabase';
import type { Product, ProductColor } from '../lib/supabase';
import { COLOR_PALETTE, type ColorOption } from '../lib/colors';
import { useRouter } from 'vue-router';

const router = useRouter();
const products = ref<Product[]>([]);
const loading = ref(true);
const isEditing = ref(false);
const editingProduct = ref<Product | null>(null);

const formData = ref({
  name: '',
  category: '',
  gender: 'hombre' as 'dama' | 'hombre',
  price: 0,
  size_type: 'tallas_disponibles' as 'talla_unica' | 'tallas_disponibles',
  available_sizes: [] as string[],
  available_colors: [] as ProductColor[],
  image_url: '',
  description: '',
});

const sizeInput = ref('');
const colorForm = ref({
  name: '',
  hex: '',
  image_url: '',
});
const isColorPickerOpen = ref(false);
const availableColors = COLOR_PALETTE;
const categories = ['Buso', 'Abrigo', 'Chaqueta', 'Gorra', 'Pantalón', 'Zapatos'];

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

const openEditForm = (product?: Product) => {
  if (product) {
    editingProduct.value = product;
    formData.value = {
      name: product.name,
      category: product.category,
      gender: product.gender,
      price: product.price,
      size_type: product.size_type,
      available_sizes: [...product.available_sizes],
      available_colors: product.available_colors ? JSON.parse(JSON.stringify(product.available_colors)) : [],
      image_url: product.image_url || '',
      description: product.description || '',
    };
  } else {
    editingProduct.value = null;
    formData.value = {
      name: '',
      category: categories[0],
      gender: 'hombre',
      price: 0,
      size_type: 'tallas_disponibles',
      available_sizes: [],
      available_colors: [],
      image_url: '',
      description: '',
    };
  }
  isEditing.value = true;
};

const closeForm = () => {
  isEditing.value = false;
  editingProduct.value = null;
};

const addSize = () => {
  if (sizeInput.value.trim() && !formData.value.available_sizes.includes(sizeInput.value.trim())) {
    formData.value.available_sizes.push(sizeInput.value.trim().toUpperCase());
    sizeInput.value = '';
  }
};

const removeSize = (size: string) => {
  formData.value.available_sizes = formData.value.available_sizes.filter(s => s !== size);
};

const selectColorFromPalette = (color: ColorOption) => {
  colorForm.value.name = color.name;
  colorForm.value.hex = color.hex;
  isColorPickerOpen.value = false;
};

const addColor = () => {
  if (!colorForm.value.name.trim() || !colorForm.value.hex.trim() || !colorForm.value.image_url.trim()) {
    alert('Completa todos los campos del color');
    return;
  }

  if (formData.value.available_colors.length >= 4) {
    alert('Máximo 4 colores permitidos');
    return;
  }

  formData.value.available_colors.push({
    name: colorForm.value.name.trim(),
    hex: colorForm.value.hex.trim(),
    image_url: colorForm.value.image_url.trim(),
  });

  colorForm.value = { name: '', hex: '', image_url: '' };
};

const removeColor = (index: number) => {
  formData.value.available_colors.splice(index, 1);
};

const saveProduct = async () => {
  if (!formData.value.name || !formData.value.category) {
    alert('Por favor completa todos los campos obligatorios');
    return;
  }

  const productData = {
    name: formData.value.name,
    category: formData.value.category,
    gender: formData.value.gender,
    price: formData.value.price,
    size_type: formData.value.size_type,
    available_sizes: formData.value.size_type === 'talla_unica' ? [] : formData.value.available_sizes,
    available_colors: formData.value.available_colors,
    image_url: formData.value.image_url,
    description: formData.value.description,
  };

  if (editingProduct.value) {
    const { error } = await supabase
      .from('products')
      .update(productData)
      .eq('id', editingProduct.value.id);

    if (error) {
      console.error('Error updating product:', error);
      alert('Error al actualizar el producto');
    } else {
      closeForm();
      fetchProducts();
    }
  } else {
    const { error } = await supabase
      .from('products')
      .insert([productData]);

    if (error) {
      console.error('Error creating product:', error);
      alert('Error al crear el producto');
    } else {
      closeForm();
      fetchProducts();
    }
  }
};

const deleteProduct = async (id: string) => {
  if (!confirm('¿Estás seguro de eliminar este producto?')) {
    return;
  }

  const { error } = await supabase
    .from('products')
    .delete()
    .eq('id', id);

  if (error) {
    console.error('Error deleting product:', error);
    alert('Error al eliminar el producto');
  } else {
    fetchProducts();
  }
};

const goToOrders = () => {
  router.push('/admin/orders');
};

const goToCatalog = () => {
  router.push('/');
};

onMounted(() => {
  fetchProducts();
});
</script>

<template>
  <div class="admin-products">
    <header class="admin-header">
      <div class="header-content">
        <h1>ADMINISTRAR PRODUCTOS</h1>
        <div class="header-actions">
          <button class="btn-secondary" @click="goToOrders">Ver Pedidos</button>
          <button class="btn-secondary" @click="goToCatalog">Ver Catálogo</button>
          <button class="btn-primary" @click="openEditForm()">+ Nuevo Producto</button>
        </div>
      </div>
    </header>

    <main class="main-content">
      <div class="container">
        <div v-if="loading" class="loading">
          <div class="loader"></div>
          <p>CARGANDO...</p>
        </div>

        <div v-else class="products-table">
          <table>
            <thead>
              <tr>
                <th>Imagen</th>
                <th>Nombre</th>
                <th>Categoría</th>
                <th>Género</th>
                <th>Precio</th>
                <th>Tallas</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="product in products" :key="product.id">
                <td>
                  <img :src="product.image_url" :alt="product.name" class="product-thumb" />
                </td>
                <td class="product-name">{{ product.name }}</td>
                <td>{{ product.category }}</td>
                <td>{{ product.gender === 'dama' ? 'Dama' : 'Hombre' }}</td>
                <td class="price">${{ product.price.toLocaleString('es-CO') }}</td>
                <td>
                  <span v-if="product.size_type === 'talla_unica'">Talla Única</span>
                  <span v-else>{{ product.available_sizes.join(', ') }}</span>
                </td>
                <td class="actions">
                  <button class="btn-edit" @click="openEditForm(product)">Editar</button>
                  <button class="btn-delete" @click="deleteProduct(product.id)">Eliminar</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </main>

    <div v-if="isEditing" class="modal-overlay" @click="closeForm">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ editingProduct ? 'EDITAR PRODUCTO' : 'NUEVO PRODUCTO' }}</h2>
          <button class="close-btn" @click="closeForm">✕</button>
        </div>

        <div class="modal-body">
          <form @submit.prevent="saveProduct">
            <div class="form-row">
              <div class="form-group">
                <label>Nombre *</label>
                <input type="text" v-model="formData.name" required />
              </div>

              <div class="form-group">
                <label>Categoría *</label>
                <select v-model="formData.category" required>
                  <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Género *</label>
                <select v-model="formData.gender" required>
                  <option value="hombre">Hombre</option>
                  <option value="dama">Dama</option>
                </select>
              </div>

              <div class="form-group">
                <label>Precio *</label>
                <input type="number" v-model.number="formData.price" required min="0" step="100" />
              </div>
            </div>

            <div class="form-group">
              <label>Tipo de talla *</label>
              <select v-model="formData.size_type" required>
                <option value="tallas_disponibles">Tallas disponibles</option>
                <option value="talla_unica">Talla única</option>
              </select>
            </div>

            <div v-if="formData.size_type === 'tallas_disponibles'" class="form-group">
              <label>Tallas disponibles</label>
              <div class="size-input">
                <input
                  type="text"
                  v-model="sizeInput"
                  placeholder="Ej: S, M, L, XL"
                  @keyup.enter="addSize"
                />
                <button type="button" class="btn-add-size" @click="addSize">Agregar</button>
              </div>
              <div class="size-tags">
                <span v-for="size in formData.available_sizes" :key="size" class="size-tag">
                  {{ size }}
                  <button type="button" @click="removeSize(size)">✕</button>
                </span>
              </div>
            </div>

            <div class="form-group">
              <label>Colores disponibles (2-4 colores)</label>

              <div class="color-selection-section">
                <button
                  type="button"
                  class="btn-open-palette"
                  @click="isColorPickerOpen = !isColorPickerOpen"
                >
                  {{ isColorPickerOpen ? 'Cerrar paleta' : 'Seleccionar color' }}
                </button>

                <div v-if="isColorPickerOpen" class="color-palette">
                  <button
                    v-for="(color, index) in availableColors"
                    :key="index"
                    type="button"
                    class="palette-color-btn"
                    :style="{ backgroundColor: color.hex }"
                    @click="selectColorFromPalette(color)"
                    :title="color.name"
                  >
                    <span class="palette-color-name">{{ color.name }}</span>
                  </button>
                </div>

                <div class="color-form" v-if="colorForm.name">
                  <div class="selected-color-display">
                    <span class="color-preview-circle" :style="{ backgroundColor: colorForm.hex }"></span>
                    <span class="selected-color-text">{{ colorForm.name }}</span>
                  </div>
                  <input
                    type="url"
                    v-model="colorForm.image_url"
                    placeholder="URL imagen del producto en este color"
                    class="color-image-input"
                  />
                  <button type="button" class="btn-add-color" @click="addColor">Agregar</button>
                </div>
              </div>

              <div class="color-tags">
                <span v-for="(color, index) in formData.available_colors" :key="index" class="color-tag">
                  <span class="color-circle" :style="{ backgroundColor: color.hex }"></span>
                  <span class="color-name">{{ color.name }}</span>
                  <button type="button" @click="removeColor(index)">✕</button>
                </span>
              </div>
            </div>

            <div class="form-group">
              <label>URL de imagen</label>
              <input type="url" v-model="formData.image_url" placeholder="https://..." />
            </div>

            <div class="form-group">
              <label>Descripción</label>
              <textarea v-model="formData.description" rows="3"></textarea>
            </div>

            <div class="form-actions">
              <button type="button" class="btn-cancel" @click="closeForm">Cancelar</button>
              <button type="submit" class="btn-save">Guardar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-products {
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

.btn-primary,
.btn-secondary {
  padding: 12px 24px;
  border: 2px solid #fff;
  cursor: pointer;
  font-weight: 700;
  font-size: 13px;
  letter-spacing: 1px;
  transition: all 0.2s ease;
  font-family: inherit;
}

.btn-primary {
  background: #fff;
  color: #000;
}

.btn-primary:hover {
  background: #f0f0f0;
}

.btn-secondary {
  background: transparent;
  color: #fff;
}

.btn-secondary:hover {
  background: #fff;
  color: #000;
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

.products-table {
  background: #fff;
  border: 2px solid #000;
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

thead {
  background: #000;
  color: #fff;
}

th {
  padding: 16px;
  text-align: left;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 1px;
  text-transform: uppercase;
}

td {
  padding: 16px;
  border-bottom: 1px solid #ddd;
  font-size: 14px;
}

.product-thumb {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border: 1px solid #ddd;
}

.product-name {
  font-weight: 600;
}

.price {
  font-weight: 700;
}

.actions {
  display: flex;
  gap: 8px;
}

.btn-edit,
.btn-delete {
  padding: 6px 12px;
  border: 2px solid #000;
  background: #fff;
  cursor: pointer;
  font-size: 12px;
  font-weight: 700;
  transition: all 0.2s ease;
  font-family: inherit;
}

.btn-edit:hover {
  background: #000;
  color: #fff;
}

.btn-delete {
  border-color: #dc2626;
  color: #dc2626;
}

.btn-delete:hover {
  background: #dc2626;
  color: #fff;
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
  max-width: 700px;
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

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  font-size: 12px;
  font-weight: 700;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #000;
  background: #fff;
  font-size: 14px;
  font-family: inherit;
}

.size-input {
  display: flex;
  gap: 8px;
}

.size-input input {
  flex: 1;
}

.btn-add-size {
  padding: 12px 20px;
  background: #000;
  color: #fff;
  border: 2px solid #000;
  cursor: pointer;
  font-weight: 700;
  font-size: 12px;
  font-family: inherit;
}

.size-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}

.size-tag {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  background: #000;
  color: #fff;
  font-size: 12px;
  font-weight: 700;
}

.size-tag button {
  background: none;
  border: none;
  color: #fff;
  cursor: pointer;
  font-size: 16px;
  padding: 0;
  line-height: 1;
}

.color-selection-section {
  margin-bottom: 16px;
}

.btn-open-palette {
  padding: 12px 24px;
  background: #000;
  color: #fff;
  border: 2px solid #000;
  cursor: pointer;
  font-weight: 700;
  font-size: 13px;
  font-family: inherit;
  margin-bottom: 16px;
  transition: all 0.2s ease;
}

.btn-open-palette:hover {
  background: #333;
}

.color-palette {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
  gap: 12px;
  padding: 16px;
  background: #f9f9f9;
  border: 2px solid #000;
  margin-bottom: 16px;
}

.palette-color-btn {
  aspect-ratio: 1;
  border: 3px solid #000;
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
  overflow: hidden;
  min-height: 60px;
}

.palette-color-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.palette-color-name {
  position: absolute;
  bottom: -30px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 11px;
  font-weight: 600;
  background: #000;
  color: #fff;
  padding: 4px 8px;
  white-space: nowrap;
  opacity: 0;
  transition: all 0.2s ease;
  pointer-events: none;
  z-index: 10;
}

.palette-color-btn:hover .palette-color-name {
  opacity: 1;
  bottom: -25px;
}

.color-form {
  display: grid;
  grid-template-columns: auto 1fr auto;
  gap: 12px;
  align-items: center;
  padding: 16px;
  background: #f9f9f9;
  border: 2px solid #000;
}

.selected-color-display {
  display: flex;
  align-items: center;
  gap: 10px;
}

.color-preview-circle {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 3px solid #000;
}

.selected-color-text {
  font-weight: 700;
  font-size: 14px;
}

.color-image-input {
  padding: 10px 12px;
  border: 2px solid #000;
  font-size: 13px;
  font-family: inherit;
}

.btn-add-color {
  padding: 10px 20px;
  background: #000;
  color: #fff;
  border: 2px solid #000;
  cursor: pointer;
  font-weight: 700;
  font-size: 13px;
  font-family: inherit;
  white-space: nowrap;
  transition: all 0.2s ease;
}

.btn-add-color:hover {
  background: #333;
}

.color-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}

.color-tag {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  background: #f5f5f5;
  border: 2px solid #000;
  color: #000;
  font-size: 12px;
  font-weight: 700;
}

.color-circle {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: 2px solid #000;
}

.color-name {
  font-weight: 600;
}

.color-tag button {
  background: none;
  border: none;
  color: #000;
  cursor: pointer;
  font-size: 16px;
  padding: 0;
  line-height: 1;
  margin-left: 4px;
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 28px;
}

.btn-cancel,
.btn-save {
  padding: 14px 28px;
  border: 2px solid #000;
  cursor: pointer;
  font-weight: 700;
  font-size: 13px;
  letter-spacing: 1px;
  font-family: inherit;
  transition: all 0.2s ease;
}

.btn-cancel {
  background: #fff;
  color: #000;
}

.btn-cancel:hover {
  background: #f0f0f0;
}

.btn-save {
  background: #000;
  color: #fff;
}

.btn-save:hover {
  background: #333;
}

@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    align-items: flex-start;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .actions {
    flex-direction: column;
  }
}
</style>
