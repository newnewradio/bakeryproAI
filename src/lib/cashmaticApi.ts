/**
 * Cashmatic API – Admin felület számára
 * A proxy szerver (server.js) port 3001-en fut.
 * Session kezelés szerver oldalon történik – nincs token a kliensben.
 */

// Port 3001 – a Cashmatic proxy szerver
// FONTOS: ha az admin és a proxy szerver különböző gépen fut,
// állítsd be a VITE_CASHMATIC_PROXY_URL env változót!
// Pl. VITE_CASHMATIC_PROXY_URL=http://192.168.2.XXX:3001
export function getCashmaticBaseUrl(): string {
  // 1. Explicit env konfig (legmegbízhatóbb)
  const envUrl = import.meta.env.VITE_CASHMATIC_PROXY_URL
  if (envUrl) return `${envUrl.replace(/\/$/, '')}/api`

  // 2. Ha localhost-ról nyitják → proxy is localhost-on fut
  if (typeof window !== 'undefined' && window.location.hostname === 'localhost') {
    return 'http://localhost:3001/api'
  }

  // 3. Különböző gépek esetén: az adminnak tudnia kell a proxy IP-jét
  // Fallback: ugyanaz a host mint az admin (csak ha egy gépen fut minden)
  return `http://${window.location.hostname}:3001/api`
}

export interface DeviceConfig {
  id: string
  name: string
  ip: string
  port: string
  protocol: string
  username: string
}

export interface CashmaticLevel {
  value: number
  currency: string
  level: number
  floatLevel: number
  maxLevel: number
  type: string
  routing: string
}

export interface CashmaticDeviceInfo {
  deviceName: string
  model: string
  serialNumber: string
  vpnAddress: string
  statusMessage: string
  errorCode: number
  errorMessage: string
  functionalityCode: number
  functionalityMessage: string
}

export interface CashmaticTransaction {
  id: number
  operation: string
  operationInfo: string
  requested: number
  inserted: number
  dispensed: number
  notDispensed: number
  currency: string
  operationPercentage: number
}

// ─── HTTP helpers ─────────────────────────────────────────────────────────────

async function get(endpoint: string, deviceId = 'default'): Promise<any> {
  const BASE = getCashmaticBaseUrl()
  const qs = deviceId !== 'default' ? `?deviceId=${encodeURIComponent(deviceId)}` : ''
  try {
    const res = await fetch(`${BASE}/${endpoint}${qs}`)
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    return await res.json()
  } catch (e: any) {
    if (e instanceof TypeError) throw new Error(`Cashmatic szerver nem elérhető (${BASE})`)
    throw e
  }
}

async function post(endpoint: string, body?: object, deviceId = 'default'): Promise<any> {
  const BASE = getCashmaticBaseUrl()
  const qs = deviceId !== 'default' ? `?deviceId=${encodeURIComponent(deviceId)}` : ''
  try {
    const res = await fetch(`${BASE}/${endpoint}${qs}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: body ? JSON.stringify(body) : undefined,
    })
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    return await res.json()
  } catch (e: any) {
    if (e instanceof TypeError) throw new Error(`Cashmatic szerver nem elérhető (${BASE})`)
    throw e
  }
}

// ─── Session / Login ──────────────────────────────────────────────────────────

/**
 * Bejelentkezés a szerveren keresztül.
 * A szerver maga kezeli a tokent – visszaadja hogy sikeres-e.
 */
export async function cashmaticLogin(deviceId = 'default'): Promise<boolean> {
  const r = await post('login', {}, deviceId)
  return r.success === true
}

export async function cashmaticSessionStatus(deviceId = 'default'): Promise<boolean> {
  try {
    const r = await get('session-status', deviceId)
    return r.isLoggedIn === true
  } catch {
    return false
  }
}

// ─── Eszköz info ──────────────────────────────────────────────────────────────

export async function cashmaticDeviceInfo(deviceId = 'default'): Promise<CashmaticDeviceInfo | null> {
  const r = await get('device-info', deviceId)
  return r.success ? (r.data ?? null) : null
}

export async function cashmaticAllLevels(deviceId = 'default'): Promise<CashmaticLevel[]> {
  const r = await get('levels', deviceId)
  return r.success ? (r.data ?? []) : []
}

export async function cashmaticActiveTransaction(deviceId = 'default'): Promise<CashmaticTransaction | null> {
  const r = await get('active-transaction', deviceId)
  return r.success ? (r.data ?? null) : null
}

export async function cashmaticLastTransaction(deviceId = 'default'): Promise<CashmaticTransaction | null> {
  const r = await get('last-transaction', deviceId)
  return r.success ? (r.data ?? null) : null
}

// ─── Eszköz kezelés ───────────────────────────────────────────────────────────

export async function getDevices(): Promise<DeviceConfig[]> {
  const r = await get('devices')
  return r.success ? (r.data ?? []) : []
}

export async function addDevice(cfg: {
  id: string; name: string; ip: string; port: string
  protocol?: string; username: string; password: string
}): Promise<{ success: boolean; message?: string }> {
  return post('devices', cfg)
}

export async function updateDevice(id: string, cfg: Partial<{
  name: string; ip: string; port: string; protocol: string; username: string; password: string
}>): Promise<{ success: boolean; message?: string }> {
  const BASE = getCashmaticBaseUrl()
  const res = await fetch(`${BASE}/devices/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(cfg),
  })
  return res.json()
}

export async function deleteDevice(id: string): Promise<{ success: boolean; message?: string }> {
  const BASE = getCashmaticBaseUrl()
  const res = await fetch(`${BASE}/devices/${id}`, { method: 'DELETE' })
  return res.json()
}

export async function testDevice(id: string, cfg?: {
  ip: string; port: string; protocol: string; username: string; password: string
}): Promise<{ success: boolean; message: string }> {
  const BASE = getCashmaticBaseUrl()
  const res = await fetch(`${BASE}/devices/${id}/test`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(cfg ?? {}),
  })
  return res.json()
}

// ─── Fizetés ─────────────────────────────────────────────────────────────────

export async function cashmaticStartPayment(
  amountInCents: number,
  deviceId = 'default'
): Promise<{ success: boolean; transactionId?: string; message?: string }> {
  return post('start-payment', { amount: amountInCents }, deviceId)
}

export async function cashmaticCancelPayment(deviceId = 'default'): Promise<{ success: boolean }> {
  return post('cancel-payment', {}, deviceId)
}

export async function cashmaticCommitPayment(deviceId = 'default'): Promise<{ success: boolean }> {
  return post('commit-payment', {}, deviceId)
}

// ─── Kifizetés ────────────────────────────────────────────────────────────────

export async function cashmaticWithdrawal(
  amountInCents: number,
  reason = 'Kifizetés',
  deviceId = 'default'
): Promise<{ success: boolean; message?: string }> {
  return post('withdrawal', { amount: amountInCents, reason, reference: 'Admin' }, deviceId)
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

export function formatHUF(amount: number): string {
  return new Intl.NumberFormat('hu-HU', {
    style: 'currency', currency: 'HUF',
    minimumFractionDigits: 0, maximumFractionDigits: 0,
  }).format(amount)
}

/** Forint → fillér (Cashmatic fillérben kér összeget) */
export function toCents(amount: number): number {
  return Math.round(amount * 100)
}

/** Fillér → forint */
export function fromCents(cents: number): number {
  return cents / 100
}
