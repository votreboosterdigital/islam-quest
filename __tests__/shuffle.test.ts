import { fisherYates, shuffleOptions } from '../lib/quiz/shuffle'

describe('fisherYates', () => {
  it('retourne un tableau de même longueur', () => {
    expect(fisherYates([1, 2, 3, 4])).toHaveLength(4)
  })

  it('contient les mêmes éléments', () => {
    expect([...fisherYates([1, 2, 3, 4])].sort()).toEqual([1, 2, 3, 4])
  })

  it('ne mute pas le tableau source', () => {
    const arr = [1, 2, 3, 4]
    const copy = [...arr]
    fisherYates(arr)
    expect(arr).toEqual(copy)
  })

  it('ne retourne pas toujours le même ordre sur 20 runs', () => {
    const arr = [1, 2, 3, 4]
    const results = new Set(Array.from({ length: 20 }, () => fisherYates([...arr]).join(',')))
    expect(results.size).toBeGreaterThan(1)
  })

  it('gère un tableau vide', () => {
    expect(fisherYates([])).toEqual([])
  })

  it('gère un tableau à un élément', () => {
    expect(fisherYates([42])).toEqual([42])
  })
})

describe('shuffleOptions', () => {
  const options = [
    { id: 'uuid-a', texte: 'Option A', ordre: 0 },
    { id: 'uuid-b', texte: 'Option B', ordre: 1 },
    { id: 'uuid-c', texte: 'Option C', ordre: 2 },
    { id: 'uuid-d', texte: 'Option D', ordre: 3 },
  ]

  it('préserve tous les ordres originaux', () => {
    const shuffled = shuffleOptions(options)
    expect(shuffled.map(o => o.ordre).sort()).toEqual([0, 1, 2, 3])
  })

  it('préserve tous les ids', () => {
    const shuffled = shuffleOptions(options)
    expect(shuffled.map(o => o.id).sort()).toEqual(['uuid-a', 'uuid-b', 'uuid-c', 'uuid-d'])
  })

  it('ne mute pas le tableau source', () => {
    const original = [...options]
    shuffleOptions(options)
    expect(options).toEqual(original)
  })
})
