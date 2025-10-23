-- Active la sécurité ligne par ligne (RLS)
ALTER TABLE public.categories_soins ENABLE ROW LEVEL SECURITY;

-- Supprime les policies précédentes (si elles existent déjà)
DROP POLICY IF EXISTS "Allow public read access to categories_soins" ON public.categories_soins;
DROP POLICY IF EXISTS "Allow user modify categories_soins" ON public.categories_soins;

-- Lecture publique : tous les utilisateurs peuvent consulter la table
CREATE POLICY "Allow public read access to categories_soins"
ON public.categories_soins
FOR SELECT
USING (true);

-- Interdit explicitement l'insertion, la mise à jour et la suppression depuis les clients publics
REVOKE ALL ON TABLE public.categories_soins FROM anon, authenticated;
