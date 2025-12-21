/*
  # Final Fix for Heatmap RLS Policies

  1. Changes
    - Drop and recreate all RLS policies with simplified structure
    - Grant all necessary permissions explicitly
    - Enable full public access for heatmap data
  
  2. Security
    - Maintain RLS but allow public access for both read and write
    - Ensure proper sequence access for ID generation
*/

-- Disable RLS temporarily to reset policies
ALTER TABLE public.heatmap_data DISABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Allow public access to heatmap data" ON public.heatmap_data;
DROP POLICY IF EXISTS "Enable anonymous inserts for heatmap data" ON public.heatmap_data;
DROP POLICY IF EXISTS "Enable anonymous reads for heatmap data" ON public.heatmap_data;

-- Re-enable RLS
ALTER TABLE public.heatmap_data ENABLE ROW LEVEL SECURITY;

-- Create a single policy for all operations
CREATE POLICY "Allow public access to heatmap data"
  ON public.heatmap_data
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- Grant all necessary permissions
GRANT ALL ON public.heatmap_data TO anon, authenticated;
GRANT ALL ON public.heatmap_data_id_seq TO anon, authenticated;

-- Ensure schema access
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Grant access to all existing sequences
DO $$
BEGIN
  EXECUTE (
    SELECT string_agg(
      format('GRANT USAGE, SELECT ON SEQUENCE %I TO anon, authenticated;', sequence_name),
      E'\n'
    )
    FROM information_schema.sequences
    WHERE sequence_schema = 'public'
  );
END $$;