/*
  # Fix Admin Authentication Setup

  1. Changes
    - Create admin user with proper password hashing
    - Set up necessary auth schema permissions
*/

-- Create admin user with proper password hashing
INSERT INTO auth.users (
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin
) VALUES (
  'a96d4bb7-c243-4e3f-9f2c-6e6b1b7e127d',
  'authenticated',
  'authenticated',
  'admin@expert.email',
  crypt('admin123', gen_salt('bf')), -- Using proper password hashing
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  true
) ON CONFLICT (id) DO UPDATE 
SET encrypted_password = crypt('admin123', gen_salt('bf'));

-- Ensure proper permissions
GRANT USAGE ON SCHEMA auth TO postgres, anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO postgres;
GRANT ALL ON ALL ROUTINES IN SCHEMA auth TO postgres;