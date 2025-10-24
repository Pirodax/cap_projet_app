-- =============================================
-- MIGRATION : CORRECTION ET LIAISON DE LA TABLE regime_assurance_maladie_details
-- =============================================
-- Ce script modifie une table existante pour la lier correctement à 'detail_soins'.

-- ÉTAPE 1: Corriger le type de la colonne pour correspondre à la clé primaire de 'detail_soins'.
-- On passe de UUID à BIGINT (int8).
ALTER TABLE public.regime_assurance_maladie_categorie_details
    ALTER COLUMN detail_soins_id TYPE BIGINT
    USING (detail_soins_id::text::bigint); -- Tente de convertir les valeurs existantes

-- Note: La clause USING est nécessaire si la table contient déjà des données.
-- Si la conversion échoue car les UUIDs ne sont pas convertibles,
-- vous devrez vider la colonne ou la table avant de changer le type:
-- UPDATE public.regime_assurance_maladie_details SET detail_soins_id = NULL; -- Option 1: vider la colonne
-- TRUNCATE public.regime_assurance_maladie_details; -- Option 2: vider la table


-- ÉTAPE 2: Ajouter la contrainte de clé étrangère pour créer le lien.
ALTER TABLE public.regime_assurance_maladie_categorie_details
    ADD CONSTRAINT fk_detail_soins
    FOREIGN KEY (detail_soins_id)
    REFERENCES public.detail_soins(id)
    ON DELETE CASCADE; -- Si un soin est supprimé, la ligne de remboursement associée l'est aussi.

-- =============================================
-- FIN DE LA MIGRATION
-- =============================================
