-- ===================================================================
-- 🔐 USER_INFOS : Accès restreint à l'utilisateur propriétaire
-- ===================================================================

ALTER TABLE public.user_infos ENABLE ROW LEVEL SECURITY;

-- Lire uniquement son propre profil
CREATE POLICY "Allow user to view own profile"
ON public.user_infos
FOR SELECT
USING (auth.uid() = user_id);

-- Mettre à jour uniquement son propre profil
CREATE POLICY "Allow user to update own profile"
ON public.user_infos
FOR UPDATE
USING (auth.uid() = user_id);

-- Créer uniquement son propre profil
CREATE POLICY "Allow user to insert own profile"
ON public.user_infos
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- ===================================================================
-- 🌍 MITUELLES : Table publique en lecture seule
-- ===================================================================

ALTER TABLE public.mituelles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to mituelles"
ON public.mituelles
FOR SELECT
USING (true);

-- ===================================================================
-- 🌍 MITUELLE_FORMULES : Lecture publique
-- ===================================================================

ALTER TABLE public.mituelle_formules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to mituelle_formules"
ON public.mituelle_formules
FOR SELECT
USING (true);

-- ===================================================================
-- 🌍 MUTUELLE_FORMULE_CATEGORIES : Lecture publique
-- ===================================================================

ALTER TABLE public.mutuelle_formule_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to mutuelle_formule_categories"
ON public.mutuelle_formule_categories
FOR SELECT
USING (true);

-- ===================================================================
-- 🌍 MUTUELLE_FORMULE_CATEGORIES_DETAILS : Lecture publique
-- ===================================================================

ALTER TABLE public.mutuelle_formule_categories_details ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to mutuelle_formule_categories_details"
ON public.mutuelle_formule_categories_details
FOR SELECT
USING (true);

-- ===================================================================
-- 🌍 REGIME_ASSURANCE_MALADIES : Lecture publique
-- ===================================================================

ALTER TABLE public.regime_assurance_maladies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to regime_assurance_maladies"
ON public.regime_assurance_maladies
FOR SELECT
USING (true);

-- ===================================================================
-- 🌍 REGIME_ASSURANCE_MALADIE_CATEGORIES : Lecture publique
-- ===================================================================

ALTER TABLE public.regime_assurance_maladie_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to regime_assurance_maladie_categories"
ON public.regime_assurance_maladie_categories
FOR SELECT
USING (true);

-- ===================================================================
-- 🌍 REGIME_ASSURANCE_MALADIE_CATEGORIE_DETAILS : Lecture publique
-- ===================================================================

ALTER TABLE public.regime_assurance_maladie_categorie_details ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to regime_assurance_maladie_categorie_details"
ON public.regime_assurance_maladie_categorie_details
FOR SELECT
USING (true);
