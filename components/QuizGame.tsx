'use client'

import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { submitAnswer, endGame } from '@/lib/quiz/actions'
import QuizCard from './QuizCard'
import DalilCard from './DalilCard'
import ProgressBar from './ProgressBar'
import Timer from './Timer'
import type { QuestionClient, QuestionWithDalil } from '@/types/quiz'

type Phase = 'question' | 'dalil'

interface QuizGameProps {
  sessionId: string
  questions: QuestionClient[]
}

export default function QuizGame({ sessionId, questions }: QuizGameProps) {
  const router = useRouter()
  const [currentIndex, setCurrentIndex] = useState(0)
  const [phase, setPhase] = useState<Phase>('question')
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null)
  const [result, setResult] = useState<{ correct: boolean; question: QuestionWithDalil } | null>(null)
  const [loading, setLoading] = useState(false)
  const [score, setScore] = useState(0)

  const currentQuestion = questions[currentIndex]
  const isLast = currentIndex === questions.length - 1

  const handleAnswer = useCallback(async (answerIndex: number) => {
    if (loading || phase !== 'question') return
    setSelectedIndex(answerIndex)
    setLoading(true)
    try {
      const res = await submitAnswer(sessionId, currentQuestion.id, answerIndex)
      setResult(res)
      if (res.correct) setScore((s) => s + 10)
      setPhase('dalil')
    } catch {
      // continue on network error
    } finally {
      setLoading(false)
    }
  }, [loading, phase, sessionId, currentQuestion?.id]) // eslint-disable-line react-hooks/exhaustive-deps

  const handleTimerExpire = useCallback(() => {
    if (phase === 'question' && !loading) {
      handleAnswer(-1)
    }
  }, [phase, loading, handleAnswer])

  const handleNext = async () => {
    if (isLast) {
      await endGame(sessionId)
      router.push(`/resultats/${sessionId}`)
      return
    }
    setCurrentIndex((i) => i + 1)
    setPhase('question')
    setSelectedIndex(null)
    setResult(null)
  }

  if (!currentQuestion) return null

  return (
    <div className="min-h-screen bg-[#F5F0E8] px-4 py-6 flex flex-col items-center">
      <div className="w-full max-w-2xl mb-6 flex items-center gap-4">
        <div className="flex-1">
          <ProgressBar current={currentIndex + 1} total={questions.length} />
        </div>
        {phase === 'question' && (
          <Timer
            key={currentIndex}
            seconds={30}
            onExpire={handleTimerExpire}
            running={phase === 'question' && !loading}
          />
        )}
      </div>

      <div className="w-full max-w-2xl mb-4 flex justify-end">
        <span className="text-sm font-semibold text-[#1B4332] bg-white border border-[#D4AF37]/40 px-3 py-1 rounded-full">
          Score : {score} pts
        </span>
      </div>

      <div className="w-full max-w-2xl flex-1">
        {phase === 'question' ? (
          <QuizCard
            texte={currentQuestion.texte}
            options={currentQuestion.options}
            onAnswer={handleAnswer}
            disabled={loading}
            selectedIndex={selectedIndex}
          />
        ) : result ? (
          <DalilCard
            dalil={result.question.dalil}
            correct={result.correct}
            onNext={handleNext}
            isLast={isLast}
          />
        ) : null}
      </div>
    </div>
  )
}
