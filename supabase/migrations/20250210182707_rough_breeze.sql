/*
  # Fix auth schema permissions

  1. Changes
    - Grant proper ownership and permissions for auth schema
    - Ensure proper role access for authentication
    - Fix schema access issues

  2. Security
    - Grant necessary permissions to service_role
    - Enable proper access for auth functions
*/

-- Ensure service_role has proper access
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA auth TO service_role;

-- Grant specific permissions to postgres role
GRANT ALL ON SCHEMA auth TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO postgres;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA auth TO postgres;

-- Ensure anon and authenticated roles have necessary access
GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;

-- Grant access to auth schema objects
ALTER DEFAULT PRIVILEGES IN SCHEMA auth 
GRANT ALL ON TABLES TO postgres, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA auth 
GRANT ALL ON SEQUENCES TO postgres, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA auth 
GRANT ALL ON FUNCTIONS TO postgres, service_role;

-- Ensure proper ownership
ALTER SCHEMA auth OWNER TO supabase_admin;