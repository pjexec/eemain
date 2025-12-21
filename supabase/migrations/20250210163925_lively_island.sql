/*
  # Fix Heatmap Permissions

  1. Changes
    - Remove invalid sequence grants
    - Simplify permissions structure
    - Ensure proper access for both anonymous and authenticated users
  
  2. Security
    - Maintain RLS with public access
    - Grant appropriate table-level permissions
*/

-- Disable RLS temporarily to reset policies
ALTER TABLE public.heatmap_data DISABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Allow public access to heatmap data" ON public.heatmap_data;

-- Re-enable RLS
ALTER TABLE public.heatmap_data ENABLE ROW LEVEL SECURITY;

-- Create a single policy for all operations
CREATE POLICY "Allow public access to heatmap data"
  ON public.heatmap_data
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- Grant necessary permissions
GRANT ALL ON public.heatmap_data TO anon;
GRANT ALL ON public.heatmap_data TO authenticated;

-- Ensure schema access
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;