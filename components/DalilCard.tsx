'use client'

import ArabicText from './ArabicText'
import type { Dalil, OptionClient } from '@/types/quiz'

interface DalilCardProps {
  dalil: Dalil
  correct: boolean
  skipped: boolean
  correctOrdre: number
  options: OptionClient[]
  onNext: () => void
  isLast: boolean
}

const LETTERS = ['A', 'B', 'C', 'D']

const SOURCE_LABELS: Record<string, { label: string; colorClass: string }> = {
  quran: { label: 'Coran', colorClass: 'bg-emerald-100 text-emerald-800 border-emerald-300' },
  hadith: { label: 'Hadith', colorClass: 'bg-amber-100 text-amber-800 border-amber-300' },
  sunnah: { label: 'Sunnah', colorClass: 'bg-amber-100 text-amber-800 border-amber-300' },
  scholar: { label: 'Savants', colorClass: 'bg-blue-100 text-blue-800 border-blue-300' },
  other: { label: 'Référence', colorClass: 'bg-slate-100 text-slate-700 border-slate-300' },
}

export default function DalilCard({
  dalil,
  correct,
  skipped,
  correctOrdre,
  options,
  onNext,
  isLast,
}: DalilCardProps) {
  const sourceInfo = SOURCE_LABELS[dalil.source_type ?? 'other'] ?? SOURCE_LABELS.other
  const correctDisplayIdx = options.findIndex((o) => o.ordre === correctOrdre)
  const correctOption = options[correctDisplayIdx]

  const statusConfig = skipped
    ? {
        colorClass: 'bg-slate-100 text-slate-700 border-slate-300',
        icon: '⏱',
        text: 'Temps écoulé',
      }
    : correct
    ? {
        colorClass: 'bg-emerald-100 text-emerald-800 border-emerald-300',
        icon: '✓',
        text: 'Bonne réponse !',
      }
    : {
        colorClass: 'bg-red-100 text-red-800 border-red-300',
        icon: '✗',
        text: 'Mauvaise réponse',
      }

  return (
    <div className="w-full max-w-2xl mx-auto">
      {/* Badge résultat */}
      <div
        className={`flex items-center gap-2 mb-4 px-4 py-2 rounded-full w-fit mx-auto font-semibold text-sm border ${statusConfig.colorClass}`}
        role="status"
        aria-live="polite"
      >
        <span aria-hidden="true">{statusConfig.icon}</span>
        <span>{statusConfig.text}</span>
      </div>

      {/* Bonne réponse si raté ou sauté */}
      {(!correct || skipped) && correctOption && (
        <div className="mb-4 px-4 py-3 rounded-xl bg-emerald-50 border border-emerald-200">
          <p className="text-xs font-semibold text-emerald-700 mb-1">Bonne réponse :</p>
          <p className="text-sm text-emerald-900 font-medium">
            <span className="font-bold">{LETTERS[correctDisplayIdx] ?? '?'}.</span>{' '}
            {correctOption.texte}
          </p>
        </div>
      )}

      {/* Carte dalil — masquée si pas de contenu (fallback erreur réseau) */}
      <div className="bg-[#1B4332] rounded-2xl overflow-hidden shadow-xl">
        {/* Explication */}
        {dalil.explication ? (
          <div className="bg-white/10 px-6 py-4">
            <p className="text-white/90 text-sm leading-relaxed">{dalil.explication}</p>
          </div>
        ) : (
          <div className="bg-white/10 px-6 py-4">
            <p className="text-white/50 text-sm text-center italic">Correction non disponible</p>
          </div>
        )}

        {/* Séparateur décoratif */}
        <div className="flex items-center gap-3 px-6 py-2" aria-hidden="true">
          <div className="h-px flex-1 bg-[#D4AF37]/40" />
          <span className="text-[#D4AF37] text-lg">❋</span>
          <div className="h-px flex-1 bg-[#D4AF37]/40" />
        </div>

        {/* Texte arabe */}
        {dalil.texte_arabe && (
          <div className="px-6 py-4">
            <ArabicText text={dalil.texte_arabe} size="lg" className="text-white" />
          </div>
        )}

        {/* Traduction */}
        {dalil.traduction && (
          <div className="px-6 pb-3">
            <p className="text-white/80 text-sm text-center italic leading-relaxed">
              {dalil.traduction}
            </p>
          </div>
        )}

        {/* Référence + badge source */}
        <div className="flex items-center justify-center gap-2 pb-4 flex-wrap px-4">
          <span className={`border text-xs font-semibold px-2 py-0.5 rounded-full ${sourceInfo.colorClass}`}>
            {sourceInfo.label}
          </span>
          <span className="bg-[#D4AF37] text-[#1B4332] text-xs font-bold px-3 py-1 rounded-full">
            {dalil.reference}
          </span>
        </div>
      </div>

      {/* Bouton suivant */}
      <button
        type="button"
        onClick={onNext}
        className="mt-6 w-full bg-[#D4AF37] hover:bg-[#B8962E] text-[#1B4332] font-bold py-3 px-6 rounded-xl transition-colors duration-200 flex items-center justify-center gap-2 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#1B4332] focus-visible:ring-offset-2"
        aria-label={isLast ? 'Voir les résultats' : 'Question suivante'}
      >
        {isLast ? 'Voir mes résultats' : 'Question suivante →'}
      </button>
    </div>
  )
}
