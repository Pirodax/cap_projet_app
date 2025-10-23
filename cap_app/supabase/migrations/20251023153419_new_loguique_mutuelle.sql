-- =============================================
-- 0️⃣ Nettoyage des anciennes structures
-- =============================================
-- On supprime les anciennes tables dans l'ordre de dépendance inverse
DROP TABLE IF EXISTS public.mutuelle_formule_categories_details CASCADE;
DROP TABLE IF EXISTS public.mutuelle_formule_categories CASCADE;
DROP TABLE IF EXISTS public.detail_soins CASCADE;
DROP TABLE IF EXISTS public.categories_soins CASCADE;

-- =============================================
-- 1️⃣ Création des tables de référence (Catégories et Détails des soins)
-- =============================================

-- Table des grandes catégories de soins
CREATE TABLE public.categories_soins (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE, -- Le nom doit être unique
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Table des détails de soins, MAINTENANT LIÉE À UNE CATÉGORIE
CREATE TABLE public.detail_soins (
    id BIGSERIAL PRIMARY KEY, -- Changé en BIGSERIAL pour la cohérence
    categorie_id BIGINT NOT NULL REFERENCES public.categories_soins(id) ON DELETE CASCADE, -- ✅ LIEN LOGIQUE AJOUTÉ
    name TEXT NOT NULL,                  -- Nom du soin (consultation, implant, etc.)
    brss NUMERIC(10,2) NOT NULL,         -- Base de remboursement (tarif de référence)
    detail TEXT                          -- Détails ou description (ex: "Conventionné secteur 1")
);

-- =============================================
-- 2️⃣ Insertion des données de référence
-- =============================================

-- Insertion des catégories
INSERT INTO public.categories_soins (name, icon) VALUES
('Soins courants', '🩹'),
('Hospitalisation', '🏥'),
('Dentaire', '🦷'),
('Optique', '👓'),
('Appareillage & Audition', '🦻'),
('Maternité / Naissance', '🤰'),
('Psychologie & Médecines douces', '🧘'),
('Prévention & Divers', '🌿'),
('Transports médicaux', '🚑');

-- Insertion de 5 exemples de soins pour la catégorie "Soins courants"
-- Pour obtenir le 'categorie_id', on fait une sous-requête sur la table categories_soins
INSERT INTO public.detail_soins (categorie_id, name, brss, detail) VALUES
((SELECT id FROM categories_soins WHERE name = 'Soins courants'), 'Consultation médecin généraliste', 26.50, 'Conventionné secteur 1 ou 2'),
((SELECT id FROM categories_soins WHERE name = 'Soins courants'), 'Consultation spécialiste', 31.50, 'Tarif pour un suivi régulier'),
((SELECT id FROM categories_soins WHERE name = 'Soins courants'), 'Actes techniques médicaux (ATM)', 69.12, 'Exemple pour un acte courant comme un ECG'),
((SELECT id FROM categories_soins WHERE name = 'Soins courants'), 'Analyses de biologie médicale', 18.90, 'Exemple pour une prise de sang standard'),
((SELECT id FROM categories_soins WHERE name = 'Soins courants'), 'Soins infirmiers', 16.75, 'Exemple pour des soins à domicile ou en cabinet');

-- =============================================
-- 3️⃣ Création de la table de liaison finale (Détails de remboursement par formule)
-- =============================================

-- Création du type ENUM s'il n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'type_remboursement') THEN
        CREATE TYPE public.type_remboursement AS ENUM ('pourcentage', 'euro');
    END IF;
END$$;

-- Cette table lie une FORMULE à un SOIN SPÉCIFIQUE et définit le remboursement.
-- Elle remplace les deux anciennes tables 'mutuelle_formule_categories' et 'mutuelle_formule_categories_details'
CREATE TABLE public.mutuelle_formule_details_remboursement (
    id BIGSERIAL PRIMARY KEY,
    -- ✅ LIEN DIRECT À LA FORMULE
    formule_id BIGINT NOT NULL REFERENCES public.mutuelle_formules(id) ON DELETE CASCADE,
    -- ✅ LIEN DIRECT AU DÉTAIL DU SOIN
    detail_soins_id BIGINT NOT NULL REFERENCES public.detail_soins(id) ON DELETE CASCADE,

    taux_mutuelle NUMERIC(10,2) NOT NULL, -- Taux ou montant remboursé par la mutuelle
    type public.type_remboursement NOT NULL, -- 'pourcentage' (de la BRSS) ou 'euro' (montant fixe)
    nbr_max INTEGER,                         -- Nombre max de remboursements par an (ex: 3 séances)

    -- Contrainte pour s'assurer qu'on ne définit pas deux fois le remboursement pour le même soin dans la même formule
    UNIQUE(formule_id, detail_soins_id)
);
