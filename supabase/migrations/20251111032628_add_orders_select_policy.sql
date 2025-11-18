/*
  # Add SELECT policy for orders table

  1. Changes
    - Add policy to allow anyone to read orders (for admin panel)
  
  2. Security
    - Read access for viewing orders in admin panel
*/

-- Allow anyone to read orders
CREATE POLICY "Anyone can read orders"
  ON orders
  FOR SELECT
  USING (true);
