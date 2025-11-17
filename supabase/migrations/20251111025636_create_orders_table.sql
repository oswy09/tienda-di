/*
  # Create Orders Table for Tracking Customer Requests

  1. New Tables
    - `orders`
      - `id` (uuid, primary key) - Unique identifier for each order
      - `customer_name` (text) - Customer's full name
      - `customer_phone` (text) - Customer's phone number
      - `customer_email` (text, nullable) - Customer's email (optional)
      - `items` (jsonb) - Array of ordered products with details
      - `total` (numeric) - Total order amount
      - `installments` (integer) - Payment plan (1 or 2 cuotas)
      - `status` (text) - Order status (pending, completed, cancelled)
      - `created_at` (timestamptz) - Order creation timestamp
  
  2. Security
    - Enable RLS on `orders` table
    - Public can insert orders (when placing order)
    - Only authenticated users can view all orders (admin dashboard)
*/

CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name text NOT NULL,
  customer_phone text NOT NULL,
  customer_email text,
  items jsonb NOT NULL,
  total numeric NOT NULL CHECK (total >= 0),
  installments integer NOT NULL DEFAULT 1 CHECK (installments IN (1, 2)),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can insert orders"
  ON orders
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Only authenticated users can view orders"
  ON orders
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only authenticated users can update orders"
  ON orders
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Only authenticated users can delete orders"
  ON orders
  FOR DELETE
  TO authenticated
  USING (true);