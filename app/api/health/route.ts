import { NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/quiz/supabase'
import { createServerClient } from '@/lib/quiz/supabase'

export async function GET() {
  const results: Record<string, unknown> = {}

  // Test 1 : service role (bypass RLS)
  try {
    const supabase = createServiceClient()
    const { count, error } = await supabase
      .from('questions')
      .select('*', { count: 'exact', head: true })
    results.service_role = error ? { error: error.message, code: error.code } : { ok: true, questions: count }
  } catch (e) {
    results.service_role = { thrown: String(e) }
  }

  // Test 2 : anon key (sujet au RLS)
  try {
    const supabase = await createServerClient()
    const { count, error } = await supabase
      .from('questions')
      .select('*', { count: 'exact', head: true })
    results.anon_key = error ? { error: error.message, code: error.code } : { ok: true, questions: count }
  } catch (e) {
    results.anon_key = { thrown: String(e) }
  }

  // Test 3 : session_answers lisible en anon ?
  try {
    const supabase = await createServerClient()
    const { data, error } = await supabase
      .from('session_answers')
      .select('id')
      .limit(1)
    results.session_answers_anon = error ? { error: error.message } : { ok: true, rows: data?.length }
  } catch (e) {
    results.session_answers_anon = { thrown: String(e) }
  }

  return NextResponse.json(results)
}
