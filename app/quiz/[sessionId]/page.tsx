import { notFound } from 'next/navigation'
import QuizGame from '@/components/QuizGame'
import { getSessionQuestions } from '@/lib/quiz/queries'
import type { TimerConfig } from '@/types/quiz'

const VALID_TIMER_VALUES = [0, 10, 20, 30, 45] as const

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
  } catch (err) {
    console.error('[QuizPage] getSessionQuestions error:', err)
    return (
      <main className="min-h-screen bg-[#F5F0E8] flex items-center justify-center p-8">
        <div className="bg-white rounded-2xl p-8 max-w-md w-full border border-red-200 shadow">
          <h2 className="text-xl font-bold text-red-700 mb-2">Erreur de connexion</h2>
          <p className="text-sm text-[#8B7355] mb-4">
            Impossible de charger la session. Vérifie que la base de données Supabase est configurée.
          </p>
          <a href="/" className="block text-center bg-[#1B4332] text-white py-2 rounded-xl font-semibold">
            Retour à l&apos;accueil
          </a>
        </div>
      </main>
    )
  }

  if (!questions.length) notFound()

  const raw = parseInt(sp.timer ?? '30', 10)
  const timerSeconds = (VALID_TIMER_VALUES as readonly number[]).includes(raw) ? raw : 30
  const timerConfig: TimerConfig = {
    enabled: timerSeconds > 0,
    seconds: timerSeconds,
  }

  return <QuizGame sessionId={sessionId} questions={questions} timerConfig={timerConfig} />
}
