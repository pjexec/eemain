/*
  # Fix Heatmap Tables and Views

  1. Changes
    - Drop existing views and functions if they exist
    - Drop existing heatmap_data table if it exists
    - Recreate heatmap_data table with proper structure
    - Recreate views and functions
    - Set up proper RLS policies
    
  2. Security
    - Enable RLS on heatmap_data table
    - Add policies for anonymous inserts
    - Add policies for authenticated reads
*/

-- Drop existing objects to avoid conflicts
DROP VIEW IF EXISTS heatmap_daily_aggregates;
DROP VIEW IF EXISTS heatmap_hourly_aggregates;
DROP FUNCTION IF EXISTS get_heatmap_stats;
DROP TABLE IF EXISTS heatmap_data;

-- Create heatmap data table
CREATE TABLE heatmap_data (
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
ALTER TABLE heatmap_data ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can insert heatmap data"
  ON heatmap_data
  FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Only authenticated users can view heatmap data"
  ON heatmap_data
  FOR SELECT
  TO authenticated
  USING (true);

-- Create views for aggregated data
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

-- Grant access to views and functions
GRANT SELECT ON heatmap_daily_aggregates TO authenticated;
GRANT SELECT ON heatmap_hourly_aggregates TO authenticated;
GRANT EXECUTE ON FUNCTION get_heatmap_stats TO authenticated;