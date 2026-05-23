'use client'

import { useEffect, useState } from 'react'

interface TimerProps {
  seconds: number
  onExpire: () => void
  running: boolean
}

export default function Timer({ seconds, onExpire, running }: TimerProps) {
  const [remaining, setRemaining] = useState(seconds)

  useEffect(() => {
    setRemaining(seconds)
  }, [seconds])

  useEffect(() => {
    if (!running) return
    if (remaining <= 0) { onExpire(); return }
    const id = setTimeout(() => setRemaining((r) => r - 1), 1000)
    return () => clearTimeout(id)
  }, [remaining, running, onExpire])

  const pct = (remaining / seconds) * 100
  const urgent = remaining <= 10

  return (
    <div className="flex items-center gap-2">
      <div className="relative w-10 h-10">
        <svg className="w-10 h-10 -rotate-90" viewBox="0 0 36 36">
          <circle cx="18" cy="18" r="15.9" fill="none" stroke="#E8DCC8" strokeWidth="3" />
          <circle
            cx="18" cy="18" r="15.9" fill="none"
            stroke={urgent ? '#ef4444' : '#D4AF37'}
            strokeWidth="3"
            strokeDasharray={`${pct} 100`}
            className="transition-all duration-1000"
          />
        </svg>
        <span className={`absolute inset-0 flex items-center justify-center text-xs font-bold ${urgent ? 'text-red-500' : 'text-[#8B7355]'}`}>
          {remaining}
        </span>
      </div>
    </div>
  )
}
