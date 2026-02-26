-- 1. Autoriser NULL dans les colonnes de taux
ALTER TABLE mutuelle_remboursements
ALTER COLUMN taux_mutuelle_conventionne DROP NOT NULL;

ALTER TABLE mutuelle_remboursements
ALTER COLUMN taux_mutuelle_non_conventionne DROP NOT NULL;

-- 2. Ajouter la colonne type pour indiquer le mode de calcul
ALTER TABLE mutuelle_remboursements
ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'pourcentage';

-- 3. Ajouter des colonnes pour les forfaits
ALTER TABLE mutuelle_remboursements
ADD COLUMN IF NOT EXISTS forfait_conventionne NUMERIC(10,2),
ADD COLUMN IF NOT EXISTS forfait_non_conventionne NUMERIC(10,2);

-- 4. Ajouter une contrainte pour valider le type
ALTER TABLE mutuelle_remboursements
ADD CONSTRAINT check_type_remboursement
CHECK (type IN ('pourcentage', 'forfait', 'forfait_annuel'));