import { z } from 'zod'

export const startGameSchema = z.object({
  niveau: z.enum(['facile', 'moyen', 'difficile']),
  categorie: z.enum(['piliers', 'coran', 'hadith', 'histoire', 'jurisprudence', 'prophetes', 'foi', 'tous']),
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
