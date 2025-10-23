-- 🔐 Table: mutuelle_formule_details_remboursement
-- Activer la RLS
ALTER TABLE public.regime_assurance_maladie_categorie_details ENABLE ROW LEVEL SECURITY;
-- Donner l'accès en lecture à tout le monde
CREATE POLICY "Les visiteurs peuvent lire les détails de remboursement des regimes d'assurance maladie"
    ON public.regime_assurance_maladie_categorie_details FOR SELECT
    USING (true);