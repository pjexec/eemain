/*
  # Fix Authentication Setup
  
  1. Changes
    - Remove all custom auth schema modifications
    - Focus only on application tables
    - Ensure proper RLS policies
    
  2. Security
    - Enable RLS on tables
    - Set up proper policies for data access
*/

-- Remove any existing tables to start fresh
DROP TABLE IF EXISTS public.heatmap_data CASCADE;

-- Create heatmap data table
CREATE TABLE public.heatmap_data (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  x integer NOT NULL,
  y integer NOT NULL,
  value integer NOT NULL DEFAULT 1,
  page text NOT NULL,
  element_type text NOT NULL,
  timestamp timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.heatmap_data ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable insert access for all users"
  ON public.heatmap_data
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Enable read access for authenticated users only"
  ON public.heatmap_data
  FOR SELECT
  TO authenticated
  USING (true);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.heatmap_data TO authenticated;
GRANT INSERT ON public.heatmap_data TO anon;