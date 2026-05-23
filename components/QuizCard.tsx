'use client'

import type { OptionClient } from '@/types/quiz'

interface QuizCardProps {
  texte: string
  options: OptionClient[]
  onAnswer: (index: number) => void
  disabled: boolean
  selectedIndex: number | null
}

const LETTERS = ['A', 'B', 'C', 'D']

export default function QuizCard({ texte, options, onAnswer, disabled, selectedIndex }: QuizCardProps) {
  return (
    <div className="w-full max-w-2xl mx-auto">
      {/* Question */}
      <div className="bg-[#F5F0E8] border border-[#D4AF37]/30 rounded-2xl p-6 mb-6 shadow-sm">
        <p className="text-[#2C1810] text-xl font-semibold text-center leading-relaxed">
          {texte}
        </p>
      </div>

      {/* Options */}
      <div className="grid gap-3">
        {options.map((option) => {
          const isSelected = selectedIndex === option.ordre
          return (
            <button
              key={option.id}
              onClick={() => !disabled && onAnswer(option.ordre)}
              disabled={disabled}
              className={`
                w-full flex items-center gap-4 px-5 py-4 rounded-xl border-2
                text-left font-medium transition-all duration-200
                ${disabled ? 'cursor-not-allowed' : 'cursor-pointer hover:border-[#D4AF37] hover:bg-[#FAF6EE] hover:shadow-md'}
                ${isSelected
                  ? 'border-[#D4AF37] bg-[#FAF6EE] shadow-md'
                  : 'border-[#E8DCC8] bg-white'
                }
              `}
            >
              <span className={`
                w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold flex-shrink-0
                ${isSelected ? 'bg-[#D4AF37] text-white' : 'bg-[#E8DCC8] text-[#8B7355]'}
              `}>
                {LETTERS[option.ordre]}
              </span>
              <span className="text-[#2C1810]">{option.texte}</span>
            </button>
          )
        })}
      </div>
    </div>
  )
}
