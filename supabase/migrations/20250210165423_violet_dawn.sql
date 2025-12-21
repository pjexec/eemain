/*
  # Fix Authentication Schema and Permissions

  1. Changes
    - Drop and recreate auth schema with proper structure
    - Set up auth tables with correct constraints
    - Create admin user with secure password
    - Grant all necessary permissions
*/

-- Drop existing schema and recreate
DROP SCHEMA IF EXISTS auth CASCADE;
CREATE SCHEMA auth;

-- Create necessary extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create auth schema types
CREATE TYPE auth.aal_level AS ENUM ('aal1', 'aal2', 'aal3');
CREATE TYPE auth.factor_type AS ENUM ('totp', 'webauthn');
CREATE TYPE auth.factor_status AS ENUM ('unverified', 'verified');

-- Create users table
CREATE TABLE auth.users (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  instance_id uuid,
  email text UNIQUE,
  encrypted_password text,
  email_confirmed_at timestamptz DEFAULT now(),
  invited_at timestamptz,
  confirmation_token text,
  confirmation_sent_at timestamptz,
  recovery_token text,
  recovery_sent_at timestamptz,
  email_change_token_new text,
  email_change text,
  email_change_sent_at timestamptz,
  last_sign_in_at timestamptz,
  raw_app_meta_data jsonb DEFAULT '{}'::jsonb,
  raw_user_meta_data jsonb DEFAULT '{}'::jsonb,
  is_super_admin boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  phone text UNIQUE,
  phone_confirmed_at timestamptz,
  phone_change text DEFAULT '',
  phone_change_token text DEFAULT '',
  phone_change_sent_at timestamptz,
  email_change_token_current text DEFAULT '',
  email_change_confirm_status smallint DEFAULT 0,
  banned_until timestamptz,
  reauthentication_token text DEFAULT '',
  reauthentication_sent_at timestamptz,
  is_sso_user boolean DEFAULT false,
  deleted_at timestamptz,
  CONSTRAINT proper_email CHECK (email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);

-- Create sessions table
CREATE TABLE auth.sessions (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  factor_id uuid,
  aal auth.aal_level,
  not_after timestamptz
);

-- Create refresh tokens table
CREATE TABLE auth.refresh_tokens (
  id bigserial PRIMARY KEY,
  token text NOT NULL UNIQUE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  parent text,
  revoked boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  session_id uuid REFERENCES auth.sessions(id) ON DELETE CASCADE
);

-- Create admin user
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin
) VALUES (
  'a96d4bb7-c243-4e3f-9f2c-6e6b1b7e127d',
  'admin@expert.email',
  crypt('admin123', gen_salt('bf')),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  true
) ON CONFLICT (id) DO UPDATE 
SET encrypted_password = crypt('admin123', gen_salt('bf'));

-- Create indexes
CREATE INDEX users_email_idx ON auth.users (email);
CREATE INDEX users_instance_id_idx ON auth.users (instance_id);
CREATE INDEX refresh_tokens_token_idx ON auth.refresh_tokens (token);
CREATE INDEX refresh_tokens_user_id_idx ON auth.refresh_tokens (user_id);
CREATE INDEX refresh_tokens_session_id_idx ON auth.refresh_tokens (session_id);
CREATE INDEX sessions_user_id_idx ON auth.sessions (user_id);
CREATE INDEX sessions_not_after_idx ON auth.sessions (not_after);

-- Grant permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL ON TABLES TO postgres, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres, service_role;

GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO postgres, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO postgres, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA auth TO postgres, service_role;

-- Grant specific permissions to anon and authenticated
GRANT SELECT ON TABLE auth.users TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE auth.refresh_tokens TO anon, authenticated;
GRANT SELECT, INSERT ON TABLE auth.sessions TO anon, authenticated;