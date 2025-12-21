/*
  # Fix Chat Tables Migration

  1. New Tables
    - `chat_conversations`
      - `id` (uuid, primary key)
      - `visitor_id` (text)
      - `status` (text: 'active' or 'closed')
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `chat_messages`
      - `id` (uuid, primary key)
      - `conversation_id` (uuid, foreign key)
      - `sender_type` (text: 'visitor' or 'admin')
      - `content` (text)
      - `created_at` (timestamp)
      - `read_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Create policies for visitor and admin access
    - Set up visitor_id claim function
*/

-- Drop existing tables if they exist to ensure clean slate
DROP TABLE IF EXISTS public.chat_messages;
DROP TABLE IF EXISTS public.chat_conversations;
DROP FUNCTION IF EXISTS public.set_claim;

-- Create function to set visitor_id claim
CREATE OR REPLACE FUNCTION public.set_claim(name text, value text)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF name IS NULL OR value IS NULL THEN
    RETURN NULL;
  END IF;
  PERFORM set_config('app.' || name, value, FALSE);
  RETURN value;
END;
$$;

-- Create chat tables
CREATE TABLE IF NOT EXISTS public.chat_conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  visitor_id text NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'closed')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.chat_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid REFERENCES public.chat_conversations(id) ON DELETE CASCADE,
  sender_type text NOT NULL CHECK (sender_type IN ('visitor', 'admin')),
  content text NOT NULL,
  created_at timestamptz DEFAULT now(),
  read_at timestamptz
);

-- Enable RLS
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Policies for chat_conversations
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Visitors can view their own conversations" ON public.chat_conversations;
  DROP POLICY IF EXISTS "Visitors can create conversations" ON public.chat_conversations;
  DROP POLICY IF EXISTS "Admins can view all conversations" ON public.chat_conversations;
END $$;

CREATE POLICY "Visitors can view their own conversations"
  ON public.chat_conversations
  FOR SELECT
  TO public
  USING (visitor_id = COALESCE(current_setting('app.visitor_id', TRUE), ''));

CREATE POLICY "Visitors can create conversations"
  ON public.chat_conversations
  FOR INSERT
  TO public
  WITH CHECK (visitor_id = COALESCE(current_setting('app.visitor_id', TRUE), ''));

CREATE POLICY "Admins can view all conversations"
  ON public.chat_conversations
  FOR ALL
  TO authenticated
  USING (true);

-- Policies for chat_messages
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Visitors can view messages from their conversations" ON public.chat_messages;
  DROP POLICY IF EXISTS "Visitors can send messages to their conversations" ON public.chat_messages;
  DROP POLICY IF EXISTS "Admins can manage all messages" ON public.chat_messages;
END $$;

CREATE POLICY "Visitors can view messages from their conversations"
  ON public.chat_messages
  FOR SELECT
  TO public
  USING (
    conversation_id IN (
      SELECT id FROM public.chat_conversations 
      WHERE visitor_id = COALESCE(current_setting('app.visitor_id', TRUE), '')
    )
  );

CREATE POLICY "Visitors can send messages to their conversations"
  ON public.chat_messages
  FOR INSERT
  TO public
  WITH CHECK (
    conversation_id IN (
      SELECT id FROM public.chat_conversations 
      WHERE visitor_id = COALESCE(current_setting('app.visitor_id', TRUE), '')
    ) AND sender_type = 'visitor'
  );

CREATE POLICY "Admins can manage all messages"
  ON public.chat_messages
  FOR ALL
  TO authenticated
  USING (true);

-- Grant necessary permissions
GRANT ALL ON public.chat_conversations TO anon, authenticated;
GRANT ALL ON public.chat_messages TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.set_claim TO anon, authenticated;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS chat_conversations_visitor_id_idx ON public.chat_conversations(visitor_id);
CREATE INDEX IF NOT EXISTS chat_messages_conversation_id_idx ON public.chat_messages(conversation_id);

-- Create realtime publication for chat messages
DROP PUBLICATION IF EXISTS supabase_realtime;
CREATE PUBLICATION supabase_realtime FOR ALL TABLES;