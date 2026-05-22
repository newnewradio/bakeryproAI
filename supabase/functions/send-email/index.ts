// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { SmtpClient } from "https://deno.land/x/smtp@v0.7.0/mod.ts" 

interface EmailRequest {
  to: string;
  subject: string;
  body: string;
  from?: string;
  replyTo?: string;
  attachments?: Array<{
    name: string;
    content: string;
    contentType: string;
  }>;
  smtpSettings: {
    host: string;
    port: number | string;
    user: string;
    pass: string;
    fromName?: string;
  };
}

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
    console.log("Email request received");
    const { to, subject, body, from, replyTo, attachments, smtpSettings } = await req.json() as EmailRequest

    // Validate required fields
    if (!to || !subject || !body || !smtpSettings) {
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

    console.log(`Connecting to SMTP server: ${smtpSettings.host}:${smtpSettings.port}`);

    // Configure SMTP client
    const client = new SmtpClient()
    
    await client.connectTLS({
      hostname: smtpSettings.host,
      port: Number(smtpSettings.port),
      username: smtpSettings.user,
      password: smtpSettings.pass,
    })

    console.log("Connected to SMTP server");

    // Prepare email options
    const emailOptions = {
      from: `${smtpSettings.fromName || 'Szemesi Pékség'} <${from || smtpSettings.user}>`,
      to: [to],
      subject: subject,
      content: body,
      html: body,
    }
    
    // Add attachments if provided
    if (attachments && attachments.length > 0) {
      emailOptions.attachments = attachments.map(attachment => {
        return {
          filename: attachment.name,
          content: Uint8Array.from(atob(attachment.content), c => c.charCodeAt(0)),
          contentType: attachment.contentType
        };
      });
    }

    console.log("Sending email");

    // Send email
    const sendResult = await client.send(emailOptions)
    console.log("Email sent successfully", sendResult);
    await client.close()

    // Log email to database
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    const { error: logError } = await supabase
      .from('sent_emails')
      .insert([{
        recipient_email: to,
        recipient_name: to.split('@')[0], 
        subject: subject,
        body: body,
        status: 'sent', 
        sent_at: new Date().toISOString() 
      }])

    if (logError) {
      console.error('Error logging email:', logError)
    }

    return new Response(
      JSON.stringify({ success: true, message: 'Email sent successfully', details: sendResult }),
      { 
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders
        }
      }
    )
  } catch (error) {
    console.error('Email sending error:', error)
    console.error('Error details:', error.message || error);
    
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