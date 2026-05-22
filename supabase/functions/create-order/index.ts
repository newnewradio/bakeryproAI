// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

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
    const { 
      customer_name, 
      customer_email, 
      customer_phone, 
      customer_address, 
      items, 
      payment_method = 'transfer',
      notes,
      location_id
    } = await req.json()

    // Validate required fields
    if (!customer_name || !items || !Array.isArray(items) || items.length === 0) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { 
          status: 400, 
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders
          } 
        }
      )
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Generate order number
    const orderNumber = `ORD-${Date.now()}`
    
    // Calculate total amount
    const totalAmount = items.reduce((sum: number, item: any) => {
      const quantity = item.quantity || 1
      const price = item.price || 0
      return sum + (quantity * price)
    }, 0)

    // Create order data
    const orderData = {
      order_number: orderNumber,
      customer_name,
      customer_email,
      customer_phone,
      customer_address,
      items,
      total_amount: totalAmount,
      payment_method,
      notes,
      status: 'pending',
      payment_status: 'pending',
      location_id,
      order_date: new Date().toISOString()
    }

    // Insert order into database
    const { data, error } = await supabase
      .from('orders')
      .insert([orderData])
      .select()

    if (error) {
      throw error
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Order created successfully', 
        order: data ? data[0] : orderData 
      }),
      { 
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders
        } 
      }
    )
  } catch (error) {
    console.error('Error creating order:', error)
    
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
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