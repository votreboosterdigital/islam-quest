'use client'

import { useState, useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { startGame } from '@/lib/quiz/actions'
import type { Niveau, Categorie } from '@/types/quiz'

const NIVEAUX: { value: Niveau; label: string; emoji: string; desc: string }[] = [
  { value: 'facile', label: 'Facile', emoji: '🌙', desc: "Bases de l'Islam" },
  { value: 'moyen', label: 'Moyen', emoji: '⭐', desc: 'Culture islamique' },
  { value: 'difficile', label: 'Difficile', emoji: '🕌', desc: 'Expert' },
]

const CATEGORIES: { value: Categorie | 'tous'; label: string }[] = [
  { value: 'tous', label: 'Toutes catégories' },
  { value: 'piliers', label: "Piliers de l'Islam" },
  { value: 'coran', label: 'Coran' },
  { value: 'hadith', label: 'Hadith' },
  { value: 'histoire', label: 'Histoire' },
  { value: 'prophetes', label: 'Prophètes' },
  { value: 'foi', label: 'Foi (Aqida)' },
  { value: 'jurisprudence', label: 'Jurisprudence' },
]

export default function NiveauSelector() {
  const router = useRouter()
  const [isPending, startTransition] = useTransition()
  const [niveau, setNiveau] = useState<Niveau>('facile')
  const [categorie, setCategorie] = useState<Categorie | 'tous'>('tous')
  const [pseudo, setPseudo] = useState('')
  const [error, setError] = useState<string | null>(null)

  const handleStart = () => {
    if (!pseudo.trim()) { setError('Entre ton prénom pour commencer.'); return }
    setError(null)
    startTransition(async () => {
      try {
        const { sessionId } = await startGame(niveau, categorie, pseudo.trim())
        router.push(`/quiz/${sessionId}`)
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Erreur de démarrage.')
      }
    })
  }

  return (
    <div className="w-full max-w-md mx-auto space-y-6">
      <div>
        <label className="block text-sm font-semibold text-[#2C1810] mb-2">Ton prénom</label>
        <input
          type="text"
          value={pseudo}
          onChange={(e) => setPseudo(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && handleStart()}
          placeholder="Ex: Yassine"
          maxLength={30}
          className="w-full px-4 py-3 rounded-xl border-2 border-[#E8DCC8] bg-white focus:border-[#D4AF37] focus:outline-none text-[#2C1810] placeholder-[#C4B49A]"
        />
      </div>

      <div>
        <label className="block text-sm font-semibold text-[#2C1810] mb-3">Niveau</label>
        <div className="grid grid-cols-3 gap-2">
          {NIVEAUX.map((n) => (
            <button
              key={n.value}
              onClick={() => setNiveau(n.value)}
              className={`flex flex-col items-center gap-1 py-3 px-2 rounded-xl border-2 transition-all ${
                niveau === n.value
                  ? 'border-[#D4AF37] bg-[#FAF6EE] shadow-sm'
                  : 'border-[#E8DCC8] bg-white hover:border-[#D4AF37]/50'
              }`}
            >
              <span className="text-2xl">{n.emoji}</span>
              <span className="text-xs font-bold text-[#2C1810]">{n.label}</span>
              <span className="text-[10px] text-[#8B7355] text-center">{n.desc}</span>
            </button>
          ))}
        </div>
      </div>

      <div>
        <label className="block text-sm font-semibold text-[#2C1810] mb-2">Catégorie</label>
        <select
          value={categorie}
          onChange={(e) => setCategorie(e.target.value as Categorie | 'tous')}
          className="w-full px-4 py-3 rounded-xl border-2 border-[#E8DCC8] bg-white focus:border-[#D4AF37] focus:outline-none text-[#2C1810]"
        >
          {CATEGORIES.map((c) => (
            <option key={c.value} value={c.value}>{c.label}</option>
          ))}
        </select>
      </div>

      {error && (
        <p className="text-red-600 text-sm bg-red-50 border border-red-200 rounded-lg px-3 py-2">
          {error}
        </p>
      )}

      <button
        onClick={handleStart}
        disabled={isPending}
        className="w-full bg-[#1B4332] hover:bg-[#155128] disabled:opacity-60 text-white font-bold py-4 rounded-xl transition-colors duration-200 text-lg shadow-lg"
      >
        {isPending ? 'Chargement...' : 'بسم الله — Commencer'}
      </button>
    </div>
  )
}
