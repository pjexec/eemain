/*
  # Fix Authentication Setup Using Public Schema

  1. Changes
    - Create authentication tables in public schema
    - Set up proper RLS policies
    - Add necessary grants and permissions
*/

-- Create auth related tables in public schema
CREATE TABLE IF NOT EXISTS public.user_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  created_at timestamptz DEFAULT now(),
  expires_at timestamptz NOT NULL,
  metadata jsonb
);

-- Enable RLS
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can manage their own sessions"
  ON public.user_sessions
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Grant necessary permissions
GRANT ALL ON public.user_sessions TO authenticated;
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Create function to validate session
CREATE OR REPLACE FUNCTION public.validate_session(session_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.user_sessions
    WHERE id = session_id
    AND expires_at > now()
  );
END;
$$;