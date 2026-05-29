-- V3 : temps moyen par question
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS avg_time_per_question SMALLINT;
