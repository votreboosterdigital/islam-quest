import type { OptionClient, SourceType } from '@/types/quiz'

export interface DistributionReport {
  total: number
  byPosition: Record<number, number>
  byPositionPct: Record<number, string>
  biased: boolean
}

// Détecte si la bonne réponse est contenue verbatim dans l'énoncé
export function detectAnswerInQuestion(
  questionTexte: string,
  options: OptionClient[],
  correctOrdre: number,
): boolean {
  const normalize = (s: string) =>
    s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').trim()

  const q = normalize(questionTexte)
  return options
    .filter((o) => o.ordre === correctOrdre)
    .some((o) => {
      const opt = normalize(o.texte)
      return opt.length > 3 && q.includes(opt)
    })
}

// Analyse la distribution des positions des bonnes réponses
export function analyzeDistribution(
  correctOrdres: number[],
  totalOptions = 4,
): DistributionReport {
  const byPosition: Record<number, number> = {}
  for (let i = 0; i < totalOptions; i++) byPosition[i] = 0
  for (const ordre of correctOrdres) {
    byPosition[ordre] = (byPosition[ordre] ?? 0) + 1
  }
  const total = correctOrdres.length
  const byPositionPct: Record<number, string> = {}
  for (const k of Object.keys(byPosition)) {
    byPositionPct[Number(k)] = total
      ? ((byPosition[Number(k)] / total) * 100).toFixed(1) + '%'
      : '0%'
  }
  const biased = Object.values(byPosition).some((v) => v / total > 0.4)
  return { total, byPosition, byPositionPct, biased }
}

// Dérive le type de source depuis la référence textuelle
export function deriveSourceType(reference: string): SourceType {
  const ref = reference.toLowerCase()
  if (
    ref.includes('sourate') ||
    ref.includes('verset') ||
    ref.includes('coran') ||
    ref.includes('quran') ||
    /\bs\s*\.\s*\d/.test(ref)
  )
    return 'quran'
  if (
    ref.includes('bukhari') ||
    ref.includes('muslim') ||
    ref.includes('tirmidhi') ||
    ref.includes('hadith') ||
    ref.includes('abu dawud') ||
    ref.includes('nasai') ||
    ref.includes('ibn majah') ||
    ref.includes('musnad') ||
    ref.includes('ahmad')
  )
    return 'hadith'
  if (ref.includes('sunnah')) return 'sunnah'
  return 'other'
}
