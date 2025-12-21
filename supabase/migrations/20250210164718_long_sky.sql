/*
  # Fix Authentication Setup

  1. Changes
    - Drop and recreate auth schema with proper permissions
    - Set up authentication tables with correct structure
    - Create admin user with proper credentials
    - Add necessary grants and permissions
*/

-- Drop and recreate auth schema
DROP SCHEMA IF EXISTS auth CASCADE;
CREATE SCHEMA auth;

-- Create auth schema types
CREATE TYPE auth.aal_level AS ENUM ('aal1', 'aal2', 'aal3');
CREATE TYPE auth.code_challenge_method AS ENUM ('s256', 'plain');
CREATE TYPE auth.factor_status AS ENUM ('unverified', 'verified');
CREATE TYPE auth.factor_type AS ENUM ('totp', 'webauthn');

-- Create users table
CREATE TABLE auth.users (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  instance_id uuid,
  aud varchar(255),
  role varchar(255),
  email varchar(255) UNIQUE,
  encrypted_password varchar(255),
  email_confirmed_at timestamptz DEFAULT now(),
  invited_at timestamptz,
  confirmation_token varchar(255),
  confirmation_sent_at timestamptz,
  recovery_token varchar(255),
  recovery_sent_at timestamptz,
  email_change_token_new varchar(255),
  email_change varchar(255),
  email_change_sent_at timestamptz,
  last_sign_in_at timestamptz,
  raw_app_meta_data jsonb,
  raw_user_meta_data jsonb,
  is_super_admin boolean,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  phone varchar(255) UNIQUE DEFAULT NULL,
  phone_confirmed_at timestamptz,
  phone_change varchar(255) DEFAULT '',
  phone_change_token varchar(255) DEFAULT '',
  phone_change_sent_at timestamptz,
  confirmed_at timestamptz GENERATED ALWAYS AS (
    LEAST(email_confirmed_at, phone_confirmed_at)
  ) STORED,
  email_change_token_current varchar(255) DEFAULT '',
  email_change_confirm_status smallint DEFAULT 0,
  banned_until timestamptz,
  reauthentication_token varchar(255) DEFAULT '',
  reauthentication_sent_at timestamptz,
  is_sso_user boolean DEFAULT false,
  deleted_at timestamptz
);

-- Create sessions table
CREATE TABLE auth.sessions (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  factor_id uuid,
  aal auth.aal_level,
  not_after timestamptz
);

-- Create refresh tokens table
CREATE TABLE auth.refresh_tokens (
  id bigserial PRIMARY KEY,
  token varchar(255) NOT NULL,
  user_id varchar(255) NOT NULL,
  revoked boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  parent varchar(255),
  session_id uuid REFERENCES auth.sessions(id) ON DELETE CASCADE
);

-- Create identities table
CREATE TABLE auth.identities (
  id text NOT NULL,
  user_id uuid NOT NULL,
  identity_data jsonb NOT NULL,
  provider text NOT NULL,
  last_sign_in_at timestamptz,
  created_at timestamptz,
  updated_at timestamptz,
  email text GENERATED ALWAYS AS (lower(identity_data->>'email')) STORED,
  CONSTRAINT identities_pkey PRIMARY KEY (provider, id),
  CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create instances table
CREATE TABLE auth.instances (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  uuid uuid,
  raw_base_config text,
  created_at timestamptz,
  updated_at timestamptz
);

-- Create audit log table
CREATE TABLE auth.audit_log_entries (
  instance_id uuid,
  id uuid NOT NULL,
  payload json,
  created_at timestamptz,
  ip_address varchar(64) DEFAULT '',
  CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id)
);

-- Create schemas table
CREATE TABLE auth.schemas (
  version text NOT NULL,
  inserted_at timestamptz DEFAULT now(),
  CONSTRAINT schemas_pkey PRIMARY KEY (version)
);

-- Create mfa factors table
CREATE TABLE auth.mfa_factors (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  friendly_name text,
  factor_type auth.factor_type,
  status auth.factor_status,
  created_at timestamptz,
  updated_at timestamptz,
  secret text
);

-- Create mfa challenges table
CREATE TABLE auth.mfa_challenges (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  factor_id uuid NOT NULL REFERENCES auth.mfa_factors(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL,
  verified_at timestamptz,
  ip_address inet
);

-- Create mfa amr claims table
CREATE TABLE auth.mfa_amr_claims (
  session_id uuid NOT NULL REFERENCES auth.sessions(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL,
  authentication_method text NOT NULL,
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY
);

-- Create flow state table
CREATE TABLE auth.flow_state (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id),
  auth_code text NOT NULL,
  code_challenge_method auth.code_challenge_method NOT NULL,
  code_challenge text NOT NULL,
  provider_type text NOT NULL,
  provider_access_token text,
  provider_refresh_token text,
  created_at timestamptz,
  updated_at timestamptz,
  authentication_method text
);

-- Create sso domains table
CREATE TABLE auth.sso_domains (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  sso_provider_id uuid NOT NULL,
  domain text NOT NULL,
  created_at timestamptz,
  updated_at timestamptz,
  CONSTRAINT sso_domains_domain_key UNIQUE (domain)
);

-- Create sso providers table
CREATE TABLE auth.sso_providers (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id text,
  created_at timestamptz,
  updated_at timestamptz
);

-- Create saml providers table
CREATE TABLE auth.saml_providers (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  sso_provider_id uuid NOT NULL,
  entity_id text NOT NULL,
  metadata_xml text NOT NULL,
  metadata_url text,
  attribute_mapping jsonb,
  created_at timestamptz,
  updated_at timestamptz,
  CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id)
);

-- Create saml relay states table
CREATE TABLE auth.saml_relay_states (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  sso_provider_id uuid NOT NULL,
  request_id text NOT NULL,
  for_email text,
  redirect_to text,
  from_ip_address inet,
  created_at timestamptz,
  updated_at timestamptz,
  flow_state_id uuid
);

-- Create admin user
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
  '$2a$10$Q.VvU6TJc1bqR1Ev6/.Bee8TF/0BSsqk8/Lqz5hUn4NRuWmjqK6Ue', -- Password: admin123
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  true
) ON CONFLICT (id) DO NOTHING;

-- Create necessary indexes
CREATE INDEX IF NOT EXISTS users_instance_id_idx ON auth.users(instance_id);
CREATE INDEX IF NOT EXISTS users_email_idx ON auth.users(email);
CREATE INDEX IF NOT EXISTS users_phone_idx ON auth.users(phone);
CREATE INDEX IF NOT EXISTS refresh_tokens_token_idx ON auth.refresh_tokens(token);
CREATE INDEX IF NOT EXISTS refresh_tokens_user_id_idx ON auth.refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS refresh_tokens_session_id_idx ON auth.refresh_tokens(session_id);
CREATE INDEX IF NOT EXISTS sessions_user_id_idx ON auth.sessions(user_id);
CREATE INDEX IF NOT EXISTS sessions_not_after_idx ON auth.sessions(not_after);
CREATE INDEX IF NOT EXISTS identities_user_id_idx ON auth.identities(user_id);
CREATE INDEX IF NOT EXISTS identities_email_idx ON auth.identities(email);
CREATE INDEX IF NOT EXISTS audit_logs_instance_id_idx ON auth.audit_log_entries(instance_id);
CREATE INDEX IF NOT EXISTS mfa_factors_user_id_idx ON auth.mfa_factors(user_id);
CREATE INDEX IF NOT EXISTS mfa_challenges_factor_id_idx ON auth.mfa_challenges(factor_id);
CREATE INDEX IF NOT EXISTS flow_state_user_id_idx ON auth.flow_state(user_id);
CREATE INDEX IF NOT EXISTS sso_domains_sso_provider_id_idx ON auth.sso_domains(sso_provider_id);
CREATE INDEX IF NOT EXISTS saml_providers_sso_provider_id_idx ON auth.saml_providers(sso_provider_id);
CREATE INDEX IF NOT EXISTS saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states(sso_provider_id);
CREATE INDEX IF NOT EXISTS saml_relay_states_flow_state_id_idx ON auth.saml_relay_states(flow_state_id);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA auth TO postgres, anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO postgres, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO postgres, authenticated;
GRANT ALL ON ALL ROUTINES IN SCHEMA auth TO postgres, authenticated;

-- Insert schema version
INSERT INTO auth.schemas (version) VALUES ('0.0.0');