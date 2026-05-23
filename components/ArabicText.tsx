interface ArabicTextProps {
  text: string
  className?: string
  size?: 'sm' | 'md' | 'lg' | 'xl'
}

const sizeClasses = {
  sm: 'text-lg leading-loose',
  md: 'text-2xl leading-loose',
  lg: 'text-3xl leading-loose',
  xl: 'text-4xl leading-loose',
}

export default function ArabicText({ text, className = '', size = 'lg' }: ArabicTextProps) {
  return (
    <p
      dir="rtl"
      lang="ar"
      className={`font-amiri text-center ${sizeClasses[size]} ${className}`}
    >
      {text}
    </p>
  )
}
