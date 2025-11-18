/*
  # Update Colors Structure in Products Table

  1. Changes
    - Change `available_colors` from array of hex strings to array of JSONB objects
    - Each color object will contain:
      - `name` (text) - Color name like "Negro", "Blanco", "Azul"
      - `hex` (text) - Hex code for display
      - `image_url` (text) - URL to product image in that color
  
  2. Migration Steps
    - Drop old column
    - Add new column with JSONB array type
    - Update sample products with new structure
*/

-- Drop old column and add new one with JSONB structure
ALTER TABLE products DROP COLUMN IF EXISTS available_colors;
ALTER TABLE products ADD COLUMN available_colors JSONB DEFAULT '[]'::jsonb;

-- Update sample products with new color structure
UPDATE products SET available_colors = '[
  {"name": "Negro", "hex": "#000000", "image_url": "https://images.pexels.com/photos/8148577/pexels-photo-8148577.jpeg"},
  {"name": "Gris Oscuro", "hex": "#1a1a1a", "image_url": "https://images.pexels.com/photos/8148577/pexels-photo-8148577.jpeg"},
  {"name": "Gris", "hex": "#2d2d2d", "image_url": "https://images.pexels.com/photos/8148577/pexels-photo-8148577.jpeg"}
]'::jsonb WHERE name = 'Buso Deportivo Premium';

UPDATE products SET available_colors = '[
  {"name": "Negro", "hex": "#1a1a1a", "image_url": "https://images.pexels.com/photos/1472380/pexels-photo-1472380.jpeg"},
  {"name": "Gris", "hex": "#4a4a4a", "image_url": "https://images.pexels.com/photos/1472380/pexels-photo-1472380.jpeg"}
]'::jsonb WHERE name = 'Abrigo Térmico';

UPDATE products SET available_colors = '[
  {"name": "Azul", "hex": "#2c3e50", "image_url": "https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg"},
  {"name": "Negro", "hex": "#000000", "image_url": "https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg"},
  {"name": "Café", "hex": "#5d4e37", "image_url": "https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg"}
]'::jsonb WHERE name = 'Chaqueta Casual';

UPDATE products SET available_colors = '[
  {"name": "Rosa", "hex": "#ffc0cb", "image_url": "https://images.pexels.com/photos/7679885/pexels-photo-7679885.jpeg"},
  {"name": "Blanco", "hex": "#ffffff", "image_url": "https://images.pexels.com/photos/7679885/pexels-photo-7679885.jpeg"},
  {"name": "Lavanda", "hex": "#e6e6fa", "image_url": "https://images.pexels.com/photos/7679885/pexels-photo-7679885.jpeg"}
]'::jsonb WHERE name = 'Buso Fit';

UPDATE products SET available_colors = '[
  {"name": "Negro", "hex": "#000000", "image_url": "https://images.pexels.com/photos/5710086/pexels-photo-5710086.jpeg"},
  {"name": "Café", "hex": "#8b4513", "image_url": "https://images.pexels.com/photos/5710086/pexels-photo-5710086.jpeg"},
  {"name": "Azul", "hex": "#2c3e50", "image_url": "https://images.pexels.com/photos/5710086/pexels-photo-5710086.jpeg"}
]'::jsonb WHERE name = 'Chaqueta Premium';

UPDATE products SET available_colors = '[
  {"name": "Café", "hex": "#8b4513", "image_url": "https://images.pexels.com/photos/7679656/pexels-photo-7679656.jpeg"},
  {"name": "Negro", "hex": "#000000", "image_url": "https://images.pexels.com/photos/7679656/pexels-photo-7679656.jpeg"},
  {"name": "Gris", "hex": "#696969", "image_url": "https://images.pexels.com/photos/7679656/pexels-photo-7679656.jpeg"}
]'::jsonb WHERE name = 'Abrigo Largo';

UPDATE products SET available_colors = '[
  {"name": "Negro", "hex": "#000000", "image_url": "https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg"},
  {"name": "Blanco", "hex": "#ffffff", "image_url": "https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg"}
]'::jsonb WHERE name = 'Gorra Deportiva';

UPDATE products SET available_colors = '[
  {"name": "Rosa", "hex": "#ffc0cb", "image_url": "https://images.pexels.com/photos/984619/pexels-photo-984619.jpeg"},
  {"name": "Blanco", "hex": "#ffffff", "image_url": "https://images.pexels.com/photos/984619/pexels-photo-984619.jpeg"}
]'::jsonb WHERE name = 'Gorra Clásica';
