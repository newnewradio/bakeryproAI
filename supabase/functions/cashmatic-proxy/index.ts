import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

// Cashmatic eszköz beállítások — ezeket a Supabase Dashboard Secrets-ben kell beállítani
const CASHMATIC_HOST = Deno.env.get('CASHMATIC_PROTOCOL') + '://' + Deno.env.get('CASHMATIC_SERVER_IP') + ':' + Deno.env.get('CASHMATIC_PORT')

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// SSL ellenőrzés kihagyása a helyi Cashmatic eszköznél
// Deno Edge Function-ban nincs közvetlen lehetőség a rejectUnauthorized=false beállítására,
// ezért a CASHMATIC_PROTOCOL=http-t ajánljuk, vagy VPN-en belüli deploy esetén
async function proxyToCashmatic(endpoint: string, body?: object) {
  const url = CASHMATIC_HOST + endpoint
  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: body ? JSON.stringify(body) : undefined,
  })
  return response.json()
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const url = new URL(req.url)
  const path = url.pathname.replace('/cashmatic-proxy', '')

  try {
    const body = req.method !== 'GET' ? await req.json() : {}

    let result: unknown
    const { token } = body

    switch (path) {
      case '/login':
        result = await proxyToCashmatic('/api/user/Login', { username: body.username, password: body.password })
        break
      case '/renew-token':
        result = await fetch(CASHMATIC_HOST + '/api/user/RenewToken', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        }).then(r => r.json())
        break
      case '/all-levels':
        result = await fetch(CASHMATIC_HOST + '/api/device/AllLevels', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` },
        }).then(r => r.json())
        break
      case '/active-transaction':
        result = await fetch(CASHMATIC_HOST + '/api/device/ActiveTransaction', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` },
        }).then(r => r.json())
        break
      case '/last-transaction':
        result = await fetch(CASHMATIC_HOST + '/api/device/LastTransaction', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` },
        }).then(r => r.json())
        break
      case '/device-info':
        result = await fetch(CASHMATIC_HOST + '/api/device/GetDeviceInfo', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` },
        }).then(r => r.json())
        break
      case '/start-payment':
        result = await fetch(CASHMATIC_HOST + '/api/transaction/StartPayment', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
          body: JSON.stringify({ amount: body.amount, queueAllowed: body.queueAllowed ?? false, timeout: body.timeout ?? 60 }),
        }).then(r => r.json())
        break
      case '/cancel-payment':
        result = await fetch(CASHMATIC_HOST + '/api/transaction/CancelPayment', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` },
        }).then(r => r.json())
        break
      case '/commit-payment':
        result = await fetch(CASHMATIC_HOST + '/api/transaction/CommitPayment', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` },
        }).then(r => r.json())
        break
      case '/start-refill':
        result = await fetch(CASHMATIC_HOST + '/api/transaction/StartRefill', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
          body: JSON.stringify({ reason: body.reason ?? 'DEFAULT_REASON', reference: body.reference ?? 'DEFAULT_REFERENCE' }),
        }).then(r => r.json())
        break
      case '/stop-refill':
        result = await fetch(CASHMATIC_HOST + '/api/transaction/StopRefill', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token}` },
        }).then(r => r.json())
        break
      case '/start-withdrawal':
        result = await fetch(CASHMATIC_HOST + '/api/transaction/StartWithdrawal', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
          body: JSON.stringify({ amount: body.amount, reason: body.reason ?? 'DEFAULT_REASON', reference: body.reference ?? 'DEFAULT_REFERENCE' }),
        }).then(r => r.json())
        break
      case '/empty-cashbox':
        result = await fetch(CASHMATIC_HOST + '/api/transaction/StartEmptyCashboxNotes', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
          body: JSON.stringify({ reason: 'DEFAULT_REASON', reference: 'DEFAULT_REFERENCE' }),
        }).then(r => r.json())
        break
      case '/report':
        result = await fetch(CASHMATIC_HOST + '/api/report/GetTransactions', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
          body: JSON.stringify({ startTime: body.startTime, endTime: body.endTime }),
        }).then(r => r.json())
        break
      default:
        return new Response(JSON.stringify({ error: 'Ismeretlen endpoint: ' + path }), {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
