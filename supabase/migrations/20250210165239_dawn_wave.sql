/*
  # Fix Authentication Schema and Permissions

  1. Changes
    - Create auth schema with proper permissions
    - Set up auth tables with correct structure
    - Create admin user with proper encryption
    - Grant all necessary permissions
*/

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create auth schema
CREATE SCHEMA IF NOT EXISTS auth;

-- Create auth tables
CREATE TABLE IF NOT EXISTS auth.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE,
  encrypted_password text,
  email_confirmed_at timestamptz DEFAULT now(),
  last_sign_in_at timestamptz,
  raw_app_meta_data jsonb DEFAULT '{}'::jsonb,
  raw_user_meta_data jsonb DEFAULT '{}'::jsonb,
  is_super_admin boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS auth.refresh_tokens (
  id bigserial PRIMARY KEY,
  token text NOT NULL,
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

-- Grant schema usage
GRANT USAGE ON SCHEMA auth TO postgres, anon, authenticated, service_role;

-- Grant table permissions
GRANT ALL ON ALL TABLES IN SCHEMA auth TO postgres, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO postgres, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA auth TO postgres, service_role;

-- Grant specific permissions to anon and authenticated roles
GRANT SELECT ON TABLE auth.users TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE auth.refresh_tokens TO anon, authenticated;

-- Create indexes
CREATE INDEX IF NOT EXISTS users_email_idx ON auth.users (email);
CREATE INDEX IF NOT EXISTS users_id_idx ON auth.users (id);
CREATE INDEX IF NOT EXISTS refresh_tokens_token_idx ON auth.refresh_tokens (token);
CREATE INDEX IF NOT EXISTS refresh_tokens_user_id_idx ON auth.refresh_tokens (user_id);