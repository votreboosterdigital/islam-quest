import { notFound } from 'next/navigation'
import Link from 'next/link'
import { getSessionResults } from '@/lib/quiz/queries'
import RevisionButton from '@/components/RevisionButton'

export default async function ResultatsPage({
  params,
}: {
  params: Promise<{ sessionId: string }>
}) {
  const { sessionId } = await params

  let results
  try {
    results = await getSessionResults(sessionId)
  } catch (err) {
    console.error('[ResultatsPage] getSessionResults error:', err)
    return (
      <main className="min-h-screen bg-[#F5F0E8] flex items-center justify-center p-8">
        <div className="bg-white rounded-2xl p-8 max-w-md w-full border border-red-200 shadow text-center">
          <h2 className="text-xl font-bold text-red-700 mb-2">Erreur</h2>
          <p className="text-sm text-[#8B7355] mb-4">Impossible de charger les résultats.</p>
          <Link href="/" className="block bg-[#1B4332] text-white py-2 rounded-xl font-semibold">
            Accueil
          </Link>
        </div>
      </main>
    )
  }

  if (!results) notFound()

  const { score, correctes, incorrectes = 0, sautees = 0, total, rang, avgTime } = results
  const pct = total ? Math.round((correctes / total) * 100) : 0

  const mention =
    pct >= 80
      ? { ar: 'مَا شَاءَ اللَّه', fr: 'Excellent travail !' }
      : pct >= 60
      ? { ar: 'بَارَكَ اللَّهُ فِيكَ', fr: 'Bien joué !' }
      : pct >= 40
      ? { ar: 'إِنْ شَاءَ اللَّه', fr: 'Continue à progresser' }
      : { ar: 'جَزَاكَ اللَّهُ خَيْرًا', fr: "Le savoir s'acquiert avec patience" }

  return (
    <main className="min-h-screen bg-[#F5F0E8] flex flex-col items-center justify-center px-4 py-12">
      <div className="w-full max-w-md">
        {/* Mention arabe */}
        <div className="text-center mb-8">
          <p
            className="font-amiri text-5xl text-[#1B4332] mb-2 leading-loose"
            dir="rtl"
            lang="ar"
            aria-hidden="true"
          >
            {mention.ar}
          </p>
          <p className="text-lg font-bold text-[#2C1810]">{mention.fr}</p>
        </div>

        {/* Score principal */}
        <div className="bg-[#1B4332] rounded-2xl p-6 text-center text-white mb-6 shadow-xl">
          <p className="text-[#D4AF37] text-sm font-semibold mb-1">Score final</p>
          <p className="text-6xl font-bold mb-1" aria-label={`${score} points`}>
            {score}
          </p>
          <p className="text-white/70 text-sm">points</p>
        </div>

        {/* Stats : correctes / incorrectes / sautées */}
        <div className="grid grid-cols-3 gap-3 mb-4">
          <div className="bg-white rounded-xl p-3 text-center border border-emerald-200 shadow-sm">
            <p className="text-2xl font-bold text-emerald-600">{correctes}</p>
            <p className="text-[10px] text-[#8B7355] mt-1 leading-tight">Correctes</p>
          </div>
          <div className="bg-white rounded-xl p-3 text-center border border-red-200 shadow-sm">
            <p className="text-2xl font-bold text-red-500">{incorrectes}</p>
            <p className="text-[10px] text-[#8B7355] mt-1 leading-tight">Incorrectes</p>
          </div>
          <div className="bg-white rounded-xl p-3 text-center border border-slate-200 shadow-sm">
            <p className="text-2xl font-bold text-slate-500">{sautees}</p>
            <p className="text-[10px] text-[#8B7355] mt-1 leading-tight">Sautées</p>
          </div>
        </div>

        {/* Taux de réussite + temps moyen */}
        <div className="grid grid-cols-2 gap-3 mb-4">
          <div className="bg-white rounded-xl p-4 text-center border border-[#E8DCC8] shadow-sm">
            <p className="text-3xl font-bold text-[#D4AF37]">{pct}%</p>
            <p className="text-xs text-[#8B7355] mt-1">Taux de réussite</p>
            <p className="text-[10px] text-[#C4B49A]">{correctes}/{total}</p>
          </div>
          {avgTime !== undefined ? (
            <div className="bg-white rounded-xl p-4 text-center border border-[#E8DCC8] shadow-sm">
              <p className="text-3xl font-bold text-[#1B4332]">{avgTime}s</p>
              <p className="text-xs text-[#8B7355] mt-1">Temps moyen</p>
              <p className="text-[10px] text-[#C4B49A]">par question</p>
            </div>
          ) : (
            <div className="bg-white rounded-xl p-4 text-center border border-[#E8DCC8] shadow-sm">
              <p className="text-3xl font-bold text-[#1B4332]">—</p>
              <p className="text-xs text-[#8B7355] mt-1">Temps moyen</p>
              <p className="text-[10px] text-[#C4B49A]">mode libre</p>
            </div>
          )}
        </div>

        {/* Classement */}
        {rang !== undefined && (
          <div className="bg-[#FAF6EE] border border-[#D4AF37]/30 rounded-xl p-4 text-center mb-6">
            <p className="text-[#8B7355] text-xs mb-1">Classement</p>
            <p className="text-xl font-bold text-[#1B4332]">
              Meilleur que {rang}% des joueurs
            </p>
          </div>
        )}

        {/* Actions */}
        <div className="space-y-3">
          {incorrectes > 0 && (
            <RevisionButton sessionId={sessionId} count={incorrectes} />
          )}
          <Link
            href="/"
            className="block w-full bg-[#1B4332] hover:bg-[#155128] text-white font-bold py-3 rounded-xl text-center transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#D4AF37] focus-visible:ring-offset-2"
          >
            Rejouer
          </Link>
          <Link
            href="/"
            className="block w-full bg-white border-2 border-[#E8DCC8] hover:border-[#D4AF37] text-[#2C1810] font-semibold py-3 rounded-xl text-center transition-colors"
          >
            Changer de niveau
          </Link>
        </div>
      </div>
    </main>
  )
}
