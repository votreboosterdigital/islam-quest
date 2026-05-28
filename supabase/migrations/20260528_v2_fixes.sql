-- Migration V2: Islam Quest
-- Rendre reponse_index nullable pour les questions sautées (timer expire)

ALTER TABLE session_answers
  ALTER COLUMN reponse_index DROP NOT NULL;

-- Index pour accélérer les requêtes de résultats
CREATE INDEX IF NOT EXISTS idx_session_answers_session
  ON session_answers(session_id);

CREATE INDEX IF NOT EXISTS idx_session_answers_correct
  ON session_answers(session_id, est_correct);

-- GRANTS pour la table session_answers (si pas déjà fait)
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.session_answers TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.session_answers TO service_role;
