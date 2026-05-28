// Lancer avec : npx ts-node --project tsconfig.json scripts/validate-questions.ts
// Nécessite NEXT_PUBLIC_SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY dans l'environnement

import { createClient } from '@supabase/supabase-js'
import { analyzeDistribution, detectAnswerInQuestion, deriveSourceType } from '../lib/quiz/validators'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
)

interface QuestionRow {
  id: string
  texte: string
  options: { id: string; texte: string; ordre: number; est_correct: boolean }[]
  dalils: { reference: string } | null
}

async function main() {
  console.log('🔍 Islam Quest — Content QA\n')

  const { data: questions, error } = await supabase
    .from('questions')
    .select('id, texte, options(id, texte, ordre, est_correct), dalils(reference)')

  if (error || !questions?.length) {
    console.error('Erreur de chargement:', error)
    process.exit(1)
  }

  const correctOrdres: number[] = []
  const issuesAnswerInQuestion: string[] = []
  const issuesMissingDalil: string[] = []
  const sourceTypes: Record<string, number> = {}

  for (const q of questions as unknown as QuestionRow[]) {
    const correct = q.options.find((o) => o.est_correct)
    if (!correct) {
      issuesAnswerInQuestion.push(`⚠️  Pas de bonne réponse — ID:${q.id.slice(0, 8)} — "${q.texte.slice(0, 60)}"`)
      continue
    }

    correctOrdres.push(correct.ordre)

    if (detectAnswerInQuestion(q.texte, q.options, correct.ordre)) {
      issuesAnswerInQuestion.push(
        `⚠️  Réponse dans l'énoncé — ID:${q.id.slice(0, 8)} — "${q.texte.slice(0, 60)}"`,
      )
    }

    if (!q.dalils) {
      issuesMissingDalil.push(`⚠️  Pas de dalil — ID:${q.id.slice(0, 8)} — "${q.texte.slice(0, 40)}"`)
    } else {
      const st = deriveSourceType(q.dalils.reference)
      sourceTypes[st] = (sourceTypes[st] ?? 0) + 1
    }
  }

  // Distribution des bonnes réponses
  console.log('📊 Distribution des bonnes réponses (avant shuffle client):')
  const dist = analyzeDistribution(correctOrdres)
  const LABELS = ['A (ordre 0)', 'B (ordre 1)', 'C (ordre 2)', 'D (ordre 3)']
  for (const [pos, count] of Object.entries(dist.byPosition)) {
    const pct = Number(dist.byPositionPct[Number(pos)].replace('%', ''))
    const bar = '█'.repeat(Math.round(pct / 5))
    console.log(`  ${LABELS[Number(pos)]}: ${dist.byPositionPct[Number(pos)].padStart(6)} ${bar} (${count})`)
  }
  if (dist.biased) {
    console.log('\n  ❌ BIAIS DÉTECTÉ — une position dépasse 40% du total')
    console.log('  → Le shuffle client-side (Fisher-Yates) corrige ce biais à l\'affichage\n')
  } else {
    console.log('\n  ✅ Distribution équilibrée dans la base\n')
  }

  // Types de sources
  console.log('📖 Répartition types de sources:')
  for (const [type, count] of Object.entries(sourceTypes)) {
    console.log(`  ${type.padEnd(10)}: ${count}`)
  }

  // Problèmes détectés
  if (issuesAnswerInQuestion.length > 0) {
    console.log(`\n⚠️  ${issuesAnswerInQuestion.length} question(s) avec réponse dans l'énoncé:`)
    issuesAnswerInQuestion.forEach((i) => console.log(' ' + i))
  } else {
    console.log('\n✅ Aucune réponse détectée dans les énoncés')
  }

  if (issuesMissingDalil.length > 0) {
    console.log(`\n⚠️  ${issuesMissingDalil.length} question(s) sans dalil:`)
    issuesMissingDalil.forEach((i) => console.log(' ' + i))
  }

  console.log(`\n📝 Total analysé: ${questions.length} questions`)
  const totalIssues = issuesAnswerInQuestion.length + issuesMissingDalil.length
  if (totalIssues === 0) {
    console.log('✅ Aucun problème de contenu détecté')
  } else {
    console.log(`❌ ${totalIssues} problème(s) à corriger`)
    process.exit(1)
  }
}

main().catch((e) => { console.error(e); process.exit(1) })
