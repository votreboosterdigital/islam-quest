import NiveauSelector from '@/components/NiveauSelector'

export default function HomePage() {
  return (
    <main className="min-h-screen bg-[#F5F0E8] flex flex-col items-center justify-center px-4 py-12">
      {/* Motif géométrique islamique SVG */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none opacity-5">
        <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern id="islamic" x="0" y="0" width="60" height="60" patternUnits="userSpaceOnUse">
              <polygon points="30,0 60,15 60,45 30,60 0,45 0,15" fill="none" stroke="#1B4332" strokeWidth="1"/>
              <polygon points="30,10 50,20 50,40 30,50 10,40 10,20" fill="none" stroke="#D4AF37" strokeWidth="0.5"/>
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#islamic)"/>
        </svg>
      </div>

      {/* Logo */}
      <div className="relative z-10 text-center mb-10">
        <div className="inline-flex items-center gap-3 mb-3">
          <div className="w-12 h-px bg-[#D4AF37]" />
          <span className="text-[#D4AF37] text-2xl">☽</span>
          <div className="w-12 h-px bg-[#D4AF37]" />
        </div>
        <h1
          dir="rtl"
          lang="ar"
          className="font-amiri text-5xl text-[#1B4332] font-bold mb-2"
        >
          مسابقة الإسلام
        </h1>
        <p className="text-xl font-bold text-[#1B4332] tracking-wider mb-1">Islam Quest</p>
        <p className="text-sm text-[#8B7355]">Testez vos connaissances — apprenez les dalils</p>
      </div>

      {/* Carte de sélection */}
      <div className="relative z-10 w-full max-w-md bg-white rounded-2xl shadow-lg border border-[#E8DCC8] p-6">
        <NiveauSelector />
      </div>
    </main>
  )
}
