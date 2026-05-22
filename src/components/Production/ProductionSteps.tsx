import React, { useState, useEffect, useCallback } from 'react'
import { 
  ChevronDown, 
  ChevronUp, 
  CheckCircle, 
  Clock, 
  AlertTriangle, 
  X, 
  Thermometer, 
  Droplets,
  Timer,
  Save
} from 'lucide-react'
import { supabase } from '../../lib/supabase'
import { toast } from 'react-hot-toast'

interface ProductionStepsProps {
  batch: {
    id: string
    batch_number: string
    recipe_id: string
    recipe_name?: string
    batch_size: number
    status: string
  }
  steps: any[]
  loading: boolean
  onClose: () => void
  onStepUpdate: () => void
}

export default function ProductionSteps({ batch, onClose, onStepUpdate }: ProductionStepsProps) {
  const [activeStep, setActiveStep] = useState<string | null>(null)
  const [updatingStep, setUpdatingStep] = useState<string | null>(null)
  const [stepData, setStepData] = useState({ actual_temperature: '', actual_humidity: '', notes: '' })
  const [recipeSteps, setRecipeSteps] = useState<any[]>([])
  const [loadingSteps, setLoadingSteps] = useState(true)

  const loadRecipeSteps = useCallback(async () => {
    try {
      setLoadingSteps(true)
      const { data, error } = await supabase
        .from('recipe_steps')
        .select('*')
        .eq('recipe_id', batch.recipe_id)
        .order('step_number')
      
      if (error) throw error
      setRecipeSteps(data || [])
    } catch (error) {
      console.error('Error:', error)
      toast.error('Hiba a lépések betöltésekor')
    } finally {
      setLoadingSteps(false)
    }
  }, [batch.recipe_id])

  useEffect(() => {
    loadRecipeSteps()
  }, [loadRecipeSteps])

  const handleUpdateStep = async (stepId: string) => {
    setUpdatingStep(stepId)
    try {
      const { error } = await supabase.from('production_progress').insert({
        batch_id: batch.id,
        recipe_step_id: stepId,
        actual_temperature: stepData.actual_temperature ? parseFloat(stepData.actual_temperature) : null,
        actual_humidity: stepData.actual_humidity ? parseFloat(stepData.actual_humidity) : null,
        notes: stepData.notes,
        recorded_at: new Date().toISOString()
      })
      if (error) throw error
      toast.success('Folyamat rögzítve')
      setStepData({ actual_temperature: '', actual_humidity: '', notes: '' })
      setActiveStep(null)
      onStepUpdate()
    } catch (error) {
      toast.error('Hiba a rögzítéskor')
    } finally {
      setUpdatingStep(null)
    }
  }

  return (
    <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 max-w-4xl w-full shadow-2xl overflow-y-auto max-h-[90vh]">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">{batch.batch_number} folyamata</h2>
          <p className="text-gray-500 text-sm">Mennyiség: {batch.batch_size} db</p>
        </div>
        <button onClick={onClose} className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg"><X className="h-6 w-6 text-white" /></button>
      </div>

      {loadingSteps ? <div className="text-white text-center py-10">Betöltés...</div> : (
        <div className="space-y-4">
          {recipeSteps.map((step, index) => (
            <div key={step.id} className="border dark:border-gray-700 rounded-xl overflow-hidden">
              <button onClick={() => setActiveStep(activeStep === step.id ? null : step.id)} className="w-full px-6 py-4 flex items-center justify-between hover:bg-gray-700 transition-colors">
                <div className="flex items-center space-x-4">
                  <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center text-white font-bold">{index + 1}</div>
                  <div className="text-left text-white font-medium">{step.title}</div>
                </div>
                {activeStep === step.id ? <ChevronUp className="text-white" /> : <ChevronDown className="text-white" />}
              </button>
              {activeStep === step.id && (
                <div className="p-6 bg-gray-700/50 border-t dark:border-gray-700 space-y-4">
                  <p className="text-gray-300 text-sm mb-4">{step.description}</p>
                  <div className="grid grid-cols-2 gap-4">
                    <input type="number" placeholder="Aktuális °C" value={stepData.actual_temperature} onChange={e => setStepData({ ...stepData, actual_temperature: e.target.value })} className="bg-gray-800 border-none rounded-lg text-white" />
                    <input type="number" placeholder="Aktuális %" value={stepData.actual_humidity} onChange={e => setStepData({ ...stepData, actual_humidity: e.target.value })} className="bg-gray-800 border-none rounded-lg text-white" />
                  </div>
                  <textarea placeholder="Megjegyzés..." value={stepData.notes} onChange={e => setStepData({ ...stepData, notes: e.target.value })} className="w-full bg-gray-800 border-none rounded-lg text-white" />
                  <button onClick={() => handleUpdateStep(step.id)} disabled={updatingStep === step.id} className="w-full bg-blue-600 text-white py-2 rounded-lg font-bold hover:bg-blue-700 flex items-center justify-center">
                    {updatingStep === step.id ? 'Rögzítés...' : <><Save className="h-4 w-4 mr-2" /> Lépés befejezése</>}
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}