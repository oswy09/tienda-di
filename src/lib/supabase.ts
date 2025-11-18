import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface ProductColor {
  name: string;
  hex: string;
  image_url: string;
}

export interface Product {
  id: string;
  name: string;
  category: string;
  gender: 'dama' | 'hombre';
  price: number;
  size_type: 'talla_unica' | 'tallas_disponibles';
  available_sizes: string[];
  available_colors: ProductColor[];
  image_url: string;
  description: string;
  created_at: string;
}

export interface CartItem {
  product: Product;
  selectedSize: string;
  selectedColor: ProductColor | null;
  quantity: number;
}
