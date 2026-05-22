import React, { useState, useEffect, useRef } from 'react'
import { 
  Bot, 
  Send, 
  Mic, 
  MicOff, 
  Settings, 
  X, 
  RefreshCw, 
  Volume2,
  VolumeX,
  Moon,
  Sun,
  Trash2
} from 'lucide-react'
import { supabase } from '../lib/supabase'
import { toast } from 'react-hot-toast'
import { useTheme } from '../contexts/ThemeContext'

interface Message {
  id: string
  role: 'user' | 'assistant' | 'system'
  content: string
  timestamp: Date
}

interface AISettings {
  model: 'gemini-2.5-flash' | 'gemini-1.5-flash' | 'gemini-pro'
  temperature: number
  maxTokens: number
  speakResponses: boolean
  voiceId: string
}

export default function AIAssistant() {
  const { theme, toggleTheme } = useTheme()
  const [messages, setMessages] = useState<Message[]>([])
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)
  const [showSettings, setShowSettings] = useState(false)
  const [settings, setSettings] = useState<AISettings>({
    model: 'gemini-2.5-flash',
    temperature: 0.7,
    maxTokens: 1000,
    speakResponses: false, // Changed to false by default
    voiceId: 'xjlfQQ3ynqiEyRpArrT8' // Vivien voice ID
  })
  const [isListening, setIsListening] = useState(false)
  const [isSpeaking, setIsSpeaking] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const recognitionRef = useRef<any>(null)

  useEffect(() => {
    // Add initial welcome message
    const welcomeMessage: Message = {
      id: Date.now().toString(),
      role: 'assistant',
      content: 'Üdvözlöm! Vivien vagyok, a Szemesi Pékség Kft. AI asszisztense. Segíthetek kérdések megválaszolásában, rendelések felvételében, készlet ellenőrzésében, és minden egyéb pékséggel kapcsolatos feladatban. Miben segíthetek?',
      timestamp: new Date()
    }
    setMessages([welcomeMessage])
    
    // Initialize speech recognition
    initSpeechRecognition()
    
    return () => {
      // Clean up speech recognition and synthesis
      if (recognitionRef.current) {
        recognitionRef.current.stop()
      }
      if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel()
      }
    }
  }, [])

  useEffect(() => {
    // Scroll to bottom when messages change
    scrollToBottom()
  }, [messages])

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  const handleSendMessage = async (voiceInput?: string) => {
    const messageText = voiceInput || input
    if (!messageText.trim()) return

    // Stop any ongoing speech
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel()
      setIsSpeaking(false)
    }

    // Add user message to chat
    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: messageText,
      timestamp: new Date()
    }
    
    setMessages(prev => [...prev, userMessage])
    setInput('')
    setLoading(true)
    
    try {
      // Call Gemini API through Supabase Edge Function
      const { data, error } = await supabase.functions.invoke('call-gemini', { 
        body: { 
          messages: [...messages, userMessage].map(msg => ({
            role: msg.role,
            content: msg.content
          })),
          model: settings.model
        }
      });
      
      if (error) {
        console.error("Error calling Gemini:", error);
        throw new Error(error.message || 'Hiba az AI szolgáltatásban');
      }
      
      if (!data || !data.text) {
        throw new Error('Érvénytelen válasz az AI-tól');
      }
      
      const assistantMessage: Message = {
        id: Date.now().toString(),
        role: 'assistant',
        content: data.text,
        timestamp: new Date()
      }
      
      setMessages(prev => [...prev, assistantMessage])
      
      // Speak response if enabled
      if (settings.speakResponses) {
        try {
          await speakTextWithElevenLabs(data.text);
        } catch (error) {
          console.error("Error with ElevenLabs TTS:", error);
          // Fallback to browser TTS
          try {
            await speakText(data.text);
          } catch (fallbackError) {
            console.error("Error with browser TTS:", fallbackError);
            toast.error("Nem sikerült a hangos válasz generálása");
          }
        }
      }
    } catch (error) {
      console.error('Error in message handling:', error)
      
      const errorMessage: Message = {
        id: Date.now().toString(),
        role: 'assistant',
        content: 'Sajnálom, hiba történt a válasz generálása során. Kérlek próbáld újra.',
        timestamp: new Date()
      }
      
      setMessages(prev => [...prev, errorMessage])
      toast.error('Hiba történt az AI válasz generálása során')
    } finally {
      setLoading(false)
    }
  }

  const speakTextWithElevenLabs = async (text: string) => {
    try {
      setIsSpeaking(true)
      
      const { data, error } = await supabase.functions.invoke('text-to-speech', {
        body: {
          text: text,
          voice: 'Vivien'
        }
      })

      if (error) {
        throw new Error(error.message || 'ElevenLabs TTS hiba')
      }

      // Play the audio
      if (data) {
        const audio = new Audio()
        const blob = new Blob([new Uint8Array(data)], { type: 'audio/mpeg' })
        const audioUrl = URL.createObjectURL(blob)
        audio.src = audioUrl
        
        audio.onended = () => {
          setIsSpeaking(false)
          URL.revokeObjectURL(audioUrl)
        }
        
        audio.onerror = () => {
          setIsSpeaking(false)
          URL.revokeObjectURL(audioUrl)
          throw new Error('Audio playback error')
        }
        
        await audio.play()
      }
    } catch (error) {
      setIsSpeaking(false)
      throw error
    }
  }

  const speakText = async (text: string) => {
    if ('speechSynthesis' in window) {
      setIsSpeaking(true)
      
      // Cancel any ongoing speech
      window.speechSynthesis.cancel();
      
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = 'hu-HU';
      utterance.rate = 0.9;
      utterance.pitch = 1;
      
      // Try to find a Hungarian voice
      const voices = window.speechSynthesis.getVoices();
      const hungarianVoice = voices.find(voice => voice.lang.startsWith('hu'));
      if (hungarianVoice) {
        utterance.voice = hungarianVoice;
      }
      
      utterance.onend = () => {
        setIsSpeaking(false)
      }
      
      utterance.onerror = () => {
        setIsSpeaking(false)
      }
      
      window.speechSynthesis.speak(utterance);
    }
  }

  const stopSpeaking = () => {
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel()
      setIsSpeaking(false)
    }
  }

  const initSpeechRecognition = () => {
    if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) {
      console.warn('Speech recognition not supported')
      return
    }
    
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    recognitionRef.current = new SpeechRecognition()
    
    recognitionRef.current.lang = 'hu-HU'
    recognitionRef.current.continuous = false
    recognitionRef.current.interimResults = false
    
    recognitionRef.current.onresult = (event: any) => {
      const transcript = event.results[0][0].transcript
      setInput(transcript)
      // Auto-send message when using voice input
      setTimeout(() => {
        handleSendMessage(transcript)
      }, 500)
      setIsListening(false)
    }
    
    recognitionRef.current.onerror = (event: any) => {
      console.error('Speech recognition error:', event.error)
      setIsListening(false)
      toast.error(`Beszéd felismerési hiba: ${event.error}`)
    }
    
    recognitionRef.current.onend = () => {
      setIsListening(false)
    }
  }

  const toggleListening = () => {
    if (isListening) {
      recognitionRef.current?.stop()
      setIsListening(false)
    } else {
      try {
        recognitionRef.current?.start()
        setIsListening(true)
        toast.success('Beszéd felismerés elindítva')
      } catch (error) {
        console.error('Error starting speech recognition:', error)
        toast.error('Hiba a beszéd felismerés indításakor')
      }
    }
  }

  const toggleSpeakResponses = () => {
    if (isSpeaking) {
      // If currently speaking, stop it
      stopSpeaking()
    } else {
      // Toggle the setting
      const newSpeakResponses = !settings.speakResponses
      setSettings(prev => ({ ...prev, speakResponses: newSpeakResponses }))
      
      if (newSpeakResponses) {
        toast.success('Hangos válaszok bekapcsolva')
        speakText('Hangos válaszok bekapcsolva.')
      } else {
        toast.success('Hangos válaszok kikapcsolva')
      }
    }
  }

  const clearChat = () => {
    stopSpeaking()
    setMessages([{
      id: Date.now().toString(),
      role: 'assistant',
      content: 'Üdvözlöm! Vivien vagyok, a Szemesi Pékség Kft. AI asszisztense. Segíthetek kérdések megválaszolásában, rendelések felvételében, készlet ellenőrzésében, és minden egyéb pékséggel kapcsolatos feladatban. Miben segíthetek?',
      timestamp: new Date()
    }])
    toast.success('Chat törölve')
  }

  return (
    <div className="flex flex-col h-[calc(100vh-8rem)]">
      {/* Header */}
      <div className="flex justify-between items-center mb-6 p-6 bg-white dark:bg-gray-800 rounded-2xl shadow-sm border border-gray-200 dark:border-gray-700">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white flex items-center">
            <Bot className="h-8 w-8 mr-3 text-amber-600" />
            Vivien AI Asszisztens
          </h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">
            Szemesi Pékség Kft. intelligens asszisztense
          </p>
        </div>
        <div className="flex space-x-2">
          <button
            onClick={toggleTheme}
            className="p-2 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
            title={theme === 'dark' ? 'Világos téma' : 'Sötét téma'}
          >
            {theme === 'dark' ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
          </button>
          <button
            onClick={toggleSpeakResponses}
            className={`p-2 rounded-full transition-colors ${
              isSpeaking 
                ? 'text-red-600 hover:text-red-700 bg-red-100 dark:bg-red-900/20' 
                : settings.speakResponses 
                  ? 'text-green-600 hover:text-green-700 bg-green-100 dark:bg-green-900/20'
                  : 'text-red-600 hover:text-red-700 bg-red-100 dark:bg-red-900/20'
            }`}
            title={
              isSpeaking 
                ? 'Beszéd leállítása' 
                : settings.speakResponses 
                  ? 'Hangos válaszok kikapcsolása' 
                  : 'Hangos válaszok bekapcsolása'
            }
          >
            {isSpeaking ? (
              <VolumeX className="h-5 w-5" />
            ) : settings.speakResponses ? (
              <Volume2 className="h-5 w-5" />
            ) : (
              <VolumeX className="h-5 w-5" />
            )}
          </button>
          <button
            onClick={clearChat}
            className="p-2 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
            title="Chat törlése"
          >
            <Trash2 className="h-5 w-5" />
          </button>
          <button
            onClick={() => setShowSettings(true)}
            className="p-2 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
            title="Beállítások"
          >
            <Settings className="h-5 w-5" />
          </button>
        </div>
      </div>

      {/* Chat Container */}
      <div className="flex-1 bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden flex flex-col">
        {/* Messages */}
        <div className="flex-1 overflow-y-auto mb-4 space-y-4">
          {messages.map((message) => (
            <div 
              key={message.id} 
              className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div 
                className={`max-w-3xl rounded-2xl px-4 py-3 ${
                  message.role === 'user' 
                    ? 'bg-amber-600 text-white' 
                    : 'bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-white'
                }`}
              >
                <div className="whitespace-pre-wrap">{message.content}</div>
                <div className={`text-xs mt-1 ${
                  message.role === 'user' 
                    ? 'text-amber-200' 
                    : 'text-gray-500 dark:text-gray-400'
                }`}>
                  {message.timestamp.toLocaleTimeString('hu-HU')}
                </div>
              </div>
            </div>
          ))}
          {loading && (
            <div className="flex justify-start">
              <div className="bg-gray-100 dark:bg-gray-700 rounded-2xl px-4 py-3">
                <div className="flex items-center space-x-2">
                  <RefreshCw className="h-4 w-4 animate-spin text-amber-600" />
                  <span className="text-gray-500 dark:text-gray-400">Vivien gondolkodik...</span>
                </div>
              </div>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>

        {/* Input */}
        <div className="flex items-center space-x-2">
          <button
            onClick={toggleListening}
            className={`p-3 rounded-full transition-colors ${
              isListening 
                ? 'bg-red-600 text-white animate-pulse' 
                : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'
            }`}
            title={isListening ? 'Beszéd felismerés leállítása' : 'Beszéd felismerés indítása'}
          >
            {isListening ? <MicOff className="h-5 w-5" /> : <Mic className="h-5 w-5" />}
          </button>
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && !loading && handleSendMessage()}
            placeholder="Írjon üzenetet Viviennek..."
            className="flex-1 px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400"
            disabled={loading}
          />
          <button
            onClick={() => handleSendMessage()}
            disabled={loading || !input.trim()}
            className="p-3 bg-amber-600 text-white rounded-full hover:bg-amber-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            title="Üzenet küldése"
          >
            {loading ? <RefreshCw className="h-5 w-5 animate-spin" /> : <Send className="h-5 w-5" />}
          </button>
        </div>
      </div>

      {/* Settings Modal */}
      {showSettings && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white dark:bg-gray-800 rounded-lg max-w-md w-full">
            <div className="p-6">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-bold text-gray-900 dark:text-white">
                  Vivien AI Beállítások
                </h2>
                <button
                  onClick={() => setShowSettings(false)}
                  className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
                >
                  <X className="h-6 w-6" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    AI Modell
                  </label>
                  <select
                    value={settings.model}
                    onChange={(e) => setSettings(prev => ({ ...prev, model: e.target.value as AISettings['model'] }))}
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-amber-500 focus:border-amber-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  >
                    <option value="gemini-2.5-flash">Gemini 2.5 Flash (Ajánlott)</option>
                    <option value="gemini-1.5-flash">Gemini 1.5 Flash (Régi)</option>
                    <option value="gemini-pro">Gemini Pro (Elavult)</option>
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Kreativitás: {settings.temperature}
                  </label>
                  <input
                    type="range"
                    min="0"
                    max="1"
                    step="0.1"
                    value={settings.temperature}
                    onChange={(e) => setSettings(prev => ({ ...prev, temperature: parseFloat(e.target.value) }))}
                    className="w-full"
                  />
                  <div className="flex justify-between text-xs text-gray-500 dark:text-gray-400">
                    <span>Precíz</span>
                    <span>Kreatív</span>
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Maximum válasz hossz: {settings.maxTokens}
                  </label>
                  <input
                    type="range"
                    min="100"
                    max="4000"
                    step="100"
                    value={settings.maxTokens}
                    onChange={(e) => setSettings(prev => ({ ...prev, maxTokens: parseInt(e.target.value) }))}
                    className="w-full"
                  />
                  <div className="flex justify-between text-xs text-gray-500 dark:text-gray-400">
                    <span>Rövid</span>
                    <span>Hosszú</span>
                  </div>
                </div>
                
                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="speakResponses"
                    checked={settings.speakResponses}
                    onChange={() => setSettings(prev => ({ ...prev, speakResponses: !prev.speakResponses }))}
                    className="h-4 w-4 text-amber-600 focus:ring-amber-500 border-gray-300 rounded"
                  />
                  <label htmlFor="speakResponses" className="ml-2 block text-sm text-gray-700 dark:text-gray-300">
                    Hangos válaszok (Vivien hangján)
                  </label>
                </div>
              </div>

              <div className="flex justify-end space-x-3 mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
                <button
                  onClick={() => setShowSettings(false)}
                  className="px-4 py-2 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                >
                  Bezárás
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

// Add these interfaces to make TypeScript happy
declare global {
  interface Window {
    SpeechRecognition?: typeof SpeechRecognition
    webkitSpeechRecognition?: typeof SpeechRecognition
  }
}