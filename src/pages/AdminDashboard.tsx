import React, { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Mail, LogOut, Send, Loader2 } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { toast, Toaster } from 'react-hot-toast';

interface Conversation {
  id: string;
  visitor_id: string;
  status: 'active' | 'closed';
  created_at: string;
  updated_at: string;
  last_message?: string;
  unread_count?: number;
}

interface Message {
  id: string;
  conversation_id: string;
  sender_type: 'visitor' | 'admin';
  content: string;
  created_at: string;
  read_at: string | null;
}

export function AdminDashboard() {
  const navigate = useNavigate();
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [selectedConversation, setSelectedConversation] = useState<Conversation | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    checkAuth();
    fetchConversations();
    subscribeToNewMessages();

    return () => {
      supabase.channel('chat').unsubscribe();
    };
  }, []);

  useEffect(() => {
    if (selectedConversation) {
      fetchMessages(selectedConversation.id);
    }
  }, [selectedConversation]);

  const checkAuth = async () => {
    const { data: { session }, error } = await supabase.auth.getSession();
    if (error || !session) {
      navigate('/admin/login');
    }
  };

  const subscribeToNewMessages = () => {
    supabase
      .channel('chat')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'chat_messages',
        },
        (payload) => {
          const newMessage = payload.new as Message;
          if (selectedConversation?.id === newMessage.conversation_id) {
            setMessages((prev) => [...prev, newMessage]);
          }
          fetchConversations(); // Refresh conversation list to update last message
        }
      )
      .subscribe();
  };

  const fetchConversations = async () => {
    try {
      const { data: conversations, error } = await supabase
        .from('chat_conversations')
        .select('*')
        .order('updated_at', { ascending: false });

      if (error) throw error;

      // Fetch last message and unread count for each conversation
      const enhancedConversations = await Promise.all(
        conversations.map(async (conv) => {
          const { data: lastMessage } = await supabase
            .from('chat_messages')
            .select('content, read_at, sender_type')
            .eq('conversation_id', conv.id)
            .order('created_at', { ascending: false })
            .limit(1)
            .single();

          const { count: unreadCount } = await supabase
            .from('chat_messages')
            .select('*', { count: 'exact', head: true })
            .eq('conversation_id', conv.id)
            .eq('sender_type', 'visitor')
            .is('read_at', null);

          return {
            ...conv,
            last_message: lastMessage?.content,
            unread_count: unreadCount || 0,
          };
        })
      );

      setConversations(enhancedConversations);
      setIsLoading(false);
    } catch (error) {
      console.error('Error fetching conversations:', error);
      toast.error('Failed to load conversations');
      setIsLoading(false);
    }
  };

  const fetchMessages = async (conversationId: string) => {
    try {
      const { data: messages, error } = await supabase
        .from('chat_messages')
        .select('*')
        .eq('conversation_id', conversationId)
        .order('created_at', { ascending: true });

      if (error) throw error;

      setMessages(messages);

      // Mark unread messages as read
      const { error: updateError } = await supabase
        .from('chat_messages')
        .update({ read_at: new Date().toISOString() })
        .eq('conversation_id', conversationId)
        .eq('sender_type', 'visitor')
        .is('read_at', null);

      if (updateError) throw updateError;
    } catch (error) {
      console.error('Error fetching messages:', error);
      toast.error('Failed to load messages');
    }
  };

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newMessage.trim() || !selectedConversation) return;

    try {
      const { error } = await supabase.from('chat_messages').insert({
        conversation_id: selectedConversation.id,
        sender_type: 'admin',
        content: newMessage.trim(),
      });

      if (error) throw error;

      setNewMessage('');
    } catch (error) {
      console.error('Error sending message:', error);
      toast.error('Failed to send message');
    }
  };

  const handleLogout = async () => {
    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
      navigate('/admin/login');
    } catch (err) {
      console.error('Error signing out:', err);
      toast.error('Failed to sign out');
    }
  };

  return (
    <div className="min-h-screen bg-black text-white">
      <Toaster
        position="top-center"
        toastOptions={{
          duration: 3000,
          style: {
            background: '#1a1a1a',
            color: '#fff',
            border: '1px solid rgba(255, 255, 255, 0.1)',
          },
        }}
      />

      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 px-2 py-2 sm:px-4 sm:py-4">
        <div className="max-w-7xl mx-auto">
          <div className="bg-white/10 backdrop-blur-xl border border-white/10 rounded-xl sm:rounded-2xl px-3 py-2.5 sm:px-6 sm:py-4">
            <div className="flex items-center justify-between">
              <Link to="/" className="flex items-center gap-3">
                <div className="relative group">
                  <div className="absolute -inset-2 bg-gradient-to-r from-blue-600 to-teal-600 rounded-lg blur opacity-25 group-hover:opacity-75 transition duration-200"></div>
                  <div className="relative bg-black/50 backdrop-blur-xl rounded-lg p-3 sm:p-2.5 ring-1 ring-white/10 group-hover:ring-white/20 transition duration-200">
                    <Mail className="w-7 h-7 sm:w-7 sm:h-7 text-blue-400 group-hover:text-blue-300 transition-colors" />
                  </div>
                </div>
                <div>
                  <span className="text-xl sm:text-xl font-bold bg-gradient-to-r from-blue-400 via-blue-200 to-teal-400 bg-clip-text text-transparent">
                    Admin Dashboard
                  </span>
                </div>
              </Link>

              <div className="flex items-center gap-4">
                <button
                  onClick={handleLogout}
                  className="inline-flex items-center gap-2 text-gray-400 hover:text-white transition-colors"
                >
                  <LogOut className="w-4 h-4" />
                  Logout
                </button>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-32 pb-16">
        <div className="mb-8">
          <h1 className="text-3xl font-bold mb-4">Support Chats</h1>
          
          {isLoading ? (
            <div className="flex items-center justify-center h-64">
              <Loader2 className="w-8 h-8 text-blue-500 animate-spin" />
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Conversations List */}
              <div className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl p-4 h-[600px] overflow-y-auto">
                <h2 className="text-lg font-semibold mb-4">Conversations</h2>
                <div className="space-y-2">
                  {conversations.map((conv) => (
                    <button
                      key={conv.id}
                      onClick={() => setSelectedConversation(conv)}
                      className={`w-full text-left p-3 rounded-xl transition-colors ${
                        selectedConversation?.id === conv.id
                          ? 'bg-blue-500/20 border border-blue-500/30'
                          : 'border border-white/10 hover:bg-white/5'
                      }`}
                    >
                      <div className="flex items-center justify-between mb-1">
                        <span className="font-medium">Visitor {conv.visitor_id.slice(0, 8)}</span>
                        {conv.unread_count > 0 && (
                          <span className="bg-blue-500 text-white text-xs px-2 py-1 rounded-full">
                            {conv.unread_count}
                          </span>
                        )}
                      </div>
                      {conv.last_message && (
                        <p className="text-sm text-gray-400 truncate">{conv.last_message}</p>
                      )}
                    </button>
                  ))}
                </div>
              </div>

              {/* Chat Messages */}
              <div className="md:col-span-2 bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl p-4 h-[600px] flex flex-col">
                {selectedConversation ? (
                  <>
                    <div className="flex-1 overflow-y-auto mb-4 space-y-4">
                      {messages.map((msg) => (
                        <div
                          key={msg.id}
                          className={`flex ${
                            msg.sender_type === 'admin' ? 'justify-end' : 'justify-start'
                          }`}
                        >
                          <div
                            className={`max-w-[80%] rounded-2xl px-4 py-2 ${
                              msg.sender_type === 'admin'
                                ? 'bg-blue-500 text-white'
                                : 'bg-white/10 text-white'
                            }`}
                          >
                            {msg.content}
                          </div>
                        </div>
                      ))}
                    </div>
                    <form onSubmit={handleSendMessage} className="flex gap-2">
                      <input
                        type="text"
                        value={newMessage}
                        onChange={(e) => setNewMessage(e.target.value)}
                        placeholder="Type your message..."
                        className="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      />
                      <button
                        type="submit"
                        disabled={!newMessage.trim()}
                        className="bg-blue-500 text-white p-2 rounded-xl hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        <Send className="w-5 h-5" />
                      </button>
                    </form>
                  </>
                ) : (
                  <div className="flex items-center justify-center h-full text-gray-400">
                    Select a conversation to start chatting
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}