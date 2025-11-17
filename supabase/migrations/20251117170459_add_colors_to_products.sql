/*
  # Add Colors to Products Table

  1. Changes
    - Add `available_colors` column to `products` table
      - Array of color hex codes (e.g., ['#000000', '#FFFFFF', '#FF0000'])
      - Defaults to empty array
      - Allows 2-4 colors per product
  
  2. Notes
    - Colors are stored as hex codes for easy rendering
    - Frontend will display colors as circular color pickers
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'products' AND column_name = 'available_colors'
  ) THEN
    ALTER TABLE products ADD COLUMN available_colors text[] DEFAULT '{}';
  END IF;
END $$;

-- Update sample products with colors
UPDATE products SET available_colors = ARRAY['#000000', '#1a1a1a', '#2d2d2d'] WHERE name = 'Buso Deportivo Premium';
UPDATE products SET available_colors = ARRAY['#1a1a1a', '#4a4a4a'] WHERE name = 'Abrigo Térmico';
UPDATE products SET available_colors = ARRAY['#2c3e50', '#000000', '#5d4e37'] WHERE name = 'Chaqueta Casual';
UPDATE products SET available_colors = ARRAY['#ffc0cb', '#ffffff', '#e6e6fa'] WHERE name = 'Buso Fit';
UPDATE products SET available_colors = ARRAY['#000000', '#8b4513', '#2c3e50'] WHERE name = 'Chaqueta Premium';
UPDATE products SET available_colors = ARRAY['#8b4513', '#000000', '#696969'] WHERE name = 'Abrigo Largo';
UPDATE products SET available_colors = ARRAY['#000000', '#ffffff', '#1a1a1a'] WHERE name = 'Gorra Deportiva';
UPDATE products SET available_colors = ARRAY['#ffc0cb', '#ffffff'] WHERE name = 'Gorra Clásica';
