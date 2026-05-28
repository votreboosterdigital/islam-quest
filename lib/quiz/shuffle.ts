import type { OptionClient } from '@/types/quiz'

// Fisher-Yates shuffle — ne mute pas le tableau source
export function fisherYates<T>(array: T[]): T[] {
  const arr = [...array]
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[arr[i], arr[j]] = [arr[j], arr[i]]
  }
  return arr
}

// Shuffle les options d'affichage sans altérer les ordres/ids d'origine
export function shuffleOptions(options: OptionClient[]): OptionClient[] {
  return fisherYates([...options])
}
