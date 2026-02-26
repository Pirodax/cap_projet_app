-- =============================================
-- 0️⃣  Nettoyage : suppression des anciennes tables
-- =============================================
DROP TABLE IF EXISTS public.mutuelle_formule_categories_details CASCADE;
DROP TABLE IF EXISTS public.regime_assurance_maladie_categorie_details CASCADE;
DROP TABLE IF EXISTS public.detail_soins CASCADE;

-- =============================================
-- 1️⃣  Création du type ENUM pour le remboursement
-- =============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'type_remboursement') THEN
        CREATE TYPE public.type_remboursement AS ENUM ('pourcentage', 'euro');
    END IF;
END$$;

-- =============================================
-- 2️⃣  TABLE DETAIL_SOIN (référence commune)
-- =============================================
CREATE TABLE public.detail_soins (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,                  -- Nom du soin (consultation, implant, etc.)
    brss NUMERIC(10,2) NOT NULL,         -- Base de remboursement (tarif de référence)
    detail TEXT                          -- Détails ou description
);

-- =============================================
-- 3️⃣  TABLE MUTUELLE_FORMULE_CATEGORIES_DETAILS
-- =============================================
CREATE TABLE public.mutuelle_formule_categories_details (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    mutuelle_formule_categories_id BIGINT NOT NULL  -- MODIFIÉ ICI : UUID -> BIGINT
      REFERENCES public.mutuelle_formule_categories(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    detail_soins_id UUID NOT NULL
        REFERENCES public.detail_soins(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    taux_mutuelle NUMERIC(10,2) NOT NULL,           -- Taux ou montant remboursé
    type public.type_remboursement NOT NULL,        -- pourcentage ou euro
    nbr_max INTEGER                                -- nombre max (ex. 3 séances / an)
);

-- =============================================
-- 4️⃣  TABLE REGIME_ASSURANCE_MALADIE_CATEGORIE_DETAILS
-- =============================================
CREATE TABLE public.regime_assurance_maladie_categorie_details (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    regime_assurance_maladie_categories_id BIGINT NOT NULL
        REFERENCES public.regime_assurance_maladie_categories(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    detail_soins_id UUID NOT NULL
        REFERENCES public.detail_soins(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    taux_secu NUMERIC(10,2) NOT NULL,              -- Taux de remboursement sécu (% BRSS)
    nbr_max INTEGER                                -- nombre max (ex. 2 par an)
);
