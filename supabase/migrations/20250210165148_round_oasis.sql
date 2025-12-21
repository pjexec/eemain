/*
  # Fix Authentication Unique Constraint

  1. Changes
    - Add unique constraint on id for auth.users table
    - Ensure proper grants for auth schema
*/

-- Create extension if not exists
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create auth schema if not exists
CREATE SCHEMA IF NOT EXISTS auth;

-- Create users table with proper constraints
CREATE TABLE IF NOT EXISTS auth.users (
  id uuid PRIMARY KEY,
  email text UNIQUE,
  encrypted_password text,
  email_confirmed_at timestamptz DEFAULT now(),
  last_sign_in_at timestamptz,
  raw_app_meta_data jsonb DEFAULT '{}'::jsonb,
  raw_user_meta_data jsonb DEFAULT '{}'::jsonb,
  is_super_admin boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT users_id_key UNIQUE (id)
);

-- Create admin user with proper password hashing
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

-- Grant necessary permissions
GRANT USAGE ON SCHEMA auth TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO postgres, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO postgres, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA auth TO postgres, service_role;