-- ===================================================================
-- MITUELLES (mutuelles)
-- ===================================================================

CREATE TABLE public.mituelles (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ===================================================================
-- MITUELLE_FORMULES
-- ===================================================================

CREATE TABLE public.mituelle_formules (
  id BIGSERIAL PRIMARY KEY,
  mituelle_id BIGINT NOT NULL REFERENCES public.mituelles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Joindre/filtrer rapidement toutes les formules d’une mutuelle
CREATE INDEX idx_mituelle_formules_mituelle_id ON public.mituelle_formules(mituelle_id);

-- ===================================================================
-- MUTUELLE_FORMULE_CATEGORIES
-- ===================================================================

CREATE TABLE public.mutuelle_formule_categories (
  id BIGSERIAL PRIMARY KEY,
  formule_id BIGINT NOT NULL REFERENCES public.mituelle_formules(id) ON DELETE CASCADE,
  name TEXT NOT NULL,   -- ex: Consultation, Dentaire, Optique
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Accélère les requêtes "toutes les catégories pour une formule"
CREATE INDEX idx_mutuelle_formule_categories_formule_id
  ON public.mutuelle_formule_categories(formule_id);

-- ===================================================================
-- MUTUELLE_FORMULE_CATEGORIES_DETAILS
-- ===================================================================

CREATE TABLE public.mutuelle_formule_categories_details (
  id BIGSERIAL PRIMARY KEY,
  categories_id BIGINT NOT NULL REFERENCES public.mutuelle_formule_categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,             -- sous-catégorie (ex: Kinésithérapie)
  taux_remboursements TEXT,       -- ex: "70% BRSS", "200% BRSS"
  details TEXT,                   -- texte libre / précisions
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Accélère "tous les détails d'une catégorie"
CREATE INDEX idx_mutuelle_formule_categories_details_categories_id
  ON public.mutuelle_formule_categories_details(categories_id);

-- ===================================================================
-- REGIME_ASSURANCE_MALADIES
-- ===================================================================

CREATE TABLE public.regime_assurance_maladies (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,     -- ex: Régime général, MSA, Étudiant
  description TEXT,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ===================================================================
-- REGIME_ASSURANCE_MALADIE_CATEGORIES
-- ===================================================================

CREATE TABLE public.regime_assurance_maladie_categories (
  id BIGSERIAL PRIMARY KEY,
  regime_assurance_maladie_id BIGINT NOT NULL
      REFERENCES public.regime_assurance_maladies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,     -- ex: Consultation, Dentaire, Optique
  description TEXT,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Accélère "toutes les catégories pour un régime"
CREATE INDEX idx_regime_assurance_maladie_categories_regime_id
  ON public.regime_assurance_maladie_categories(regime_assurance_maladie_id);

-- ===================================================================
-- REGIME_ASSURANCE_MALADIE_CATEGORIE_DETAILS
-- ===================================================================

CREATE TABLE public.regime_assurance_maladie_categorie_details (
  id BIGSERIAL PRIMARY KEY,
  categorie_id BIGINT NOT NULL
      REFERENCES public.regime_assurance_maladie_categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,           -- sous-catégorie (ex: Kinésithérapie)
  taux_remboursements TEXT,     -- ex: "70% BRSS"
  details TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Accélère "tous les détails d'une catégorie de régime"
CREATE INDEX idx_regime_assurance_maladie_categorie_details_categorie_id
  ON public.regime_assurance_maladie_categorie_details(categorie_id);
