import React, { useState, useEffect, useCallback, useRef } from 'react'
import {
  Loader, RefreshCw, AlertCircle, TrendingUp, DollarSign, Zap,
  Wifi, WifiOff, Monitor, Settings, ChevronDown, Plus, Trash2,
  Edit2, Check, X, Banknote, ArrowDownCircle, Printer,
} from 'lucide-react'
import {
  cashmaticSessionStatus, cashmaticLogin, cashmaticDeviceInfo, cashmaticAllLevels,
  cashmaticActiveTransaction, cashmaticLastTransaction, cashmaticWithdrawal,
  getDevices, addDevice, updateDevice, deleteDevice, testDevice,
  formatHUF, toCents, fromCents,
  type DeviceConfig, type CashmaticLevel, type CashmaticDeviceInfo, type CashmaticTransaction,
} from '../lib/cashmaticApi'
import { useTheme } from '../contexts/ThemeContext'
import { toast } from 'react-hot-toast'

type Tab = 'overview' | 'levels' | 'registers' | 'withdrawal' | 'printer'

export default function Cashmatic() {
  const { theme } = useTheme()
  const dark = theme === 'dark'

  // Kapcsolat állapot
  const [online, setOnline] = useState<boolean | null>(null)
  const [loading, setLoading] = useState(true)

  // Eszköz adatok
  const [selectedDeviceId, setSelectedDeviceId] = useState('default')
  const [devices, setDevices] = useState<DeviceConfig[]>([])
  const [deviceInfo, setDeviceInfo] = useState<CashmaticDeviceInfo | null>(null)
  const [levels, setLevels] = useState<CashmaticLevel[]>([])
  const [activeTransaction, setActiveTransaction] = useState<CashmaticTransaction | null>(null)
  const [lastTransaction, setLastTransaction] = useState<CashmaticTransaction | null>(null)

  // UI
  const [activeTab, setActiveTab] = useState<Tab>('overview')
  const [showDeviceMenu, setShowDeviceMenu] = useState(false)
  const [showAddDevice, setShowAddDevice] = useState(false)

  // Kifizetés
  const [withdrawalAmount, setWithdrawalAmount] = useState('')
  const [withdrawalReason, setWithdrawalReason] = useState('Kifizetés')
  const [withdrawalLoading, setWithdrawalLoading] = useState(false)

  // IP Nyomtató beállítások
  const [printerIp, setPrinterIp] = useState(() => localStorage.getItem('printer_ip') || import.meta.env.VITE_PRINTER_IP || '192.168.2.30')
  const [printerPort, setPrinterPort] = useState(() => localStorage.getItem('printer_port') || import.meta.env.VITE_PRINTER_PORT || '9100')
  const [printerName, setPrinterName] = useState(() => localStorage.getItem('printer_name') || import.meta.env.VITE_PRINTER_NAME || 'HP Nyomtató')
  const [printerProtocol, setPrinterProtocol] = useState(() => localStorage.getItem('printer_protocol') || 'RAW')
  const [printerSaved, setPrinterSaved] = useState(false)

  // Új eszköz form
  const [newDevice, setNewDevice] = useState({ id: '', name: '', ip: '', port: '50301', protocol: 'https', username: '', password: '' })

  const pollRef = useRef<NodeJS.Timeout>()

  // ─── Init ─────────────────────────────────────────────────────────────────

  useEffect(() => {
    init()
    return () => clearInterval(pollRef.current)
  }, [])

  useEffect(() => {
    if (online) loadDeviceData()
  }, [selectedDeviceId, online])

  async function init() {
    setLoading(true)
    try {
      await loadDevices()
      const isOnline = await cashmaticSessionStatus(selectedDeviceId)
      if (!isOnline) {
        const ok = await cashmaticLogin(selectedDeviceId)
        setOnline(ok)
        if (!ok) { toast.error('Cashmatic nem elérhető'); return }
      } else {
        setOnline(true)
      }
      toast.success('✓ Cashmatic kapcsolat OK')
      await loadDeviceData()
      // Polling 5 másodpercenként
      pollRef.current = setInterval(() => loadDeviceData(), 5000)
    } catch (e: any) {
      setOnline(false)
      toast.error('Cashmatic hiba: ' + e.message)
    } finally {
      setLoading(false)
    }
  }

  async function loadDevices() {
    const devs = await getDevices()
    setDevices(devs)
  }

  async function loadDeviceData() {
    try {
      const [info, lvls, activeTx, lastTx] = await Promise.all([
        cashmaticDeviceInfo(selectedDeviceId),
        cashmaticAllLevels(selectedDeviceId),
        cashmaticActiveTransaction(selectedDeviceId),
        cashmaticLastTransaction(selectedDeviceId),
      ])
      setDeviceInfo(info)
      setLevels(lvls)
      setActiveTransaction(activeTx)
      setLastTransaction(lastTx)
    } catch (e: any) {
      console.error('Adatbetöltés hiba:', e.message)
    }
  }

  async function handleRefresh() {
    setLoading(true)
    await loadDeviceData()
    setLoading(false)
    toast.success('Frissítve')
  }

  async function handleWithdrawal() {
    const amount = parseFloat(withdrawalAmount)
    if (!amount || amount <= 0) { toast.error('Adj meg érvényes összeget!'); return }
    setWithdrawalLoading(true)
    try {
      const r = await cashmaticWithdrawal(toCents(amount), withdrawalReason, selectedDeviceId)
      if (r.success) {
        toast.success(`✅ Kifizetés elindítva: ${formatHUF(amount)}`)
        setWithdrawalAmount('')
        await loadDeviceData()
      } else {
        toast.error('Kifizetés hiba: ' + (r.message ?? 'Ismeretlen hiba'))
      }
    } catch (e: any) {
      toast.error('Kifizetés hiba: ' + e.message)
    } finally {
      setWithdrawalLoading(false)
    }
  }

  async function handleAddDevice() {
    if (!newDevice.id || !newDevice.name || !newDevice.ip || !newDevice.username || !newDevice.password)
      return toast.error('Minden mező kötelező!')
    const r = await addDevice(newDevice)
    if (r.success) {
      toast.success('Eszköz hozzáadva!')
      setShowAddDevice(false)
      setNewDevice({ id: '', name: '', ip: '', port: '50301', protocol: 'https', username: '', password: '' })
      await loadDevices()
    } else toast.error(r.message ?? 'Hiba')
  }

  async function handleTestDevice(id: string) {
    const r = await testDevice(id)
    toast(r.message, { icon: r.success ? '✅' : '❌' })
  }

  async function handleDeleteDevice(id: string) {
    if (!confirm('Biztosan törlöd?')) return
    const r = await deleteDevice(id)
    if (r.success) { toast.success('Eszköz törölve'); await loadDevices() }
    else toast.error(r.message ?? 'Hiba')
  }

  // ─── Styles ────────────────────────────────────────────────────────────────

  const card = `rounded-2xl p-6 border ${dark ? 'bg-gray-800 border-gray-700' : 'bg-white border-gray-200'}`
  const tabBtn = (t: Tab) =>
    `px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
      activeTab === t
        ? 'bg-blue-600 text-white'
        : dark ? 'text-gray-300 hover:bg-gray-700' : 'text-gray-600 hover:bg-gray-100'
    }`

  // ─── Loading state ─────────────────────────────────────────────────────────

  if (loading && online === null) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="text-center">
          <Loader className="h-12 w-12 animate-spin text-blue-600 mx-auto mb-4" />
          <p className="text-gray-600 dark:text-gray-400">Cashmatic csatlakozás…</p>
        </div>
      </div>
    )
  }

  if (online === false) {
    return (
      <div className="bg-red-50 dark:bg-red-900/20 rounded-2xl p-6 border border-red-200 dark:border-red-800">
        <div className="flex items-center gap-3 text-red-700 dark:text-red-400 mb-4">
          <AlertCircle className="h-6 w-6" />
          <div>
            <p className="font-semibold">Cashmatic nem elérhető</p>
            <p className="text-sm">
              A proxy szerver (localhost:3001) nem fut, vagy a Cashmatic gép ki van kapcsolva.
            </p>
          </div>
        </div>
        <button onClick={init} className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg">
          Újra próbálja
        </button>
      </div>
    )
  }

  // ─── Render ────────────────────────────────────────────────────────────────

  return (
    <div className="space-y-6">

      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white flex items-center gap-3">
            <Monitor className="h-8 w-8 text-blue-600" />
            Cashmatic Pénztárgép
          </h1>
          <p className="text-gray-600 dark:text-gray-400 mt-1">
            Valós idejű pénztárgép adatok és kezelés
          </p>
        </div>
        <div className="flex items-center gap-3">
          {/* Online badge */}
          <span className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-medium ${
            online ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
          }`}>
            {online ? <Wifi className="h-4 w-4" /> : <WifiOff className="h-4 w-4" />}
            {online ? 'Online' : 'Offline'}
          </span>

          {/* Kassza választó */}
          <div className="relative">
            <button
              onClick={() => setShowDeviceMenu(v => !v)}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border text-sm border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50"
            >
              <Monitor className="h-4 w-4 text-blue-500" />
              {devices.find(d => d.id === selectedDeviceId)?.name ?? 'Főpénztár'}
              <ChevronDown className="h-3.5 w-3.5 text-gray-400" />
            </button>
            {showDeviceMenu && (
              <div className="absolute right-0 top-full mt-1 z-50 w-48 bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 shadow-lg">
                {devices.map(d => (
                  <button
                    key={d.id}
                    onClick={() => { setSelectedDeviceId(d.id); setShowDeviceMenu(false) }}
                    className={`w-full text-left px-4 py-2 text-sm hover:bg-gray-50 dark:hover:bg-gray-700 ${
                      d.id === selectedDeviceId ? 'font-semibold text-blue-600' : 'text-gray-700 dark:text-gray-300'
                    }`}
                  >
                    {d.name}
                  </button>
                ))}
              </div>
            )}
          </div>

          <button
            onClick={handleRefresh}
            disabled={loading}
            className="p-2 text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded-lg transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`h-5 w-5 ${loading ? 'animate-spin' : ''}`} />
          </button>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-2">
        {(['overview', 'levels', 'registers', 'withdrawal', 'printer'] as Tab[]).map(t => (
          <button key={t} className={tabBtn(t)} onClick={() => setActiveTab(t)}>
            {t === 'overview' && '📋 Áttekintés'}
            {t === 'levels' && '💰 Pénzszintek'}
            {t === 'registers' && '🖥️ Kasszák'}
            {t === 'withdrawal' && '💸 Kifizetés'}
            {t === 'printer' && '🖨️ Nyomtató'}
          </button>
        ))}
      </div>

      {/* Tab: Áttekintés */}
      {activeTab === 'overview' && (
        <div className="space-y-4">

          {/* Aktív tranzakció */}
          {activeTransaction && (activeTransaction.operation ?? '').toLowerCase() !== 'idle' && (
            <div className="bg-blue-50 dark:bg-blue-900/20 rounded-2xl p-6 border border-blue-200 dark:border-blue-800">
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center">
                <Zap className="h-5 w-5 mr-2 text-blue-600" />
                🔄 Aktív Tranzakció
              </h2>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {[
                  ['Operáció', activeTransaction.operation, 'text-gray-900 dark:text-white'],
                  ['Kért összeg', formatHUF(fromCents(activeTransaction.requested ?? 0)), 'text-gray-900 dark:text-white'],
                  ['Bedobott', formatHUF(fromCents(activeTransaction.inserted ?? 0)), 'text-green-600'],
                  ['Kiadott', formatHUF(fromCents(activeTransaction.dispensed ?? 0)), 'text-blue-600'],
                ].map(([label, value, cls]) => (
                  <div key={label as string}>
                    <p className="text-xs text-gray-600 dark:text-gray-400">{label}</p>
                    <p className={`font-semibold ${cls}`}>{value}</p>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Device Info */}
          {deviceInfo && (
            <div className={card}>
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                📋 Eszköz Információ
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {[
                  ['Eszköz Név', deviceInfo.deviceName],
                  ['Modell', deviceInfo.model],
                  ['Sorozatszám', deviceInfo.serialNumber],
                  ['Státusz', deviceInfo.statusMessage],
                ].map(([label, value]) => (
                  <div key={label}>
                    <p className="text-sm text-gray-600 dark:text-gray-400">{label}</p>
                    <p className="font-semibold text-gray-900 dark:text-white">{value ?? '–'}</p>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Utolsó tranzakció */}
          {lastTransaction && (
            <div className={card}>
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                <TrendingUp className="h-5 w-5 text-green-600" />
                Utolsó Tranzakció
              </h2>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                <div>
                  <p className="text-gray-500 dark:text-gray-400">Típus</p>
                  <p className="font-medium text-gray-900 dark:text-white">{lastTransaction.operation}</p>
                </div>
                <div>
                  <p className="text-gray-500 dark:text-gray-400">Összeg</p>
                  <p className="font-medium text-green-600">{formatHUF(fromCents(lastTransaction.requested ?? 0))}</p>
                </div>
              </div>
            </div>
          )}

          {!deviceInfo && !activeTransaction && (
            <div className="text-center py-12 text-gray-400">
              <AlertCircle className="h-12 w-12 mx-auto mb-3" />
              <p>Adatok betöltése…</p>
            </div>
          )}
        </div>
      )}

      {/* Tab: Pénzszintek */}
      {activeTab === 'levels' && (
        <div className={card}>
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <DollarSign className="h-5 w-5 text-green-600" />
            💰 Pénz Szintek
          </h2>
          {levels.length === 0 ? (
            <p className="text-gray-500 text-center py-8">Nincs adat</p>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {levels.map((level, idx) => {
                const pct = level.maxLevel > 0 ? Math.min((level.level / level.maxLevel) * 100, 100) : 0
                return (
                  <div key={idx} className={`rounded-xl p-4 border ${dark ? 'bg-gray-700 border-gray-600' : 'bg-gray-50 border-gray-200'}`}>
                    <div className="flex justify-between mb-2">
                      <p className="font-semibold text-gray-900 dark:text-white">{level.type ?? 'Denom'}</p>
                      <p className="text-sm text-gray-500">{level.currency}</p>
                    </div>
                    <div className="space-y-1 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-500">Aktuális:</span>
                        <span className="font-semibold text-gray-900 dark:text-white">{level.level}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-500">Max:</span>
                        <span className="font-semibold text-gray-900 dark:text-white">{level.maxLevel}</span>
                      </div>
                    </div>
                    <div className="mt-3 w-full bg-gray-300 dark:bg-gray-600 rounded-full h-2">
                      <div
                        className={`h-2 rounded-full transition-all ${
                          pct > 50 ? 'bg-green-500' : pct > 20 ? 'bg-yellow-500' : 'bg-red-500'
                        }`}
                        style={{ width: `${pct}%` }}
                      />
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </div>
      )}

      {/* Tab: Kasszák */}
      {activeTab === 'registers' && (
        <div className="space-y-4">
          <div className={card}>
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white">🖥️ Regisztrált Kasszák</h2>
              <button
                onClick={() => setShowAddDevice(v => !v)}
                className="flex items-center gap-1.5 px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm"
              >
                <Plus className="h-4 w-4" /> Új kassza
              </button>
            </div>

            {showAddDevice && (
              <div className={`mb-4 p-4 rounded-xl border ${dark ? 'bg-gray-700 border-gray-600' : 'bg-gray-50 border-gray-200'}`}>
                <h3 className="font-medium text-gray-900 dark:text-white mb-3">Új kassza hozzáadása</h3>
                <div className="grid grid-cols-2 gap-3">
                  {[
                    { key: 'id', label: 'ID', placeholder: 'kassza2' },
                    { key: 'name', label: 'Név', placeholder: '2. pénztár' },
                    { key: 'ip', label: 'IP cím', placeholder: '192.168.1.105' },
                    { key: 'port', label: 'Port', placeholder: '50301' },
                    { key: 'username', label: 'Felhasználó', placeholder: 'balint' },
                    { key: 'password', label: 'Jelszó', placeholder: '****' },
                  ].map(f => (
                    <div key={f.key}>
                      <label className="text-xs text-gray-500 mb-1 block">{f.label}</label>
                      <input
                        value={(newDevice as any)[f.key]}
                        onChange={e => setNewDevice(d => ({ ...d, [f.key]: e.target.value }))}
                        placeholder={f.placeholder}
                        type={f.key === 'password' ? 'password' : 'text'}
                        className="w-full px-3 py-1.5 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-sm text-gray-900 dark:text-white"
                      />
                    </div>
                  ))}
                </div>
                <div className="flex gap-2 mt-3">
                  <button onClick={handleAddDevice} className="px-4 py-1.5 bg-green-600 hover:bg-green-700 text-white rounded-lg text-sm">Mentés</button>
                  <button onClick={() => setShowAddDevice(false)} className="px-4 py-1.5 bg-gray-500 hover:bg-gray-600 text-white rounded-lg text-sm">Mégsem</button>
                </div>
              </div>
            )}

            <div className="space-y-3">
              {devices.map(d => (
                <div key={d.id} className={`flex items-center justify-between p-4 rounded-xl border ${dark ? 'bg-gray-700 border-gray-600' : 'bg-gray-50 border-gray-200'}`}>
                  <div>
                    <p className="font-medium text-gray-900 dark:text-white">{d.name}</p>
                    <p className="text-sm text-gray-500">{d.protocol}://{d.ip}:{d.port} · {d.username}</p>
                  </div>
                  <div className="flex gap-2">
                    <button
                      onClick={() => handleTestDevice(d.id)}
                      className="px-3 py-1.5 bg-blue-100 hover:bg-blue-200 text-blue-700 rounded-lg text-xs"
                    >Test</button>
                    {d.id !== 'default' && (
                      <button
                        onClick={() => handleDeleteDevice(d.id)}
                        className="p-1.5 text-red-500 hover:bg-red-50 rounded-lg"
                      ><Trash2 className="h-4 w-4" /></button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Tab: Kifizetés */}
      {activeTab === 'withdrawal' && (
        <div className={card}>
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <ArrowDownCircle className="h-5 w-5 text-orange-600" />
            💸 Kifizetés a gépből
          </h2>
          <p className="text-sm text-gray-500 dark:text-gray-400 mb-4">
            A Cashmatic gép a megadott összeget fogja kiadni.
          </p>
          <div className="space-y-4 max-w-md">
            <div>
              <label className="text-sm text-gray-600 dark:text-gray-400 mb-1 block">Összeg (Ft)</label>
              <input
                type="number"
                value={withdrawalAmount}
                onChange={e => setWithdrawalAmount(e.target.value)}
                placeholder="pl. 5000"
                className="w-full px-4 py-2 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label className="text-sm text-gray-600 dark:text-gray-400 mb-1 block">Ok / megjegyzés</label>
              <input
                type="text"
                value={withdrawalReason}
                onChange={e => setWithdrawalReason(e.target.value)}
                placeholder="Kifizetés"
                className="w-full px-4 py-2 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
            <button
              onClick={handleWithdrawal}
              disabled={withdrawalLoading || !withdrawalAmount}
              className="w-full py-3 bg-orange-600 hover:bg-orange-700 disabled:opacity-50 text-white rounded-xl font-semibold flex items-center justify-center gap-2"
            >
              {withdrawalLoading ? <Loader className="h-5 w-5 animate-spin" /> : <Banknote className="h-5 w-5" />}
              {withdrawalLoading ? 'Feldolgozás…' : 'Kifizetés indítása'}
            </button>
          </div>
        </div>
      )}

      {/* Tab: Nyomtató */}
      {activeTab === 'printer' && (
        <div className={card}>
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-1 flex items-center gap-2">
            <Printer className="h-5 w-5 text-blue-600" />
            IP Nyomtató beállítások
          </h2>
          <p className="text-sm text-gray-500 dark:text-gray-400 mb-6">
            Hálózati (IP) nyomtató konfigurálása a blokknyomtatáshoz.
            Az adatok a böngészőben kerülnek mentésre és az összes nyomtatási folyamat ezt fogja használni.
          </p>

          <div className="space-y-4 max-w-md">
            <div>
              <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1 block">Nyomtató neve</label>
              <input
                type="text"
                value={printerName}
                onChange={e => setPrinterName(e.target.value)}
                placeholder="pl. HP LaserJet"
                className="w-full px-4 py-2 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div>
              <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1 block">IP-cím</label>
              <input
                type="text"
                value={printerIp}
                onChange={e => setPrinterIp(e.target.value)}
                placeholder="192.168.2.30"
                className="w-full px-4 py-2 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white font-mono focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p className="text-xs text-gray-400 mt-1">A hálózati nyomtató IP-címe (HP859A35 → 192.168.2.30)</p>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1 block">Port</label>
                <input
                  type="text"
                  value={printerPort}
                  onChange={e => setPrinterPort(e.target.value)}
                  placeholder="9100"
                  className="w-full px-4 py-2 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white font-mono focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
                <p className="text-xs text-gray-400 mt-1">Általában 9100 (RAW)</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1 block">Protokoll</label>
                <select
                  value={printerProtocol}
                  onChange={e => setPrinterProtocol(e.target.value)}
                  className="w-full px-4 py-2 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="RAW">RAW / JetDirect (9100)</option>
                  <option value="IPP">IPP (631)</option>
                  <option value="LPD">LPD (515)</option>
                </select>
              </div>
            </div>

            <div className={`flex items-start gap-3 p-3 rounded-xl border ${
              printerProtocol === 'RAW'
                ? 'bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800'
                : 'bg-amber-50 dark:bg-amber-900/20 border-amber-200 dark:border-amber-800'
            }`}>
              <div className="text-sm">
                {printerProtocol === 'RAW' && (
                  <p className="text-blue-700 dark:text-blue-300">
                    <strong>RAW / JetDirect:</strong> Közvetlen nyomtatás a hálózaton (leggyorsabb). HP nyomtatókhoz ajánlott.
                    A szerver (server.js) net.Socket segítségével küld adatot a <code className="bg-blue-100 dark:bg-blue-800 px-1 rounded">{printerIp}:{printerPort}</code> címre.
                  </p>
                )}
                {printerProtocol === 'IPP' && (
                  <p className="text-amber-700 dark:text-amber-300">
                    <strong>IPP:</strong> Internet Printing Protocol. Ha a HP nyomtatón engedélyezve van, a port általában 631.
                  </p>
                )}
                {printerProtocol === 'LPD' && (
                  <p className="text-amber-700 dark:text-amber-300">
                    <strong>LPD:</strong> Line Printer Daemon. Régebbi protokoll, port: 515.
                  </p>
                )}
              </div>
            </div>

            {printerSaved && (
              <div className="flex items-center gap-2 text-green-600 dark:text-green-400 text-sm font-medium">
                <Check className="h-4 w-4" /> Mentve!
              </div>
            )}

            <div className="flex gap-3 pt-2">
              <button
                onClick={() => {
                  localStorage.setItem('printer_ip', printerIp)
                  localStorage.setItem('printer_port', printerPort)
                  localStorage.setItem('printer_name', printerName)
                  localStorage.setItem('printer_protocol', printerProtocol)
                  setPrinterSaved(true)
                  setTimeout(() => setPrinterSaved(false), 2500)
                  toast.success(`✅ Nyomtató mentve: ${printerName} (${printerIp}:${printerPort})`)
                }}
                className="flex-1 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-semibold flex items-center justify-center gap-2"
              >
                <Printer className="h-5 w-5" /> Mentés
              </button>
              <button
                onClick={() => {
                  const testMsg = `\x1B\x40Nyomtató teszt\n${printerName}\n${printerIp}:${printerPort}\n${new Date().toLocaleString('hu-HU')}\n\n\n`
                  navigator.clipboard.writeText(`Nyomtató IP: ${printerIp}:${printerPort}`)
                  toast(`ℹ️ IP a vágólapra másolva: ${printerIp}:${printerPort}\n\nA szerver oldali nyomtatás a server.js RAW socket küldéssel működik.`, { duration: 4000 })
                }}
                className="px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 flex items-center gap-2 text-sm"
              >
                <Wifi className="h-4 w-4" /> IP másolás
              </button>
            </div>

            <div className="mt-2 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-xl border border-gray-200 dark:border-gray-600 text-xs text-gray-500 dark:text-gray-400">
              <p className="font-semibold mb-1">💡 server.js nyomtatás aktiváláshoz add hozzá ezt a server.js-hez:</p>
              <pre className="text-xs font-mono bg-white dark:bg-gray-800 p-2 rounded-lg overflow-x-auto border border-gray-200 dark:border-gray-600 whitespace-pre-wrap">{`const net = require('net');
app.post('/api/print', (req, res) => {
  const { data } = req.body;
  const client = new net.Socket();
  client.connect(${printerPort}, '${printerIp}', () => {
    client.write(Buffer.from(data, 'base64'));
    client.end();
    res.json({ success: true });
  });
  client.on('error', e => res.status(500).json({ success: false, message: e.message }));
});`}</pre>
            </div>
          </div>
        </div>
      )}

    </div>
  )
}
