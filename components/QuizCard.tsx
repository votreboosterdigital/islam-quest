'use client'

import type { OptionClient } from '@/types/quiz'

interface QuizCardProps {
  texte: string
  options: OptionClient[]
  onAnswer: (index: number) => void
  disabled: boolean
  selectedIndex: number | null
  loading: boolean
}

const LETTERS = ['A', 'B', 'C', 'D']

export default function QuizCard({
  texte,
  options,
  onAnswer,
  disabled,
  selectedIndex,
  loading,
}: QuizCardProps) {
  return (
    <div className="w-full max-w-2xl mx-auto">
      {/* Énoncé */}
      <div className="bg-[#F5F0E8] border border-[#D4AF37]/30 rounded-2xl p-6 mb-6 shadow-sm">
        <p className="text-[#2C1810] text-xl font-semibold text-center leading-relaxed">
          {texte}
        </p>
      </div>

      {/* Options */}
      <div className="grid gap-3" role="group" aria-label="Choisir une réponse">
        {options.map((option, displayIdx) => {
          const isSelected = selectedIndex === option.ordre
          const isPending = isSelected && loading
          const isDisabledNotSelected = disabled && !isSelected

          return (
            <button
              key={option.id}
              type="button"
              onClick={() => !disabled && onAnswer(option.ordre)}
              disabled={disabled}
              aria-label={`Option ${LETTERS[displayIdx]} : ${option.texte}`}
              aria-pressed={isSelected}
              className={[
                'w-full flex items-center gap-4 px-5 py-4 rounded-xl border-2 text-left font-medium transition-all duration-150',
                // Curseur
                disabled ? 'cursor-not-allowed' : 'cursor-pointer',
                // Hover (uniquement si pas disabled)
                !disabled
                  ? 'hover:border-[#D4AF37] hover:bg-[#FAF6EE] hover:shadow-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#D4AF37] focus-visible:ring-offset-1'
                  : '',
                // Sélectionné en attente de réponse serveur
                isPending ? 'border-[#D4AF37] bg-[#FAF6EE] shadow-md' : '',
                // Sélectionné (confirmé)
                isSelected && !loading ? 'border-[#D4AF37] bg-[#FAF6EE] shadow-md' : '',
                // Non sélectionné + disabled → atténué
                isDisabledNotSelected ? 'opacity-40 border-[#E8DCC8] bg-white' : '',
                // État par défaut
                !isSelected && !disabled ? 'border-[#E8DCC8] bg-white' : '',
              ]
                .filter(Boolean)
                .join(' ')}
            >
              {/* Lettre */}
              <span
                className={[
                  'w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold flex-shrink-0',
                  isSelected ? 'bg-[#D4AF37] text-white' : 'bg-[#E8DCC8] text-[#8B7355]',
                ].join(' ')}
                aria-hidden="true"
              >
                {LETTERS[displayIdx]}
              </span>

              {/* Texte */}
              <span className="text-[#2C1810] flex-1">{option.texte}</span>

              {/* Spinner pendant l'attente serveur */}
              {isPending && (
                <span
                  className="w-4 h-4 rounded-full border-2 border-[#D4AF37] border-t-transparent animate-spin flex-shrink-0"
                  aria-hidden="true"
                />
              )}
            </button>
          )
        })}
      </div>
    </div>
  )
}
