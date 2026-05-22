import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { 
  ChefHat, Plus, Search, Clock, CheckCircle, XCircle, RefreshCw, 
  FileText, QrCode, Truck, Package, Calendar, Scale, ListChecks,
  ArrowRight, ChevronRight, AlertTriangle, X, CheckSquare,
  ClipboardList, Info, Eye, ChevronDown, TrendingUp, Users,
  Flame, Layers, BarChart2, ShoppingBag
} from 'lucide-react'
import { supabase } from '../lib/supabase'
import { toast } from 'react-hot-toast'
import ProductionSteps from '../components/Production/ProductionSteps'
import BarcodeScanner from '../components/Inventory/BarcodeScanner'

interface ProductionBatch {
  id: string
  batch_number: string
  recipe_id: string
  batch_size: number
  status: 'planned' | 'in_progress' | 'completed' | 'failed'
  start_time: string | null
  end_time: string | null
  actual_yield: number | null
  notes: string | null
  created_at: string
  products?: {
    id: string
    name: string
    category: string
    ingredients: any[]
    yield_amount: number
  }
  related_orders?: RelatedOrder[]
}

interface RelatedOrder {
  id: string
  order_number: string
  customer_name: string
  quantity: number
}

const STATUS_CONFIG: Record<string, { label: string; color: string; bg: string; dot: string }> = {
  planned:     { label: 'Tervezett',    color: 'text-amber-400',  bg: 'bg-amber-500/10 border-amber-500/30',  dot: 'bg-amber-400' },
  in_progress: { label: 'Folyamatban', color: 'text-blue-400',   bg: 'bg-blue-500/10 border-blue-500/30',    dot: 'bg-blue-400 animate-pulse' },
  completed:   { label: 'Kész',        color: 'text-emerald-400',bg: 'bg-emerald-500/10 border-emerald-500/30',dot: 'bg-emerald-400' },
  failed:      { label: 'Sikertelen',  color: 'text-red-400',    bg: 'bg-red-500/10 border-red-500/30',      dot: 'bg-red-400' },
}

export default function Production() {
  const navigate = useNavigate()
  const [batches, setBatches] = useState<ProductionBatch[]>([])
  const [loading, setLoading] = useState(true)
  const [steps, setSteps] = useState<any[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [filterStatus, setFilterStatus] = useState<string>('all')
  const [showAddModal, setShowAddModal] = useState(false)
  const [showStepsModal, setShowStepsModal] = useState(false)
  const [showStatsModal, setShowStatsModal] = useState(false)
  const [selectedBatch, setSelectedBatch] = useState<ProductionBatch | null>(null)
  const [analytics, setAnalytics] = useState<any[]>([])
  const [showScanner, setShowScanner] = useState(false)
  const [products, setProducts] = useState<any[]>([])
  const [scalingData, setScalingData] = useState<any[]>([])
  const [expandedIngredient, setExpandedIngredient] = useState<string | null>(null)
  const [orders, setOrders] = useState<any[]>([])

  const [formData, setFormData] = useState({
    recipe_id: '',
    batch_size: 100,
    notes: ''
  })

  useEffect(() => {
    loadBatches()
    loadProducts()
    loadOrders()
  }, [])

  const loadOrders = async () => {
    const { data } = await supabase
      .from('orders')
      .select('id, order_number, customer_name, items, status')
      .in('status', ['pending', 'processing', 'confirmed'])
      .order('created_at', { ascending: false })
    if (data) setOrders(data)
  }

  const loadBatches = async () => {
    try {
      setLoading(true)
      const { data, error } = await supabase
        .from('production_batches')
        .select(`
          *,
          products:products!production_batches_recipe_id_fkey (
            id, name, category, ingredients, yield_amount
          )
        `)
        .order('created_at', { ascending: false })
      
      if (error) throw error
      const batchesData = data || []
      setBatches(batchesData)
      calculateDailyScaling(batchesData)
    } catch (error: any) {
      console.error('Database error:', error)
      toast.error('Hiba az adatok szinkronizálásakor')
    } finally {
      setLoading(false)
    }
  }

  const loadProducts = async () => {
    const { data } = await supabase.from('products').select('id, name, category').order('name')
    if (data) setProducts(data)
  }

  // Find orders related to a batch product
  const getRelatedOrders = (batch: ProductionBatch): RelatedOrder[] => {
    if (!batch.products?.id) return []
    const related: RelatedOrder[] = []
    orders.forEach(order => {
      const items: any[] = Array.isArray(order.items) ? order.items : []
      items.forEach((item: any) => {
        const pid = item.product_id || item.id || item.recipe_id
        if (pid === batch.recipe_id || pid === batch.products?.id) {
          related.push({
            id: order.id,
            order_number: order.order_number,
            customer_name: order.customer_name,
            quantity: item.quantity || 1
          })
        }
      })
    })
    return related
  }

  const calculateDailyScaling = (allBatches: ProductionBatch[]) => {
    const ingredientTotals: { [key: string]: { name: string, total: number, unit: string, details: any[] } } = {}
    allBatches.filter(b => b.status === 'planned' || b.status === 'in_progress').forEach(batch => {
      const recipeIngredients = batch.products?.ingredients || []
      const yieldBase = batch.products?.yield_amount || 1
      const multiplier = batch.batch_size / yieldBase
      recipeIngredients.forEach((ing: any) => {
        const key = `${ing.name.toLowerCase()}-${ing.unit}`
        const amountValue = typeof ing.amount === 'string' ? parseFloat(ing.amount.replace(',', '.')) : ing.amount
        const amountForThisBatch = (amountValue * multiplier)
        if (!ingredientTotals[key]) {
          ingredientTotals[key] = { name: ing.name, total: 0, unit: ing.unit, details: [] }
        }
        ingredientTotals[key].total += amountForThisBatch
        ingredientTotals[key].details.push({
          batch_number: batch.batch_number,
          product_name: batch.products?.name,
          amount: amountForThisBatch,
          batch_id: batch.id,
          recipe_id: batch.recipe_id
        })
      })
    })
    setScalingData(Object.values(ingredientTotals))
  }

  const handleOpenStats = async (batchId: string) => {
    const { data } = await supabase.from('v_production_analytics').select('*').eq('batch_id', batchId)
    setAnalytics(data || [])
    setShowStatsModal(true)
  }

  const handleCreateBatch = async () => {
    if (!formData.recipe_id) return toast.error('Válasszon terméket')
    try {
      const { error } = await supabase.from('production_batches').insert({
        batch_number: `BATCH-${Date.now().toString().slice(-6)}`,
        recipe_id: formData.recipe_id,
        batch_size: formData.batch_size,
        status: 'planned',
        notes: formData.notes
      })
      if (error) throw error
      toast.success('Gyártás ütemezve!')
      setShowAddModal(false)
      loadBatches()
    } catch (e) { toast.error('Hiba a mentéskor') }
  }

  const handleStartBatch = async (id: string) => {
    const { error } = await supabase.from('production_batches').update({ 
      status: 'in_progress', start_time: new Date().toISOString() 
    }).eq('id', id)
    if (!error) { toast.success('Gyártás megkezdve!'); loadBatches(); }
  }

  const handleViewSteps = async (batch: ProductionBatch) => {
    const rId = batch.recipe_id || batch.products?.id
    if (!rId) return toast.error('Hiba: Recept nem található!')
    setSelectedBatch(batch)
    try {
      const { data, error } = await supabase
        .from('recipe_steps').select('*')
        .eq('recipe_id', rId)
        .order('step_number', { ascending: true })
      if (error) throw error
      setSteps(data || [])
      setShowStepsModal(true)
    } catch (error) { toast.error('Hiba a lépések betöltésekor') }
  }

  const filteredBatches = batches.filter(batch => {
    const matchSearch = batch.batch_number?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      batch.products?.name?.toLowerCase().includes(searchTerm.toLowerCase())
    const matchStatus = filterStatus === 'all' || batch.status === filterStatus
    return matchSearch && matchStatus
  })

  const statusCounts = batches.reduce((acc, b) => {
    acc[b.status] = (acc[b.status] || 0) + 1
    return acc
  }, {} as Record<string, number>)

  return (
    <div className="min-h-screen bg-gray-950 text-white">
      {/* ── HEADER ── */}
      <div className="px-6 pt-8 pb-6 border-b border-white/5">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
          <div>
            <div className="flex items-center gap-3 mb-1">
              <div className="p-2.5 bg-amber-500/10 rounded-2xl border border-amber-500/20">
                <ChefHat className="h-7 w-7 text-amber-400" />
              </div>
              <h1 className="text-3xl font-black tracking-tight text-white">Termelésirányítás</h1>
            </div>
            <div className="flex items-center gap-2 ml-14">
              <div className="h-1.5 w-1.5 bg-emerald-400 rounded-full animate-pulse" />
              <span className="text-xs font-semibold text-gray-500 uppercase tracking-widest">Pék terminál aktív</span>
            </div>
          </div>
          <div className="flex gap-2">
            <button onClick={() => setShowScanner(true)} className="flex items-center gap-2 px-4 py-2.5 bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl text-sm font-semibold transition-all">
              <QrCode className="h-4 w-4 text-amber-400" /> QR Olvasó
            </button>
            <button onClick={loadBatches} className="flex items-center gap-2 px-4 py-2.5 bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl text-sm font-semibold transition-all">
              <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin text-blue-400' : 'text-gray-400'}`} />
            </button>
            <button onClick={() => setShowAddModal(true)} className="flex items-center gap-2 px-5 py-2.5 bg-amber-500 hover:bg-amber-400 text-black rounded-xl text-sm font-black transition-all shadow-lg shadow-amber-500/20">
              <Plus className="h-4 w-4" /> Új Gyártás
            </button>
          </div>
        </div>

        {/* Quick stats bar */}
        <div className="flex gap-3 mt-6 overflow-x-auto pb-1">
          {(['all', 'planned', 'in_progress', 'completed', 'failed'] as const).map(s => (
            <button
              key={s}
              onClick={() => setFilterStatus(s)}
              className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all border ${
                filterStatus === s 
                  ? 'bg-white text-black border-white' 
                  : 'bg-white/5 border-white/10 text-gray-400 hover:text-white hover:bg-white/10'
              }`}
            >
              {s === 'all' ? (
                <><Layers className="h-3.5 w-3.5" /> Összes ({batches.length})</>
              ) : (
                <>
                  <div className={`h-2 w-2 rounded-full ${STATUS_CONFIG[s]?.dot}`} />
                  {STATUS_CONFIG[s]?.label} ({statusCounts[s] || 0})
                </>
              )}
            </button>
          ))}
          <div className="ml-auto flex items-center gap-2 bg-white/5 border border-white/10 rounded-xl px-3 py-2 min-w-[200px]">
            <Search className="h-3.5 w-3.5 text-gray-500 flex-shrink-0" />
            <input
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
              placeholder="Keresés..."
              className="bg-transparent text-xs text-white placeholder:text-gray-600 outline-none w-full"
            />
          </div>
        </div>
      </div>

      <div className="p-6 space-y-8">

        {/* ── 1. FÁZIS: NAPI KIMÉRÉS ── */}
        {scalingData.length > 0 && (
          <section>
            <div className="flex items-center gap-3 mb-4">
              <div className="p-2 bg-amber-500/10 rounded-xl border border-amber-500/20">
                <Scale className="h-5 w-5 text-amber-400" />
              </div>
              <div>
                <h2 className="text-lg font-black tracking-tight uppercase">1. Fázis — Napi Kimérés</h2>
                <p className="text-xs text-gray-500">Összes szükséges alapanyag a tervezett / folyamatban lévő gyártásokhoz</p>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
              {scalingData.map((ing, idx) => {
                const isExpanded = expandedIngredient === ing.name
                // Gather related orders for each batch in this ingredient
                const batchOrdersMap: Record<string, RelatedOrder[]> = {}
                ing.details.forEach((det: any) => {
                  const matchBatch = batches.find(b => b.batch_number === det.batch_number)
                  if (matchBatch) {
                    batchOrdersMap[det.batch_number] = getRelatedOrders(matchBatch)
                  }
                })
                const allRelatedOrders = Object.values(batchOrdersMap).flat()
                const uniqueCustomers = [...new Set(allRelatedOrders.map(o => o.customer_name))]

                return (
                  <div
                    key={idx}
                    className={`bg-gray-900 border rounded-2xl overflow-hidden transition-all cursor-pointer ${
                      isExpanded ? 'border-amber-500/50 shadow-lg shadow-amber-500/5' : 'border-white/8 hover:border-white/15'
                    }`}
                    onClick={() => setExpandedIngredient(isExpanded ? null : ing.name)}
                  >
                    <div className="p-5">
                      <div className="flex items-start justify-between mb-3">
                        <div>
                          <p className="text-[10px] font-black text-gray-500 uppercase tracking-widest mb-1">{ing.name}</p>
                          <p className="text-3xl font-black text-white">
                            {ing.total.toFixed(2)}
                            <span className="text-sm font-bold text-amber-400 ml-1">{ing.unit}</span>
                          </p>
                        </div>
                        <div className={`p-2 rounded-xl transition-all ${isExpanded ? 'bg-amber-500/20 text-amber-400' : 'bg-white/5 text-gray-500'}`}>
                          <ChevronDown className={`h-4 w-4 transition-transform ${isExpanded ? 'rotate-180' : ''}`} />
                        </div>
                      </div>

                      {/* Rendelések mini badge-ek */}
                      {uniqueCustomers.length > 0 && (
                        <div className="flex flex-wrap gap-1.5 mt-3 pt-3 border-t border-white/5">
                          <Users className="h-3 w-3 text-blue-400 flex-shrink-0 mt-0.5" />
                          {uniqueCustomers.slice(0, 2).map((c, i) => (
                            <span key={i} className="text-[10px] font-semibold bg-blue-500/10 text-blue-300 px-2 py-0.5 rounded-full border border-blue-500/20">
                              {c}
                            </span>
                          ))}
                          {uniqueCustomers.length > 2 && (
                            <span className="text-[10px] font-semibold text-gray-500">+{uniqueCustomers.length - 2}</span>
                          )}
                        </div>
                      )}
                    </div>

                    {/* Expanded details */}
                    {isExpanded && (
                      <div className="border-t border-white/5 bg-black/20">
                        {ing.details.map((det: any, dIdx: number) => {
                          const batchOrders = batchOrdersMap[det.batch_number] || []
                          return (
                            <div key={dIdx} className="px-5 py-4 border-b border-white/5 last:border-none">
                              <div className="flex justify-between items-start mb-2">
                                <div>
                                  <p className="text-sm font-bold text-white">{det.product_name}</p>
                                  <p className="text-[10px] font-mono text-gray-600 uppercase">#{det.batch_number}</p>
                                </div>
                                <span className="text-sm font-black text-amber-400">{det.amount.toFixed(2)} {ing.unit}</span>
                              </div>
                              {/* Rendelések ehhez a batch-hez */}
                              {batchOrders.length > 0 && (
                                <div className="mt-2 space-y-1">
                                  <p className="text-[9px] font-black text-gray-600 uppercase tracking-widest flex items-center gap-1">
                                    <ShoppingBag className="h-2.5 w-2.5" /> Rendelők
                                  </p>
                                  {batchOrders.map((ord, oi) => (
                                    <div key={oi} className="flex items-center justify-between text-[11px] bg-blue-500/5 border border-blue-500/15 rounded-lg px-3 py-1.5">
                                      <span className="text-blue-300 font-semibold">{ord.customer_name}</span>
                                      <span className="text-gray-500 font-mono">{ord.order_number}</span>
                                    </div>
                                  ))}
                                </div>
                              )}
                              {batchOrders.length === 0 && (
                                <p className="text-[10px] text-gray-700 mt-1 italic">Nincs hozzárendelt rendelés</p>
                              )}
                            </div>
                          )
                        })}
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
          </section>
        )}

        {/* ── 2. FÁZIS: GYÁRTÁSI SORREND ── */}
        <section>
          <div className="flex items-center gap-3 mb-4">
            <div className="p-2 bg-blue-500/10 rounded-xl border border-blue-500/20">
              <ListChecks className="h-5 w-5 text-blue-400" />
            </div>
            <div>
              <h2 className="text-lg font-black tracking-tight uppercase">2. Fázis — Gyártási Sorrend</h2>
              <p className="text-xs text-gray-500">{filteredBatches.length} tétel a szűrési feltételek alapján</p>
            </div>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
              {[1,2,3].map(i => (
                <div key={i} className="bg-gray-900 border border-white/5 rounded-2xl h-64 animate-pulse" />
              ))}
            </div>
          ) : filteredBatches.length === 0 ? (
            <div className="text-center py-16 bg-gray-900/50 rounded-2xl border border-white/5">
              <Package className="h-12 w-12 text-gray-700 mx-auto mb-3" />
              <p className="text-gray-500 font-semibold">Nincs megjeleníthető gyártási tétel</p>
              <button onClick={() => setShowAddModal(true)} className="mt-4 text-amber-400 text-sm font-bold hover:text-amber-300">
                + Új gyártás létrehozása
              </button>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
              {filteredBatches.map((batch) => {
                const cfg = STATUS_CONFIG[batch.status] || STATUS_CONFIG.planned
                const relatedOrders = getRelatedOrders(batch)
                const startTime = batch.start_time ? new Date(batch.start_time) : null
                const elapsed = startTime ? Math.round((new Date().getTime() - startTime.getTime()) / 60000) : null

                return (
                  <div
                    key={batch.id}
                    className={`relative bg-gray-900 border rounded-2xl overflow-hidden transition-all hover:shadow-xl group ${cfg.bg}`}
                  >
                    {/* Status stripe */}
                    <div className={`h-1 w-full ${cfg.dot.replace('animate-pulse', '').trim()} opacity-60`} 
                         style={{background: batch.status === 'in_progress' ? '#3b82f6' : batch.status === 'completed' ? '#10b981' : batch.status === 'failed' ? '#ef4444' : '#f59e0b'}} />

                    <div className="p-5">
                      {/* Top row */}
                      <div className="flex items-start justify-between mb-4">
                        <div className="flex items-center gap-2.5">
                          <div className={`h-2 w-2 rounded-full ${cfg.dot}`} />
                          <span className={`text-[10px] font-black uppercase tracking-widest ${cfg.color}`}>{cfg.label}</span>
                        </div>
                        <div className="flex items-center gap-1.5">
                          <button
                            onClick={() => handleOpenStats(batch.id)}
                            className="p-1.5 bg-white/5 hover:bg-white/10 rounded-lg text-gray-500 hover:text-blue-400 transition-all"
                            title="Analitika"
                          >
                            <BarChart2 size={14}/>
                          </button>
                          <span className="text-[10px] font-mono text-gray-600 bg-white/5 px-2 py-1 rounded-lg">
                            #{batch.batch_number}
                          </span>
                        </div>
                      </div>

                      {/* Product name */}
                      <h3 className="text-xl font-black text-white mb-1 leading-tight line-clamp-2">
                        {batch.products?.name || 'Ismeretlen termék'}
                      </h3>
                      <p className="text-xs text-gray-500 mb-4">
                        {batch.products?.category || '—'} • {batch.batch_size} adagos
                      </p>

                      {/* Timer if in progress */}
                      {batch.status === 'in_progress' && elapsed !== null && (
                        <div className="flex items-center gap-2 mb-4 p-2.5 bg-blue-500/10 border border-blue-500/20 rounded-xl">
                          <Clock className="h-3.5 w-3.5 text-blue-400" />
                          <span className="text-xs font-bold text-blue-300">
                            {Math.floor(elapsed / 60)}h {elapsed % 60}m eltelt
                          </span>
                        </div>
                      )}

                      {/* Related orders */}
                      {relatedOrders.length > 0 && (
                        <div className="mb-4 p-3 bg-white/3 border border-white/8 rounded-xl">
                          <p className="text-[9px] font-black text-gray-600 uppercase tracking-widest mb-2 flex items-center gap-1">
                            <ShoppingBag className="h-2.5 w-2.5 text-blue-400" /> Rendelők ({relatedOrders.length})
                          </p>
                          <div className="space-y-1">
                            {relatedOrders.slice(0, 3).map((ord, i) => (
                              <div key={i} className="flex items-center justify-between">
                                <span className="text-xs font-semibold text-blue-300">{ord.customer_name}</span>
                                <span className="text-[10px] font-mono text-gray-600">{ord.order_number}</span>
                              </div>
                            ))}
                            {relatedOrders.length > 3 && (
                              <p className="text-[10px] text-gray-600">+{relatedOrders.length - 3} további rendelés</p>
                            )}
                          </div>
                        </div>
                      )}

                      {/* Actions */}
                      <div className="space-y-2">
                        {batch.status === 'completed' ? (
                          <button
                            onClick={() => navigate('/delivery-notes')}
                            className="w-full flex items-center justify-center gap-2 py-3 bg-emerald-500/10 hover:bg-emerald-500/20 border border-emerald-500/30 text-emerald-400 rounded-xl text-sm font-black transition-all"
                          >
                            <Truck size={16} /> Szállítólevél
                          </button>
                        ) : (
                          <>
                            <button
                              onClick={() => handleViewSteps(batch)}
                              className="w-full flex items-center justify-center gap-2 py-3 bg-white/5 hover:bg-white/10 border border-white/10 text-gray-300 hover:text-white rounded-xl text-sm font-bold transition-all"
                            >
                              <FileText size={15} className="text-amber-400" /> Intelligens Útmutató
                            </button>
                            {batch.status === 'planned' && (
                              <button
                                onClick={() => handleStartBatch(batch.id)}
                                className="w-full flex items-center justify-center gap-2 py-3 bg-amber-500 hover:bg-amber-400 text-black rounded-xl text-sm font-black transition-all shadow-lg shadow-amber-500/20"
                              >
                                <Flame size={16} /> Gyártás Megkezdése
                              </button>
                            )}
                          </>
                        )}
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </section>
      </div>

      {/* ── MODAL: ANALITIKA ── */}
      {showStatsModal && (
        <div className="fixed inset-0 bg-black/90 z-[3000] flex items-center justify-center p-4 backdrop-blur-md">
          <div className="bg-gray-900 border border-white/10 rounded-3xl p-8 w-full max-w-xl shadow-2xl">
            <div className="flex justify-between items-center mb-6 border-b border-white/10 pb-5">
              <h3 className="text-xl font-black text-white uppercase tracking-tight">Gyártási Idővonal</h3>
              <button onClick={() => setShowStatsModal(false)} className="p-2 bg-white/5 rounded-xl text-gray-400 hover:text-red-400 transition-all"><X size={20}/></button>
            </div>
            <div className="space-y-3 max-h-[60vh] overflow-y-auto">
              {analytics.length === 0 ? (
                <p className="text-gray-500 text-center py-8">Nincs rögzített adat.</p>
              ) : analytics.map((a, i) => (
                <div key={i} className="flex justify-between items-center p-4 bg-white/3 border border-white/8 rounded-2xl">
                  <div>
                    <p className="text-amber-400 font-black text-sm">{a.step_title}</p>
                    <p className="text-xs text-gray-600">{new Date(a.started_at).toLocaleTimeString()}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-white font-black text-lg">{a.duration_minutes} perc</p>
                    <p className="text-[10px] text-gray-600 uppercase">Terv: {a.planned_minutes}p</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* ── MODAL: PÉK-VEZÉRLÉS ── */}
      {showStepsModal && selectedBatch && (
        <div className="fixed inset-0 bg-black/98 z-[2000] flex items-center justify-center p-4 backdrop-blur-3xl">
          <div className="w-full max-w-6xl h-[95vh] overflow-hidden flex flex-col bg-gray-900 border border-white/10 rounded-3xl shadow-2xl">
            <div className="p-8 border-b border-white/10 flex justify-between items-center">
              <div>
                <p className="text-[10px] font-black text-amber-400 uppercase tracking-[0.2em] mb-1">Technológiai folyamatvezérlés</p>
                <h2 className="text-3xl font-black text-white uppercase tracking-tight">{selectedBatch.products?.name}</h2>
              </div>
              <button onClick={() => setShowStepsModal(false)} className="p-4 bg-white/5 rounded-2xl text-gray-400 hover:text-red-400 transition-all"><X size={28} /></button>
            </div>
            <div className="flex-1 overflow-y-auto p-8">
              <ProductionSteps batch={selectedBatch} steps={steps} loading={false} onClose={() => setShowStepsModal(false)} onStepUpdate={loadBatches} />
            </div>
          </div>
        </div>
      )}

      {/* ── MODAL: ÚJ GYÁRTÁS ── */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black/90 flex items-center justify-center z-[1000] p-4 backdrop-blur-xl">
          <div className="bg-gray-900 border border-white/10 rounded-3xl p-8 w-full max-w-md shadow-2xl">
            <div className="flex justify-between items-center mb-6">
              <h3 className="text-xl font-black text-white uppercase tracking-tight">Gyártás Ütemezés</h3>
              <button onClick={() => setShowAddModal(false)} className="p-2 bg-white/5 rounded-xl text-gray-400 hover:text-red-400 transition-all"><X size={20}/></button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[10px] font-black text-gray-500 uppercase tracking-widest mb-2 block">Termék / Recept</label>
                <select
                  value={formData.recipe_id}
                  onChange={(e) => setFormData({ ...formData, recipe_id: e.target.value })}
                  className="w-full bg-white/5 border border-white/10 rounded-xl p-3.5 text-white font-bold focus:border-amber-400 focus:bg-white/8 outline-none transition-all"
                >
                  <option value="">Válasszon terméket...</option>
                  {products.map(p => <option key={p.id} value={p.id}>{p.name}</option>)}
                </select>
              </div>
              <div>
                <label className="text-[10px] font-black text-gray-500 uppercase tracking-widest mb-2 block">Adagok száma</label>
                <input
                  type="number"
                  value={formData.batch_size}
                  onChange={(e) => setFormData({ ...formData, batch_size: parseInt(e.target.value) })}
                  className="w-full bg-white/5 border border-white/10 rounded-xl p-3.5 text-white text-2xl font-black focus:border-amber-400 focus:bg-white/8 outline-none transition-all"
                />
              </div>
              <div>
                <label className="text-[10px] font-black text-gray-500 uppercase tracking-widest mb-2 block">Megjegyzés (opcionális)</label>
                <textarea
                  value={formData.notes}
                  onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                  rows={2}
                  className="w-full bg-white/5 border border-white/10 rounded-xl p-3.5 text-white font-medium focus:border-amber-400 focus:bg-white/8 outline-none resize-none transition-all placeholder:text-gray-700"
                  placeholder="Opcionális megjegyzés..."
                />
              </div>
              <button
                onClick={handleCreateBatch}
                className="w-full py-4 bg-amber-500 hover:bg-amber-400 text-black rounded-xl font-black text-sm uppercase tracking-wide transition-all shadow-lg shadow-amber-500/20"
              >
                Gyártás Mentése
              </button>
            </div>
          </div>
        </div>
      )}

      {showScanner && (
        <div className="fixed inset-0 bg-black/95 z-[5000] flex items-center justify-center p-4">
          <div className="bg-gray-900 border border-white/10 rounded-3xl p-6 w-full max-w-md">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-black text-white">QR / Vonalkód Olvasó</h3>
              <button onClick={() => setShowScanner(false)} className="p-2 bg-white/5 rounded-xl text-gray-400 hover:text-red-400"><X size={20}/></button>
            </div>
            <BarcodeScanner onScan={(code) => { toast.success(`Kód: ${code}`); setShowScanner(false) }} onClose={() => setShowScanner(false)} />
          </div>
        </div>
      )}
    </div>
  )
}