import { notFound } from 'next/navigation'
import QuizGame from '@/components/QuizGame'
import { getSessionQuestions } from '@/lib/quiz/queries'

export default async function QuizPage({
  params,
}: {
  params: Promise<{ sessionId: string }>
}) {
  const { sessionId } = await params
  const questions = await getSessionQuestions(sessionId)

  if (!questions.length) notFound()

  return <QuizGame sessionId={sessionId} questions={questions} />
}
