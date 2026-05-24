'use client'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <main className="min-h-screen bg-[#F5F0E8] flex items-center justify-center p-8">
      <div className="bg-white rounded-2xl p-8 max-w-md w-full border border-red-200 shadow text-center">
        <p className="text-4xl mb-4">⚠️</p>
        <h2 className="text-xl font-bold text-red-700 mb-2">Une erreur s&apos;est produite</h2>
        <p className="text-sm text-[#8B7355] mb-2">
          La base de données Supabase n&apos;est peut-être pas encore configurée (tables manquantes).
        </p>
        {error.digest && (
          <p className="text-xs text-gray-400 mb-4 font-mono">Digest : {error.digest}</p>
        )}
        <div className="space-y-2">
          <button
            onClick={reset}
            className="block w-full bg-[#1B4332] text-white py-2 rounded-xl font-semibold"
          >
            Réessayer
          </button>
          <a href="/" className="block w-full bg-white border-2 border-[#E8DCC8] text-[#2C1810] py-2 rounded-xl font-semibold">
            Accueil
          </a>
        </div>
      </div>
    </main>
  )
}
