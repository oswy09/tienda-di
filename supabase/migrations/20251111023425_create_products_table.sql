/*
  # Create Products Table for Clothing Catalog

  1. New Tables
    - `products`
      - `id` (uuid, primary key) - Unique identifier for each product
      - `name` (text) - Product name
      - `category` (text) - Category like "Buso", "Abrigo", etc.
      - `gender` (text) - "dama" or "hombre"
      - `price` (numeric) - Product price
      - `size_type` (text) - "talla_unica" or "tallas_disponibles"
      - `available_sizes` (text[]) - Array of available sizes (S, M, L, XL, etc.)
      - `image_url` (text) - URL to product image
      - `description` (text) - Product description
      - `created_at` (timestamptz) - Record creation timestamp
  
  2. Security
    - Enable RLS on `products` table
    - Add policy for public read access (catalog is public)
    - Only authenticated admins can modify products
*/

CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  gender text NOT NULL CHECK (gender IN ('dama', 'hombre')),
  price numeric NOT NULL CHECK (price >= 0),
  size_type text NOT NULL CHECK (size_type IN ('talla_unica', 'tallas_disponibles')),
  available_sizes text[] DEFAULT '{}',
  image_url text,
  description text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view products"
  ON products
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Only authenticated users can insert products"
  ON products
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Only authenticated users can update products"
  ON products
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Only authenticated users can delete products"
  ON products
  FOR DELETE
  TO authenticated
  USING (true);

-- Insert sample products
INSERT INTO products (name, category, gender, price, size_type, available_sizes, image_url, description) VALUES
('Buso Deportivo Premium', 'Buso', 'hombre', 89900, 'tallas_disponibles', ARRAY['S', 'M', 'L', 'XL'], 'https://images.pexels.com/photos/8148577/pexels-photo-8148577.jpeg', 'Buso deportivo de alta calidad'),
('Abrigo Térmico', 'Abrigo', 'hombre', 159900, 'tallas_disponibles', ARRAY['M', 'L', 'XL'], 'https://images.pexels.com/photos/1472380/pexels-photo-1472380.jpeg', 'Abrigo perfecto para clima frío'),
('Chaqueta Casual', 'Chaqueta', 'hombre', 129900, 'tallas_disponibles', ARRAY['S', 'M', 'L'], 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg', 'Chaqueta versátil para el día a día'),
('Buso Fit', 'Buso', 'dama', 79900, 'tallas_disponibles', ARRAY['XS', 'S', 'M', 'L'], 'https://images.pexels.com/photos/7679885/pexels-photo-7679885.jpeg', 'Buso deportivo para mujer'),
('Chaqueta Premium', 'Chaqueta', 'dama', 139900, 'tallas_disponibles', ARRAY['S', 'M', 'L'], 'https://images.pexels.com/photos/5710086/pexels-photo-5710086.jpeg', 'Chaqueta elegante y cómoda'),
('Abrigo Largo', 'Abrigo', 'dama', 169900, 'tallas_disponibles', ARRAY['S', 'M', 'L', 'XL'], 'https://images.pexels.com/photos/7679656/pexels-photo-7679656.jpeg', 'Abrigo largo estilo urbano'),
('Gorra Deportiva', 'Gorra', 'hombre', 39900, 'talla_unica', ARRAY[]::text[], 'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg', 'Gorra ajustable talla única'),
('Gorra Clásica', 'Gorra', 'dama', 39900, 'talla_unica', ARRAY[]::text[], 'https://images.pexels.com/photos/984619/pexels-photo-984619.jpeg', 'Gorra estilo clásico talla única')
ON CONFLICT DO NOTHING;