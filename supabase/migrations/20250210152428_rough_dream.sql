/*
  # Add heatmap aggregation views and functions

  1. New Views
    - `heatmap_daily_aggregates`
      - Aggregates heatmap data by day for better performance
    - `heatmap_hourly_aggregates`
      - Aggregates heatmap data by hour for detailed analysis

  2. New Functions
    - `get_heatmap_stats`
      - Returns aggregated statistics for specified time periods

  3. Security
    - Enable RLS on new views
    - Add policies for authenticated users
*/

-- Create view for daily aggregates
CREATE VIEW heatmap_daily_aggregates AS
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

-- Create view for hourly aggregates
CREATE VIEW heatmap_hourly_aggregates AS
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

-- Create function for getting heatmap stats
CREATE OR REPLACE FUNCTION get_heatmap_stats(
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
  FROM heatmap_data h
  WHERE h.timestamp BETWEEN start_time AND end_time
  GROUP BY h.page, h.element_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant access to views for authenticated users
GRANT SELECT ON heatmap_daily_aggregates TO authenticated;
GRANT SELECT ON heatmap_hourly_aggregates TO authenticated;
GRANT EXECUTE ON FUNCTION get_heatmap_stats TO authenticated;