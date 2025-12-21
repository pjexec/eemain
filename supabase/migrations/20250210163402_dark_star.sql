/*
  # Fix heatmap views and functions

  1. Changes
    - Drop existing views and functions in correct order
    - Recreate views and functions with proper schema
    - Ensure proper access grants
  
  2. Security
    - Maintain existing RLS policies
    - Grant appropriate access to authenticated users
*/

-- Drop existing objects in correct dependency order
DROP VIEW IF EXISTS public.heatmap_daily_aggregates CASCADE;
DROP VIEW IF EXISTS public.heatmap_hourly_aggregates CASCADE;
DROP FUNCTION IF EXISTS public.get_heatmap_stats CASCADE;

-- Recreate views for aggregated data
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

-- Recreate function for getting heatmap stats
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