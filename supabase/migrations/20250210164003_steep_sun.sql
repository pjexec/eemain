/*
  # Fix Sequence Permissions

  1. Changes
    - Remove invalid sequence grants
    - Add proper table permissions
    - Ensure schema access
  
  2. Security
    - Maintain existing RLS policies
    - Grant appropriate table-level permissions
*/

-- Grant necessary permissions
GRANT ALL ON public.heatmap_data TO anon;
GRANT ALL ON public.heatmap_data TO authenticated;

-- Ensure schema access
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;

-- Grant access to views
GRANT SELECT ON public.heatmap_daily_aggregates TO authenticated;
GRANT SELECT ON public.heatmap_hourly_aggregates TO authenticated;

-- Grant function access
GRANT EXECUTE ON FUNCTION public.get_heatmap_stats TO authenticated;