/*
  # Create missing views and functions
  
  1. Changes
    - Create views and functions IF NOT EXISTS
    - Grant proper permissions
    
  2. Security
    - Grant appropriate access to authenticated users
*/

-- Create views for aggregated data if they don't exist
CREATE VIEW IF NOT EXISTS heatmap_daily_aggregates AS
SELECT
  date_trunc('day', timestamp) as day,
  page,
  element_type,
  COUNT(*) as interaction_count,
  AVG(x) as avg_x,
  AVG(y) as avg_y,
  SUM(value) as total_value
FROM heatmap_data
GROUP BY date_trunc('day', timestamp), page, element_type;

CREATE VIEW IF NOT EXISTS heatmap_hourly_aggregates AS
SELECT
  date_trunc('hour', timestamp) as hour,
  page,
  element_type,
  COUNT(*) as interaction_count,
  AVG(x) as avg_x,
  AVG(y) as avg_y,
  SUM(value) as total_value
FROM heatmap_data
GROUP BY date_trunc('hour', timestamp), page, element_type;

-- Create function if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_heatmap_stats') THEN
    CREATE FUNCTION get_heatmap_stats(
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
    ) AS $func$
    BEGIN
      RETURN QUERY
      SELECT
        h.page,
        h.element_type,
        COUNT(*)::bigint as total_interactions,
        AVG(h.x)::numeric as avg_x,
        AVG(h.y)::numeric as avg_y,
        SUM(h.value)::bigint as total_value
      FROM heatmap_data h
      WHERE h.timestamp BETWEEN start_time AND end_time
      GROUP BY h.page, h.element_type;
    END;
    $func$ LANGUAGE plpgsql SECURITY DEFINER;
  END IF;
END $$;

-- Grant access to views and functions
GRANT SELECT ON heatmap_daily_aggregates TO authenticated;
GRANT SELECT ON heatmap_hourly_aggregates TO authenticated;
GRANT EXECUTE ON FUNCTION get_heatmap_stats TO authenticated;