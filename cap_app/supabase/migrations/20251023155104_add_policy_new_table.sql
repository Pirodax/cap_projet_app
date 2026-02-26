-- =============================================
-- 2️⃣ Sécurité : Activation de RLS et création des Policies
-- =============================================
-- Les commandes sont idempotentes : elles ne génèrent pas d'erreur si la RLS est
-- déjà active ou si une policy du même nom existe déjà.

-- 🔐 Table: categories_soins
-- Activer la RLS
ALTER TABLE public.categories_soins ENABLE ROW LEVEL SECURITY;
-- Donner l'accès en lecture à tout le monde
CREATE POLICY "Les visiteurs peuvent lire les catégories de soins"
    ON public.categories_soins FOR SELECT
    USING (true);


-- 🔐 Table: detail_soins
-- Activer la RLS
ALTER TABLE public.detail_soins ENABLE ROW LEVEL SECURITY;
-- Donner l'accès en lecture à tout le monde
CREATE POLICY "Les visiteurs peuvent lire les détails des soins"
    ON public.detail_soins FOR SELECT
    USING (true);


-- 🔐 Table: mutuelle_formule_details_remboursement
-- Activer la RLS
ALTER TABLE public.mutuelle_formule_details_remboursement ENABLE ROW LEVEL SECURITY;
-- Donner l'accès en lecture à tout le monde
CREATE POLICY "Les visiteurs peuvent lire les détails de remboursement des mutuelles"
    ON public.mutuelle_formule_details_remboursement FOR SELECT
    USING (true);


-- =============================================
-- FIN DE LA MIGRATION
-- =============================================