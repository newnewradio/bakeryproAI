import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { 
  ChefHat, Plus, Search, Filter, Clock, CheckCircle, XCircle, 
  Calendar, RefreshCw, AlertTriangle, Package, Truck, FileText, QrCode
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
  quality_score: number | null
  temperature: number | null
  humidity: number | null
  notes: string | null
  location_id: string | null
  baker_id: string | null
  created_at: string
  updated_at: string
  products?: {
    name: string
    category: string
  }
  locations?: {
    name: string
  }
  profiles?: {
    full_name: string
  }
}

export default function Production() {
  const navigate = useNavigate()
  const [batches, setBatches] = useState<ProductionBatch[]>([])
  const [loading, setLoading] = useState(true)
  const [steps, setSteps] = useState<any[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [showAddModal, setShowAddModal] = useState(false)
  const [showStepsModal, setShowStepsModal] = useState(false)
  const [selectedBatch, setSelectedBatch] = useState<ProductionBatch | null>(null)
  const [showScanner, setShowScanner] = useState(false)
  const [products, setProducts] = useState<any[]>([])
  const [bakers, setBakers] = useState<any[]>([])
  const [formData, setFormData] = useState({
    recipe_id: '',
    batch_size: 100,
    baker_id: '',
    notes: ''
  })

  useEffect(() => {
    loadBatches()
    loadProducts()
    loadBakers()
  }, [])

  const loadBatches = async () => {
    try {
      setLoading(true)
      const { data, error } = await supabase
        .from('production_batches')
        .select(`
          *,
          products!production_batches_recipe_id_fkey (name, category),
          locations!location_id (name),
          profiles:baker_id (full_name)
        `)
        .order('created_at', { ascending: false })
      
      if (error) throw error
      setBatches(data || [])
    } catch (error: any) {
      console.error('Database error:', error)
      toast.error('Hiba a gyártási tételek betöltésekor')
    } finally {
      setLoading(false)
    }
  }

  const loadProducts = async () => {
    const { data } = await supabase.from('products').select('id, name, category').order('name')
    if (data) setProducts(data)
  }

  const loadBakers = async () => {
    const { data } = await supabase.from('profiles').select('id, full_name').eq('role', 'baker').eq('status', 'active').order('full_name')
    if (data) setBakers(data)
  }

  const handleCreateBatch = async () => {
    if (!formData.recipe_id) { toast.error('Válasszon terméket!'); return; }
    try {
      const { error } = await supabase.from('production_batches').insert({
        batch_number: `BATCH-${Date.now().toString().slice(-6)}`,
        recipe_id: formData.recipe_id,
        batch_size: formData.batch_size,
        status: 'planned',
        baker_id: formData.baker_id || null,
        notes: formData.notes || null
      })
      if (error) throw error
      toast.success('Gyártási tétel létrehozva!')
      setShowAddModal(false)
      loadBatches()
    } catch (e) { toast.error('Hiba a létrehozáskor') }
  }

  const handleStartBatch = async (id: string) => {
    const { error } = await supabase.from('production_batches').update({ 
      status: 'in_progress', 
      start_time: new Date().toISOString() 
    }).eq('id', id)
    if (!error) loadBatches()
  }

  const handleCompleteBatch = async (id: string) => {
    const { error } = await supabase.from('production_batches').update({ 
      status: 'completed', 
      end_time: new Date().toISOString() 
    }).eq('id', id)
    if (!error) loadBatches()
  }

  const handleGenerateDeliveryNote = async (batchId: string) => {
    const { data: batchData } = await supabase
      .from('production_batches')
      .select(`*, products!production_batches_recipe_id_fkey (name, category)`)
      .eq('id', batchId).single()
    
    if (batchData) toast.success('Szállítólevél generálása...')
  }

  const handleViewSteps = (batch: ProductionBatch) => {
    setSelectedBatch(batch)
    supabase.from('recipe_steps').select('*').eq('recipe_id', batch.recipe_id).order('step_number')
      .then(({ data }) => {
        if (data) setSteps(data)
        setShowStepsModal(true)
      })
  }

  const filteredBatches = batches.filter(batch => 
    batch.batch_number?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    batch.products?.name?.toLowerCase().includes(searchTerm.toLowerCase())
  )

  return (
    <div className="space-y-6 p-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white flex items-center">
          <ChefHat className="h-8 w-8 mr-3 text-amber-600" /> Termelés
        </h1>
        <div className="flex space-x-3">
          <button onClick={() => setShowScanner(true)} className="bg-amber-600 text-white px-4 py-2 rounded-lg flex items-center gap-2"><QrCode className="w-4 h-4" /> QR olvasó</button>
          <button onClick={loadBatches} className="bg-white dark:bg-gray-800 border dark:border-gray-700 px-4 py-2 rounded-lg text-gray-700 dark:text-white flex items-center"><RefreshCw className="h-5 w-5 mr-2" /> Frissítés</button>
          <button onClick={() => setShowAddModal(true)} className="bg-amber-600 text-white px-4 py-2 rounded-lg flex items-center"><Plus className="h-5 w-5 mr-2" /> Új tétel</button>
        </div>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-sm border dark:border-gray-700">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <input type="text" placeholder="Keresés..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className="w-full px-4 py-2 border dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white" />
          <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="w-full px-4 py-2 border dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white">
            <option value="all">Összes állapot</option>
            <option value="planned">Tervezett</option>
            <option value="in_progress">Folyamatban</option>
            <option value="completed">Befejezve</option>
          </select>
        </div>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-sm border dark:border-gray-700 overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead className="bg-gray-50 dark:bg-gray-900">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tétel</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Termék</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Állapot</th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Műveletek</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
            {loading ? (<tr><td colSpan={4} className="text-center py-4">Betöltés...</td></tr>) : 
             filteredBatches.map((batch) => (
              <tr key={batch.id} className="hover:bg-gray-50 dark:hover:bg-gray-700">
                <td className="px-6 py-4 text-sm text-gray-900 dark:text-white">{batch.batch_number}</td>
                <td className="px-6 py-4 text-sm text-gray-900 dark:text-white">{batch.products?.name}</td>
                <td className="px-6 py-4 text-sm">
                   <span className="px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">{batch.status}</span>
                </td>
                <td className="px-6 py-4 text-right flex justify-end space-x-2">
                  <button onClick={() => handleViewSteps(batch)} className="text-blue-600"><FileText className="h-5 w-5" /></button>
                  {batch.status === 'planned' && <button onClick={() => handleStartBatch(batch.id)} className="text-green-600"><Clock className="h-5 w-5" /></button>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showAddModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl w-full max-w-md">
            <h3 className="text-xl font-bold mb-4 text-gray-900 dark:text-white">Új gyártás</h3>
            <select value={formData.recipe_id} onChange={(e) => setFormData({...formData, recipe_id: e.target.value})} className="w-full mb-4 p-2 border rounded-lg bg-gray-50 dark:bg-gray-700 text-white">
              <option value="">Válasszon terméket</option>
              {products.map(p => <option key={p.id} value={p.id}>{p.name}</option>)}
            </select>
            <input type="number" value={formData.batch_size} onChange={(e) => setFormData({...formData, batch_size: parseInt(e.target.value)})} className="w-full mb-4 p-2 border rounded-lg bg-gray-50 dark:bg-gray-700 text-white" />
            <div className="flex justify-end space-x-2">
              <button onClick={() => setShowAddModal(false)} className="px-4 py-2 text-gray-500">Mégse</button>
              <button onClick={handleCreateBatch} className="px-4 py-2 bg-amber-600 text-white rounded-lg">Létrehozás</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}