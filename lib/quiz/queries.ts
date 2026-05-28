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

  return answers.map((a) => {
    const q = questions.find((qq) => qq.id === a.question_id)!
    return {
      id: q.id,
      texte: q.texte,
      niveau: q.niveau as QuestionClient['niveau'],
      categorie: q.categorie as QuestionClient['categorie'],
      // Ordre original — le shuffle visuel se fait côté client dans useQuizGame
      options: (q.options as { id: string; texte: string; ordre: number }[]).sort(
        (a, b) => a.ordre - b.ordre,
      ),
    } satisfies QuestionClient
  })
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
    .select('est_correct, reponse_index')
    .eq('session_id', sessionId)

  const total = answers?.length ?? 0
  const correctes = answers?.filter((a) => a.est_correct).length ?? 0
  const sautees = answers?.filter((a) => a.reponse_index === null).length ?? 0
  const incorrectes = total - correctes - sautees
  const score = session.score ?? 0

  const [{ count: below }, { count: totalSessions }] = await Promise.all([
    supabase
      .from('sessions')
      .select('*', { count: 'exact', head: true })
      .not('ended_at', 'is', null)
      .lte('score', score),
    supabase
      .from('sessions')
      .select('*', { count: 'exact', head: true })
      .not('ended_at', 'is', null),
  ])

  const rang = totalSessions ? Math.round(((below ?? 0) / totalSessions) * 100) : undefined

  return { score, correctes, incorrectes, sautees, total, rang }
}
