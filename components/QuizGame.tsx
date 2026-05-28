'use client'

import { useQuizGame } from '@/hooks/useQuizGame'
import QuizCard from './QuizCard'
import DalilCard from './DalilCard'
import ProgressBar from './ProgressBar'
import Timer from './Timer'
import type { QuestionClient, TimerConfig } from '@/types/quiz'

interface QuizGameProps {
  sessionId: string
  questions: QuestionClient[]
  timerConfig: TimerConfig
}

export default function QuizGame({ sessionId, questions, timerConfig }: QuizGameProps) {
  const {
    currentIndex,
    phase,
    currentQuestion,
    selectedIndex,
    result,
    loading,
    score,
    isLast,
    handleAnswer,
    handleExpired,
    handleNext,
  } = useQuizGame({ sessionId, questions, timerConfig })

  if (!currentQuestion) return null

  const showTimer = phase === 'question' && timerConfig.enabled
  const showDalil = (phase === 'dalil' || phase === 'expired') && result

  return (
    <div className="min-h-screen bg-[#F5F0E8] px-4 py-6 flex flex-col items-center">
      {/* Header */}
      <div className="w-full max-w-2xl mb-6 flex items-center gap-4">
        <div className="flex-1">
          <ProgressBar current={currentIndex + 1} total={questions.length} />
        </div>
        {showTimer && (
          <Timer
            key={`${currentIndex}-timer`}
            duration={timerConfig.seconds}
            onExpire={handleExpired}
            running={phase === 'question' && !loading}
          />
        )}
        <span className="text-sm font-semibold text-[#1B4332] bg-white border border-[#D4AF37]/40 px-3 py-1 rounded-full whitespace-nowrap">
          {score} pts
        </span>
      </div>

      {/* Corps */}
      <div className="w-full max-w-2xl flex-1">
        {phase === 'question' ? (
          <QuizCard
            key={currentQuestion.id}
            texte={currentQuestion.texte}
            options={currentQuestion.shuffledOptions}
            onAnswer={handleAnswer}
            disabled={loading}
            selectedIndex={selectedIndex}
            loading={loading}
          />
        ) : showDalil ? (
          <DalilCard
            dalil={result.question.dalil}
            correct={result.correct}
            skipped={result.skipped || phase === 'expired'}
            correctOrdre={result.question.correctOrdre}
            options={currentQuestion.shuffledOptions}
            onNext={handleNext}
            isLast={isLast}
          />
        ) : null}
      </div>
    </div>
  )
}
