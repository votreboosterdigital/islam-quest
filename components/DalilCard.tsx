'use client'

import ArabicText from './ArabicText'
import type { Dalil } from '@/types/quiz'

interface DalilCardProps {
  dalil: Dalil
  correct: boolean
  onNext: () => void
  isLast: boolean
}

export default function DalilCard({ dalil, correct, onNext, isLast }: DalilCardProps) {
  return (
    <div className="w-full max-w-2xl mx-auto animate-fade-in">
      {/* Résultat badge */}
      <div className={`flex items-center gap-2 mb-4 px-4 py-2 rounded-full w-fit mx-auto font-semibold text-sm ${
        correct
          ? 'bg-emerald-100 text-emerald-800 border border-emerald-300'
          : 'bg-red-100 text-red-800 border border-red-300'
      }`}>
        <span>{correct ? '✓' : '✗'}</span>
        <span>{correct ? 'Bonne réponse !' : 'Mauvaise réponse'}</span>
      </div>

      {/* Carte principale */}
      <div className="bg-[#1B4332] rounded-2xl overflow-hidden shadow-xl">
        {/* Explication */}
        <div className="bg-white/10 px-6 py-4">
          <p className="text-white/90 text-sm leading-relaxed">{dalil.explication}</p>
        </div>

        {/* Séparateur décoratif */}
        <div className="flex items-center gap-3 px-6 py-2">
          <div className="h-px flex-1 bg-[#D4AF37]/40" />
          <span className="text-[#D4AF37] text-lg">❋</span>
          <div className="h-px flex-1 bg-[#D4AF37]/40" />
        </div>

        {/* Texte arabe */}
        <div className="px-6 py-4">
          <ArabicText text={dalil.texte_arabe} size="lg" className="text-white" />
        </div>

        {/* Traduction */}
        <div className="px-6 pb-3">
          <p className="text-white/80 text-sm text-center italic leading-relaxed">
            {dalil.traduction}
          </p>
        </div>

        {/* Référence */}
        <div className="flex justify-center pb-4">
          <span className="bg-[#D4AF37] text-[#1B4332] text-xs font-bold px-3 py-1 rounded-full">
            {dalil.reference}
          </span>
        </div>
      </div>

      {/* Bouton suivant */}
      <button
        onClick={onNext}
        className="mt-6 w-full bg-[#D4AF37] hover:bg-[#B8962E] text-[#1B4332] font-bold py-3 px-6 rounded-xl transition-colors duration-200 flex items-center justify-center gap-2"
      >
        {isLast ? 'Voir mes résultats' : 'Question suivante →'}
      </button>
    </div>
  )
}
