export type Niveau = 'facile' | 'moyen' | 'difficile'
export type Categorie = 'piliers' | 'coran' | 'hadith' | 'histoire' | 'jurisprudence' | 'prophetes' | 'foi' | 'tous'

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
}

export interface StartGameResult {
  sessionId: string
  questions: QuestionClient[]
}

export interface SubmitAnswerResult {
  correct: boolean
  question: QuestionWithDalil
}

export interface EndGameResult {
  score: number
  correctes: number
  total: number
  rang?: number
}
