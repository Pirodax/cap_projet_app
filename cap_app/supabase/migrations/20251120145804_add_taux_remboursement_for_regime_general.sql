-- ============================================
-- Script d'insertion du régime général et des taux de remboursement
-- IDs des soins: 71 à 135
-- ============================================

-- ============================================
-- 1. Insertion du Régime Général
-- ============================================

INSERT INTO assurance_maladie_regimes (name, description, icon) VALUES
('Régime Général', 'Régime général de la Sécurité sociale (salariés, travailleurs indépendants, étudiants)', '🏥');

-- ============================================
-- 2. Taux de remboursement par soin
-- Structure: regimes_id, soins_id, taux_assurance_maladie,  nbr_max
-- ============================================

-- ============================================
-- Catégorie 1: Soins courants (soins_id 71-82)
-- ============================================

INSERT INTO assurance_maladie_remboursements (regimes_id, soins_id, taux_assurance_maladie,  nbr_max) VALUES
-- Consultations médicales
(8, 71, 70.00,  NULL),  -- Consultation médecin généraliste
(8, 72, 70.00,  NULL),  -- Consultation spécialiste (ophtalmologie)
(8, 73, 70.00,  NULL),  -- Consultation spécialiste (gynécologie)
(8, 74, 70.00,  NULL),  -- Consultation spécialiste (autres)
(8, 75, 70.00,  NULL),  -- Consultation pédiatre
(8, 76, 70.00,  NULL),  -- Consultation sage-femme
(8, 77, 60.00,  NULL),  -- Consultation chirurgien-dentiste

-- Actes paramédicaux
(8, 78, 60.00,  NULL),   -- Soins infirmiers
(8, 79, 60.00,  NULL),   -- Kinésithérapie
(8, 80, 60.00,  NULL),   -- Orthophonie
(8, 81, 60.00,  NULL),   -- Orthoptie
(8, 82, 60.00,  NULL);   -- Pédicure-podologue

-- ============================================
-- Catégorie 2: Hospitalisation (soins_id 83-86)
-- ============================================

INSERT INTO assurance_maladie_remboursements (regimes_id, soins_id, taux_assurance_maladie,  nbr_max) VALUES
(8, 83, 0.00,  NULL),   -- Forfait journalier (pris en charge par C2S uniquement)
(8, 84, 80.00,  NULL),  -- Frais d'hospitalisation
(8, 85, 0.00,  NULL),   -- Chambre particulière (non remboursé)
(8, 86, 80.00,  NULL);  -- Honoraires chirurgien + anesthésiste

-- ============================================
-- Catégorie 3: Dentaire (soins_id 87-97)
-- ============================================

INSERT INTO assurance_maladie_remboursements (regimes_id, soins_id, taux_assurance_maladie,  nbr_max) VALUES
(8, 87, 60.00,  NULL),   -- Soins dentaires conservateurs
(8, 88, 60.00,  NULL),   -- Détartrage
(8, 89, 60.00,  NULL),   -- Prothèses fixes 100% santé (couronne céramo-métallique)
(8, 90, 60.00,  NULL),   -- Prothèses fixes 100% santé (couronne alliage)
(8, 91, 60.00,  NULL),   -- Prothèses fixes hors 100% santé (bridge)
(8, 92, 60.00,  NULL),   -- Prothèses amovibles 100% santé
(8, 93, 60.00,  NULL),   -- Prothèses amovibles hors 100% santé
(8, 94, 60.00,  NULL),   -- Inlay / onlay
(8, 95, 100.00,  NULL),  -- Orthodontie enfant (< 16 ans)
(8, 96, 60.00,  NULL),   -- Réparations de prothèses amovibles
(8, 97, 60.00,  NULL);   -- Couronne hors panier C2S

-- ============================================
-- Catégorie 4: Optique (soins_id 98-102)
-- ============================================

INSERT INTO assurance_maladie_remboursements (regimes_id, soins_id, taux_assurance_maladie,  nbr_max) VALUES
(8, 98, 60.00,  NULL),   -- Équipement lunettes complet 100% santé
(8, 99, 60.00,  NULL),   -- Verres hors 100% santé
(8, 100, 60.00,  NULL),  -- Monture hors 100% santé
(8, 101, 60.00,  NULL),  -- Prestation d'appairage de verres
(8, 102, 60.00,  NULL);  -- Lentilles de contact remboursées

-- ============================================
-- Catégorie 5: Appareillage & Audition (soins_id 103-109)
-- ============================================

INSERT INTO assurance_maladie_remboursements (regimes_id, soins_id, taux_assurance_maladie,  nbr_max) VALUES
(8, 103, 60.00,  NULL),  -- Aides auditives 100% santé (< 20 ans ou cécité)
(8, 104, 60.00,  NULL),  -- Aides auditives 100% santé (> 20 ans)
(8, 105, 60.00,  NULL),  -- Aides auditives hors 100% santé (classe II)
(8, 106, 60.00,  NULL),  -- Piles pour aides auditives
(8, 107, 60.00,  NULL),  -- Matelas / surmatelas anti-escarres
(8, 108, 60.00,  NULL),  -- Dispositifs pour insulinothérapie
(8, 109, 60.00,  NULL);  -- Orthopédie simple

-- ============================================
-- Catégorie 6: Maternité / Naissance (soins_id 110-114)
-- ============================================

INSERT INTO assurance_maladie_remboursements (regimes_id, soins_id, taux_assurance_maladie,  nbr_max) VALUES
(8, 110, 70.00,  NULL),   -- Consultations de suivi de grossesse & échographies
(8, 111, 100.00,  NULL),  -- Accouchement (honoraires accoucheur / sage-femme)
(8, 112, 80.00,  NULL),   -- Séjour en maternité
(8, 113, 100.00,  NULL),  -- Anesthésie péridurale
(8, 114, 100.00,  NULL);  -- Suivi post-partum mère / nouveau-né

-- ============================================
-- Catégorie 7: Psychologie & Médecines douces (soins_id 115-120)
-- ============================================

INSERT INTO assurance_maladie_remboursements (regimes_id, soins_id, taux_assurance_maladie,  nbr_max) VALUES
(8, 115, 60.00,  12),     -- Séances « Mon soutien psy » (max 12 séances/an)
(8, 116, 0.00,  NULL),    -- Consultations psychologue libéral (non remboursé)
(8, 117, 0.00,  NULL),    -- Séances d'ostéopathie (non remboursé)
(8, 118, 0.00,  NULL),    -- Séances de chiropractie (non remboursé)
(8, 119, 0.00,  NULL),    -- Séances d'acupuncture (non remboursé)
(8, 120, 0.00,  NULL);    -- Autres médecines douces (non remboursé)

-- ============================================
-- Catégorie 8: Prévention & Divers (soins_id 121-133)
-- ============================================

INSERT INTO assurance_maladie_remboursements (regimes_id, soins_id, taux_assurance_maladie,  nbr_max) VALUES
-- Médicaments
(8, 121, 65.00,  NULL),   -- Médicaments à SMR majeur / important
(8, 122, 30.00,  NULL),   -- Médicaments à SMR modéré
(8, 123, 15.00,  NULL),   -- Médicaments à SMR faible
(8, 124, 100.00,  NULL),  -- Médicaments pris en charge à 100% (ALD)

-- Substituts nicotiniques
(8, 125, 65.00,  NULL),   -- Patchs nicotiniques
(8, 126, 65.00,  NULL),   -- Gommes / pastilles substituts nicotiniques

-- Biologie
(8, 127, 60.00,  NULL),   -- Analyses de biologie (actes B)
(8, 128, 70.00,  NULL),   -- Anatomopathologie / cytologie (actes P)
(8, 129, 100.00,  NULL),  -- Dépistage VIH / hépatite

-- Cures thermales
(8, 130, 70.00,  NULL),   -- Cure thermale libre - Honoraires médicaux
(8, 131, 65.00,  NULL),   -- Cure thermale libre - Frais d'hydrothérapie
(8, 132, 80.00,  NULL),   -- Cure thermale avec hospitalisation

-- Prévention
(8, 133, 60.00,  NULL);   -- Vaccinations et actes de prévention

-- ============================================
-- Catégorie 9: Transports médicaux (soins_id 134-135)
-- ============================================

INSERT INTO assurance_maladie_remboursements (regimes_id, soins_id, taux_assurance_maladie,  nbr_max) VALUES
(8, 134, 65.00,  NULL),   -- Transport sanitaire
(8, 135, 65.00,  NULL);   -- Transport lié aux cures thermales

-- ============================================
-- Fin du script
-- Régime: 1 (Régime Général)
-- Remboursements: 65 taux (IDs soins de 71 à 135)
-- ============================================