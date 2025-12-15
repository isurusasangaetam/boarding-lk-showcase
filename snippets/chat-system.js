/**
 * REAL-TIME CHAT SYSTEM
 * * Highlights:
 * 1. Custom Implementation: Built from scratch without 3rd party Chat SDKs.
 * 2. Relational Data: Joins 'Conversations', 'Messages', and 'Users' tables.
 * 3. Auto-Scroll: Automatically snaps to bottom when new messages arrive.
 */

import { useState, useEffect, useRef } from 'react'
import { supabase } from '@/lib/supabaseClient'

export default function ChatRoom({ chatId, currentUser }) {
    const [messages, setMessages] = useState([])
    const messagesEndRef = useRef(null)

    // 1. WEBSOCKET SUBSCRIPTION
    // Listens for 'INSERT' events on the 'messages' table specifically for this chat
    useEffect(() => {
        const channel = supabase
            .channel(`chat:${chatId}`)
            .on('postgres_changes', { 
                event: 'INSERT', 
                schema: 'public', 
                table: 'messages', 
                filter: `conversation_id=eq.${chatId}` 
            }, (payload) => {
                // Append new message to state immediately
                setMessages((prev) => [...prev, payload.new])
                scrollToBottom()
            })
            .subscribe()

        return () => supabase.removeChannel(channel)
    }, [chatId])

    // 2. AUTO-SCROLL LOGIC
    // Ensures user always sees the latest message
    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
    }

    // 3. SEND MESSAGE LOGIC
    async function sendMessage(text) {
        // Insert directly to DB; The subscription above will catch it and update UI
        await supabase
            .from('messages')
            .insert({
                conversation_id: chatId,
                sender_id: currentUser.id,
                content: text
            })
    }
}