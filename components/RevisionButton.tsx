'use client'

import { useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { startRevisionGame } from '@/lib/quiz/actions'

interface RevisionButtonProps {
  sessionId: string
  count: number
}

export default function RevisionButton({ sessionId, count }: RevisionButtonProps) {
  const [isPending, startTransition] = useTransition()
  const router = useRouter()

  return (
    <button
      type="button"
      disabled={isPending}
      onClick={() =>
        startTransition(async () => {
          const { sessionId: newId } = await startRevisionGame(sessionId)
          router.push(`/quiz/${newId}?timer=0`)
        })
      }
      className="block w-full bg-[#D4AF37] hover:bg-[#B8962E] disabled:opacity-60 text-[#1B4332] font-bold py-3 rounded-xl text-center transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#1B4332] focus-visible:ring-offset-2"
    >
      {isPending
        ? 'Chargement...'
        : `Réviser mes ${count} erreur${count > 1 ? 's' : ''} →`}
    </button>
  )
}
