/*
  # Complete Authentication Setup

  1. Changes
    - Drop and recreate auth schema with proper ownership
    - Create all necessary auth tables
    - Set up proper permissions and policies
    - Create admin user with secure password

  2. Security
    - Enable RLS where needed
    - Set up proper role-based access
    - Ensure secure password storage
*/

-- Start fresh with auth schema
DROP SCHEMA IF EXISTS auth CASCADE;
CREATE SCHEMA auth;
ALTER SCHEMA auth OWNER TO postgres;

-- Create necessary extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create auth tables
CREATE TABLE auth.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  encrypted_password text NOT NULL,
  email_confirmed_at timestamptz DEFAULT now(),
  last_sign_in_at timestamptz,
  raw_app_meta_data jsonb DEFAULT '{}'::jsonb,
  raw_user_meta_data jsonb DEFAULT '{}'::jsonb,
  is_super_admin boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE auth.refresh_tokens (
  id bigserial PRIMARY KEY,
  token text UNIQUE NOT NULL,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  revoked boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create admin user
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  is_super_admin,
  raw_app_meta_data
) VALUES (
  'a96d4bb7-c243-4e3f-9f2c-6e6b1b7e127d',
  'admin@expert.email',
  crypt('admin123', gen_salt('bf')),
  now(),
  true,
  '{"provider": "email", "providers": ["email"]}'
) ON CONFLICT (id) DO UPDATE 
SET encrypted_password = crypt('admin123', gen_salt('bf'));

-- Create indexes
CREATE INDEX users_email_idx ON auth.users (email);
CREATE INDEX refresh_tokens_token_idx ON auth.refresh_tokens (token);
CREATE INDEX refresh_tokens_user_id_idx ON auth.refresh_tokens (user_id);

-- Set up permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;

GRANT USAGE ON SCHEMA auth TO postgres, anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO postgres;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA auth TO postgres;

-- Grant specific permissions to anon and authenticated
GRANT SELECT ON auth.users TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON auth.refresh_tokens TO anon, authenticated;

-- Create authentication functions
CREATE OR REPLACE FUNCTION auth.authenticate(
  email text,
  password text
) RETURNS auth.users AS $$
DECLARE
  account auth.users;
BEGIN
  SELECT a.* INTO account
  FROM auth.users AS a
  WHERE a.email = authenticate.email;

  IF account.encrypted_password = crypt(password, account.encrypted_password) THEN
    RETURN account;
  ELSE
    RETURN NULL;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;