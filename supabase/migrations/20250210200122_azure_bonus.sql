-- Drop existing chat tables
DROP TABLE IF EXISTS public.chat_messages;
DROP TABLE IF EXISTS public.chat_conversations;

-- Create chat tables
CREATE TABLE public.chat_conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  visitor_id text NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'closed')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE public.chat_messages (
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

-- Simple policies that allow all operations
CREATE POLICY "Enable all operations for everyone on conversations"
  ON public.chat_conversations
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable all operations for everyone on messages"
  ON public.chat_messages
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- Grant necessary permissions
GRANT ALL ON public.chat_conversations TO anon, authenticated;
GRANT ALL ON public.chat_messages TO anon, authenticated;

-- Create indexes for better performance
CREATE INDEX chat_conversations_visitor_id_idx ON public.chat_conversations(visitor_id);
CREATE INDEX chat_messages_conversation_id_idx ON public.chat_messages(conversation_id);

-- Enable realtime for these tables
DROP PUBLICATION IF EXISTS supabase_realtime;
CREATE PUBLICATION supabase_realtime FOR TABLE chat_conversations, chat_messages;