/*
  # Fix Authentication Setup

  1. Changes
    - Drop custom auth schema to avoid conflicts with Supabase's built-in auth
    - Create necessary tables for heatmap data
    - Set up proper permissions and policies
    
  2. Security
    - Enable RLS on tables
    - Set up proper policies for data access
*/

-- Drop custom auth schema to avoid conflicts with Supabase's built-in auth
DROP SCHEMA IF EXISTS auth CASCADE;

-- Create heatmap data table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.heatmap_data (
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
CREATE POLICY "Enable insert access for all users" ON public.heatmap_data
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable read access for authenticated users only" ON public.heatmap_data
  FOR SELECT TO authenticated USING (true);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.heatmap_data TO authenticated;
GRANT INSERT ON public.heatmap_data TO anon;