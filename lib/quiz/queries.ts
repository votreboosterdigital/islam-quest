import { createServiceClient } from './supabase'
import type { QuestionClient, EndGameResult } from '@/types/quiz'

export async function getSessionQuestions(sessionId: string): Promise<QuestionClient[]> {
  const supabase = createServiceClient()

  const { data: answers, error: answersError } = await supabase
    .from('session_answers')
    .select('question_id, ordre')
    .eq('session_id', sessionId)
    .order('ordre')

  if (answersError || !answers?.length) return []

  const questionIds = answers.map((a) => a.question_id)

  const { data: questions, error: qError } = await supabase
    .from('questions')
    .select('id, texte, niveau, categorie, options(id, texte, ordre)')
    .in('id', questionIds)

  if (qError || !questions) return []

  const ordered = answers.map((a) => {
    const q = questions.find((qq) => qq.id === a.question_id)!
    return {
      id: q.id,
      texte: q.texte,
      niveau: q.niveau as QuestionClient['niveau'],
      categorie: q.categorie as QuestionClient['categorie'],
      options: (q.options as { id: string; texte: string; ordre: number }[])
        .sort((a, b) => a.ordre - b.ordre),
    } satisfies QuestionClient
  })

  return ordered
}

export async function getSessionResults(sessionId: string): Promise<EndGameResult | null> {
  const supabase = createServiceClient()

  const { data: session } = await supabase
    .from('sessions')
    .select('score, ended_at')
    .eq('id', sessionId)
    .single()

  if (!session || !session.ended_at) return null

  const { data: answers } = await supabase
    .from('session_answers')
    .select('est_correct')
    .eq('session_id', sessionId)

  const total = answers?.length ?? 0
  const correctes = answers?.filter((a) => a.est_correct).length ?? 0

  const { count } = await supabase
    .from('sessions')
    .select('*', { count: 'exact', head: true })
    .not('ended_at', 'is', null)
    .lte('score', session.score)

  const { count: totalSessions } = await supabase
    .from('sessions')
    .select('*', { count: 'exact', head: true })
    .not('ended_at', 'is', null)

  const rang = totalSessions
    ? Math.round(((count ?? 0) / totalSessions) * 100)
    : undefined

  return { score: session.score, correctes, total, rang }
}
