/*
  # Create heatmap tracking table

  1. New Tables
    - `heatmap_data`
      - `id` (uuid, primary key)
      - `x` (integer, x-coordinate of interaction)
      - `y` (integer, y-coordinate of interaction)
      - `value` (integer, interaction value)
      - `page` (text, page path)
      - `element_type` (text, type of element interacted with)
      - `timestamp` (timestamptz, when interaction occurred)
      - `created_at` (timestamptz, when record was created)

  2. Security
    - Enable RLS on `heatmap_data` table
    - Add policy for authenticated users to read all data
    - Add policy for anonymous users to insert data
*/

CREATE TABLE IF NOT EXISTS heatmap_data (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  x integer NOT NULL,
  y integer NOT NULL,
  value integer NOT NULL DEFAULT 1,
  page text NOT NULL,
  element_type text NOT NULL,
  timestamp timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE heatmap_data ENABLE ROW LEVEL SECURITY;

-- Allow anonymous users to insert data
CREATE POLICY "Anyone can insert heatmap data"
  ON heatmap_data
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Only authenticated users can view heatmap data
CREATE POLICY "Only authenticated users can view heatmap data"
  ON heatmap_data
  FOR SELECT
  TO authenticated
  USING (true);