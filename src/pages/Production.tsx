import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { 
  ChefHat, 
  Plus, 
  Search, 
  Clock, 
  CheckCircle, 
  XCircle, 
  RefreshCw, 
  FileText, 
  QrCode,
  Truck,
  Package,
  Calendar,
  Scale,
  ListChecks,
  ArrowRight,
  ChevronRight,
  AlertTriangle,
  X,
  CheckSquare,
  ClipboardList,
  Info,
  Eye,
  ChevronDown,
  TrendingUp
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
}

export default function Production() {
  const navigate = useNavigate()
  const [batches, setBatches] = useState<ProductionBatch[]>([])
  const [loading, setLoading] = useState(true)
  const [steps, setSteps] = useState<any[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [showAddModal, setShowAddModal] = useState(false)
  const [showStepsModal, setShowStepsModal] = useState(false)
  const [showStatsModal, setShowStatsModal] = useState(false)
  const [selectedBatch, setSelectedBatch] = useState<ProductionBatch | null>(null)
  const [analytics, setAnalytics] = useState<any[]>([])
  const [showScanner, setShowScanner] = useState(false)
  const [products, setProducts] = useState<any[]>([])
  const [scalingData, setScalingData] = useState<any[]>([])
  const [showScalingDetails, setShowScalingDetails] = useState<string | null>(null)

  const [formData, setFormData] = useState({
    recipe_id: '',
    batch_size: 100,
    notes: ''
  })

  useEffect(() => {
    loadBatches()
    loadProducts()
  }, [])

  const loadBatches = async () => {
    try {
      setLoading(true)
      const { data, error } = await supabase
        .from('production_batches')
        .select(`
          *,
          products:products!production_batches_recipe_id_fkey (
            id,
            name, 
            category,
            ingredients,
            yield_amount
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
          amount: amountForThisBatch
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
    if (!error) { 
      toast.success('Gyártás megkezdve!'); 
      loadBatches(); 
    }
  }

  const handleViewSteps = async (batch: ProductionBatch) => {
    const rId = batch.recipe_id || batch.products?.id;
    if (!rId) return toast.error('Hiba: Recept nem található!');
    setSelectedBatch(batch)
    try {
      const { data, error } = await supabase
        .from('recipe_steps')
        .select('*')
        .eq('recipe_id', rId)
        .order('step_number', { ascending: true })
      if (error) throw error
      setSteps(data || [])
      setShowStepsModal(true)
    } catch (error) { toast.error('Hiba a lépések betöltésekor') }
  }

  const filteredBatches = batches.filter(batch => 
    batch.batch_number?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    batch.products?.name?.toLowerCase().includes(searchTerm.toLowerCase())
  )

  return (
    <div className="p-6 space-y-8 bg-gray-950 min-h-screen text-white font-sans">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 border-b border-gray-800 pb-8">
        <div>
          <h1 className="text-4xl font-black text-white flex items-center tracking-tighter uppercase">
            <ChefHat className="h-12 w-12 mr-4 text-amber-500" /> Termelésirányítás
          </h1>
          <div className="flex items-center gap-2 text-green-500 mt-2 font-bold uppercase text-xs tracking-widest">
            <div className="h-2 w-2 bg-green-500 rounded-full animate-pulse" /> Pék terminál aktív
          </div>
        </div>
        <div className="flex gap-3">
          <button onClick={() => setShowScanner(true)} className="bg-gray-900 text-white px-6 py-3 rounded-2xl border border-gray-800 flex items-center gap-2 font-bold hover:bg-gray-800 transition-all">
            <QrCode className="h-5 w-5 text-amber-500" /> QR Olvasó
          </button>
          <button onClick={loadBatches} className="bg-gray-900 text-white px-6 py-3 rounded-2xl border border-gray-800 flex items-center gap-2 font-bold">
            <RefreshCw className={`h-5 w-5 ${loading ? 'animate-spin' : ''}`} /> Frissítés
          </button>
          <button onClick={() => setShowAddModal(true)} className="bg-amber-600 text-black px-8 py-3 rounded-2xl font-black hover:bg-amber-500 transition-all shadow-xl shadow-amber-600/20 flex items-center gap-2">
            <Plus className="h-6 w-6" /> ÚJ GYÁRTÁS
          </button>
        </div>
      </div>

      {/* --- 1. FÁZIS: KIMÉRÉS --- */}
      <div className="bg-gray-900 border border-amber-500/20 rounded-[2.5rem] p-8 shadow-2xl relative overflow-hidden">
        <div className="flex items-center gap-4 mb-8">
          <div className="bg-amber-500/10 p-4 rounded-3xl border border-amber-500/20"><Scale className="text-amber-500" size={32} /></div>
          <h2 className="text-3xl font-black tracking-tight uppercase">1. FÁZIS: NAPI ÖSSZESÍTETT KIMÉRÉS</h2>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {scalingData.map((ing, idx) => (
            <div key={idx} className="bg-gray-800/30 backdrop-blur-md p-6 rounded-[2rem] border border-gray-700/50 flex flex-col group hover:border-amber-500/50 transition-all">
              <div className="flex justify-between items-start mb-4">
                <div>
                  <p className="text-gray-500 text-[10px] font-black uppercase mb-1">{ing.name}</p>
                  <p className="text-4xl font-black text-white">{ing.total.toFixed(2)} <span className="text-sm font-bold text-amber-500">{ing.unit}</span></p>
                </div>
                <button onClick={() => setShowScalingDetails(showScalingDetails === ing.name ? null : ing.name)} className="p-3 bg-gray-900 rounded-2xl text-gray-400 hover:text-amber-500 transition-all">
                  {showScalingDetails === ing.name ? <ChevronDown size={20} /> : <Info size={20} />}
                </button>
              </div>
              {showScalingDetails === ing.name && (
                <div className="mt-4 space-y-2 border-t border-gray-800 pt-4">
                  {ing.details.map((det: any, dIdx: number) => (
                    <div key={dIdx} className="flex justify-between items-center text-xs py-1 border-b border-gray-800/30 last:border-none">
                      <span className="text-gray-400 font-medium">{det.product_name} <span className="text-[9px] font-mono">#{det.batch_number}</span></span>
                      <span className="text-white font-black">{det.amount.toFixed(2)} {ing.unit}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* --- 2. FÁZIS: GYÁRTÁS --- */}
      <div className="space-y-6">
        <h2 className="text-2xl font-black px-2 flex items-center gap-3 uppercase tracking-widest"><ListChecks className="text-blue-500" /> 2. FÁZIS: GYÁRTÁSI SORREND</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
          {filteredBatches.map((batch) => (
            <div key={batch.id} className={`relative overflow-hidden rounded-[2.5rem] border-2 transition-all duration-500 group ${
              batch.status === 'completed' ? 'bg-green-900/10 border-green-500/50' : batch.status === 'in_progress' ? 'bg-gray-900 border-amber-500 shadow-2xl' : 'bg-gray-900/40 border-gray-800'
            }`}>
              <div className="p-8">
                <div className="flex justify-between items-start mb-6">
                  <Package className={batch.status === 'completed' ? 'text-green-500' : batch.status === 'in_progress' ? 'text-amber-500' : 'text-gray-500'} size={32} />
                  <div className="flex gap-2">
                    <button onClick={() => handleOpenStats(batch.id)} className="p-2 bg-gray-800 rounded-xl text-blue-400 hover:text-white transition-colors" title="Analitika"><TrendingUp size={20}/></button>
                    <span className={`text-[10px] font-black px-4 py-2 rounded-full uppercase ${batch.status === 'completed' ? 'bg-green-500 text-black' : batch.status === 'in_progress' ? 'bg-amber-500 text-black' : 'bg-gray-800 text-gray-500'}`}>{batch.status}</span>
                  </div>
                </div>
                <h3 className="text-2xl font-black text-white mb-6 h-14 overflow-hidden uppercase tracking-tighter leading-tight">{batch.products?.name || 'Ismeretlen'}</h3>
                
                <div className="flex flex-col gap-3">
                  {batch.status === 'completed' ? (
                    <button 
                      onClick={() => navigate('/delivery-notes')}
                      className="w-full bg-blue-600 hover:bg-blue-500 text-white py-5 rounded-[1.5rem] font-black flex items-center justify-center gap-3 shadow-lg transition-all"
                    >
                      <Truck size={24} /> SZÁLLÍTÓLEVÉL MEGNYITÁSA
                    </button>
                  ) : (
                    <>
                      <button onClick={() => handleViewSteps(batch)} className="w-full bg-gray-800 hover:bg-gray-700 text-white py-5 rounded-[1.5rem] font-black flex items-center justify-center gap-3 border border-gray-700 shadow-lg">
                        <FileText className="h-6 w-6 text-amber-500" /> INTELLIGENS ÚTMUTATÓ
                      </button>
                      {batch.status === 'planned' && (
                        <button onClick={() => handleStartBatch(batch.id)} className="w-full bg-amber-600 hover:bg-amber-500 text-black py-5 rounded-[1.5rem] font-black shadow-xl shadow-amber-900/40">
                          GYÁRTÁS MEGKEZDÉSE <ArrowRight className="h-6 w-6" />
                        </button>
                      )}
                    </>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* MODAL: ADMIN ANALITIKA */}
      {showStatsModal && (
        <div className="fixed inset-0 bg-black/95 z-[3000] flex items-center justify-center p-4 backdrop-blur-md">
           <div className="bg-gray-900 border border-gray-800 rounded-[3rem] p-10 w-full max-w-2xl shadow-2xl">
             <div className="flex justify-between items-center mb-8 border-b border-gray-800 pb-6">
               <h3 className="text-3xl font-black text-white tracking-tighter uppercase">Gyártási Idővonal</h3>
               <button onClick={() => setShowStatsModal(false)} className="bg-gray-800 p-4 rounded-3xl text-white hover:text-red-500 transition-all"><X size={28}/></button>
             </div>
             <div className="space-y-4 max-h-[60vh] overflow-y-auto">
               {analytics.length === 0 ? <p className="text-gray-500">Nincs rögzített adat.</p> : analytics.map((a, i) => (
                 <div key={i} className="flex justify-between items-center p-4 bg-black/40 rounded-2xl border border-gray-800">
                    <div>
                      <p className="text-amber-500 font-black text-sm uppercase">{a.step_title}</p>
                      <p className="text-xs text-gray-500">{new Date(a.started_at).toLocaleTimeString()}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-white font-black text-xl">{a.duration_minutes} perc</p>
                      <p className="text-[10px] text-gray-600 uppercase">Terv: {a.planned_minutes}p</p>
                    </div>
                 </div>
               ))}
             </div>
           </div>
        </div>
      )}

      {/* MODAL: PÉK-VEZÉRLÉS */}
      {showStepsModal && selectedBatch && (
        <div className="fixed inset-0 bg-black/98 z-[2000] flex items-center justify-center p-4 backdrop-blur-3xl">
          <div className="w-full max-w-6xl h-[95vh] overflow-hidden flex flex-col bg-gray-900 border border-gray-800 rounded-[3.5rem] shadow-2xl">
            <div className="p-10 border-b border-gray-800 flex justify-between items-center bg-black/20">
              <div>
                <h2 className="text-5xl font-black text-white uppercase tracking-tighter">{selectedBatch.products?.name}</h2>
                <p className="text-amber-500 font-bold mt-2 uppercase tracking-[0.2em] text-xs">Technológiai folyamatvezérlés aktív</p>
              </div>
              <button onClick={() => setShowStepsModal(false)} className="bg-gray-800 p-6 rounded-[2rem] text-white hover:text-red-500 transition-all shadow-2xl"><X size={40} /></button>
            </div>
            <div className="flex-1 overflow-y-auto p-12 bg-black/10">
              <ProductionSteps batch={selectedBatch} steps={steps} loading={false} onClose={() => setShowStepsModal(false)} onStepUpdate={loadBatches} />
            </div>
          </div>
        </div>
      )}

      {/* ADD MODAL */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black/95 flex items-center justify-center z-[1000] p-4 backdrop-blur-xl">
          <div className="bg-gray-900 border border-gray-800 rounded-[3rem] p-12 w-full max-w-xl shadow-2xl">
            <h3 className="text-3xl font-black text-white tracking-tighter uppercase mb-10">Gyártás Ütemezés</h3>
            <div className="space-y-8">
              <select value={formData.recipe_id} onChange={(e) => setFormData({ ...formData, recipe_id: e.target.value })} className="w-full bg-gray-800 border-2 border-gray-700 rounded-2xl p-5 text-white text-xl font-bold focus:border-amber-500 outline-none appearance-none">
                <option value="">Recept választás...</option>
                {products.map(p => <option key={p.id} value={p.id}>{p.name}</option>)}
              </select>
              <input type="number" value={formData.batch_size} onChange={(e) => setFormData({ ...formData, batch_size: parseInt(e.target.value) })} className="w-full bg-gray-800 border-2 border-gray-700 rounded-2xl p-5 text-white text-3xl font-black focus:border-amber-500 outline-none" />
              <button onClick={handleCreateBatch} className="w-full bg-amber-600 text-black py-6 rounded-[1.5rem] font-black text-2xl uppercase shadow-2xl hover:bg-amber-500 transition-all">Mentés</button>
              <button onClick={() => setShowAddModal(false)} className="w-full text-gray-500 font-bold uppercase text-sm">Mégse</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}