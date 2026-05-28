import { detectAnswerInQuestion, analyzeDistribution, deriveSourceType } from '../lib/quiz/validators'

const opts = [
  { id: 'a', texte: 'cinq', ordre: 0 },
  { id: 'b', texte: 'quatre', ordre: 1 },
  { id: 'c', texte: 'six', ordre: 2 },
  { id: 'd', texte: 'sept', ordre: 3 },
]

describe('detectAnswerInQuestion', () => {
  it('détecte quand la réponse est dans la question', () => {
    expect(
      detectAnswerInQuestion("L'Islam a cinq piliers.", opts, 0),
    ).toBe(true)
  })

  it('ne détecte pas quand la réponse est absente', () => {
    expect(
      detectAnswerInQuestion("Combien de piliers y a-t-il ?", opts, 0),
    ).toBe(false)
  })

  it('est insensible à la casse', () => {
    expect(
      detectAnswerInQuestion("L'ISLAM A CINQ PILIERS.", opts, 0),
    ).toBe(true)
  })

  it('ignore les mots trop courts (≤3 chars)', () => {
    const shortOpts = [{ id: 'x', texte: 'un', ordre: 0 }, ...opts.slice(1)]
    expect(
      detectAnswerInQuestion("Il y a un pilier.", shortOpts, 0),
    ).toBe(false)
  })
})

describe('analyzeDistribution', () => {
  it('calcule correctement la distribution', () => {
    const report = analyzeDistribution([0, 1, 1, 1, 2, 2, 3, 3, 3, 3])
    expect(report.total).toBe(10)
    expect(report.byPosition[1]).toBe(3)
    expect(report.byPosition[3]).toBe(4)
  })

  it('détecte un biais quand une position > 40%', () => {
    const biased = analyzeDistribution([1, 1, 1, 1, 1, 0, 2, 3, 0, 2])
    expect(biased.biased).toBe(true)
  })

  it('ne détecte pas de biais avec distribution équilibrée', () => {
    const balanced = analyzeDistribution([0, 1, 2, 3, 0, 1, 2, 3])
    expect(balanced.biased).toBe(false)
  })
})

describe('deriveSourceType', () => {
  it('identifie un verset coranique', () => {
    expect(deriveSourceType('Sourate Al-Baqara, verset 2')).toBe('quran')
    expect(deriveSourceType('Coran S.2:255')).toBe('quran')
  })

  it('identifie un hadith', () => {
    expect(deriveSourceType('Sahih Bukhari — Hadith n°8')).toBe('hadith')
    expect(deriveSourceType('Sahih Muslim n°16')).toBe('hadith')
    expect(deriveSourceType('Sunan At-Tirmidhi n°2641')).toBe('hadith')
  })

  it('identifie sunnah', () => {
    expect(deriveSourceType('Sunnah du Prophète')).toBe('sunnah')
  })

  it('retourne other pour une ref inconnue', () => {
    expect(deriveSourceType('Consensus des savants')).toBe('other')
  })
})
