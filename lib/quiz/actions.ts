'use server'

import { createServiceClient } from './supabase'
import { startGameSchema, submitAnswerSchema } from './schemas'
import { deriveSourceType } from './validators'
import type { StartGameResult, SubmitAnswerResult, EndGameResult } from '@/types/quiz'

export async function startGame(
  niveau: string,
  categorie: string,
  pseudo: string,
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

  // Shuffle côté serveur (Fisher-Yates inline pour Server Action)
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
      // Options triées par ordre original — le shuffle visuel est fait côté client
      options: (q.options as { id: string; texte: string; ordre: number }[]).sort(
        (a, b) => a.ordre - b.ordre,
      ),
    })),
  }
}

export async function submitAnswer(
  sessionId: string,
  questionId: string,
  answerIndex: number,
): Promise<SubmitAnswerResult> {
  const supabase = createServiceClient()
  const skipped = answerIndex === -1

  const { data: options, error: oError } = await supabase
    .from('options')
    .select('id, texte, ordre, est_correct')
    .eq('question_id', questionId)
    .order('ordre')

  if (oError || !options?.length) throw new Error('Options introuvables.')

  const correctOption = options.find((o) => o.est_correct)
  const isCorrect = !skipped && correctOption?.ordre === answerIndex

  // Mise à jour session_answer (erreur silencieuse intentionnelle)
  await supabase
    .from('session_answers')
    .update({
      reponse_index: skipped ? null : answerIndex,
      est_correct: isCorrect,
      answered_at: new Date().toISOString(),
    })
    .eq('session_id', sessionId)
    .eq('question_id', questionId)

  // Incrément score si correct
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

  // Récupération dalil + question en parallèle
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

  if (!questionData) throw new Error('Question introuvable.')

  // Dalil peut être absent — on fournit un fallback plutôt que de throw
  const dalil = dalilData
    ? {
        id: dalilData.id as string,
        explication: (dalilData.explication ?? '') as string,
        texte_arabe: (dalilData.texte_arabe ?? '') as string,
        traduction: (dalilData.traduction ?? '') as string,
        reference: (dalilData.reference ?? '') as string,
        source_type: deriveSourceType(dalilData.reference),
      }
    : {
        id: '',
        explication: '',
        texte_arabe: '',
        traduction: '',
        reference: '',
        source_type: 'other' as const,
      }

  return {
    correct: isCorrect,
    skipped,
    question: {
      id: questionData.id as string,
      texte: questionData.texte as string,
      niveau: questionData.niveau as SubmitAnswerResult['question']['niveau'],
      categorie: questionData.categorie as SubmitAnswerResult['question']['categorie'],
      options: options.map((o) => ({ id: o.id as string, texte: o.texte as string, ordre: o.ordre as number })),
      correctOrdre: correctOption?.ordre ?? 0,
      dalil,
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
    supabase
      .from('session_answers')
      .select('est_correct, reponse_index')
      .eq('session_id', sessionId),
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
