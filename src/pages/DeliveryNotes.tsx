import React, { useState, useEffect } from 'react'
import { 
  FileText, 
  Plus, 
  Search, 
  Filter, 
  Download, 
  Edit, 
  Trash2, 
  Eye, 
  Calendar,
  RefreshCw,
  CheckCircle,
  XCircle,
  Clock,
  Save,
  X,
  Truck,
  MapPin,
  User
} from 'lucide-react'
import { supabase } from '../lib/supabase'
import { toast } from 'react-hot-toast'
import { useNavigate } from 'react-router-dom'

interface DeliveryNote {
  id: string
  order_id: string | null
  order_number: string
  batch_id: string | null
  status: 'pending' | 'in_progress' | 'delivered' | 'cancelled'
  driver_id: string | null
  vehicle_id: string | null
  customer_name: string
  customer_address: string | null
  items: any[]
  created_at: string
  updated_at: string
  delivery_date: string | null
  notes: string | null
  location_id: string | null
}

interface Order {
  id: string
  order_number: string
  customer_name: string
  status: string
  items: any[]
}

interface Batch {
  id: string
  batch_number: string
  recipe_id: string
  batch_size: number
  status: string
  products?: {
    name: string
  }
}

interface Driver {
  id: string
  full_name: string
}

interface Vehicle {
  id: string
  license_plate: string
  model: string
}

interface Location {
  id: string
  name: string
}

export default function DeliveryNotes() {
  const navigate = useNavigate()
  const [deliveryNotes, setDeliveryNotes] = useState<DeliveryNote[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [showAddModal, setShowAddModal] = useState(false)
  const [showViewModal, setShowViewModal] = useState(false)
  const [selectedNote, setSelectedNote] = useState<DeliveryNote | null>(null)
  const [orders, setOrders] = useState<Order[]>([])
  const [batches, setBatches] = useState<Batch[]>([])
  const [drivers, setDrivers] = useState<Driver[]>([])
  const [vehicles, setVehicles] = useState<Vehicle[]>([])
  const [locations, setLocations] = useState<Location[]>([])
  const [formData, setFormData] = useState({
    order_id: '',
    batch_id: '',
    driver_id: '',
    vehicle_id: '',
    customer_name: '',
    customer_address: '',
    delivery_date: '',
    notes: '',
    location_id: ''
  })

  useEffect(() => {
    loadDeliveryNotes()
    loadOrders()
    loadBatches()
    loadDrivers()
    loadVehicles()
    loadLocations()
  }, [])

  const loadDeliveryNotes = async () => {
    try {
      setLoading(true)
      
      const { data, error } = await supabase
        .from('delivery_notes')
        .select('*')
        .order('created_at', { ascending: false })
      
      if (error) {
        console.error('Database error:', error)
        toast.error('Hiba a szállítólevelek betöltésekor')
        return
      }
      
      if (data) {
        setDeliveryNotes(data)
      }
    } catch (error) {
      console.error('Hiba a szállítólevelek betöltésekor:', error)
      toast.error('Hiba a szállítólevelek betöltésekor')
    } finally {
      setLoading(false)
    }
  }

  const loadOrders = async () => {
    try {
      // Load orders that are in pending, processing, or confirmed status
      const { data, error } = await supabase
        .from('orders')
        .select('id, order_number, customer_name, status, items')
        .in('status', ['pending', 'processing', 'confirmed'])
        .order('created_at', { ascending: false })
      
      if (error) {
        console.error('Database error:', error)
        toast.error('Hiba a rendelések betöltésekor')
        return
      }
      
      if (data) {
        setOrders(data)
      }
    } catch (error) {
      console.error('Hiba a rendelések betöltésekor:', error)
      toast.error('Hiba a rendelések betöltésekor')
    }
  }

  const loadBatches = async () => {
    try {
      // Load batches that are completed
      const { data, error } = await supabase
        .from('production_batches')
        .select(`
          id, 
          batch_number, 
          recipe_id, 
          batch_size, 
          status,
          products:recipe_id (name)
        `)
        .eq('status', 'completed')
        .order('created_at', { ascending: false })
      
      if (error) {
        console.error('Database error:', error)
        toast.error('Hiba a gyártási tételek betöltésekor')
        return
      }
      
      if (data) {
        setBatches(data)
      }
    } catch (error) {
      console.error('Hiba a gyártási tételek betöltésekor:', error)
      toast.error('Hiba a gyártási tételek betöltésekor')
    }
  }

  const loadDrivers = async () => {
    try {
      // Load drivers (profiles with role = driver)
      const { data, error } = await supabase
        .from('profiles')
        .select('id, full_name')
        .eq('role', 'driver')
        .eq('status', 'active')
        .order('full_name')
      
      if (error) {
        console.error('Database error:', error)
        toast.error('Hiba a sofőrök betöltésekor')
        return
      }
      
      if (data) {
        setDrivers(data)
      }
    } catch (error) {
      console.error('Hiba a sofőrök betöltésekor:', error)
      toast.error('Hiba a sofőrök betöltésekor')
    }
  }

  const loadVehicles = async () => {
    try {
      // Load active vehicles
      const { data, error } = await supabase
        .from('vehicles')
        .select('id, license_plate, model')
        .eq('status', 'active')
        .order('license_plate')
      
      if (error) {
        console.error('Database error:', error)
        toast.error('Hiba a járművek betöltésekor')
        return
      }
      
      if (data) {
        setVehicles(data)
      }
    } catch (error) {
      console.error('Hiba a járművek betöltésekor:', error)
      toast.error('Hiba a járművek betöltésekor')
    }
  }

  const loadLocations = async () => {
    try {
      // Load active locations
      const { data, error } = await supabase
        .from('locations')
        .select('id, name')
        .eq('status', 'active')
        .order('name')
      
      if (error) {
        console.error('Database error:', error)
        toast.error('Hiba a helyszínek betöltésekor')
        return
      }
      
      if (data) {
        setLocations(data)
      }
    } catch (error) {
      console.error('Hiba a helyszínek betöltésekor:', error)
      toast.error('Hiba a helyszínek betöltésekor')
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    try {
      setLoading(true)
      
      // Validate required fields
      if (!formData.customer_name) {
        toast.error('Kérjük adja meg az ügyfél nevét')
        return
      }
      
      // Get order details if order_id is provided
      let orderDetails = null
      if (formData.order_id) {
        const { data, error } = await supabase
          .from('orders')
          .select('*')
          .eq('id', formData.order_id)
          .single()
        
        if (error) {
          console.error('Error fetching order details:', error)
        } else {
          orderDetails = data
        }
      }
      
      // Get batch details if batch_id is provided
      let batchDetails = null
      if (formData.batch_id) {
        const { data, error } = await supabase
          .from('production_batches')
          .select(`
            *,
            products:recipe_id (name)
          `)
          .eq('id', formData.batch_id)
          .single()
        
        if (error) {
          console.error('Error fetching batch details:', error)
        } else {
          batchDetails = data
        }
      }
      
      // Prepare items array
      let items = []
      
      if (orderDetails && orderDetails.items) {
        // Use items from order
        items = orderDetails.items
      } else if (batchDetails) {
        // Create item from batch
        items = [{
          id: batchDetails.recipe_id,
          name: batchDetails.products?.name || 'Ismeretlen termék',
          quantity: batchDetails.batch_size,
          price: 0
        }]
      }
      
      // Generate order number if not from an existing order
      const orderNumber = orderDetails ? orderDetails.order_number : `DN-${Date.now().toString().slice(-6)}`
      
      // Create delivery note data
      const deliveryNoteData = {
        order_id: formData.order_id || null,
        order_number: orderNumber,
        batch_id: formData.batch_id || null,
        status: 'pending',
        driver_id: formData.driver_id || null,
        vehicle_id: formData.vehicle_id || null,
        customer_name: formData.customer_name,
        customer_address: formData.customer_address || null,
        items,
        delivery_date: formData.delivery_date ? new Date(formData.delivery_date).toISOString() : null,
        notes: formData.notes || null,
        location_id: formData.location_id || null
      }
      
      // Insert into database
      const { data, error } = await supabase
        .from('delivery_notes')
        .insert(deliveryNoteData)
        .select()
      
      if (error) {
        console.error('Database error:', error)
        toast.error('Hiba a szállítólevél létrehozásakor')
        return
      }
      
      toast.success('Szállítólevél sikeresen létrehozva!')
      setShowAddModal(false)
      resetForm()
      loadDeliveryNotes()
    } catch (error) {
      console.error('Hiba a szállítólevél létrehozásakor:', error)
      toast.error('Hiba a szállítólevél létrehozásakor')
    } finally {
      setLoading(false)
    }
  }

  const resetForm = () => {
    setFormData({
      order_id: '',
      batch_id: '',
      driver_id: '',
      vehicle_id: '',
      customer_name: '',
      customer_address: '',
      delivery_date: '',
      notes: '',
      location_id: ''
    })
  }

  const handleOrderChange = async (orderId: string) => {
    if (!orderId) {
      setFormData(prev => ({
        ...prev,
        order_id: '',
        customer_name: '',
        customer_address: ''
      }))
      return
    }
    
    try {
      // Get order details
      const { data, error } = await supabase
        .from('orders')
        .select('*')
        .eq('id', orderId)
        .single()
      
      if (error) {
        console.error('Error fetching order details:', error)
        toast.error('Hiba a rendelés adatainak betöltésekor')
        return
      }
      
      if (data) {
        setFormData(prev => ({
          ...prev,
          order_id: orderId,
          customer_name: data.customer_name || '',
          customer_address: data.customer_address || data.delivery_address || '',
          location_id: data.location_id || prev.location_id
        }))
      }
    } catch (error) {
      console.error('Hiba a rendelés adatainak betöltésekor:', error)
      toast.error('Hiba a rendelés adatainak betöltésekor')
    }
  }

  const handleBatchChange = async (batchId: string) => {
    if (!batchId) {
      return
    }
    
    try {
      // Get batch details
      const { data, error } = await supabase
        .from('production_batches')
        .select(`
          *,
          products:recipe_id (name)
        `)
        .eq('id', batchId)
        .single()
      
      if (error) {
        console.error('Error fetching batch details:', error)
        toast.error('Hiba a gyártási tétel adatainak betöltésekor')
        return
      }
      
      if (data) {
        // If batch has a webshop_order_id, try to find the corresponding order
        if (data.webshop_order_id) {
          const { data: orderData, error: orderError } = await supabase
            .from('orders')
            .select('*')
            .eq('order_number', data.webshop_order_id)
            .maybeSingle()
          
          if (!orderError && orderData) {
            setFormData(prev => ({
              ...prev,
              batch_id: batchId,
              order_id: orderData.id,
              customer_name: orderData.customer_name || '',
              customer_address: orderData.customer_address || orderData.delivery_address || '',
              location_id: orderData.location_id || data.location_id || prev.location_id
            }))
            return
          }
        }
        
        // If no order found, just update with batch info
        setFormData(prev => ({
          ...prev,
          batch_id: batchId,
          location_id: data.location_id || prev.location_id
        }))
      }
    } catch (error) {
      console.error('Hiba a gyártási tétel adatainak betöltésekor:', error)
      toast.error('Hiba a gyártási tétel adatainak betöltésekor')
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Biztosan törölni szeretné ezt a szállítólevelet?')) return
    
    try {
      const { error } = await supabase
        .from('delivery_notes')
        .delete()
        .eq('id', id)
      
      if (error) {
        console.error('Database error:', error)
        toast.error('Hiba a szállítólevél törlésekor')
        return
      }
      
      toast.success('Szállítólevél sikeresen törölve!')
      loadDeliveryNotes()
    } catch (error) {
      console.error('Hiba a szállítólevél törlésekor:', error)
      toast.error('Hiba a szállítólevél törlésekor')
    }
  }

  const handleUpdateStatus = async (id: string, status: DeliveryNote['status']) => {
    try {
      const { error } = await supabase
        .from('delivery_notes')
        .update({ status })
        .eq('id', id)
      
      if (error) {
        console.error('Database error:', error)
        toast.error('Hiba a szállítólevél állapotának frissítésekor')
        return
      }
      
      toast.success(`Szállítólevél állapota frissítve: ${status}`)
      loadDeliveryNotes()
    } catch (error) {
      console.error('Hiba a szállítólevél állapotának frissítésekor:', error)
      toast.error('Hiba a szállítólevél állapotának frissítésekor')
    }
  }

  const handlePrint = (note: DeliveryNote) => {
    // In a real app, this would generate a PDF and print it
    toast.success('Szállítólevél nyomtatása folyamatban...')
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400'
      case 'in_progress': return 'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400'
      case 'delivered': return 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400'
      case 'cancelled': return 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400'
      default: return 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400'
    }
  }

  const getStatusText = (status: string) => {
    switch (status) {
      case 'pending': return 'Függőben'
      case 'in_progress': return 'Folyamatban'
      case 'delivered': return 'Kiszállítva'
      case 'cancelled': return 'Törölve'
      default: return status
    }
  }

  const filteredNotes = deliveryNotes.filter(note => {
    const matchesSearch = 
      note.order_number.toLowerCase().includes(searchTerm.toLowerCase()) ||
      note.customer_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (note.customer_address && note.customer_address.toLowerCase().includes(searchTerm.toLowerCase()))
    
    const matchesStatus = statusFilter === 'all' || note.status === statusFilter
    
    return matchesSearch && matchesStatus
  })

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white flex items-center">
            <FileText className="h-8 w-8 mr-3 text-blue-600" />
            Szállítólevelek
          </h1>
          <p className="mt-2 text-gray-600 dark:text-gray-400">
            Szállítólevelek kezelése és nyomon követése
          </p>
        </div>
        <div className="flex space-x-3">
          <button
            onClick={loadDeliveryNotes}
            className="inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-xl text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
          >
            <RefreshCw className="h-5 w-5 mr-2" />
            Frissítés
          </button>
          <button
            onClick={() => setShowAddModal(true)}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-xl text-white bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700 transition-all duration-200 shadow-lg shadow-blue-500/25"
          >
            <Plus className="h-5 w-5 mr-2" />
            Új szállítólevél
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-sm border border-gray-200 dark:border-gray-700">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Keresés
            </label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Szállítólevél száma, ügyfél neve vagy címe..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Állapot
            </label>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
              <option value="all">Összes állapot</option>
              <option value="pending">Függőben</option>
              <option value="in_progress">Folyamatban</option>
              <option value="delivered">Kiszállítva</option>
              <option value="cancelled">Törölve</option>
            </select>
          </div>
        </div>
      </div>

      {/* Delivery Notes Table */}
      <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead className="bg-gray-50 dark:bg-gray-900">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Szállítólevél
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Ügyfél
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Állapot
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Dátum
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Sofőr
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Műveletek
                </th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              {loading ? (
                <tr>
                  <td colSpan={6} className="px-6 py-4 text-center">
                    <div className="flex justify-center">
                      <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                    </div>
                  </td>
                </tr>
              ) : filteredNotes.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-4 text-center text-gray-500 dark:text-gray-400">
                    Nincsenek szállítólevelek
                  </td>
                </tr>
              ) : (
                filteredNotes.map((note) => (
                  <tr key={note.id} className="hover:bg-gray-50 dark:hover:bg-gray-700">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900 dark:text-white">
                        {note.order_number}
                      </div>
                      <div className="text-xs text-gray-500 dark:text-gray-400">
                        {new Date(note.created_at).toLocaleDateString('hu-HU')}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900 dark:text-white">
                        {note.customer_name}
                      </div>
                      <div className="text-xs text-gray-500 dark:text-gray-400">
                        {note.customer_address || 'Nincs cím megadva'}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(note.status)}`}>
                        {getStatusText(note.status)}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                      {note.delivery_date ? new Date(note.delivery_date).toLocaleDateString('hu-HU') : 'Nincs megadva'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                      {note.driver_id ? 'Sofőr neve' : 'Nincs megadva'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <div className="flex justify-end space-x-2">
                        <button
                          onClick={() => {
                            setSelectedNote(note)
                            setShowViewModal(true)
                          }}
                          className="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                          title="Megtekintés"
                        >
                          <Eye className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handlePrint(note)}
                          className="text-green-600 hover:text-green-900 dark:text-green-400 dark:hover:text-green-300"
                          title="Nyomtatás"
                        >
                          <Download className="h-4 w-4" />
                        </button>
                        {note.status === 'pending' && (
                          <button
                            onClick={() => handleUpdateStatus(note.id, 'in_progress')}
                            className="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                            title="Kiszállítás indítása"
                          >
                            <Truck className="h-4 w-4" />
                          </button>
                        )}
                        {note.status === 'in_progress' && (
                          <button
                            onClick={() => handleUpdateStatus(note.id, 'delivered')}
                            className="text-green-600 hover:text-green-900 dark:text-green-400 dark:hover:text-green-300"
                            title="Kiszállítva"
                          >
                            <CheckCircle className="h-4 w-4" />
                          </button>
                        )}
                        {note.status !== 'delivered' && note.status !== 'cancelled' && (
                          <button
                            onClick={() => handleDelete(note.id)}
                            className="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300"
                            title="Törlés"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white dark:bg-gray-800 rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-bold text-gray-900 dark:text-white">
                  Új szállítólevél
                </h2>
                <button
                  onClick={() => setShowAddModal(false)}
                  className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
                >
                  <X className="h-6 w-6" />
                </button>
              </div>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Rendelés
                    </label>
                    <select
                      value={formData.order_id}
                      onChange={(e) => handleOrderChange(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                    >
                      <option value="">Válasszon rendelést</option>
                      {orders.map(order => (
                        <option key={order.id} value={order.id}>
                          {order.order_number} - {order.customer_name}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Gyártási tétel
                    </label>
                    <select
                      value={formData.batch_id}
                      onChange={(e) => handleBatchChange(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                    >
                      <option value="">Válasszon gyártási tételt</option>
                      {batches.map(batch => (
                        <option key={batch.id} value={batch.id}>
                          {batch.batch_number} - {batch.products?.name || 'Ismeretlen termék'} ({batch.batch_size} db)
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Ügyfél neve *
                    </label>
                    <input
                      type="text"
                      value={formData.customer_name}
                      onChange={(e) => setFormData({ ...formData, customer_name: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Szállítási cím
                    </label>
                    <input
                      type="text"
                      value={formData.customer_address}
                      onChange={(e) => setFormData({ ...formData, customer_address: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Sofőr
                    </label>
                    <select
                      value={formData.driver_id}
                      onChange={(e) => setFormData({ ...formData, driver_id: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                    >
                      <option value="">Válasszon sofőrt</option>
                      {drivers.map(driver => (
                        <option key={driver.id} value={driver.id}>
                          {driver.full_name}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Jármű
                    </label>
                    <select
                      value={formData.vehicle_id}
                      onChange={(e) => setFormData({ ...formData, vehicle_id: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                    >
                      <option value="">Válasszon járművet</option>
                      {vehicles.map(vehicle => (
                        <option key={vehicle.id} value={vehicle.id}>
                          {vehicle.license_plate} - {vehicle.model}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Helyszín
                    </label>
                    <select
                      value={formData.location_id}
                      onChange={(e) => setFormData({ ...formData, location_id: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                    >
                      <option value="">Válasszon helyszínt</option>
                      {locations.map(location => (
                        <option key={location.id} value={location.id}>
                          {location.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Szállítási dátum
                    </label>
                    <input
                      type="date"
                      value={formData.delivery_date}
                      onChange={(e) => setFormData({ ...formData, delivery_date: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                    />
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Megjegyzések
                  </label>
                  <textarea
                    value={formData.notes}
                    onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                    rows={3}
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  />
                </div>

                <div className="flex justify-end space-x-3 mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
                  <button
                    type="button"
                    onClick={() => setShowAddModal(false)}
                    className="px-4 py-2 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                  >
                    Mégse
                  </button>
                  <button
                    type="submit"
                    disabled={loading}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center"
                  >
                    <Save className="h-4 w-4 mr-2" />
                    {loading ? 'Mentés...' : 'Mentés'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* View Modal */}
      {showViewModal && selectedNote && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white dark:bg-gray-800 rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-bold text-gray-900 dark:text-white">
                  Szállítólevél részletei
                </h2>
                <button
                  onClick={() => setShowViewModal(false)}
                  className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
                >
                  <X className="h-6 w-6" />
                </button>
              </div>

              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Szállítólevél szám</label>
                    <p className="text-sm text-gray-900 dark:text-white">{selectedNote.order_number}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Állapot</label>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(selectedNote.status)}`}>
                      {getStatusText(selectedNote.status)}
                    </span>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Ügyfél neve</label>
                    <p className="text-sm text-gray-900 dark:text-white">{selectedNote.customer_name}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Szállítási cím</label>
                    <p className="text-sm text-gray-900 dark:text-white">{selectedNote.customer_address || '-'}</p>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Tételek</label>
                  <div className="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
                    <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                      <thead className="bg-gray-50 dark:bg-gray-900">
                        <tr>
                          <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Termék</th>
                          <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Mennyiség</th>
                        </tr>
                      </thead>
                      <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                        {selectedNote.items && selectedNote.items.map((item, index) => (
                          <tr key={index}>
                            <td className="px-4 py-2 text-sm text-gray-900 dark:text-white">{item.name}</td>
                            <td className="px-4 py-2 text-sm text-gray-900 dark:text-white">{item.quantity} db</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>

                {selectedNote.notes && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Megjegyzések</label>
                    <p className="text-sm text-gray-900 dark:text-white">{selectedNote.notes}</p>
                  </div>
                )}
              </div>

              <div className="flex justify-end space-x-3 mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
                <button
                  onClick={() => setShowViewModal(false)}
                  className="px-4 py-2 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                >
                  Bezárás
                </button>
                <button
                  onClick={() => handlePrint(selectedNote)}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center"
                >
                  <Download className="h-4 w-4 mr-2" />
                  Nyomtatás
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}