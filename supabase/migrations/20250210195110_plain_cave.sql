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

-- Policies for chat_conversations
CREATE POLICY "Enable insert for anon"
  ON public.chat_conversations
  FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Enable select for anon"
  ON public.chat_conversations
  FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Enable all for authenticated"
  ON public.chat_conversations
  FOR ALL
  TO authenticated
  USING (true);

-- Policies for chat_messages
CREATE POLICY "Enable insert for anon"
  ON public.chat_messages
  FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Enable select for anon"
  ON public.chat_messages
  FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Enable all for authenticated"
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

-- Enable realtime for these tables
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE chat_conversations, chat_messages;
COMMIT;