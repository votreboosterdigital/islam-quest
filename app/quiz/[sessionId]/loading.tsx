export default function QuizLoading() {
  return (
    <div className="min-h-screen bg-[#F5F0E8] flex flex-col items-center justify-center px-4">
      <div className="w-full max-w-2xl space-y-6 animate-pulse">
        <div className="h-4 bg-[#E8DCC8] rounded-full" />
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-[#E8DCC8]">
          <div className="h-6 bg-[#E8DCC8] rounded-lg mb-3 w-3/4 mx-auto" />
          <div className="h-4 bg-[#E8DCC8] rounded-lg w-1/2 mx-auto" />
        </div>
        {[0, 1, 2, 3].map((i) => (
          <div key={i} className="h-14 bg-white rounded-xl border border-[#E8DCC8]" />
        ))}
      </div>
      <p
        className="mt-8 text-[#8B7355] font-amiri text-2xl"
        dir="rtl"
        lang="ar"
      >
        بسم الله الرحمن الرحيم
      </p>
    </div>
  )
}
