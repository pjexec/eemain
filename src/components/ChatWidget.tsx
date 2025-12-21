import React, { useState, useEffect, useRef } from 'react';
import { MessageCircle, X, Send, Loader2 } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { nanoid } from 'nanoid';

interface Message {
  id: string;
  sender_type: 'visitor' | 'admin';
  content: string;
  created_at: string;
}

interface Conversation {
  id: string;
  visitor_id: string;
  status: string;
}

export function ChatWidget() {
  const [isOpen, setIsOpen] = useState(false);
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [visitorId, setVisitorId] = useState('');
  const [conversation, setConversation] = useState<Conversation | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const [isSending, setIsSending] = useState(false);

  useEffect(() => {
    // Get or create visitor ID
    const storedVisitorId = localStorage.getItem('visitorId');
    const newVisitorId = storedVisitorId || nanoid();
    if (!storedVisitorId) {
      localStorage.setItem('visitorId', newVisitorId);
    }
    setVisitorId(newVisitorId);
  }, []);

  useEffect(() => {
    if (isOpen && visitorId) {
      initializeChat();
    }
  }, [isOpen, visitorId]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const initializeChat = async () => {
    setIsLoading(true);
    try {
      // Get or create conversation
      const { data: existingConversations, error: fetchError } = await supabase
        .from('chat_conversations')
        .select()
        .eq('visitor_id', visitorId)
        .eq('status', 'active')
        .limit(1);

      if (fetchError) throw fetchError;

      let currentConversation: Conversation | null = null;

      if (existingConversations && existingConversations.length > 0) {
        currentConversation = existingConversations[0];
        setConversation(currentConversation);
        
        // Load existing messages
        const { data: existingMessages, error: messagesError } = await supabase
          .from('chat_messages')
          .select()
          .eq('conversation_id', currentConversation.id)
          .order('created_at', { ascending: true });
        
        if (messagesError) throw messagesError;
        
        if (existingMessages) {
          setMessages(existingMessages);
          // Subscribe to new messages
          subscribeToMessages(currentConversation.id);
        }
      } else {
        // Create new conversation
        const { data: newConversation, error: createError } = await supabase
          .from('chat_conversations')
          .insert([{ visitor_id: visitorId }])
          .select()
          .single();

        if (createError) throw createError;

        if (newConversation) {
          currentConversation = newConversation;
          setConversation(newConversation);
          
          // Add welcome message
          const { data: welcomeMessage, error: welcomeError } = await supabase
            .from('chat_messages')
            .insert([{
              conversation_id: newConversation.id,
              sender_type: 'admin',
              content: 'Hi! How can I help you today?'
            }])
            .select()
            .single();

          if (welcomeError) throw welcomeError;

          if (welcomeMessage) {
            setMessages([welcomeMessage]);
            // Subscribe to new messages
            subscribeToMessages(newConversation.id);
          }
        }
      }
    } catch (error) {
      console.error('Error initializing chat:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const subscribeToMessages = (conversationId: string) => {
    const channel = supabase.channel(`chat:${conversationId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'chat_messages',
          filter: `conversation_id=eq.${conversationId}`,
        },
        (payload) => {
          const newMessage = payload.new as Message;
          setMessages(prev => [...prev, newMessage]);
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  };

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!message.trim() || !conversation || isSending) return;

    const messageContent = message.trim();
    setMessage('');
    setIsSending(true);

    try {
      const { data: newMessage, error } = await supabase
        .from('chat_messages')
        .insert([{
          conversation_id: conversation.id,
          sender_type: 'visitor',
          content: messageContent
        }])
        .select()
        .single();

      if (error) throw error;

      if (newMessage) {
        setMessages(prev => [...prev, newMessage]);
      }
    } catch (error) {
      console.error('Error sending message:', error);
      setMessage(messageContent);
    } finally {
      setIsSending(false);
    }
  };

  if (!isOpen) {
    return (
      <button
        onClick={() => setIsOpen(true)}
        className="fixed bottom-4 right-4 p-4 bg-blue-500 text-white rounded-full shadow-lg hover:bg-blue-600 transition-colors z-50"
      >
        <MessageCircle className="w-6 h-6" />
      </button>
    );
  }

  return (
    <div className="fixed bottom-4 right-4 w-96 h-[600px] bg-black border border-white/10 rounded-2xl shadow-2xl flex flex-col z-50">
      <div className="p-4 border-b border-white/10 flex items-center justify-between">
        <div>
          <h3 className="font-semibold text-white">Chat Support</h3>
          <p className="text-sm text-gray-400">We typically reply in a few minutes</p>
        </div>
        <button
          onClick={() => setIsOpen(false)}
          className="text-gray-400 hover:text-white transition-colors"
        >
          <X className="w-5 h-5" />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {isLoading ? (
          <div className="flex items-center justify-center h-full">
            <Loader2 className="w-6 h-6 text-blue-500 animate-spin" />
          </div>
        ) : (
          messages.map((msg) => (
            <div
              key={msg.id}
              className={`flex ${
                msg.sender_type === 'visitor' ? 'justify-end' : 'justify-start'
              }`}
            >
              <div
                className={`max-w-[80%] rounded-2xl px-4 py-2 ${
                  msg.sender_type === 'visitor'
                    ? 'bg-blue-500 text-white'
                    : 'bg-white/5 text-white'
                }`}
              >
                {msg.content}
              </div>
            </div>
          ))
        )}
        <div ref={messagesEndRef} />
      </div>

      <form onSubmit={handleSendMessage} className="p-4 border-t border-white/10">
        <div className="flex gap-2">
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Type your message..."
            className="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            type="submit"
            disabled={!message.trim() || isSending}
            className="bg-blue-500 text-white p-2 rounded-xl hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSending ? (
              <Loader2 className="w-5 h-5 animate-spin" />
            ) : (
              <Send className="w-5 h-5" />
            )}
          </button>
        </div>
      </form>
    </div>
  );
}