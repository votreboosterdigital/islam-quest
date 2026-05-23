'use server'

import { z } from 'zod'
import { createServiceClient } from './supabase'
import type { StartGameResult, SubmitAnswerResult, EndGameResult } from '@/types/quiz'

const startGameSchema = z.object({
  niveau: z.enum(['facile', 'moyen', 'difficile']),
  categorie: z.enum(['piliers','coran','hadith','histoire','jurisprudence','prophetes','foi','tous']),
  pseudo: z.string().min(1).max(30),
})

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

  if (parsed.categorie !== 'tous') {
    query = query.eq('categorie', parsed.categorie)
  }
  if (parsed.niveau !== ('tous' as unknown as 'facile' | 'moyen' | 'difficile')) {
    query = query.eq('niveau', parsed.niveau)
  }

  const { data: allQuestions, error: qError } = await query

  if (qError || !allQuestions?.length) {
    throw new Error('Aucune question trouvée pour ce niveau/catégorie.')
  }

  const shuffled = allQuestions.sort(() => Math.random() - 0.5).slice(0, 10)

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

  const questions = shuffled.map((q) => ({
    id: q.id,
    texte: q.texte,
    niveau: q.niveau as StartGameResult['questions'][number]['niveau'],
    categorie: q.categorie as StartGameResult['questions'][number]['categorie'],
    options: (q.options as { id: string; texte: string; ordre: number }[])
      .sort((a, b) => a.ordre - b.ordre),
  }))

  return { sessionId: session.id, questions }
}

export async function submitAnswer(
  sessionId: string,
  questionId: string,
  answerIndex: number
): Promise<SubmitAnswerResult> {
  const supabase = createServiceClient()

  const { data: options, error: oError } = await supabase
    .from('options')
    .select('id, texte, ordre, est_correct')
    .eq('question_id', questionId)
    .order('ordre')

  if (oError || !options) throw new Error('Options introuvables.')

  const correct = options.find((o) => o.est_correct)
  const isCorrect = correct?.ordre === answerIndex

  await supabase
    .from('session_answers')
    .update({ reponse_index: answerIndex, est_correct: isCorrect, answered_at: new Date().toISOString() })
    .eq('session_id', sessionId)
    .eq('question_id', questionId)

  if (isCorrect) {
    const { data: session } = await supabase
      .from('sessions')
      .select('score')
      .eq('id', sessionId)
      .single()

    await supabase
      .from('sessions')
      .update({ score: (session?.score ?? 0) + 10 })
      .eq('id', sessionId)
  }

  const { data: dalilData } = await supabase
    .from('dalils')
    .select('id, explication, texte_arabe, traduction, reference')
    .eq('question_id', questionId)
    .single()

  const { data: questionData } = await supabase
    .from('questions')
    .select('id, texte, niveau, categorie')
    .eq('id', questionId)
    .single()

  if (!questionData || !dalilData) throw new Error('Données question introuvables.')

  return {
    correct: isCorrect,
    question: {
      id: questionData.id,
      texte: questionData.texte,
      niveau: questionData.niveau as SubmitAnswerResult['question']['niveau'],
      categorie: questionData.categorie as SubmitAnswerResult['question']['categorie'],
      options: options.map((o) => ({ id: o.id, texte: o.texte, ordre: o.ordre })),
      dalil: dalilData,
    },
  }
}

export async function endGame(sessionId: string): Promise<EndGameResult> {
  const supabase = createServiceClient()

  await supabase
    .from('sessions')
    .update({ ended_at: new Date().toISOString() })
    .eq('id', sessionId)

  const { data: session } = await supabase
    .from('sessions')
    .select('score')
    .eq('id', sessionId)
    .single()

  const { data: answers } = await supabase
    .from('session_answers')
    .select('est_correct')
    .eq('session_id', sessionId)

  const total = answers?.length ?? 0
  const correctes = answers?.filter((a) => a.est_correct).length ?? 0
  const score = session?.score ?? 0

  const { count: below } = await supabase
    .from('sessions')
    .select('*', { count: 'exact', head: true })
    .not('ended_at', 'is', null)
    .neq('id', sessionId)
    .lte('score', score)

  const { count: totalSessions } = await supabase
    .from('sessions')
    .select('*', { count: 'exact', head: true })
    .not('ended_at', 'is', null)

  const rang = totalSessions
    ? Math.round(((below ?? 0) / totalSessions) * 100)
    : undefined

  return { score, correctes, total, rang }
}
