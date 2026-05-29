import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { submitAnswer, endGame } from '@/lib/quiz/actions'
import { shuffleOptions } from '@/lib/quiz/shuffle'
import type {
  QuestionClient,
  OptionClient,
  SubmitAnswerResult,
  Phase,
  TimerConfig,
} from '@/types/quiz'

function makeFallbackResult(question: QuestionClient): SubmitAnswerResult {
  return {
    correct: false,
    skipped: true,
    question: {
      id: question.id,
      texte: question.texte,
      niveau: question.niveau,
      categorie: question.categorie,
      options: question.options,
      correctOrdre: 0,
      dalil: {
        id: '',
        explication: '',
        texte_arabe: '',
        traduction: '',
        reference: '',
        source_type: 'other' as const,
      },
    },
  }
}

interface UseQuizGameProps {
  sessionId: string
  questions: QuestionClient[]
  timerConfig: TimerConfig
}

interface CurrentQuestion extends QuestionClient {
  shuffledOptions: OptionClient[]
}

interface UseQuizGameReturn {
  currentIndex: number
  phase: Phase
  currentQuestion: CurrentQuestion
  selectedIndex: number | null
  result: SubmitAnswerResult | null
  loading: boolean
  score: number
  timerConfig: TimerConfig
  isLast: boolean
  handleAnswer: (answerIndex: number) => Promise<void>
  handleExpired: () => void
  handleNext: () => Promise<void>
}

export function useQuizGame({
  sessionId,
  questions,
  timerConfig,
}: UseQuizGameProps): UseQuizGameReturn {
  const router = useRouter()
  const [currentIndex, setCurrentIndex] = useState(0)
  const [phase, setPhase] = useState<Phase>('question')
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null)
  const [result, setResult] = useState<SubmitAnswerResult | null>(null)
  const [loading, setLoading] = useState(false)
  const [score, setScore] = useState(0)

  // Shuffle calculé une seule fois par session (map stable via useState init)
  const [shuffledOptionsMap] = useState<Map<string, OptionClient[]>>(() => {
    const map = new Map<string, OptionClient[]>()
    for (const q of questions) {
      map.set(q.id, shuffleOptions(q.options))
    }
    return map
  })

  const currentQuestion = questions[currentIndex]
  const isLast = currentIndex === questions.length - 1

  const handleAnswer = useCallback(
    async (answerIndex: number) => {
      if (loading || phase !== 'question') return
      setSelectedIndex(answerIndex)
      setLoading(true)
      try {
        const res = await submitAnswer(sessionId, currentQuestion.id, answerIndex)
        setResult(res)
        if (res.correct) setScore((s) => s + 10)
        setPhase('dalil')
      } catch {
        // En cas d'erreur serveur : fallback minimal pour éviter la page blanche
        setResult(makeFallbackResult(currentQuestion))
        setPhase('dalil')
      } finally {
        setLoading(false)
      }
    },
    [loading, phase, sessionId, currentQuestion?.id],
  )

  const handleExpired = useCallback(() => {
    if (phase !== 'question' || loading) return
    submitAnswer(sessionId, currentQuestion.id, -1)
      .then((res) => {
        setResult(res)
        setPhase('expired')
      })
      .catch(() => {
        // Fallback pour éviter la page blanche si le serveur ne répond pas
        setResult(makeFallbackResult(currentQuestion))
        setPhase('expired')
      })
  }, [phase, loading, sessionId, currentQuestion?.id])

  const handleNext = useCallback(async () => {
    if (isLast) {
      await endGame(sessionId)
      router.push(`/resultats/${sessionId}`)
      return
    }
    setCurrentIndex((i) => i + 1)
    setPhase('question')
    setSelectedIndex(null)
    setResult(null)
  }, [isLast, sessionId, router])

  return {
    currentIndex,
    phase,
    currentQuestion: currentQuestion
      ? {
          ...currentQuestion,
          shuffledOptions: shuffledOptionsMap.get(currentQuestion.id) ?? currentQuestion.options,
        }
      : (null as unknown as CurrentQuestion),
    selectedIndex,
    result,
    loading,
    score,
    timerConfig,
    isLast,
    handleAnswer,
    handleExpired,
    handleNext,
  }
}
