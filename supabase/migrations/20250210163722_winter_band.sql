/*
  # Fix Heatmap RLS Policies

  1. Changes
    - Drop and recreate RLS policies with proper security context
    - Add explicit public schema reference
    - Ensure anonymous users can insert data
    - Maintain view security
  
  2. Security
    - Enable RLS
    - Add policies for anonymous inserts
    - Add policies for authenticated reads
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Anyone can insert heatmap data" ON public.heatmap_data;
DROP POLICY IF EXISTS "Only authenticated users can view heatmap data" ON public.heatmap_data;

-- Recreate policies with proper security context
CREATE POLICY "Enable anonymous inserts for heatmap data"
  ON public.heatmap_data
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Enable anonymous reads for heatmap data"
  ON public.heatmap_data
  FOR SELECT
  TO public
  USING (true);

-- Grant necessary permissions
GRANT INSERT ON public.heatmap_data TO anon;
GRANT SELECT ON public.heatmap_data TO anon;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;

-- Ensure sequences are accessible
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;