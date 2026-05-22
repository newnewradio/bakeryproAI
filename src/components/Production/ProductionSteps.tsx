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
import IngredientCalculator from './IngredientCalculator'
import { useNavigate } from 'react-router-dom'

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

export default function ProductionSteps({ batch, steps: initialSteps, loading, onClose, onStepUpdate }: ProductionStepsProps) {
  const [activeStep, setActiveStep] = useState<string | null>(null)
  const [updatingStep, setUpdatingStep] = useState<string | null>(null)
  const [stepData, setStepData] = useState({
    actual_temperature: '',
    actual_humidity: '',
    notes: ''
  })
  const [recipeSteps, setRecipeSteps] = useState<any[]>(initialSteps || [])
  const [loadingSteps, setLoadingSteps] = useState(true)
  const navigate = useNavigate()

  const loadRecipeSteps = useCallback(async () => {
    try {
      setLoadingSteps(true)
      
      // Egyszerűen a recipe_steps-et töltjük be recipe_id alapján
      const { data, error } = await supabase
        .from('recipe_steps')
        .select('*')
        .eq('recipe_id', batch.recipe_id)
        .order('step_number')
      
      if (error) {
        console.error('Error loading recipe steps:', error)
        toast.error('Hiba a gyártási lépések betöltésekor')
        setRecipeSteps([])
        return
      }
      
      if (data && data.length > 0) {
        setRecipeSteps(data)
      } else {
        // Ha nincsenek lépések, hozz létre default-okat
        console.warn('No recipe steps found, creating defaults...')
        await createDefaultSteps()
      }
    } catch (error) {
      console.error('Error:', error)
      toast.error('Hiba a gyártási lépések betöltésekor')
      setRecipeSteps([])
    } finally {
      setLoadingSteps(false)
    }
  }, [batch.recipe_id])

  const createDefaultSteps = async () => {
    try {
      const defaultSteps = [
        {
          recipe_id: batch.recipe_id,
          step_number: 1,
          title: 'Előkészítés',
          description: 'Alapanyagok kimérése és előkészítése',
          duration_minutes: 15
        },
        {
          recipe_id: batch.recipe_id,
          step_number: 2,
          title: 'Dagasztás',
          description: 'Alapanyagok összekeverése és dagasztása',
          duration_minutes: 20
        },
        {
          recipe_id: batch.recipe_id,
          step_number: 3,
          title: 'Kelesztés',
          description: 'Tészta kelesztése',
          duration_minutes: 60,
          temperature: 30,
          humidity: 80
        },
        {
          recipe_id: batch.recipe_id,
          step_number: 4,
          title: 'Formázás',
          description: 'Tészta formázása',
          duration_minutes: 15
        },
        {
          recipe_id: batch.recipe_id,
          step_number: 5,
          title: 'Sütés',
          description: 'Tészta sütése',
          duration_minutes: 30,
          temperature: 220
        }
      ]

      const { data, error } = await supabase
        .from('recipe_steps')
        .insert(defaultSteps)
        .select()

      if (error) {
        console.error('Error creating default steps:', error)
        toast.error('Nem lehet létrehozni az alapértelmezett lépéseket')
        return
      }

      if (data) {
        setRecipeSteps(data)
        toast.success('Alapértelmezett lépések létrehozva - szerkesztheted őket a Receptek oldalon')
      }
    } catch (error) {
      console.error('Error:', error)
      toast.error('Hiba az alapértelmezett lépések létrehozásakor')
    }
  }

  useEffect(() => {
    loadRecipeSteps()
  }, [batch.id, loadRecipeSteps])

  const handleUpdateStep = async (stepId: string) => {
    if (!stepData.actual_temperature && !stepData.actual_humidity && !stepData.notes) {
      toast.error('Adj meg legalább egy adat-t')
      return
    }

    setUpdatingStep(stepId)
    try {
      // Logolunk egy production_progress rekordot
      const { error } = await supabase
        .from('production_progress')
        .insert({
          batch_id: batch.id,
          recipe_step_id: stepId,
          actual_temperature: stepData.actual_temperature ? parseFloat(stepData.actual_temperature) : null,
          actual_humidity: stepData.actual_humidity ? parseFloat(stepData.actual_humidity) : null,
          notes: stepData.notes,
          recorded_at: new Date().toISOString()
        })

      if (error) throw error

      toast.success('Lépés rögzítve!')
      setStepData({ actual_temperature: '', actual_humidity: '', notes: '' })
      setActiveStep(null)
      onStepUpdate()
    } catch (error) {
      console.error('Error updating step:', error)
      toast.error('Hiba a lépés rögzítésekor')
    } finally {
      setUpdatingStep(null)
    }
  }

  if (loadingSteps) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 max-w-4xl">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
            {batch.recipe_name || batch.batch_number}
          </h2>
          <p className="text-gray-600 dark:text-gray-400 text-sm mt-1">
            Tétel: {batch.batch_number} | Mennyiség: {batch.batch_size} db
          </p>
        </div>
        <button
          onClick={onClose}
          className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
        >
          <X className="h-6 w-6 text-gray-500" />
        </button>
      </div>

      {recipeSteps.length === 0 ? (
        <div className="text-center py-12">
          <AlertTriangle className="h-12 w-12 text-amber-600 mx-auto mb-4" />
          <p className="text-gray-600 dark:text-gray-400">Nincs recept lépés ehhez a termékhez</p>
          <p className="text-sm text-gray-500 dark:text-gray-400 mt-2">Menj a Receptek oldalra, és add hozzá a lépéseket</p>
        </div>
      ) : (
        <div className="space-y-4">
          {recipeSteps.map((step, index) => (
            <div
              key={step.id}
              className="border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden hover:shadow-md transition-shadow"
            >
              <button
                onClick={() => setActiveStep(activeStep === step.id ? null : step.id)}
                className="w-full px-6 py-4 flex items-center justify-between hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
              >
                <div className="flex items-center space-x-4">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center text-sm font-semibold text-blue-600 dark:text-blue-400">
                    {index + 1}
                  </div>
                  <div className="text-left">
                    <h3 className="font-semibold text-gray-900 dark:text-white">{step.title}</h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">{step.description}</p>
                  </div>
                </div>
                {activeStep === step.id ? (
                  <ChevronUp className="h-5 w-5 text-gray-400" />
                ) : (
                  <ChevronDown className="h-5 w-5 text-gray-400" />
                )}
              </button>

              {activeStep === step.id && (
                <div className="border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 px-6 py-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                    {step.temperature && (
                      <div className="space-y-2">
                        <label className="flex items-center text-sm font-medium text-gray-700 dark:text-gray-300">
                          <Thermometer className="h-4 w-4 mr-2 text-red-600" />
                          Tervezett hőmérséklet: {step.temperature}°C
                        </label>
                        <input
                          type="number"
                          placeholder="Aktuális °C"
                          value={stepData.actual_temperature}
                          onChange={e => setStepData({ ...stepData, actual_temperature: e.target.value })}
                          className="w-full border rounded-lg px-3 py-2 dark:bg-gray-600 dark:border-gray-500 dark:text-white"
                        />
                      </div>
                    )}

                    {step.humidity && (
                      <div className="space-y-2">
                        <label className="flex items-center text-sm font-medium text-gray-700 dark:text-gray-300">
                          <Droplets className="h-4 w-4 mr-2 text-blue-600" />
                          Tervezett páratartalom: {step.humidity}%
                        </label>
                        <input
                          type="number"
                          placeholder="Aktuális %"
                          value={stepData.actual_humidity}
                          onChange={e => setStepData({ ...stepData, actual_humidity: e.target.value })}
                          className="w-full border rounded-lg px-3 py-2 dark:bg-gray-600 dark:border-gray-500 dark:text-white"
                        />
                      </div>
                    )}
                  </div>

                  {step.duration_minutes && (
                    <div className="mb-6 p-4 bg-white dark:bg-gray-600 rounded-lg border border-gray-200 dark:border-gray-500 flex items-center">
                      <Timer className="h-5 w-5 text-amber-600 mr-3" />
                      <span className="text-sm font-medium text-gray-700 dark:text-gray-100">
                        Becsült időtartam: {step.duration_minutes} perc
                      </span>
                    </div>
                  )}

                  <div className="space-y-2 mb-6">
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                      Megjegyzések
                    </label>
                    <textarea
                      placeholder="Pl: Jól haladt, sütőhőmérséklet ideális..."
                      value={stepData.notes}
                      onChange={e => setStepData({ ...stepData, notes: e.target.value })}
                      rows={3}
                      className="w-full border rounded-lg px-3 py-2 dark:bg-gray-600 dark:border-gray-500 dark:text-white"
                    />
                  </div>

                  <button
                    onClick={() => handleUpdateStep(step.id)}
                    disabled={updatingStep === step.id}
                    className="w-full bg-blue-600 hover:bg-blue-700 disabled:opacity-50 text-white font-semibold rounded-lg py-2 flex items-center justify-center gap-2 transition-colors"
                  >
                    {updatingStep === step.id ? (
                      <>
                        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                        Rögzítés...
                      </>
                    ) : (
                      <>
                        <Save className="h-4 w-4" />
                        Lépés befejezése
                      </>
                    )}
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
