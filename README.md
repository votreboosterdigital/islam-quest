# Islam Quest

Quiz islamique full-stack avec dalils authentiques du Coran et de la Sunna.

## Stack

- Next.js 16+ App Router · TypeScript strict · Tailwind CSS 4
- Supabase (PostgreSQL) · Server Actions · Amiri font (texte arabe)

## Démarrage local

1. `npm install`
2. Copier `.env.local.example` → `.env.local` et remplir les 3 variables Supabase
3. Exécuter `supabase/schema.sql` entièrement dans le **SQL Editor** Supabase Dashboard
4. `npm run dev` → http://localhost:3000

## Déploiement Vercel

1. Pusher le repo sur GitHub
2. Importer dans Vercel
3. Ajouter les variables d'environnement : `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`
4. Deploy automatique à chaque push `main`

## Quiz

- 10 questions par partie (sélection aléatoire)
- 30 secondes par question · 10 pts par bonne réponse
- Dalil (Coran ou Hadith) affiché après chaque réponse
- Classement comparatif en fin de partie

## 40 questions — 3 niveaux — 7 catégories

Piliers · Coran · Hadith · Histoire · Prophètes · Foi (Aqida) · Jurisprudence
