'use client'

import { useTimer } from '@/hooks/useTimer'

interface TimerProps {
  duration: number
  onExpire: () => void
  running: boolean
}

export default function Timer({ duration, onExpire, running }: TimerProps) {
  const { remaining, pct, isUrgent } = useTimer({
    duration,
    enabled: running,
    onExpire,
    autoStart: true,
  })

  const strokeColor = isUrgent ? '#ef4444' : '#D4AF37'

  return (
    <div
      role="timer"
      aria-label={`Temps restant : ${remaining} seconde${remaining !== 1 ? 's' : ''}`}
      aria-live="off"
      className="flex items-center gap-2"
    >
      <div className="relative w-10 h-10">
        <svg className="w-10 h-10 -rotate-90" viewBox="0 0 36 36" aria-hidden="true">
          <circle cx="18" cy="18" r="15.9" fill="none" stroke="#E8DCC8" strokeWidth="3" />
          <circle
            cx="18"
            cy="18"
            r="15.9"
            fill="none"
            stroke={strokeColor}
            strokeWidth="3"
            strokeDasharray={`${pct} 100`}
            className="transition-all duration-1000"
          />
        </svg>
        <span
          className={`absolute inset-0 flex items-center justify-center text-xs font-bold select-none ${
            isUrgent ? 'text-red-500' : 'text-[#8B7355]'
          }`}
        >
          {remaining}
        </span>
      </div>
    </div>
  )
}
