-- ===================================================================
-- TABLE: user_infos
-- Description : Contient les informations de profil des utilisateurs,
-- reliées à leur compte d’authentification Supabase.
-- ===================================================================

CREATE TABLE public.user_infos (
    id BIGSERIAL PRIMARY KEY,

    -- Référence à auth.users (table système Supabase)
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Informations de profil
    username TEXT NOT NULL,
    date_of_birth DATE,

    -- Références mutuelle / formule / régime
    mituelle_id BIGINT REFERENCES public.mituelles(id) ON DELETE SET NULL,
    mituelle_formule_id BIGINT REFERENCES public.mituelle_formules(id) ON DELETE SET NULL,
    regime_assurance_maladie_id BIGINT REFERENCES public.regime_assurance_maladies(id) ON DELETE SET NULL,

    -- Suivi de la dernière mise à jour
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ===================================================================
-- INDEXES
-- ===================================================================

CREATE INDEX idx_user_infos_user_id ON public.user_infos(user_id);
CREATE INDEX idx_user_infos_regime_id ON public.user_infos(regime_assurance_maladie_id);
CREATE INDEX idx_user_infos_mituelle_id ON public.user_infos(mituelle_id);

-- ===================================================================
-- CONTRAINTES
-- ===================================================================

-- Un utilisateur ne peut avoir qu’un seul profil
ALTER TABLE public.user_infos
ADD CONSTRAINT unique_user_profile UNIQUE (user_id);

-- ===================================================================
-- TRIGGER DE MISE À JOUR AUTOMATIQUE DE updated_at
-- ===================================================================

CREATE OR REPLACE FUNCTION public.update_user_infos_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_infos_timestamp
BEFORE UPDATE ON public.user_infos
FOR EACH ROW
EXECUTE FUNCTION public.update_user_infos_timestamp();

-- ===================================================================
-- COMMENTAIRES (facultatifs, utiles pour Supabase Studio)
-- ===================================================================

COMMENT ON TABLE public.user_infos IS 'Stocke les informations de profil utilisateur liées au compte Supabase.';
COMMENT ON COLUMN public.user_infos.user_id IS 'Référence à auth.users.id (Supabase Auth).';
COMMENT ON COLUMN public.user_infos.mituelle_id IS 'Référence à la mutuelle choisie.';
COMMENT ON COLUMN public.user_infos.mituelle_formule_id IS 'Référence à la formule spécifique de la mutuelle.';
COMMENT ON COLUMN public.user_infos.regime_assurance_maladie_id IS 'Référence au régime d’assurance maladie (régime général, MSA, étudiant, etc.).';
COMMENT ON COLUMN public.user_infos.updated_at IS 'Horodatage de la dernière mise à jour du profil.';
