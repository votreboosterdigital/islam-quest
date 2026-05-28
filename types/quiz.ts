export type Niveau = 'facile' | 'moyen' | 'difficile'
export type Categorie = 'piliers' | 'coran' | 'hadith' | 'histoire' | 'jurisprudence' | 'prophetes' | 'foi' | 'tous'
export type Phase = 'question' | 'dalil' | 'expired'
export type SourceType = 'quran' | 'hadith' | 'sunnah' | 'scholar' | 'other'

export interface TimerConfig {
  enabled: boolean
  seconds: number
}

export interface OptionClient {
  id: string
  texte: string
  ordre: number
}

export interface Dalil {
  id: string
  explication: string
  texte_arabe: string
  traduction: string
  reference: string
  source_type?: SourceType
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
  correctOrdre: number
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
}

export interface QuizConfig {
  timer: TimerConfig
}
