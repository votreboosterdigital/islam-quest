import { notFound } from 'next/navigation'
import QuizGame from '@/components/QuizGame'
import { getSessionQuestions } from '@/lib/quiz/queries'

export default async function QuizPage({
  params,
}: {
  params: Promise<{ sessionId: string }>
}) {
  const { sessionId } = await params

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

  return <QuizGame sessionId={sessionId} questions={questions} />
}
