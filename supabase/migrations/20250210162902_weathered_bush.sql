/*
  # Reset and recreate database schema
  
  1. Changes
    - Drop all existing objects in correct order
    - Recreate tables, views, and functions
    - Set up proper security policies
    
  2. Security
    - Enable RLS on heatmap_data table
    - Create policies for anonymous inserts and authenticated reads
    - Grant appropriate permissions to views and functions
*/

-- Drop existing objects in correct dependency order
DROP VIEW IF EXISTS public.heatmap_daily_aggregates CASCADE;
DROP VIEW IF EXISTS public.heatmap_hourly_aggregates CASCADE;
DROP FUNCTION IF EXISTS public.get_heatmap_stats CASCADE;
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
CREATE POLICY "Anyone can insert heatmap data"
  ON public.heatmap_data
  FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Only authenticated users can view heatmap data"
  ON public.heatmap_data
  FOR SELECT
  TO authenticated
  USING (true);

-- Create views for aggregated data
CREATE VIEW public.heatmap_daily_aggregates AS
SELECT
  date_trunc('day', timestamp) as day,
  page,
  element_type,
  COUNT(*) as interaction_count,
  AVG(x) as avg_x,
  AVG(y) as avg_y,
  SUM(value) as total_value
FROM public.heatmap_data
GROUP BY date_trunc('day', timestamp), page, element_type;

CREATE VIEW public.heatmap_hourly_aggregates AS
SELECT
  date_trunc('hour', timestamp) as hour,
  page,
  element_type,
  COUNT(*) as interaction_count,
  AVG(x) as avg_x,
  AVG(y) as avg_y,
  SUM(value) as total_value
FROM public.heatmap_data
GROUP BY date_trunc('hour', timestamp), page, element_type;

-- Create function for getting heatmap stats
CREATE OR REPLACE FUNCTION public.get_heatmap_stats(
  start_time timestamptz,
  end_time timestamptz
)
RETURNS TABLE (
  page text,
  element_type text,
  total_interactions bigint,
  avg_x numeric,
  avg_y numeric,
  total_value bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    h.page,
    h.element_type,
    COUNT(*)::bigint as total_interactions,
    AVG(h.x)::numeric as avg_x,
    AVG(h.y)::numeric as avg_y,
    SUM(h.value)::bigint as total_value
  FROM public.heatmap_data h
  WHERE h.timestamp BETWEEN start_time AND end_time
  GROUP BY h.page, h.element_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant access to views and functions
GRANT SELECT ON public.heatmap_daily_aggregates TO authenticated;
GRANT SELECT ON public.heatmap_hourly_aggregates TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_heatmap_stats TO authenticated;