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

const TIMER_OPTIONS: { value: number; label: string; desc: string }[] = [
  { value: 0, label: 'Libre', desc: 'Sans limite' },
  { value: 20, label: '20 s', desc: 'Rapide' },
  { value: 30, label: '30 s', desc: 'Normal' },
  { value: 45, label: '45 s', desc: 'Détendu' },
]

export default function NiveauSelector() {
  const router = useRouter()
  const [isPending, startTransition] = useTransition()
  const [niveau, setNiveau] = useState<Niveau>('facile')
  const [categorie, setCategorie] = useState<Categorie | 'tous'>('tous')
  const [pseudo, setPseudo] = useState('')
  const [timerSeconds, setTimerSeconds] = useState<number>(30)
  const [error, setError] = useState<string | null>(null)

  const handleStart = () => {
    if (!pseudo.trim()) {
      setError('Entre ton prénom pour commencer.')
      return
    }
    setError(null)
    startTransition(async () => {
      try {
        const { sessionId } = await startGame(niveau, categorie, pseudo.trim())
        router.push(`/quiz/${sessionId}?timer=${timerSeconds}`)
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Erreur de démarrage.')
      }
    })
  }

  return (
    <div className="w-full max-w-md mx-auto space-y-6">
      {/* Prénom */}
      <div>
        <label htmlFor="pseudo" className="block text-sm font-semibold text-[#2C1810] mb-2">
          Ton prénom
        </label>
        <input
          id="pseudo"
          type="text"
          value={pseudo}
          onChange={(e) => setPseudo(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && handleStart()}
          placeholder="Ex: Yassine"
          maxLength={30}
          autoComplete="given-name"
          className="w-full px-4 py-3 rounded-xl border-2 border-[#E8DCC8] bg-white focus:border-[#D4AF37] focus:outline-none text-[#2C1810] placeholder-[#C4B49A]"
        />
      </div>

      {/* Niveau */}
      <div>
        <span id="niveau-label" className="block text-sm font-semibold text-[#2C1810] mb-3">
          Niveau
        </span>
        <div className="grid grid-cols-3 gap-2" role="radiogroup" aria-labelledby="niveau-label">
          {NIVEAUX.map((n) => (
            <button
              key={n.value}
              type="button"
              role="radio"
              aria-checked={niveau === n.value}
              onClick={() => setNiveau(n.value)}
              className={`flex flex-col items-center gap-1 py-3 px-2 rounded-xl border-2 transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#D4AF37] focus-visible:ring-offset-1 ${
                niveau === n.value
                  ? 'border-[#D4AF37] bg-[#FAF6EE] shadow-sm'
                  : 'border-[#E8DCC8] bg-white hover:border-[#D4AF37]/50'
              }`}
            >
              <span className="text-2xl" aria-hidden="true">{n.emoji}</span>
              <span className="text-xs font-bold text-[#2C1810]">{n.label}</span>
              <span className="text-[10px] text-[#8B7355] text-center">{n.desc}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Catégorie */}
      <div>
        <label htmlFor="categorie" className="block text-sm font-semibold text-[#2C1810] mb-2">
          Catégorie
        </label>
        <select
          id="categorie"
          value={categorie}
          onChange={(e) => setCategorie(e.target.value as Categorie | 'tous')}
          className="w-full px-4 py-3 rounded-xl border-2 border-[#E8DCC8] bg-white focus:border-[#D4AF37] focus:outline-none text-[#2C1810]"
        >
          {CATEGORIES.map((c) => (
            <option key={c.value} value={c.value}>{c.label}</option>
          ))}
        </select>
      </div>

      {/* Mode chrono */}
      <div>
        <span id="timer-label" className="block text-sm font-semibold text-[#2C1810] mb-3">
          Chrono
        </span>
        <div className="grid grid-cols-4 gap-2" role="radiogroup" aria-labelledby="timer-label">
          {TIMER_OPTIONS.map((t) => (
            <button
              key={t.value}
              type="button"
              role="radio"
              aria-checked={timerSeconds === t.value}
              onClick={() => setTimerSeconds(t.value)}
              className={`flex flex-col items-center gap-1 py-2.5 px-1 rounded-xl border-2 transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#D4AF37] focus-visible:ring-offset-1 ${
                timerSeconds === t.value
                  ? 'border-[#D4AF37] bg-[#FAF6EE] shadow-sm'
                  : 'border-[#E8DCC8] bg-white hover:border-[#D4AF37]/50'
              }`}
            >
              <span className="text-xs font-bold text-[#2C1810] text-center leading-tight">{t.label}</span>
              <span className="text-[9px] text-[#8B7355] text-center leading-tight">{t.desc}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Erreur */}
      {error && (
        <p role="alert" className="text-red-600 text-sm bg-red-50 border border-red-200 rounded-lg px-3 py-2">
          {error}
        </p>
      )}

      {/* CTA */}
      <button
        type="button"
        onClick={handleStart}
        disabled={isPending}
        className="w-full bg-[#1B4332] hover:bg-[#155128] disabled:opacity-60 text-white font-bold py-4 rounded-xl transition-colors duration-200 text-lg shadow-lg focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#D4AF37] focus-visible:ring-offset-2"
      >
        {isPending ? 'Chargement...' : 'بسم الله — Commencer'}
      </button>
    </div>
  )
}
