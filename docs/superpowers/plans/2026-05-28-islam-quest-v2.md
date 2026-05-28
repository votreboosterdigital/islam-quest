# Islam Quest V2 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor Islam Quest V1 en V2 fiable, rapide, sans biais de réponses, avec timer optionnel et feedback immédiat.

**Architecture:** Découpler la logique métier (hooks `useQuizGame`, `useTimer`) des composants UI. Shuffle Fisher-Yates côté client sur les options. Timer optionnel configuré en URL param (`?timer=0|10|20|30`). Phase `expired` dédiée (no auto-select).

**Tech Stack:** Next.js 16 App Router, React 19, TypeScript strict, Supabase, Zod 4, Tailwind v4

---

## AUDIT RÉSUMÉ — PROBLÈMES CONFIRMÉS

| # | Problème | Root cause | Sévérité |
|---|---------|-----------|---------|
| 1 | 54% des bonnes réponses = option B | Options jamais shufflées (`sort((a,b) => a.ordre - b.ordre)` = ordre fixe) | CRITIQUE |
| 2 | Auto-sélection au timer expire | `handleAnswer(-1)` appelé dans `handleTimerExpire` | CRITIQUE |
| 3 | Timer hardcodé 30s, non optionnel | `seconds={30}` hardcodé dans QuizGame | HAUTE |
| 4 | Latence perçue correction | Attente réponse serveur avant phase switch, animation 400ms | HAUTE |
| 5 | Aucune accessibilité | Pas d'aria-label sur les boutons options | MOYENNE |
| 6 | 0 tests | Aucun fichier test | MOYENNE |
| 7 | Sources non différenciées | Format dalil ne distingue pas verset vs hadith | BASSE |

---

## FILE MAP

```
types/
  quiz.ts                          MODIFY — extend TimerMode, Source, Phase
lib/quiz/
  shuffle.ts                       CREATE — Fisher-Yates, shuffleOptions
  validators.ts                    CREATE — detectAnswerInQuestion, analyzeDistribution
  actions.ts                       MODIFY — handle skip (-1), optimize queries
  queries.ts                       MODIFY — add getSessionAnswersDetail
hooks/
  useTimer.ts                      CREATE — timer logic decoupled
  useQuizGame.ts                   CREATE — quiz orchestration logic
components/
  Timer.tsx                        MODIFY — use useTimer, aria-live, cleaner props
  NiveauSelector.tsx               MODIFY — add timer mode selector
  QuizCard.tsx                     MODIFY — pending/correct/incorrect states, aria, shuffle
  DalilCard.tsx                    MODIFY — expired state, source type badge
  QuizGame.tsx                     MODIFY — use useQuizGame hook, handle expired phase
app/quiz/[sessionId]/
  page.tsx                         MODIFY — read searchParams.timer, pass config
app/resultats/[sessionId]/
  page.tsx                         MODIFY — non-répondues, temps moyen, refaire erreurs
scripts/
  validate-questions.ts            CREATE — content QA CLI
__tests__/
  shuffle.test.ts                  CREATE
  validators.test.ts               CREATE
  useTimer.test.ts                 CREATE
supabase/migrations/
  20260528_session_answers_v2.sql  CREATE — add time_spent_ms, skipped columns
```

---

## Task 1: Types V2 + Zod schemas

**Files:**
- Modify: `types/quiz.ts`
- Create: `lib/quiz/schemas.ts`

- [ ] **Step 1: Update types/quiz.ts**

```typescript
export type Niveau = 'facile' | 'moyen' | 'difficile'
export type Categorie = 'piliers' | 'coran' | 'hadith' | 'histoire' | 'jurisprudence' | 'prophetes' | 'foi' | 'tous'
export type Phase = 'question' | 'dalil' | 'expired'
export type SourceType = 'quran' | 'hadith' | 'sunnah' | 'scholar' | 'other'

export interface TimerConfig {
  enabled: boolean
  seconds: number // 0 = disabled
}

export interface OptionClient {
  id: string
  texte: string
  ordre: number
}

export interface Source {
  type: SourceType
  reference: string
  citationShort?: string
  relevance: 'primary' | 'secondary'
}

export interface Dalil {
  id: string
  explication: string
  texte_arabe: string
  traduction: string
  reference: string
  source_type?: SourceType // derived from reference field
}

export interface QuestionClient {
  id: string
  texte: string
  niveau: Niveau
  categorie: Categorie
  options: OptionClient[]
}

export interface QuestionWithDalil extends QuestionClient {
  dalil: Dalil
  correctOrdre: number // sent after answer, enables client feedback
}

export interface StartGameResult {
  sessionId: string
  questions: QuestionClient[]
}

export interface SubmitAnswerResult {
  correct: boolean
  skipped: boolean
  question: QuestionWithDalil
}

export interface EndGameResult {
  score: number
  correctes: number
  incorrectes: number
  sautees: number
  total: number
  rang?: number
  tempsTotal?: number // ms
}

export interface QuizConfig {
  timer: TimerConfig
}
```

- [ ] **Step 2: Create lib/quiz/schemas.ts**

```typescript
import { z } from 'zod'

export const startGameSchema = z.object({
  niveau: z.enum(['facile', 'moyen', 'difficile']),
  categorie: z.enum(['piliers','coran','hadith','histoire','jurisprudence','prophetes','foi','tous']),
  pseudo: z.string().min(1).max(30),
})

export const submitAnswerSchema = z.object({
  sessionId: z.string().uuid(),
  questionId: z.string().uuid(),
  answerIndex: z.number().int().min(-1).max(3),
})

export const timerConfigSchema = z.object({
  enabled: z.boolean(),
  seconds: z.number().int().min(0).max(120),
})
```

- [ ] **Step 3: Commit**
```bash
git add types/quiz.ts lib/quiz/schemas.ts
git commit -m "feat: types V2 — TimerConfig, Phase, SourceType, SubmitAnswerResult enrichi"
```

---

## Task 2: Fisher-Yates shuffle + tests

**Files:**
- Create: `lib/quiz/shuffle.ts`
- Create: `__tests__/shuffle.test.ts`

- [ ] **Step 1: Write test (failing)**

```typescript
// __tests__/shuffle.test.ts
import { fisherYates, shuffleOptions } from '../lib/quiz/shuffle'

describe('fisherYates', () => {
  it('retourne un tableau de même longueur', () => {
    const arr = [1, 2, 3, 4]
    expect(fisherYates([...arr])).toHaveLength(4)
  })

  it('contient les mêmes éléments', () => {
    const arr = [1, 2, 3, 4]
    expect(fisherYates([...arr]).sort()).toEqual([1, 2, 3, 4])
  })

  it('ne mute pas le tableau source', () => {
    const arr = [1, 2, 3, 4]
    const copy = [...arr]
    fisherYates(arr)
    expect(arr).toEqual(copy)
  })

  it('ne retourne pas toujours le même ordre (sur 10 runs)', () => {
    const arr = [1, 2, 3, 4]
    const results = new Set(Array.from({ length: 10 }, () => fisherYates([...arr]).join(',')))
    expect(results.size).toBeGreaterThan(1)
  })
})

describe('shuffleOptions', () => {
  it('préserve les ordres originaux des options', () => {
    const options = [
      { id: 'a', texte: 'Option A', ordre: 0 },
      { id: 'b', texte: 'Option B', ordre: 1 },
      { id: 'c', texte: 'Option C', ordre: 2 },
      { id: 'd', texte: 'Option D', ordre: 3 },
    ]
    const shuffled = shuffleOptions(options)
    const ordres = shuffled.map(o => o.ordre).sort()
    expect(ordres).toEqual([0, 1, 2, 3])
  })

  it('préserve les ids', () => {
    const options = [
      { id: 'uuid-a', texte: 'A', ordre: 0 },
      { id: 'uuid-b', texte: 'B', ordre: 1 },
    ]
    const shuffled = shuffleOptions(options)
    const ids = shuffled.map(o => o.id).sort()
    expect(ids).toEqual(['uuid-a', 'uuid-b'])
  })
})
```

- [ ] **Step 2: Créer lib/quiz/shuffle.ts**

```typescript
import type { OptionClient } from '@/types/quiz'

// Fisher-Yates shuffle — ne mute pas le tableau source
export function fisherYates<T>(array: T[]): T[] {
  const arr = [...array]
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[arr[i], arr[j]] = [arr[j], arr[i]]
  }
  return arr
}

// Shuffle les options d'affichage sans altérer les ordres/ids d'origine
export function shuffleOptions(options: OptionClient[]): OptionClient[] {
  return fisherYates([...options])
}
```

- [ ] **Step 3: Vérifier tests (si Jest configuré)**

```bash
cd C:/Users/Admin/islam-quest && npx jest --testPathPattern="shuffle" 2>&1 | tail -20
```

- [ ] **Step 4: Commit**
```bash
git add lib/quiz/shuffle.ts __tests__/shuffle.test.ts
git commit -m "feat: Fisher-Yates shuffle — corrige biais distribution réponses correctes"
```

---

## Task 3: Content QA validators

**Files:**
- Create: `lib/quiz/validators.ts`
- Create: `scripts/validate-questions.ts`

- [ ] **Step 1: Créer lib/quiz/validators.ts**

```typescript
import type { OptionClient, SourceType } from '@/types/quiz'

export interface DistributionReport {
  total: number
  byPosition: Record<number, number>
  byPositionPct: Record<number, string>
  biased: boolean // true si une position > 40%
}

export interface ContentIssue {
  questionId: string
  questionTexte: string
  type: 'answer-in-question' | 'similar-options' | 'short-correct-option'
  detail: string
}

// Détecte si une des options (notamment la bonne) est contenue dans l'énoncé
export function detectAnswerInQuestion(
  questionTexte: string,
  options: OptionClient[],
  correctOrdre: number
): boolean {
  const q = questionTexte.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')
  return options
    .filter(o => o.ordre === correctOrdre)
    .some(o => {
      const opt = o.texte.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')
      return q.includes(opt) && opt.length > 3
    })
}

// Analyse la distribution des positions des bonnes réponses
export function analyzeDistribution(
  correctOrdres: number[],
  totalOptions = 4
): DistributionReport {
  const byPosition: Record<number, number> = {}
  for (let i = 0; i < totalOptions; i++) byPosition[i] = 0
  for (const ordre of correctOrdres) {
    byPosition[ordre] = (byPosition[ordre] ?? 0) + 1
  }
  const total = correctOrdres.length
  const byPositionPct: Record<number, string> = {}
  for (const k of Object.keys(byPosition)) {
    byPositionPct[Number(k)] = total ? ((byPosition[Number(k)] / total) * 100).toFixed(1) + '%' : '0%'
  }
  const biased = Object.values(byPosition).some(v => v / total > 0.4)
  return { total, byPosition, byPositionPct, biased }
}

// Dérive le type de source depuis la référence textuelle
export function deriveSourceType(reference: string): SourceType {
  const ref = reference.toLowerCase()
  if (ref.includes('sourate') || ref.includes('verset') || ref.includes('coran') || ref.includes('quran') || /s\.\d/.test(ref)) return 'quran'
  if (ref.includes('bukhari') || ref.includes('muslim') || ref.includes('tirmidhi') || ref.includes('hadith') || ref.includes('abu dawud') || ref.includes('nasai') || ref.includes('ibn majah') || ref.includes('musnad')) return 'hadith'
  if (ref.includes('sunnah')) return 'sunnah'
  return 'other'
}
```

- [ ] **Step 2: Créer scripts/validate-questions.ts**

```typescript
// npx ts-node scripts/validate-questions.ts
import { createClient } from '@supabase/supabase-js'
import { analyzeDistribution, detectAnswerInQuestion, deriveSourceType } from '../lib/quiz/validators'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

async function main() {
  console.log('🔍 Analyse Islam Quest — Content QA\n')

  const { data: questions } = await supabase
    .from('questions')
    .select('id, texte, options(id, texte, ordre, est_correct), dalils(reference)')

  if (!questions?.length) { console.error('Aucune question'); process.exit(1) }

  const correctOrdres: number[] = []
  const issues: string[] = []

  for (const q of questions) {
    const correct = (q.options as { id: string; texte: string; ordre: number; est_correct: boolean }[])
      .find(o => o.est_correct)
    if (!correct) continue
    correctOrdres.push(correct.ordre)

    if (detectAnswerInQuestion(q.texte, q.options as { id: string; texte: string; ordre: number }[], correct.ordre)) {
      issues.push(`⚠️  Réponse dans la question — ID:${q.id.slice(0,8)} — "${q.texte.slice(0,60)}"`)
    }
  }

  console.log('📊 Distribution des bonnes réponses:')
  const dist = analyzeDistribution(correctOrdres)
  const LABELS = ['A', 'B', 'C', 'D']
  for (const [pos, count] of Object.entries(dist.byPosition)) {
    const bar = '█'.repeat(Math.round(count / dist.total * 20))
    console.log(`  ${LABELS[Number(pos)]}: ${dist.byPositionPct[Number(pos)].padStart(6)} ${bar} (${count})`)
  }
  if (dist.biased) console.log('\n  ❌ BIAIS DÉTECTÉ — une position dépasse 40%')
  else console.log('\n  ✅ Distribution équilibrée')

  if (issues.length > 0) {
    console.log(`\n⚠️  ${issues.length} questions avec réponse dans l'énoncé:`)
    issues.forEach(i => console.log(' ' + i))
  } else {
    console.log('\n✅ Aucune réponse trouvée dans les énoncés')
  }

  console.log(`\n📝 Total analysé: ${questions.length} questions`)
}

main().catch(console.error)
```

- [ ] **Step 3: Commit**
```bash
git add lib/quiz/validators.ts scripts/validate-questions.ts
git commit -m "feat: content QA — validators distribution + détection réponse dans énoncé"
```

---

## Task 4: Hook useTimer

**Files:**
- Create: `hooks/useTimer.ts`

- [ ] **Step 1: Créer hooks/useTimer.ts**

```typescript
import { useEffect, useState, useCallback, useRef } from 'react'

interface UseTimerProps {
  duration: number  // secondes
  enabled: boolean
  onExpire?: () => void
  autoStart?: boolean
}

interface UseTimerReturn {
  remaining: number
  pct: number       // 0-100
  isUrgent: boolean // <= 10s
  isRunning: boolean
  isExpired: boolean
  start: () => void
  pause: () => void
  reset: () => void
}

export function useTimer({ duration, enabled, onExpire, autoStart = true }: UseTimerProps): UseTimerReturn {
  const [remaining, setRemaining] = useState(duration)
  const [isRunning, setIsRunning] = useState(autoStart && enabled)
  const onExpireRef = useRef(onExpire)
  onExpireRef.current = onExpire

  useEffect(() => {
    setRemaining(duration)
    setIsRunning(autoStart && enabled)
  }, [duration, enabled, autoStart])

  useEffect(() => {
    if (!enabled || !isRunning) return
    if (remaining <= 0) {
      setIsRunning(false)
      onExpireRef.current?.()
      return
    }
    const id = setTimeout(() => setRemaining(r => r - 1), 1000)
    return () => clearTimeout(id)
  }, [remaining, isRunning, enabled])

  const start = useCallback(() => { if (enabled) setIsRunning(true) }, [enabled])
  const pause = useCallback(() => setIsRunning(false), [])
  const reset = useCallback(() => {
    setRemaining(duration)
    setIsRunning(autoStart && enabled)
  }, [duration, autoStart, enabled])

  return {
    remaining,
    pct: duration > 0 ? (remaining / duration) * 100 : 0,
    isUrgent: remaining <= 10 && remaining > 0,
    isRunning,
    isExpired: remaining <= 0,
    start,
    pause,
    reset,
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add hooks/useTimer.ts
git commit -m "feat: hook useTimer découplé — pause/resume/reset, enabled flag"
```

---

## Task 5: Timer component V2

**Files:**
- Modify: `components/Timer.tsx`

- [ ] **Step 1: Réécrire components/Timer.tsx**

```typescript
'use client'

import { useTimer } from '@/hooks/useTimer'

interface TimerProps {
  duration: number
  onExpire: () => void
  running: boolean
}

export default function Timer({ duration, onExpire, running }: TimerProps) {
  const { remaining, pct, isUrgent } = useTimer({
    duration,
    enabled: running,
    onExpire,
    autoStart: true,
  })

  const strokeColor = isUrgent ? '#ef4444' : '#D4AF37'
  const circumference = 100 // approximation pour SVG simplifié

  return (
    <div
      role="timer"
      aria-label={`Temps restant : ${remaining} secondes`}
      aria-live="off"
      className="flex items-center gap-2"
    >
      <div className="relative w-10 h-10">
        <svg className="w-10 h-10 -rotate-90" viewBox="0 0 36 36" aria-hidden="true">
          <circle cx="18" cy="18" r="15.9" fill="none" stroke="#E8DCC8" strokeWidth="3" />
          <circle
            cx="18" cy="18" r="15.9" fill="none"
            stroke={strokeColor}
            strokeWidth="3"
            strokeDasharray={`${pct} 100`}
            className="transition-all duration-1000"
          />
        </svg>
        <span className={`absolute inset-0 flex items-center justify-center text-xs font-bold select-none ${isUrgent ? 'text-red-500' : 'text-[#8B7355]'}`}>
          {remaining}
        </span>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: Commit**
```bash
git add components/Timer.tsx
git commit -m "refactor: Timer V2 — useTimer hook, aria-live, props renommées"
```

---

## Task 6: NiveauSelector V2 — mode timer

**Files:**
- Modify: `components/NiveauSelector.tsx`

- [ ] **Step 1: Réécrire NiveauSelector.tsx avec timer mode**

```typescript
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
  { value: 0, label: 'Sans chrono', desc: 'Prenez votre temps' },
  { value: 20, label: '20 sec', desc: 'Rythme modéré' },
  { value: 30, label: '30 sec', desc: 'Recommandé' },
  { value: 45, label: '45 sec', desc: 'Détendu' },
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
    if (!pseudo.trim()) { setError('Entre ton prénom pour commencer.'); return }
    setError(null)
    startTransition(async () => {
      try {
        const { sessionId } = await startGame(niveau, categorie, pseudo.trim())
        const timerParam = timerSeconds > 0 ? `?timer=${timerSeconds}` : '?timer=0'
        router.push(`/quiz/${sessionId}${timerParam}`)
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Erreur de démarrage.')
      }
    })
  }

  return (
    <div className="w-full max-w-md mx-auto space-y-6">
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

      <div>
        <span className="block text-sm font-semibold text-[#2C1810] mb-3" id="niveau-label">
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
              className={`flex flex-col items-center gap-1 py-3 px-2 rounded-xl border-2 transition-all ${
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

      <div>
        <span className="block text-sm font-semibold text-[#2C1810] mb-3" id="timer-label">
          Mode chrono
        </span>
        <div className="grid grid-cols-4 gap-2" role="radiogroup" aria-labelledby="timer-label">
          {TIMER_OPTIONS.map((t) => (
            <button
              key={t.value}
              type="button"
              role="radio"
              aria-checked={timerSeconds === t.value}
              onClick={() => setTimerSeconds(t.value)}
              className={`flex flex-col items-center gap-1 py-2.5 px-1 rounded-xl border-2 transition-all ${
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

      {error && (
        <p role="alert" className="text-red-600 text-sm bg-red-50 border border-red-200 rounded-lg px-3 py-2">
          {error}
        </p>
      )}

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
```

- [ ] **Step 2: Commit**
```bash
git add components/NiveauSelector.tsx
git commit -m "feat: NiveauSelector V2 — sélecteur mode chrono, aria, labels accessibles"
```

---

## Task 7: Server action V2 — fix skip + optimize

**Files:**
- Modify: `lib/quiz/actions.ts`

- [ ] **Step 1: Mettre à jour submitAnswer pour gérer skip (-1)**

Changements clés dans `submitAnswer`:
- `answerIndex === -1` → `skipped = true`, `isCorrect = false`
- Retourner `correctOrdre` dans la réponse (pour affichage côté client)
- Combiner la mise à jour du score dans la même requête

```typescript
'use server'

import { createServiceClient } from './supabase'
import { startGameSchema, submitAnswerSchema } from './schemas'
import type { StartGameResult, SubmitAnswerResult, EndGameResult } from '@/types/quiz'
import { deriveSourceType } from './validators'

export async function startGame(
  niveau: string,
  categorie: string,
  pseudo: string
): Promise<StartGameResult> {
  const parsed = startGameSchema.parse({ niveau, categorie, pseudo })
  const supabase = createServiceClient()

  let query = supabase
    .from('questions')
    .select('id, texte, niveau, categorie, options(id, texte, ordre)')

  if (parsed.categorie !== 'tous') query = query.eq('categorie', parsed.categorie)
  if (parsed.niveau !== ('tous' as unknown as 'facile' | 'moyen' | 'difficile')) {
    query = query.eq('niveau', parsed.niveau)
  }

  const { data: allQuestions, error: qError } = await query
  if (qError || !allQuestions?.length) {
    throw new Error('Aucune question trouvée pour ce niveau/catégorie.')
  }

  // Shuffle questions (serveur) — les options sont shufflées côté client
  const arr = [...allQuestions]
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[arr[i], arr[j]] = [arr[j], arr[i]]
  }
  const shuffled = arr.slice(0, 10)

  const { data: session, error: sError } = await supabase
    .from('sessions')
    .insert({ pseudo: parsed.pseudo, niveau: parsed.niveau, categorie: parsed.categorie })
    .select('id')
    .single()

  if (sError || !session) throw new Error('Erreur création session.')

  const sessionAnswers = shuffled.map((q, i) => ({
    session_id: session.id,
    question_id: q.id,
    ordre: i,
  }))

  const { error: saError } = await supabase.from('session_answers').insert(sessionAnswers)
  if (saError) throw new Error('Erreur insertion questions session.')

  return {
    sessionId: session.id,
    questions: shuffled.map((q) => ({
      id: q.id,
      texte: q.texte,
      niveau: q.niveau as StartGameResult['questions'][number]['niveau'],
      categorie: q.categorie as StartGameResult['questions'][number]['categorie'],
      options: (q.options as { id: string; texte: string; ordre: number }[])
        .sort((a, b) => a.ordre - b.ordre),
    })),
  }
}

export async function submitAnswer(
  sessionId: string,
  questionId: string,
  answerIndex: number
): Promise<SubmitAnswerResult> {
  submitAnswerSchema.parse({ sessionId, questionId, answerIndex })
  const supabase = createServiceClient()
  const skipped = answerIndex === -1

  const { data: options, error: oError } = await supabase
    .from('options')
    .select('id, texte, ordre, est_correct')
    .eq('question_id', questionId)
    .order('ordre')

  if (oError || !options) throw new Error('Options introuvables.')

  const correctOption = options.find((o) => o.est_correct)
  const isCorrect = !skipped && correctOption?.ordre === answerIndex

  // Update session_answer + score en parallèle
  await Promise.all([
    supabase
      .from('session_answers')
      .update({
        reponse_index: skipped ? null : answerIndex,
        est_correct: isCorrect,
        answered_at: new Date().toISOString(),
      })
      .eq('session_id', sessionId)
      .eq('question_id', questionId),

    isCorrect
      ? supabase.rpc('increment_score', { session_id_param: sessionId, points: 10 })
      : Promise.resolve(),
  ])

  const [{ data: dalilData }, { data: questionData }] = await Promise.all([
    supabase
      .from('dalils')
      .select('id, explication, texte_arabe, traduction, reference')
      .eq('question_id', questionId)
      .single(),
    supabase
      .from('questions')
      .select('id, texte, niveau, categorie')
      .eq('id', questionId)
      .single(),
  ])

  if (!questionData || !dalilData) throw new Error('Données question introuvables.')

  return {
    correct: isCorrect,
    skipped,
    question: {
      id: questionData.id,
      texte: questionData.texte,
      niveau: questionData.niveau as SubmitAnswerResult['question']['niveau'],
      categorie: questionData.categorie as SubmitAnswerResult['question']['categorie'],
      options: options.map((o) => ({ id: o.id, texte: o.texte, ordre: o.ordre })),
      correctOrdre: correctOption?.ordre ?? 0,
      dalil: {
        ...dalilData,
        source_type: deriveSourceType(dalilData.reference),
      },
    },
  }
}

export async function endGame(sessionId: string): Promise<EndGameResult> {
  const supabase = createServiceClient()

  await supabase
    .from('sessions')
    .update({ ended_at: new Date().toISOString() })
    .eq('id', sessionId)

  const [{ data: session }, { data: answers }] = await Promise.all([
    supabase.from('sessions').select('score').eq('id', sessionId).single(),
    supabase.from('session_answers').select('est_correct, reponse_index').eq('session_id', sessionId),
  ])

  const total = answers?.length ?? 0
  const correctes = answers?.filter((a) => a.est_correct).length ?? 0
  const sautees = answers?.filter((a) => a.reponse_index === null).length ?? 0
  const incorrectes = total - correctes - sautees
  const score = session?.score ?? 0

  const [{ count: below }, { count: totalSessions }] = await Promise.all([
    supabase
      .from('sessions')
      .select('*', { count: 'exact', head: true })
      .not('ended_at', 'is', null)
      .neq('id', sessionId)
      .lte('score', score),
    supabase
      .from('sessions')
      .select('*', { count: 'exact', head: true })
      .not('ended_at', 'is', null),
  ])

  const rang = totalSessions ? Math.round(((below ?? 0) / totalSessions) * 100) : undefined

  return { score, correctes, incorrectes, sautees, total, rang }
}
```

Note: `increment_score` est une fonction Supabase RPC. Si elle n'existe pas, fallback sur update direct (voir migration task).

- [ ] **Step 2: Commit**
```bash
git add lib/quiz/actions.ts lib/quiz/schemas.ts
git commit -m "fix: submitAnswer — gère skip (-1), parallélise queries, retourne correctOrdre"
```

---

## Task 8: Hook useQuizGame + QuizGame V2

**Files:**
- Create: `hooks/useQuizGame.ts`
- Modify: `components/QuizGame.tsx`

- [ ] **Step 1: Créer hooks/useQuizGame.ts**

```typescript
import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { submitAnswer, endGame } from '@/lib/quiz/actions'
import { shuffleOptions } from '@/lib/quiz/shuffle'
import type { QuestionClient, QuestionWithDalil, SubmitAnswerResult, Phase, TimerConfig } from '@/types/quiz'

interface UseQuizGameProps {
  sessionId: string
  questions: QuestionClient[]
  timerConfig: TimerConfig
}

interface UseQuizGameReturn {
  currentIndex: number
  phase: Phase
  currentQuestion: QuestionClient & { shuffledOptions: ReturnType<typeof shuffleOptions> }
  selectedIndex: number | null
  result: SubmitAnswerResult | null
  loading: boolean
  score: number
  timerConfig: TimerConfig
  isLast: boolean
  handleAnswer: (answerIndex: number) => Promise<void>
  handleExpired: () => void
  handleNext: () => Promise<void>
}

export function useQuizGame({ sessionId, questions, timerConfig }: UseQuizGameProps): UseQuizGameReturn {
  const router = useRouter()
  const [currentIndex, setCurrentIndex] = useState(0)
  const [phase, setPhase] = useState<Phase>('question')
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null)
  const [result, setResult] = useState<SubmitAnswerResult | null>(null)
  const [loading, setLoading] = useState(false)
  const [score, setScore] = useState(0)

  // Shuffle options une fois par question (mémorisé via currentIndex)
  const [shuffledOptionsMap] = useState<Map<string, ReturnType<typeof shuffleOptions>>>(() => {
    const map = new Map<string, ReturnType<typeof shuffleOptions>>()
    for (const q of questions) {
      map.set(q.id, shuffleOptions(q.options))
    }
    return map
  })

  const currentQuestion = questions[currentIndex]
  const isLast = currentIndex === questions.length - 1

  const handleAnswer = useCallback(async (answerIndex: number) => {
    if (loading || phase !== 'question') return
    setSelectedIndex(answerIndex)
    setLoading(true)
    try {
      const res = await submitAnswer(sessionId, currentQuestion.id, answerIndex)
      setResult(res)
      if (res.correct) setScore((s) => s + 10)
      setPhase('dalil')
    } catch {
      // Ne pas crasher sur erreur réseau — laisser l'utilisateur continuer
      setPhase('dalil')
    } finally {
      setLoading(false)
    }
  }, [loading, phase, sessionId, currentQuestion?.id])

  const handleExpired = useCallback(() => {
    if (phase !== 'question' || loading) return
    // Soumettre comme "sauté" (-1) et passer à la phase expired
    submitAnswer(sessionId, currentQuestion.id, -1)
      .then(res => {
        setResult(res)
        setPhase('expired')
      })
      .catch(() => setPhase('expired'))
  }, [phase, loading, sessionId, currentQuestion?.id])

  const handleNext = useCallback(async () => {
    if (isLast) {
      await endGame(sessionId)
      router.push(`/resultats/${sessionId}`)
      return
    }
    setCurrentIndex((i) => i + 1)
    setPhase('question')
    setSelectedIndex(null)
    setResult(null)
  }, [isLast, sessionId, router])

  return {
    currentIndex,
    phase,
    currentQuestion: currentQuestion
      ? { ...currentQuestion, shuffledOptions: shuffledOptionsMap.get(currentQuestion.id) ?? currentQuestion.options }
      : null as unknown as UseQuizGameReturn['currentQuestion'],
    selectedIndex,
    result,
    loading,
    score,
    timerConfig,
    isLast,
    handleAnswer,
    handleExpired,
    handleNext,
  }
}
```

- [ ] **Step 2: Réécrire components/QuizGame.tsx**

```typescript
'use client'

import { useQuizGame } from '@/hooks/useQuizGame'
import QuizCard from './QuizCard'
import DalilCard from './DalilCard'
import ProgressBar from './ProgressBar'
import Timer from './Timer'
import type { QuestionClient, TimerConfig } from '@/types/quiz'

interface QuizGameProps {
  sessionId: string
  questions: QuestionClient[]
  timerConfig: TimerConfig
}

export default function QuizGame({ sessionId, questions, timerConfig }: QuizGameProps) {
  const {
    currentIndex,
    phase,
    currentQuestion,
    selectedIndex,
    result,
    loading,
    score,
    isLast,
    handleAnswer,
    handleExpired,
    handleNext,
  } = useQuizGame({ sessionId, questions, timerConfig })

  if (!currentQuestion) return null

  return (
    <div className="min-h-screen bg-[#F5F0E8] px-4 py-6 flex flex-col items-center">
      {/* Header: progression + timer + score */}
      <div className="w-full max-w-2xl mb-6 flex items-center gap-4">
        <div className="flex-1">
          <ProgressBar current={currentIndex + 1} total={questions.length} />
        </div>
        {phase === 'question' && timerConfig.enabled && (
          <Timer
            key={`${currentIndex}-timer`}
            duration={timerConfig.seconds}
            onExpire={handleExpired}
            running={phase === 'question' && !loading}
          />
        )}
        <span className="text-sm font-semibold text-[#1B4332] bg-white border border-[#D4AF37]/40 px-3 py-1 rounded-full whitespace-nowrap">
          {score} pts
        </span>
      </div>

      {/* Corps du quiz */}
      <div className="w-full max-w-2xl flex-1">
        {phase === 'question' ? (
          <QuizCard
            key={currentQuestion.id}
            texte={currentQuestion.texte}
            options={currentQuestion.shuffledOptions}
            onAnswer={handleAnswer}
            disabled={loading || phase !== 'question'}
            selectedIndex={selectedIndex}
            loading={loading}
          />
        ) : result ? (
          <DalilCard
            dalil={result.question.dalil}
            correct={result.correct}
            skipped={result.skipped || phase === 'expired'}
            correctOrdre={result.question.correctOrdre}
            options={currentQuestion.shuffledOptions}
            onNext={handleNext}
            isLast={isLast}
          />
        ) : null}
      </div>
    </div>
  )
}
```

- [ ] **Step 3: Commit**
```bash
git add hooks/useQuizGame.ts components/QuizGame.tsx
git commit -m "refactor: QuizGame V2 — hook useQuizGame, phase expired, shuffle options"
```

---

## Task 9: QuizCard V2 — feedback immédiat + a11y

**Files:**
- Modify: `components/QuizCard.tsx`

- [ ] **Step 1: Réécrire components/QuizCard.tsx**

```typescript
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

export default function QuizCard({ texte, options, onAnswer, disabled, selectedIndex, loading }: QuizCardProps) {
  return (
    <div className="w-full max-w-2xl mx-auto" role="main" aria-label="Question en cours">
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
                disabled && !isSelected ? 'opacity-50 cursor-not-allowed' : '',
                !disabled ? 'cursor-pointer hover:border-[#D4AF37] hover:bg-[#FAF6EE] hover:shadow-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#D4AF37] focus-visible:ring-offset-1' : '',
                isSelected && !loading ? 'border-[#D4AF37] bg-[#FAF6EE] shadow-md' : '',
                isPending ? 'border-[#D4AF37] bg-[#FAF6EE] shadow-md animate-pulse' : '',
                !isSelected && !disabled ? 'border-[#E8DCC8] bg-white' : '',
                !isSelected && disabled ? 'border-[#E8DCC8] bg-white/60' : '',
              ].join(' ')}
            >
              <span className={[
                'w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold flex-shrink-0',
                isSelected ? 'bg-[#D4AF37] text-white' : 'bg-[#E8DCC8] text-[#8B7355]',
              ].join(' ')} aria-hidden="true">
                {LETTERS[displayIdx]}
              </span>
              <span className="text-[#2C1810]">{option.texte}</span>
              {isPending && (
                <span className="ml-auto w-4 h-4 rounded-full border-2 border-[#D4AF37] border-t-transparent animate-spin" aria-hidden="true" />
              )}
            </button>
          )
        })}
      </div>
    </div>
  )
}
```

- [ ] **Step 2: Commit**
```bash
git add components/QuizCard.tsx
git commit -m "feat: QuizCard V2 — aria-label, pending spinner, disable partiel, focus-visible"
```

---

## Task 10: DalilCard V2 — expired state + source badge

**Files:**
- Modify: `components/DalilCard.tsx`

- [ ] **Step 1: Réécrire components/DalilCard.tsx**

```typescript
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
const SOURCE_LABELS: Record<string, { label: string; color: string }> = {
  quran: { label: 'Coran', color: 'bg-emerald-100 text-emerald-800 border-emerald-300' },
  hadith: { label: 'Hadith', color: 'bg-amber-100 text-amber-800 border-amber-300' },
  sunnah: { label: 'Sunnah', color: 'bg-amber-100 text-amber-800 border-amber-300' },
  other: { label: 'Référence', color: 'bg-slate-100 text-slate-700 border-slate-300' },
}

export default function DalilCard({ dalil, correct, skipped, correctOrdre, options, onNext, isLast }: DalilCardProps) {
  const sourceInfo = SOURCE_LABELS[dalil.source_type ?? 'other'] ?? SOURCE_LABELS.other
  const correctOption = options.find(o => o.ordre === correctOrdre)
  const correctDisplayIdx = options.findIndex(o => o.ordre === correctOrdre)

  const statusConfig = skipped
    ? { bg: 'bg-slate-100 text-slate-700 border-slate-300', icon: '⏱', text: 'Temps écoulé' }
    : correct
    ? { bg: 'bg-emerald-100 text-emerald-800 border-emerald-300', icon: '✓', text: 'Bonne réponse !' }
    : { bg: 'bg-red-100 text-red-800 border-red-300', icon: '✗', text: 'Mauvaise réponse' }

  return (
    <div className="w-full max-w-2xl mx-auto" role="region" aria-label="Correction">
      {/* Badge résultat */}
      <div className={`flex items-center gap-2 mb-4 px-4 py-2 rounded-full w-fit mx-auto font-semibold text-sm border ${statusConfig.bg}`}
        role="status" aria-live="polite">
        <span aria-hidden="true">{statusConfig.icon}</span>
        <span>{statusConfig.text}</span>
      </div>

      {/* Si incorrect ou sauté : afficher la bonne réponse */}
      {(!correct || skipped) && correctOption && (
        <div className="mb-4 px-4 py-3 rounded-xl bg-emerald-50 border border-emerald-200">
          <p className="text-xs font-semibold text-emerald-700 mb-1">Bonne réponse :</p>
          <p className="text-sm text-emerald-900 font-medium">
            <span className="font-bold">{LETTERS[correctDisplayIdx]}.</span> {correctOption.texte}
          </p>
        </div>
      )}

      {/* Carte dalil */}
      <div className="bg-[#1B4332] rounded-2xl overflow-hidden shadow-xl">
        {/* Explication */}
        <div className="bg-white/10 px-6 py-4">
          <p className="text-white/90 text-sm leading-relaxed">{dalil.explication}</p>
        </div>

        {/* Séparateur */}
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

        {/* Référence + type de source */}
        <div className="flex items-center justify-center gap-2 pb-4 flex-wrap px-4">
          <span className={`border text-xs font-semibold px-2 py-0.5 rounded-full ${sourceInfo.color}`}>
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
```

- [ ] **Step 2: Commit**
```bash
git add components/DalilCard.tsx
git commit -m "feat: DalilCard V2 — état expired, badge source Coran/Hadith, bonne réponse affichée"
```

---

## Task 11: Quiz page V2 — lire timer depuis URL

**Files:**
- Modify: `app/quiz/[sessionId]/page.tsx`

- [ ] **Step 1: Lire searchParams.timer et passer TimerConfig**

```typescript
import { notFound } from 'next/navigation'
import { getSessionQuestions } from '@/lib/quiz/queries'
import QuizGame from '@/components/QuizGame'
import type { TimerConfig } from '@/types/quiz'

export default async function QuizPage({
  params,
  searchParams,
}: {
  params: Promise<{ sessionId: string }>
  searchParams: Promise<{ timer?: string }>
}) {
  const [{ sessionId }, sp] = await Promise.all([params, searchParams])

  let questions
  try {
    questions = await getSessionQuestions(sessionId)
  } catch {
    return notFound()
  }

  if (!questions?.length) return notFound()

  const timerSecondsRaw = parseInt(sp.timer ?? '30', 10)
  const timerSeconds = [0, 10, 20, 30, 45].includes(timerSecondsRaw) ? timerSecondsRaw : 30
  const timerConfig: TimerConfig = {
    enabled: timerSeconds > 0,
    seconds: timerSeconds,
  }

  return <QuizGame sessionId={sessionId} questions={questions} timerConfig={timerConfig} />
}
```

- [ ] **Step 2: Commit**
```bash
git add app/quiz/[sessionId]/page.tsx
git commit -m "feat: quiz page — lit ?timer=N depuis URL, passe TimerConfig à QuizGame"
```

---

## Task 12: Résultats V2 — stats enrichies

**Files:**
- Modify: `app/resultats/[sessionId]/page.tsx`

- [ ] **Step 1: Enrichir la page résultats avec correctes/incorrectes/sautées**

Remplacer le contenu de la page résultats pour afficher les 3 compteurs + message motivant sobre.

```typescript
import { notFound } from 'next/navigation'
import Link from 'next/link'
import { getSessionResults } from '@/lib/quiz/queries'

export default async function ResultatsPage({
  params,
}: {
  params: Promise<{ sessionId: string }>
}) {
  const { sessionId } = await params

  let results
  try {
    results = await getSessionResults(sessionId)
  } catch (err) {
    console.error('[ResultatsPage] getSessionResults error:', err)
    return (
      <main className="min-h-screen bg-[#F5F0E8] flex items-center justify-center p-8">
        <div className="bg-white rounded-2xl p-8 max-w-md w-full border border-red-200 shadow text-center">
          <h2 className="text-xl font-bold text-red-700 mb-2">Erreur</h2>
          <p className="text-sm text-[#8B7355] mb-4">Impossible de charger les résultats.</p>
          <Link href="/" className="block bg-[#1B4332] text-white py-2 rounded-xl font-semibold">Accueil</Link>
        </div>
      </main>
    )
  }

  if (!results) notFound()

  const { score, correctes, incorrectes = 0, sautees = 0, total, rang } = results
  const pct = total ? Math.round((correctes / total) * 100) : 0

  const mention =
    pct >= 80 ? { ar: 'مَا شَاءَ اللَّه', fr: 'Excellent travail !' } :
    pct >= 60 ? { ar: 'بَارَكَ اللَّهُ فِيكَ', fr: 'Bien joué !' } :
    pct >= 40 ? { ar: 'إِنْ شَاءَ اللَّه', fr: 'Continue à progresser' } :
    { ar: 'جَزَاكَ اللَّهُ خَيْرًا', fr: 'Le savoir s'acquiert avec patience' }

  return (
    <main className="min-h-screen bg-[#F5F0E8] flex flex-col items-center justify-center px-4 py-12">
      <div className="w-full max-w-md" role="main" aria-label="Résultats du quiz">
        {/* Message arabe + mention */}
        <div className="text-center mb-8">
          <p className="font-amiri text-5xl text-[#1B4332] mb-2 leading-loose" dir="rtl" lang="ar" aria-hidden="true">
            {mention.ar}
          </p>
          <p className="text-lg font-bold text-[#2C1810]">{mention.fr}</p>
        </div>

        {/* Score principal */}
        <div className="bg-[#1B4332] rounded-2xl p-6 text-center text-white mb-6 shadow-xl">
          <p className="text-[#D4AF37] text-sm font-semibold mb-1">Score final</p>
          <p className="text-6xl font-bold mb-1" aria-label={`${score} points`}>{score}</p>
          <p className="text-white/70 text-sm">points</p>
        </div>

        {/* Stats détaillées */}
        <div className="grid grid-cols-3 gap-3 mb-6">
          <div className="bg-white rounded-xl p-3 text-center border border-emerald-200 shadow-sm">
            <p className="text-2xl font-bold text-emerald-600">{correctes}</p>
            <p className="text-[10px] text-[#8B7355] mt-1 leading-tight">Correctes</p>
          </div>
          <div className="bg-white rounded-xl p-3 text-center border border-red-200 shadow-sm">
            <p className="text-2xl font-bold text-red-500">{incorrectes}</p>
            <p className="text-[10px] text-[#8B7355] mt-1 leading-tight">Incorrectes</p>
          </div>
          <div className="bg-white rounded-xl p-3 text-center border border-slate-200 shadow-sm">
            <p className="text-2xl font-bold text-slate-500">{sautees}</p>
            <p className="text-[10px] text-[#8B7355] mt-1 leading-tight">Sautées</p>
          </div>
        </div>

        {/* Taux de réussite */}
        <div className="bg-white rounded-xl p-4 text-center border border-[#E8DCC8] shadow-sm mb-4">
          <p className="text-3xl font-bold text-[#D4AF37]">{pct}%</p>
          <p className="text-xs text-[#8B7355] mt-1">Taux de réussite</p>
        </div>

        {/* Classement */}
        {rang !== undefined && (
          <div className="bg-[#FAF6EE] border border-[#D4AF37]/30 rounded-xl p-4 text-center mb-6">
            <p className="text-[#8B7355] text-xs mb-1">Classement</p>
            <p className="text-xl font-bold text-[#1B4332]">
              Meilleur que {rang}% des joueurs
            </p>
          </div>
        )}

        {/* Actions */}
        <div className="space-y-3">
          <Link
            href="/"
            className="block w-full bg-[#1B4332] hover:bg-[#155128] text-white font-bold py-3 rounded-xl text-center transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#D4AF37] focus-visible:ring-offset-2"
          >
            Rejouer
          </Link>
          <Link
            href="/"
            className="block w-full bg-white border-2 border-[#E8DCC8] hover:border-[#D4AF37] text-[#2C1810] font-semibold py-3 rounded-xl text-center transition-colors"
          >
            Changer de niveau
          </Link>
        </div>
      </div>
    </main>
  )
}
```

- [ ] **Step 2: Mettre à jour queries.ts — getSessionResults retourne incorrectes + sautees**

Dans `lib/quiz/queries.ts`, s'assurer que `getSessionResults` retourne le type `EndGameResult` enrichi avec `incorrectes` et `sautees`.

- [ ] **Step 3: Commit**
```bash
git add app/resultats/[sessionId]/page.tsx lib/quiz/queries.ts
git commit -m "feat: résultats V2 — correctes/incorrectes/sautées, mentions arabes, classement"
```

---

## Task 13: Migration DB + RPC score

**Files:**
- Create: `supabase/migrations/20260528_v2_fixes.sql`

- [ ] **Step 1: Créer la migration**

```sql
-- Migration V2: session_answers nullable + RPC increment_score

-- Permettre reponse_index NULL pour les questions sautées
ALTER TABLE session_answers
  ALTER COLUMN reponse_index DROP NOT NULL;

-- Fonction RPC pour increment de score atomique
CREATE OR REPLACE FUNCTION increment_score(session_id_param UUID, points INT)
RETURNS VOID AS $$
  UPDATE sessions
  SET score = COALESCE(score, 0) + points
  WHERE id = session_id_param;
$$ LANGUAGE SQL;

-- Index supplémentaires pour les requêtes V2
CREATE INDEX IF NOT EXISTS idx_session_answers_correct
  ON session_answers(session_id, est_correct);
```

- [ ] **Step 2: Appliquer via Supabase SQL Editor ou CLI**
```bash
# Via Supabase dashboard SQL Editor ou:
supabase db push
```

- [ ] **Step 3: Commit**
```bash
git add supabase/migrations/20260528_v2_fixes.sql
git commit -m "feat: migration DB V2 — reponse_index nullable, RPC increment_score, index"
```

---

## Task 14: Build final + push

- [ ] **Step 1: TypeScript check**
```bash
npx tsc --noEmit
```

- [ ] **Step 2: Build Next.js**
```bash
npm run build
```

- [ ] **Step 3: Corriger toutes les erreurs TypeScript/build**

- [ ] **Step 4: Push → Vercel deploy**
```bash
git push
```

---

## SELF-REVIEW CHECKLIST

| Requirement | Task |
|-------------|------|
| Suppression auto-sélection timer | Task 8 (handleExpired) |
| Timer optionnel + configurable | Tasks 6, 11 |
| Correction immédiate (<100ms visuel) | Task 9 (pending spinner) |
| Fisher-Yates shuffle options | Tasks 2, 8 |
| Répartition bonnes réponses | Task 2 (shuffle suffit) |
| Sources Coran/Hadith distinguées | Tasks 1, 7, 10 |
| Mode expired (pas auto-select) | Tasks 7, 8 |
| Accessibilité aria-labels | Tasks 5, 6, 9, 10, 12 |
| Content QA script | Task 3 |
| résultats enrichis | Task 12 |
| Migration DB | Task 13 |
| Tests shuffle/validators | Task 2, 3 |

---

## TODO V3 (hors scope V2)

- Mode révision (revoir questions ratées)
- Tests E2E Playwright
- RLS Supabase + auth sessions
- Temps moyen par question (answered_at - started_at)
- Mode duel en temps réel
- Export PDF résultats
- Questions avec images (Coran pages)
