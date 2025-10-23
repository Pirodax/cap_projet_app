-- Active la sécurité ligne par ligne (RLS)
ALTER TABLE public.mutuelle_formule_categories ENABLE ROW LEVEL SECURITY;

-- Supprime d'éventuelles anciennes policies pour éviter les doublons
DROP POLICY IF EXISTS "Allow public read access to mutuelle_formule_categories" ON public.mutuelle_formule_categories;
DROP POLICY IF EXISTS "Allow user insert or update own data" ON public.mutuelle_formule_categories;

-- Lecture publique (toutes les formules / catégories sont visibles par les utilisateurs)
CREATE POLICY "Allow public read access to mutuelle_formule_categories"
ON public.mutuelle_formule_categories
FOR SELECT
USING (true);

-- ⚠️ Ne pas autoriser d'insertion, de mise à jour ou de suppression depuis le client Flutter
-- (seules les migrations, scripts ou le backend admin peuvent le faire)
REVOKE ALL ON TABLE public.mutuelle_formule_categories FROM anon, authenticated;
