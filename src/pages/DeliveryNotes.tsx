import React, { useState, useEffect, useRef } from 'react'
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
  User,
  Package,
  Printer,
  ChevronRight,
  Navigation,
  UserCheck,
  Fuel,
  ExternalLink,
  AlertTriangle,
  Receipt
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
  subtotal?: number
  tax_amount?: number
  discount_amount?: number
  total_amount?: number
  created_at: string
  updated_at: string
  delivery_date: string | null
  notes: string | null
  location_id: string | null
  production_batches?: {
    batch_number: string
    status: string
  }
  driver_profile?: {
    full_name: string
  }
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
  const [showAssignModal, setShowAssignModal] = useState(false)
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
    delivery_date: new Date().toISOString().split('T')[0],
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
        .select(`
          *,
          production_batches!delivery_notes_batch_id_fkey (
            batch_number,
            status
          ),
          driver_profile:profiles!driver_id (
            full_name
          )
        `)
        .order('created_at', { ascending: false })
      
      if (error) throw error
      setDeliveryNotes(data || [])
    } catch (error) {
      console.error('Error:', error)
      toast.error('Hiba a szállítólevelek betöltésekor')
    } finally {
      setLoading(false)
    }
  }

  const loadOrders = async () => {
    try {
      const { data, error } = await supabase
        .from('orders')
        .select('id, order_number, customer_name, status, items')
        .in('status', ['pending', 'processing', 'confirmed'])
        .order('created_at', { ascending: false })
      if (!error && data) setOrders(data)
    } catch (error) { console.error(error) }
  }

  const loadBatches = async () => {
    try {
      const { data, error } = await supabase
        .from('production_batches')
        .select(`id, batch_number, recipe_id, batch_size, status, products:products!production_batches_recipe_id_fkey (name)`)
        .eq('status', 'completed')
        .order('created_at', { ascending: false })
      if (!error && data) setBatches(data)
    } catch (error) { console.error(error) }
  }

  const loadDrivers = async () => {
    try {
      const { data, error } = await supabase.from('profiles').select('id, full_name').eq('role', 'driver').eq('status', 'active')
      if (!error && data) setDrivers(data)
    } catch (error) { console.error(error) }
  }

  const loadVehicles = async () => {
    try {
      const { data, error } = await supabase.from('vehicles').select('id, license_plate, model').eq('status', 'active')
      if (!error && data) setVehicles(data)
    } catch (error) { console.error(error) }
  }

  const loadLocations = async () => {
    try {
      const { data, error } = await supabase.from('locations').select('id, name').eq('status', 'active')
      if (!error && data) setLocations(data)
    } catch (error) { console.error(error) }
  }

  const handlePrint = (note: DeliveryNote) => {
    const printWindow = window.open('', '_blank');
    if (!printWindow) return;

    const htmlContent = `
      <html>
        <head>
          <title>SZÁLLÍTÓLEVÉL - ${note.order_number}</title>
          <style>
            body { font-family: 'Helvetica', Arial, sans-serif; padding: 40px; color: #1a1a1a; line-height: 1.6; }
            .header { display: flex; justify-content: space-between; border-bottom: 3px solid #000; padding-bottom: 20px; margin-bottom: 30px; }
            .company-info h1 { margin: 0; font-size: 28px; font-weight: 900; text-transform: uppercase; }
            .company-info p { margin: 2px 0; font-size: 13px; color: #444; }
            .doc-details { text-align: right; }
            .doc-details h2 { margin: 0; font-size: 24px; color: #2563eb; font-weight: 900; }
            .box-grid { display: flex; gap: 40px; margin-bottom: 40px; }
            .box { flex: 1; border: 1px solid #e5e7eb; padding: 25px; border-radius: 15px; background: #f9fafb; }
            .box h3 { margin: 0 0 15px 0; font-size: 12px; text-transform: uppercase; color: #6b7280; letter-spacing: 1px; border-bottom: 1px solid #e5e7eb; padding-bottom: 5px; }
            .box p { margin: 4px 0; font-size: 15px; font-weight: 700; }
            table { width: 100%; border-collapse: collapse; margin: 30px 0; background: white; }
            th { text-align: left; background: #1f2937; color: white; padding: 14px 18px; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
            td { padding: 14px 18px; border-bottom: 1px solid #e5e7eb; font-size: 15px; }
            .total { text-align: right; font-size: 20px; font-weight: 900; margin-top: 30px; border-top: 2px solid #000; padding-top: 10px; }
            .footer-sig { margin-top: 100px; display: flex; justify-content: space-between; gap: 100px; }
            .sig-box { flex: 1; border-top: 2px solid #000; padding-top: 15px; text-align: center; font-size: 13px; font-weight: 900; text-transform: uppercase; }
            @media print { .no-print { display: none; } body { padding: 20px; } }
          </style>
        </head>
        <body>
          <div class="header">
            <div class="company-info">
              <h1>Szemesi Pékség Kft.</h1>
              <p>8636 Balatonszemes, Fő utca 1.</p>
              <p>Adószám: 12345678-2-42 | Tel: +36 30 123 4567</p>
            </div>
            <div class="doc-details">
              <h2>SZÁLLÍTÓLEVÉL</h2>
              <p>Sorszám: <strong>${note.order_number}</strong></p>
              <p>Dátum: ${new Date(note.created_at).toLocaleDateString('hu-HU')}</p>
            </div>
          </div>

          <div class="box-grid">
            <div class="box">
              <h3>Eladó / Szállító</h3>
              <p>Szemesi Pékség Kft.</p>
              <p>Központi Sütőüzem</p>
              <p>8636 Balatonszemes</p>
            </div>
            <div class="box">
              <h3>Vevő / Átvevő</h3>
              <p>${note.customer_name}</p>
              <p>${note.customer_address || 'Helyszíni átvétel'}</p>
            </div>
          </div>

          <table>
            <thead>
              <tr>
                <th>Megnevezés</th>
                <th style="text-align: right;">Mennyiség</th>
                <th style="text-align: center;">Egység</th>
                <th>Megjegyzés</th>
              </tr>
            </thead>
            <tbody>
              ${note.items?.map((item: any) => `
                <tr>
                  <td style="font-weight: bold;">${item.name}</td>
                  <td style="text-align: right; font-weight: 900;">${item.quantity}</td>
                  <td style="text-align: center;">${item.unit || 'db'}</td>
                  <td style="font-size: 12px; color: #666;">${note.production_batches ? 'Gyártás: ' + note.production_batches.batch_number : ''}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>

          <div class="footer-sig">
            <div class="sig-box">Kiadó (Pékség képviseletében)</div>
            <div class="sig-box">Átvevő (Vevő vagy Szállító)</div>
          </div>

          <div style="margin-top: 50px; font-size: 10px; color: #999; text-align: center;">
            Ez a bizonylat az AI Bakery Pro rendszerrel készült.
          </div>

          <script>
            window.onload = function() { window.print(); setTimeout(function() { window.close(); }, 500); }
          </script>
        </body>
      </html>
    `;

    printWindow.document.write(htmlContent);
    printWindow.document.close();
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      setLoading(true)
      if (!formData.customer_name) return toast.error('Ügyfél neve kötelező!')
      
      let items = []
      let orderNumber = `DN-${Date.now().toString().slice(-6)}`

      if (formData.order_id) {
        const order = orders.find(o => o.id === formData.order_id)
        if (order) {
          // Minden tételhez egységesen hozzáadjuk a szükséges mezőket
          items = order.items.map((item: any) => ({
            ...item,
            unit_price: item.unit_price || item.price || 0,
            tax_rate: 27,
            tax_amount: ((item.quantity || 1) * (item.unit_price || item.price || 0)) * 0.27,
            total_amount: ((item.quantity || 1) * (item.unit_price || item.price || 0)) * 1.27
          }))
          orderNumber = order.order_number;
        }
      } else if (formData.batch_id) {
        const batch = batches.find(b => b.id === formData.batch_id)
        if (batch) {
          items = [{
            id: batch.recipe_id,
            name: (batch as any).products?.name || 'Termék',
            quantity: batch.batch_size,
            unit: 'db',
            unit_price: 0,
            tax_rate: 27,
            tax_amount: 0,
            total_amount: 0
          }]
        }
      }
      
      // Számítások a számla mintájára
      const subtotal = items.reduce((sum: number, item: any) => sum + ((item.quantity || 0) * (item.unit_price || 0)), 0)
      const taxAmount = items.reduce((sum: number, item: any) => sum + (item.tax_amount || 0), 0)
      const discountAmount = 0
      const totalAmount = subtotal + taxAmount - discountAmount

      const { data, error } = await supabase.from('delivery_notes').insert({
        order_id: formData.order_id || null,
        order_number: orderNumber,
        batch_id: formData.batch_id || null,
        status: 'pending',
        driver_id: formData.driver_id || null,
        vehicle_id: formData.vehicle_id || null,
        customer_name: formData.customer_name,
        customer_address: formData.customer_address,
        items,
        subtotal,
        tax_amount: taxAmount,
        discount_amount: discountAmount,
        total_amount: totalAmount,
        delivery_date: formData.delivery_date,
        notes: formData.notes,
        location_id: formData.location_id || null
      }).select().single()
      
      if (error) throw error

      // ✅ ÚJ: Automatikus számla generálás a szállítólevél alapján (Invoices.tsx mintájára)
      try {
        const dueDate = new Date()
        dueDate.setDate(dueDate.getDate() + 30)
        const invoiceNumber = `INV-${orderNumber}`

        const { data: invoiceData, error: invoiceError } = await supabase
          .from('invoices')
          .insert({
            invoice_number: invoiceNumber,
            customer_name: formData.customer_name,
            customer_address: formData.customer_address || null,
            order_id: formData.order_id || null,
            order_number: orderNumber,
            issue_date: new Date().toISOString().split('T')[0],
            due_date: dueDate.toISOString().split('T')[0],
            payment_method: 'not_specified',
            payment_status: 'pending',
            subtotal: subtotal || 0,
            tax_amount: taxAmount || 0,
            discount_amount: discountAmount,
            total_amount: totalAmount || 0,
            notes: `Automatikusan generálva a ${orderNumber} szállítólevél alapján`,
            created_by: (await supabase.auth.getUser()).data.user?.id
          })
          .select().single()

        if (!invoiceError && invoiceData && items.length > 0) {
          // Számlatételek hozzáadása
          await supabase.from('invoice_items').insert(
            items.map((item: any) => ({
              invoice_id: invoiceData.id,
              description: item.name || 'Termék',
              quantity: item.quantity || 1,
              unit_price: item.unit_price || 0,
              tax_rate: item.tax_rate || 27,
              tax_amount: item.tax_amount || 0,
              total_amount: item.total_amount || 0
            }))
          )
          toast.success(`✅ Szállítólevél + Számla (${invoiceNumber}) sikeresen rögzítve!`)
        } else {
          toast.success('Szállítólevél sikeresen rögzítve!')
          if (invoiceError) console.warn('Számla generálás hiba:', invoiceError)
        }
      } catch (invoiceErr) {
        console.warn('Számla auto-generálás nem sikerült:', invoiceErr)
        toast.success('Szállítólevél sikeresen rögzítve! (Számla manuálisan szükséges)')
      }

      setShowAddModal(false); resetForm(); loadDeliveryNotes();
      handlePrint(data)
    } catch (error: any) {
      toast.error('Hiba a mentéskor: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const handleUpdateStatus = async (id: string, status: string) => {
    try {
      // FIX: Csak a státuszt küldjük, semmi join-olt adatot
      const { error } = await supabase
        .from('delivery_notes')
        .update({ status: status })
        .eq('id', id)
      
      if (error) throw error
      toast.success(`Állapot frissítve: ${status}`)
      loadDeliveryNotes()
    } catch (e: any) {
      console.error(e)
      toast.error('PATCH hiba: Az adatbázis elutasította a módosítást.')
    }
  }

  // ✅ ÚJ: Szállítás indítása - státusz frissítés + Google Maps navigáció megnyitása
  const handleStartDelivery = async (note: DeliveryNote) => {
    try {
      // 1. Státusz frissítése in_progress-ra
      const { error } = await supabase
        .from('delivery_notes')
        .update({ status: 'in_progress' })
        .eq('id', note.id)

      if (error) throw error

      toast.success('🚚 Kiszállítás megkezdve!')
      loadDeliveryNotes()

      // 2. Google Maps megnyitása a kiszállítási címmel
      if (note.customer_address) {
        const origin = encodeURIComponent('Balatonszemes, Fő utca 1, Magyarország')
        const destination = encodeURIComponent(note.customer_address + ', Magyarország')
        const mapsUrl = `https://www.google.com/maps/dir/?api=1&origin=${origin}&destination=${destination}&travelmode=driving`
        window.open(mapsUrl, '_blank')
      } else {
        toast('ℹ️ Nincs kiszállítási cím megadva, navigáció nem indítható.', { icon: '📍' })
      }
    } catch (e: any) {
      console.error(e)
      toast.error('Hiba a szállítás indításakor.')
    }
  }

  // ✅ ÚJ: Szállítólevél "Kiszállítva" státuszra állítása
  const handleMarkDelivered = async (note: DeliveryNote) => {
    try {
      const { error } = await supabase
        .from('delivery_notes')
        .update({ status: 'delivered' })
        .eq('id', note.id)

      if (error) throw error

      toast.success('✅ Szállítólevél kiszállítottnak jelölve!')
      loadDeliveryNotes()
      if (showViewModal) setShowViewModal(false)
    } catch (e: any) {
      console.error(e)
      toast.error('Hiba a státusz frissítésénél.')
    }
  }

  // ✅ ÚJ: Számla generálása szállítólevél alapján
  const handleGenerateInvoice = async (note: DeliveryNote) => {
    try {
      setLoading(true)

      // Szállítólevél teljes adatainak letöltése
      const { data: fullNote, error: fetchError } = await supabase
        .from('delivery_notes')
        .select('*')
        .eq('id', note.id)
        .single()

      if (fetchError || !fullNote) throw new Error('Szállítólevél adatok nem érhetők el')

      // Számla adatok előkészítése
      const items = fullNote.items || []
      const subtotal = items.reduce((sum: number, item: any) => sum + ((item.quantity || 0) * (item.unit_price || 0)), 0)
      const taxAmount = items.reduce((sum: number, item: any) => sum + (item.tax_amount || 0), 0)
      const totalAmount = subtotal + taxAmount
      const dueDate = new Date()
      dueDate.setDate(dueDate.getDate() + 30)
      const invoiceNumber = `INV-${fullNote.order_number}-${Date.now().toString().slice(-4)}`

      // Számla beszúrása
      const { data: invoiceData, error: invoiceError } = await supabase
        .from('invoices')
        .insert({
          invoice_number: invoiceNumber,
          customer_name: fullNote.customer_name,
          customer_address: fullNote.customer_address || null,
          order_id: fullNote.order_id || null,
          order_number: fullNote.order_number,
          issue_date: new Date().toISOString().split('T')[0],
          due_date: dueDate.toISOString().split('T')[0],
          payment_method: 'not_specified',
          payment_status: 'pending',
          subtotal: subtotal || 0,
          tax_amount: taxAmount || 0,
          discount_amount: 0,
          total_amount: totalAmount || 0,
          notes: `Szállítólevélből (${fullNote.order_number}) automatikusan generálva`,
          created_by: (await supabase.auth.getUser()).data.user?.id
        })
        .select().single()

      if (invoiceError) throw invoiceError

      if (invoiceData && items.length > 0) {
        // Számlatételek hozzáadása
        const { error: itemsError } = await supabase
          .from('invoice_items')
          .insert(
            items.map((item: any) => ({
              invoice_id: invoiceData.id,
              description: item.name || 'Termék',
              quantity: item.quantity || 1,
              unit_price: item.unit_price || 0,
              tax_rate: item.tax_rate || 27,
              tax_amount: item.tax_amount || 0,
              total_amount: item.total_amount || 0
            }))
          )

        if (itemsError) {
          console.error('Számlatételek hozzáadásánál hiba:', itemsError)
        }

        toast.success(`✅ Számla sikeresen létrehozva!`)
        setShowViewModal(false)
      }
    } catch (e: any) {
      console.error(e)
      toast.error('Hiba a számla generálásánál: ' + e.message)
    } finally {
      setLoading(false)
    }
  }

  const handleAssignDriver = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedNote) return;
    try {
      const { error } = await supabase
        .from('delivery_notes')
        .update({ 
          driver_id: formData.driver_id, 
          vehicle_id: formData.vehicle_id 
        })
        .eq('id', selectedNote.id);
      
      if (error) throw error;
      toast.success('Sofőr és jármű rögzítve!');
      setShowAssignModal(false);
      loadDeliveryNotes();
    } catch (e) { toast.error('Hiba a hozzárendelésnél'); }
  }

  const resetForm = () => {
    setFormData({
      order_id: '', batch_id: '', driver_id: '', vehicle_id: '',
      customer_name: '', customer_address: '', delivery_date: new Date().toISOString().split('T')[0],
      notes: '', location_id: ''
    })
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400'
      case 'in_progress': return 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400'
      case 'delivered': return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
      case 'cancelled': return 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'
      default: return 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-400'
    }
  }

  const filteredNotes = deliveryNotes.filter(note => 
    note.order_number.toLowerCase().includes(searchTerm.toLowerCase()) ||
    note.customer_name.toLowerCase().includes(searchTerm.toLowerCase())
  )

  return (
    <div className="p-6 space-y-6 bg-gray-950 min-h-screen text-white font-sans">
      {/* Header UI */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 border-b border-gray-800 pb-8">
        <div>
          <h1 className="text-4xl font-black flex items-center tracking-tighter uppercase text-blue-500">
            <Truck className="h-10 w-10 mr-4" /> SZÁLLÍTÓLEVELEK
          </h1>
          <p className="text-gray-500 font-bold mt-1 uppercase tracking-widest text-xs">Logisztikai irányítóközpont</p>
        </div>
        <div className="flex flex-wrap gap-3">
          <button onClick={loadDeliveryNotes} className="bg-gray-900 p-3 rounded-2xl border border-gray-800 hover:bg-gray-800 transition-all shadow-lg">
            <RefreshCw className={loading ? 'animate-spin' : ''} />
          </button>
          <button onClick={() => navigate('/route-optimization')} className="bg-gray-900 px-6 py-3 rounded-2xl border border-gray-800 font-black flex items-center gap-2 hover:bg-gray-800 transition-all text-xs tracking-widest uppercase">
            <Navigation size={18} className="text-blue-500" /> Útvonal optimalizálás
          </button>
          <button onClick={() => setShowAddModal(true)} className="bg-blue-600 text-white px-8 py-3 rounded-2xl font-black shadow-[0_0_30px_rgba(37,99,235,0.3)] hover:bg-blue-500 flex items-center gap-2 transition-all uppercase tracking-tighter text-sm">
            <Plus size={24} /> ÚJ BIZONYLAT
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 bg-gray-900/50 p-6 rounded-[2.5rem] border border-gray-800">
        <div className="relative">
          <Search className="absolute left-5 top-1/2 -translate-y-1/2 text-gray-500" size={20} />
          <input 
            type="text" 
            placeholder="Keresés ügyfél, cím vagy bizonylatszám alapján..." 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-14 pr-4 py-4 bg-gray-800 border-none rounded-2xl text-white font-medium focus:ring-2 focus:ring-blue-500"
          />
        </div>
        <div className="flex gap-3">
           <select 
             value={statusFilter} 
             onChange={(e) => setStatusFilter(e.target.value)}
             className="flex-1 bg-gray-800 border-none rounded-2xl px-6 py-4 text-white font-bold outline-none appearance-none"
           >
             <option value="all">MINDEN ÁLLAPOT</option>
             <option value="pending">VÁRAKOZÓ</option>
             <option value="in_progress">SZÁLLÍTÁS ALATT</option>
             <option value="delivered">KISZÁLLÍTVA</option>
           </select>
           <button className="p-4 bg-gray-800 rounded-2xl text-gray-400 hover:text-white transition-all"><Filter/></button>
        </div>
      </div>

      {/* Grid List */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
        {loading ? (
          <div className="col-span-full py-20 text-center uppercase font-black animate-pulse text-gray-600 tracking-[0.3em]">Adatok letöltése az adatbázisból...</div>
        ) : filteredNotes.length === 0 ? (
          <div className="col-span-full py-32 text-center bg-gray-900/20 rounded-[3rem] border-2 border-dashed border-gray-800 text-gray-700 font-black uppercase tracking-widest">Nincsenek aktív kiszállítások</div>
        ) : (
          filteredNotes.map((note) => (
            <div key={note.id} className="bg-gray-900 border border-gray-800 rounded-[3rem] p-8 hover:border-blue-500 transition-all group relative overflow-hidden shadow-2xl flex flex-col justify-between h-full">
              <div className="absolute top-0 right-0 p-8 opacity-[0.03] pointer-events-none group-hover:opacity-[0.07] transition-all"><FileText size={150} /></div>
              
              <div className="relative">
                <div className="flex justify-between items-start mb-8">
                  <div>
                    <h3 className="text-3xl font-black text-white group-hover:text-blue-400 transition-colors tracking-tighter uppercase">{note.order_number}</h3>
                    <div className="flex items-center gap-2 mt-2">
                        <Calendar size={14} className="text-gray-600"/>
                        <p className="text-[10px] text-gray-500 uppercase font-black tracking-widest">{new Date(note.created_at).toLocaleString('hu-HU')}</p>
                    </div>
                  </div>
                  <span className={`px-5 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest shadow-lg ${getStatusColor(note.status)}`}>
                    {note.status === 'pending' ? 'Várakozik' : note.status === 'in_progress' ? 'Úton' : 'Kész'}
                  </span>
                </div>

                <div className="space-y-5 mb-10">
                  <div className="flex items-start gap-4">
                    <div className="p-3 bg-blue-500/10 rounded-2xl"><User size={18} className="text-blue-500"/></div>
                    <div>
                        <p className="text-[10px] text-gray-600 uppercase font-black tracking-widest mb-1">Ügyfél neve</p>
                        <p className="text-lg font-bold text-gray-100">{note.customer_name}</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-4">
                    <div className="p-3 bg-amber-500/10 rounded-2xl"><MapPin size={18} className="text-amber-500"/></div>
                    <div>
                        <p className="text-[10px] text-gray-600 uppercase font-black tracking-widest mb-1">Kiszállítási cím</p>
                        <p className="text-sm text-gray-400 font-medium leading-snug">{note.customer_address || 'Telephelyi átvétel'}</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-4 pt-4 border-t border-gray-800">
                    <div className="p-3 bg-purple-500/10 rounded-2xl"><UserCheck size={18} className="text-purple-500"/></div>
                    <div>
                        <p className="text-[10px] text-gray-600 uppercase font-black tracking-widest mb-1">Hozzárendelt sofőr</p>
                        <p className={`text-xs font-black uppercase ${note.driver_profile?.full_name ? 'text-blue-400' : 'text-red-500/50 italic'}`}>
                          {note.driver_profile?.full_name || 'NINCS KIJELÖLVE'}
                        </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="space-y-3">
                <div className="flex gap-2">
                  <button 
                    onClick={() => { setSelectedNote(note); setShowViewModal(true); }} 
                    className="flex-1 bg-gray-800 p-5 rounded-2xl hover:bg-gray-700 font-black text-xs uppercase tracking-widest transition-all border border-gray-700"
                  >
                    Részletek
                  </button>
                  <button 
                    onClick={() => handlePrint(note)} 
                    className="p-5 bg-gray-800 rounded-2xl hover:bg-green-600 text-green-500 hover:text-white border border-gray-700 transition-all shadow-xl"
                  >
                    <Printer size={22}/>
                  </button>
                  <button 
                    onClick={() => { setSelectedNote(note); setShowAssignModal(true); }} 
                    className="p-5 bg-gray-800 rounded-2xl hover:bg-purple-600 text-purple-400 hover:text-white border border-gray-700 transition-all shadow-xl"
                  >
                    <UserCheck size={22}/>
                  </button>
                </div>

                {note.status === 'pending' && (
                  <button 
                    onClick={() => handleStartDelivery(note)} 
                    className="w-full bg-blue-600 py-5 rounded-[1.5rem] font-black uppercase text-sm tracking-tighter hover:bg-blue-500 transition-all flex items-center justify-center gap-3 shadow-[0_10px_30px_rgba(37,99,235,0.2)]"
                  >
                    <Navigation size={20} /> SZÁLLÍTÁS MEGKEZDÉSE + NAVIGÁCIÓ
                  </button>
                )}

                {note.status === 'in_progress' && (
                   <button 
                    onClick={() => handleMarkDelivered(note)}
                    className="w-full bg-green-600 py-5 rounded-[1.5rem] font-black uppercase text-sm tracking-tighter hover:bg-green-500 transition-all flex items-center justify-center gap-3 shadow-[0_10px_30px_rgba(34,197,94,0.2)]"
                   >
                    <CheckCircle size={20} /> KISZÁLLÍTVA
                   </button>
                )}

                {note.status === 'delivered' && (
                   <button 
                    onClick={() => handleGenerateInvoice(note)}
                    disabled={loading}
                    className="w-full bg-purple-600 py-5 rounded-[1.5rem] font-black uppercase text-sm tracking-tighter hover:bg-purple-500 transition-all flex items-center justify-center gap-3 shadow-[0_10px_30px_rgba(147,51,234,0.2)] disabled:opacity-50"
                   >
                    <Receipt size={20} /> SZÁMLA GENERÁLÁS
                   </button>
                )}
              </div>
            </div>
          ))
        )}
      </div>

      {/* --- ADD MODAL --- */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black/95 z-[1000] flex items-center justify-center p-4 backdrop-blur-xl">
          <div className="bg-gray-900 border border-gray-800 rounded-[3rem] p-12 w-full max-w-2xl shadow-2xl overflow-y-auto max-h-[90vh]">
            <div className="flex justify-between items-center mb-12 border-b border-gray-800 pb-8">
              <h2 className="text-4xl font-black uppercase tracking-tighter">Új Bizonylat</h2>
              <button onClick={() => setShowAddModal(false)} className="bg-gray-800 p-4 rounded-3xl hover:text-red-500 transition-all text-white"><X size={28}/></button>
            </div>
            <form onSubmit={handleSubmit} className="space-y-8">
              <div className="space-y-4">
                <p className="text-[10px] font-black text-gray-500 uppercase tracking-widest ml-2">Forrás kiválasztása</p>
                <select 
                  onChange={(e) => { 
                    const b = batches.find(bt => bt.id === e.target.value); 
                    setFormData({...formData, batch_id: e.target.value, customer_name: b?.products?.name ? 'Gyártás: ' + b.products.name : '' }) 
                  }} 
                  className="w-full bg-gray-800 border-none rounded-2xl p-5 text-white font-bold text-lg"
                >
                  <option value="">Válasszon kész gyártási fázist...</option>
                  {batches.map(b => <option key={b.id} value={b.id}>{b.batch_number} - {b.products?.name}</option>)}
                </select>
              </div>

              <div className="space-y-6">
                <p className="text-[10px] font-black text-gray-500 uppercase tracking-widest ml-2">Ügyfél adatai</p>
                <input required placeholder="Ügyfél neve" value={formData.customer_name} onChange={e => setFormData({...formData, customer_name: e.target.value})} className="w-full bg-gray-800 border-none rounded-2xl p-5 text-white text-xl font-black placeholder:text-gray-700" />
                <input placeholder="Kiszállítási cím" value={formData.customer_address} onChange={e => setFormData({...formData, customer_address: e.target.value})} className="w-full bg-gray-800 border-none rounded-2xl p-5 text-white font-bold placeholder:text-gray-700" />
                <input type="date" value={formData.delivery_date} onChange={e => setFormData({...formData, delivery_date: e.target.value})} className="w-full bg-gray-800 border-none rounded-2xl p-5 text-white font-black" />
              </div>

              <button disabled={loading} type="submit" className="w-full bg-blue-600 py-8 rounded-[2rem] font-black text-2xl hover:bg-blue-500 uppercase tracking-tighter transition-all shadow-[0_20px_50px_rgba(37,99,235,0.3)]">
                BIZONYLAT RÖGZÍTÉSE ÉS NYOMTATÁSA
              </button>
            </form>
          </div>
        </div>
      )}

      {/* --- ASSIGN SOFŐR MODAL --- */}
      {showAssignModal && selectedNote && (
        <div className="fixed inset-0 bg-black/95 z-[1100] flex items-center justify-center p-4 backdrop-blur-md">
           <div className="bg-gray-900 border border-gray-800 rounded-[3rem] p-12 w-full max-w-md shadow-2xl">
              <h2 className="text-3xl font-black uppercase mb-10 tracking-tighter text-center">Logisztikai Beosztás</h2>
              <form onSubmit={handleAssignDriver} className="space-y-8">
                 <div className="space-y-6">
                    <div className="space-y-2">
                       <label className="text-[10px] font-black text-gray-500 uppercase ml-2 tracking-widest">Kiszállító Sofőr</label>
                       <select required value={formData.driver_id} onChange={e => setFormData({...formData, driver_id: e.target.value})} className="w-full bg-gray-800 border-none rounded-2xl p-6 text-white text-lg font-black outline-none focus:ring-2 focus:ring-amber-500 transition-all">
                          <option value="">Válasszon munkatársat...</option>
                          {drivers.map(d => <option key={d.id} value={d.id}>{d.full_name}</option>)}
                       </select>
                    </div>
                    <div className="space-y-2">
                       <label className="text-[10px] font-black text-gray-500 uppercase ml-2 tracking-widest">Gépjármű</label>
                       <select required value={formData.vehicle_id} onChange={e => setFormData({...formData, vehicle_id: e.target.value})} className="w-full bg-gray-800 border-none rounded-2xl p-6 text-white text-lg font-black outline-none focus:ring-2 focus:ring-amber-500 transition-all">
                          <option value="">Válasszon rendszámot...</option>
                          {vehicles.map(v => <option key={v.id} value={v.id}>{v.license_plate} - {v.model}</option>)}
                       </select>
                    </div>
                 </div>
                 <button type="submit" className="w-full bg-amber-600 text-black py-7 rounded-[2rem] font-black uppercase text-xl hover:bg-amber-500 shadow-xl shadow-amber-600/20 transition-all">BEOSZTÁS MENTÉSE</button>
                 <button type="button" onClick={() => setShowAssignModal(false)} className="w-full text-gray-500 font-bold uppercase text-xs tracking-widest">Bezárás mentés nélkül</button>
              </form>
           </div>
        </div>
      )}

      {/* --- VIEW MODAL --- */}
      {showViewModal && selectedNote && (
        <div className="fixed inset-0 bg-black/98 z-[1000] flex items-center justify-center p-4 backdrop-blur-2xl">
          <div className="bg-gray-900 border border-gray-800 rounded-[4rem] p-12 w-full max-w-5xl shadow-2xl overflow-y-auto max-h-[95vh]">
            <div className="flex justify-between items-center mb-12 border-b border-gray-800 pb-8">
              <div>
                 <p className="text-blue-500 font-black text-xs uppercase tracking-[0.3em] mb-2">Bizonylat Adatlap</p>
                 <h2 className="text-5xl font-black uppercase tracking-tighter">{selectedNote.order_number}</h2>
              </div>
              <button onClick={() => setShowViewModal(false)} className="bg-gray-800 p-6 rounded-[2rem] text-white hover:text-red-500 transition-all"><X size={40}/></button>
            </div>
            
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 mb-12">
              <div className="bg-black/30 p-10 rounded-[3rem] border border-gray-800 shadow-inner">
                <h4 className="text-[10px] text-gray-600 font-black uppercase mb-8 flex items-center gap-2 tracking-[0.2em]"><User size={14}/> Vevői információk</h4>
                <p className="text-3xl font-black text-white mb-3">{selectedNote.customer_name}</p>
                <p className="text-xl text-gray-400 font-medium flex items-center gap-3"><MapPin size={24} className="text-blue-500"/> {selectedNote.customer_address || 'Helyszíni átvétel'}</p>
                {selectedNote.notes && (
                   <div className="mt-8 p-6 bg-amber-500/5 rounded-2xl border border-amber-500/10 italic text-amber-200/70">
                      "{selectedNote.notes}"
                   </div>
                )}
              </div>
              <div className="bg-black/30 p-10 rounded-[3rem] border border-gray-800 shadow-inner">
                <h4 className="text-[10px] text-gray-600 font-black uppercase mb-8 flex items-center gap-2 tracking-[0.2em]"><Truck size={14}/> Logisztikai adatok</h4>
                <div className="space-y-6">
                   <div className="flex justify-between items-end border-b border-gray-800 pb-4">
                      <span className="text-gray-500 text-xs font-black uppercase tracking-widest">Állapot</span>
                      <span className="text-2xl font-black text-amber-500 uppercase tracking-tighter">{selectedNote.status}</span>
                   </div>
                   <div className="flex justify-between items-end border-b border-gray-800 pb-4">
                      <span className="text-gray-500 text-xs font-black uppercase tracking-widest">Kiszállító</span>
                      <span className="text-xl font-black text-white uppercase tracking-tighter">{selectedNote.driver_profile?.full_name || 'Nincs sofőr'}</span>
                   </div>
                   <div className="flex justify-between items-end border-b border-gray-800 pb-4">
                      <span className="text-gray-500 text-xs font-black uppercase tracking-widest">Dátum</span>
                      <span className="text-xl font-black text-white uppercase tracking-tighter">{selectedNote.delivery_date ? new Date(selectedNote.delivery_date).toLocaleDateString('hu-HU') : '-'}</span>
                   </div>
                </div>
              </div>
            </div>

            <div className="bg-gray-800/50 rounded-[3rem] border border-gray-700 overflow-hidden mb-12 shadow-2xl">
              <table className="w-full text-left">
                <thead className="bg-gray-800 text-[11px] text-gray-400 uppercase font-black tracking-widest">
                  <tr><th className="px-10 py-6">Tétel megnevezése</th><th className="px-10 py-6 text-right">Mennyiség</th></tr>
                </thead>
                <tbody className="divide-y divide-gray-800">
                  {selectedNote.items?.map((item: any, i: number) => (
                    <tr key={i} className="hover:bg-black/20 transition-all">
                      <td className="px-10 py-7 text-white text-xl font-black flex items-center gap-4"><Package size={24} className="text-gray-600"/> {item.name}</td>
                      <td className="px-10 py-7 text-right text-white font-black text-3xl tracking-tighter">{item.quantity} {item.unit || 'db'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div className="flex flex-col md:flex-row gap-6">
               <button onClick={() => handlePrint(selectedNote)} className="flex-1 bg-green-600 py-8 rounded-[2.5rem] font-black flex items-center justify-center gap-4 text-white text-2xl hover:bg-green-500 transition-all shadow-[0_20px_50px_rgba(34,197,94,0.3)]"><Printer size={32}/> NYOMTATÁS</button>
               {selectedNote.status === 'pending' && (
                  <button onClick={() => { setShowViewModal(false); handleStartDelivery(selectedNote) }} className="flex-1 bg-blue-600 py-8 rounded-[2.5rem] font-black flex items-center justify-center gap-4 text-white text-2xl hover:bg-blue-500 transition-all shadow-[0_20px_50px_rgba(37,99,235,0.3)]"><Navigation size={32}/> SZÁLLÍTÁS INDÍTÁSA + NAVIGÁCIÓ</button>
               )}
               {selectedNote.status === 'in_progress' && (
                  <button onClick={() => handleMarkDelivered(selectedNote)} className="flex-1 bg-green-600 py-8 rounded-[2.5rem] font-black flex items-center justify-center gap-4 text-white text-2xl hover:bg-green-500 transition-all shadow-[0_20px_50px_rgba(34,197,94,0.3)]"><CheckCircle size={32}/> KISZÁLLÍTVA</button>
               )}
               {selectedNote.status === 'delivered' && (
                  <button onClick={() => handleGenerateInvoice(selectedNote)} disabled={loading} className="flex-1 bg-purple-600 py-8 rounded-[2.5rem] font-black flex items-center justify-center gap-4 text-white text-2xl hover:bg-purple-500 transition-all shadow-[0_20px_50px_rgba(147,51,234,0.3)] disabled:opacity-50"><Receipt size={32}/> SZÁMLA GENERÁLÁS</button>
               )}
               <button onClick={() => setShowViewModal(false)} className="bg-gray-800 px-16 py-8 rounded-[2.5rem] font-black text-xl text-gray-500 hover:text-white transition-all">BEZÁRÁS</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}