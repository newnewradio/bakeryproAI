// supabase/functions/text-to-speech/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { text, voice = "Vivien" } = await req.json()

    if (!text) {
      console.error('No text provided')
      return new Response(
        JSON.stringify({ error: 'Text is required' }),
        { 
          status: 400, 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders
          } 
        }
      )
    }

    // Get ElevenLabs API key from environment
    const apiKey = Deno.env.get('ELEVENLABS_API_KEY')
    
    if (!apiKey) {
      console.error('ElevenLabs API key not found in environment variables')
      return new Response(
        JSON.stringify({ error: 'ElevenLabs API key not configured' }),
        { 
          status: 500, 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders
          } 
        }
      )
    }

    // Get voice ID based on voice name
    const voiceId = getVoiceId(voice)

    console.log(`Calling ElevenLabs API with voice: ${voice} (ID: ${voiceId})`)
    console.log(`Text length: ${text.length} characters`)
    console.log(`API key length: ${apiKey.length} characters`)

    const requestBody = {
      text,
      model_id: "eleven_monolingual_v1",
      voice_settings: {
        stability: 0.5,
        similarity_boost: 0.5,
        style: 0.0,
        use_speaker_boost: true
      }
    }

    console.log('Request body:', JSON.stringify(requestBody, null, 2))

    // Call ElevenLabs API
    const response = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`, {
      method: 'POST',
      headers: {
        'Accept': 'audio/mpeg',
        'Content-Type': 'application/json',
        'xi-api-key': apiKey
      },
      body: JSON.stringify(requestBody)
    })

    console.log(`ElevenLabs API response status: ${response.status}`)
    console.log(`ElevenLabs API response headers:`, Object.fromEntries(response.headers.entries()))

    if (!response.ok) {
      const errorText = await response.text()
      console.error('ElevenLabs API error response:', errorText)
      console.error('Status code:', response.status)
      console.error('Status text:', response.statusText)
      
      let errorMessage = `ElevenLabs API error: ${response.status} ${response.statusText}`
      
      // Parse specific error messages
      try {
        const errorData = JSON.parse(errorText)
        if (errorData.detail) {
          errorMessage = `ElevenLabs API error: ${errorData.detail}`
        } else if (errorData.message) {
          errorMessage = `ElevenLabs API error: ${errorData.message}`
        }
        console.log('Parsed error data:', errorData)
      } catch (e) {
        console.log('Could not parse error response as JSON, using raw text')
        if (errorText) {
          errorMessage = `ElevenLabs API error: ${errorText}`
        }
      }
      
      return new Response(
        JSON.stringify({ 
          error: errorMessage,
          status: response.status,
          statusText: response.statusText,
          details: errorText
        }),
        { 
          status: response.status, 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders
          } 
        }
      )
    }

    // Get audio data
    const audioData = await response.arrayBuffer()
    
    if (!audioData || audioData.byteLength === 0) {
      console.error('No audio data received from ElevenLabs')
      return new Response(
        JSON.stringify({ error: 'No audio data received from ElevenLabs' }),
        { 
          status: 500, 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders
          } 
        }
      )
    }

    console.log(`Audio data received: ${audioData.byteLength} bytes`)
    
    // Return audio data with proper headers
    return new Response(
      audioData,
      { 
        headers: { 
          'Content-Type': 'audio/mpeg',
          'Content-Length': audioData.byteLength.toString(),
          'Cache-Control': 'no-cache',
          ...corsHeaders
        } 
      }
    )
  } catch (error) {
    console.error('Error in text-to-speech function:', error)
    console.error('Error stack:', error.stack)
    
    return new Response(
      JSON.stringify({ 
        error: error.message || 'Internal server error',
        details: error.stack,
        type: error.constructor.name
      }),
      { 
        status: 500, 
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders
        } 
      }
    )
  }
})

// Function to get voice ID based on voice name
function getVoiceId(voice: string): string {
  const voices: { [key: string]: string } = {
    "Vivien": "xjlfQQ3ynqiEyRpArrT8", // Ugyanaz mint Vera
  }
  
  return voices[voice] || voices["Vivien"] // Default to Vera if voice not found
}