import { useEffect, useState, useCallback, useRef } from 'react'

interface UseTimerProps {
  duration: number
  enabled: boolean
  onExpire?: () => void
  autoStart?: boolean
}

interface UseTimerReturn {
  remaining: number
  pct: number
  isUrgent: boolean
  isRunning: boolean
  isExpired: boolean
  start: () => void
  pause: () => void
  reset: () => void
}

export function useTimer({
  duration,
  enabled,
  onExpire,
  autoStart = true,
}: UseTimerProps): UseTimerReturn {
  const [remaining, setRemaining] = useState(duration)
  const [isRunning, setIsRunning] = useState(autoStart && enabled)
  const onExpireRef = useRef(onExpire)
  onExpireRef.current = onExpire

  // Reset quand la question change (duration ou enabled changent)
  useEffect(() => {
    setRemaining(duration)
    setIsRunning(autoStart && enabled)
  }, [duration, enabled, autoStart])

  useEffect(() => {
    if (!enabled || !isRunning) return
    if (remaining <= 0) {
      setIsRunning(false)
      onExpireRef.current?.()
      return
    }
    const id = setTimeout(() => setRemaining((r) => r - 1), 1000)
    return () => clearTimeout(id)
  }, [remaining, isRunning, enabled])

  const start = useCallback(() => {
    if (enabled) setIsRunning(true)
  }, [enabled])

  const pause = useCallback(() => setIsRunning(false), [])

  const reset = useCallback(() => {
    setRemaining(duration)
    setIsRunning(autoStart && enabled)
  }, [duration, autoStart, enabled])

  return {
    remaining,
    pct: duration > 0 ? (remaining / duration) * 100 : 0,
    isUrgent: remaining <= 10 && remaining > 0 && enabled,
    isRunning,
    isExpired: enabled && remaining <= 0,
    start,
    pause,
    reset,
  }
}
