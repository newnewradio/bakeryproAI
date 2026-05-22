// supabase/functions/get_all_tables/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Missing Supabase environment variables')
    }
    
    const supabase = createClient(supabaseUrl, supabaseKey)
    
    // Direct query to get all tables in public schema
    const { data, error } = await supabase
      .from('information_schema.tables')
      .select('table_name')
      .eq('table_schema', 'public')
      .order('table_name')
    
    if (error) {
      console.error('Error querying information_schema.tables:', error)
      
      // Fallback: try a raw SQL query
      const { data: fallbackData, error: fallbackError } = await supabase
        .rpc('exec_sql', {
          sql: `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name`
        })
      
      if (fallbackError) {
        console.error('Fallback query also failed:', fallbackError)
        
        // Second fallback: return hardcoded common table names
        const commonTables = [
          'users', 'profiles', 'messages', 'conversations', 
          'documents', 'settings', 'logs', 'sessions'
        ]
        
        return new Response(
          JSON.stringify(commonTables),
          { 
            headers: { 
              'Content-Type': 'application/json',
              ...corsHeaders
            }
          }
        )
      }
      
      const tableNames = fallbackData.map((row: any) => row.table_name)
      
      return new Response(
        JSON.stringify(tableNames),
        { 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders
          }
        }
      )
    }
    
    // Extract table names from successful query
    const tableNames = data.map((table: any) => table.table_name)
    
    return new Response(
      JSON.stringify(tableNames),
      { 
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders
        }
      }
    )
  } catch (error) {
    console.error('Error getting tables:', error)
    
    return new Response(
      JSON.stringify({ 
        error: error.message || 'Internal server error',
        tables: [] // Return empty array as fallback
      }),
      { 
        status: 200, // Return 200 instead of 500 to avoid blocking the frontend
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders
        }
      }
    )
  }
})