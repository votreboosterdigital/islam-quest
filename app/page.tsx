import NiveauSelector from '@/components/NiveauSelector'

export default function HomePage() {
  return (
    <main className="min-h-screen bg-[#F5F0E8]">
      {/* Hero — dark green avec motif islamique */}
      <div className="relative bg-[#1B4332] overflow-hidden">
        {/* Motif étoile islamique 8 branches en fond */}
        <div className="absolute inset-0 opacity-[0.06] pointer-events-none">
          <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <pattern id="star8" x="0" y="0" width="120" height="120" patternUnits="userSpaceOnUse">
                {/* Étoile 8 branches via deux carrés superposés */}
                <rect x="25" y="25" width="70" height="70" fill="none" stroke="#D4AF37" strokeWidth="1.2"/>
                <rect x="25" y="25" width="70" height="70" fill="none" stroke="#D4AF37" strokeWidth="1.2" transform="rotate(45 60 60)"/>
                {/* Diagonales de connexion */}
                <line x1="0" y1="0" x2="25" y2="25" stroke="#D4AF37" strokeWidth="0.6"/>
                <line x1="120" y1="0" x2="95" y2="25" stroke="#D4AF37" strokeWidth="0.6"/>
                <line x1="0" y1="120" x2="25" y2="95" stroke="#D4AF37" strokeWidth="0.6"/>
                <line x1="120" y1="120" x2="95" y2="95" stroke="#D4AF37" strokeWidth="0.6"/>
                {/* Point central */}
                <circle cx="60" cy="60" r="3" fill="none" stroke="#D4AF37" strokeWidth="0.8"/>
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#star8)"/>
          </svg>
        </div>

        {/* Contenu hero */}
        <div className="relative z-10 px-4 pt-14 pb-10 text-center max-w-lg mx-auto">
          {/* Bismillah */}
          <p
            dir="rtl"
            lang="ar"
            className="font-amiri text-xl text-[#D4AF37]/80 mb-5 tracking-wide"
          >
            بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ
          </p>

          {/* Séparateur doré */}
          <div className="flex items-center justify-center gap-3 mb-6" aria-hidden="true">
            <div className="w-12 h-px bg-[#D4AF37]/50" />
            <span className="text-[#D4AF37] text-base">✦</span>
            <div className="w-24 h-px bg-[#D4AF37]/50" />
            <span className="text-[#D4AF37] text-base">✦</span>
            <div className="w-12 h-px bg-[#D4AF37]/50" />
          </div>

          {/* Titre arabe */}
          <h1
            dir="rtl"
            lang="ar"
            className="font-amiri text-6xl text-white font-bold mb-3 leading-tight"
          >
            مسابقة الإسلام
          </h1>

          {/* Titre français */}
          <p className="text-2xl font-bold text-[#D4AF37] mb-2 tracking-wider">Islam Quest</p>
          <p className="text-white/55 text-sm mb-8">
            Testez vos connaissances islamiques · Apprenez les dalils
          </p>

          {/* Statistiques */}
          <div className="flex items-center justify-center gap-6">
            <div className="text-center">
              <p className="text-2xl font-bold text-[#D4AF37]">200+</p>
              <p className="text-white/50 text-xs mt-0.5">questions</p>
            </div>
            <div className="w-px h-8 bg-white/15" aria-hidden="true" />
            <div className="text-center">
              <p className="text-2xl font-bold text-[#D4AF37]">7</p>
              <p className="text-white/50 text-xs mt-0.5">catégories</p>
            </div>
            <div className="w-px h-8 bg-white/15" aria-hidden="true" />
            <div className="text-center">
              <p className="text-2xl font-bold text-[#D4AF37]">3</p>
              <p className="text-white/50 text-xs mt-0.5">niveaux</p>
            </div>
          </div>
        </div>

        {/* Transition courbe vers la section formulaire */}
        <div className="relative h-10 overflow-hidden" aria-hidden="true">
          <svg
            viewBox="0 0 1440 40"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            className="absolute bottom-0 w-full"
            preserveAspectRatio="none"
          >
            <path d="M0 40 Q360 0 720 20 Q1080 40 1440 10 L1440 40 Z" fill="#F5F0E8" />
          </svg>
        </div>
      </div>

      {/* Section formulaire */}
      <div className="px-4 pt-8 pb-16 flex flex-col items-center">
        {/* Carte de configuration */}
        <div className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-[#E8DCC8] p-6">
          {/* En-tête carte */}
          <div className="text-center mb-6">
            <p className="text-xs font-semibold text-[#8B7355] uppercase tracking-widest mb-1">
              Configure ta partie
            </p>
            <div className="w-8 h-0.5 bg-[#D4AF37] mx-auto" aria-hidden="true" />
          </div>

          <NiveauSelector />
        </div>

        {/* Piliers en bas — trois points forts */}
        <div className="grid grid-cols-3 gap-3 mt-8 w-full max-w-md">
          {[
            { icon: '📖', label: 'Coran & Hadith', desc: 'Sources authentiques' },
            { icon: '🏆', label: 'Classement', desc: 'Compare-toi aux joueurs' },
            { icon: '🔄', label: 'Révision', desc: 'Retravaille tes erreurs' },
          ].map((item) => (
            <div
              key={item.label}
              className="bg-white rounded-xl p-3 text-center border border-[#E8DCC8] shadow-sm"
            >
              <span className="text-2xl" aria-hidden="true">{item.icon}</span>
              <p className="text-[11px] font-bold text-[#2C1810] mt-1 leading-tight">{item.label}</p>
              <p className="text-[9px] text-[#8B7355] mt-0.5 leading-tight">{item.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </main>
  )
}
