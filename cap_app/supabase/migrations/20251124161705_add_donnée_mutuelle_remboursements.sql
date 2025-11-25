-- ============================================
-- Script d'insertion des remboursements Alan Option 2 (VERSION COMPLÈTE)
-- Formule ID: 2
-- Soins ID: 71 à 135
-- Avec types de remboursement: pourcentage, forfait, forfait_annuel
-- ============================================

-- ============================================
-- Catégorie 1: Soins courants (soins_id 71-82)
-- ============================================

-- Consultations médicales - TYPE: pourcentage
INSERT INTO mutuelle_remboursements (formule_id, soins_id, type, taux_mutuelle_conventionne, taux_mutuelle_non_conventionne, forfait_conventionne, forfait_non_conventionne, nbr_max, detail) VALUES
(2, 71, 'pourcentage', 110.00, 90.00, NULL, NULL, NULL, 'Consultation généraliste - Conv: 180% BRSS | Non-conv: 160% BRSS'),
(2, 72, 'pourcentage', 130.00, 110.00, NULL, NULL, NULL, 'Consultation spécialiste ophtalmologie - Conv: 200% | Non-conv: 180%'),
(2, 73, 'pourcentage', 130.00, 110.00, NULL, NULL, NULL, 'Consultation spécialiste gynécologie - Conv: 200% | Non-conv: 180%'),
(2, 74, 'pourcentage', 130.00, 110.00, NULL, NULL, NULL, 'Consultation autres spécialistes - Conv: 200% | Non-conv: 180%'),
(2, 75, 'pourcentage', 130.00, 110.00, NULL, NULL, NULL, 'Consultation pédiatre - Conv: 200% | Non-conv: 180%'),
(2, 76, 'pourcentage', 130.00, 110.00, NULL, NULL, NULL, 'Consultation sage-femme - Conv: 200% | Non-conv: 180%'),
(2, 77, 'pourcentage', 40.00, 40.00, NULL, NULL, NULL, 'Consultation dentiste - 100% BRSS (60% AMO + 40% mutuelle)');

-- Actes paramédicaux - TYPE: pourcentage
INSERT INTO mutuelle_remboursements (formule_id, soins_id, type, taux_mutuelle_conventionne, taux_mutuelle_non_conventionne, forfait_conventionne, forfait_non_conventionne, nbr_max, detail) VALUES
(2, 78, 'pourcentage', 70.00, 70.00, NULL, NULL, NULL, 'Soins infirmiers - 130% BRSS (60% AMO + 70% mutuelle)'),
(2, 79, 'pourcentage', 70.00, 70.00, NULL, NULL, NULL, 'Kinésithérapie - 130% BRSS'),
(2, 80, 'pourcentage', 70.00, 70.00, NULL, NULL, NULL, 'Orthophonie - 130% BRSS'),
(2, 81, 'pourcentage', 70.00, 70.00, NULL, NULL, NULL, 'Orthoptie - 130% BRSS'),
(2, 82, 'pourcentage', 70.00, 70.00, NULL, NULL, NULL, 'Pédicure-podologue - 130% BRSS');

-- ============================================
-- Catégorie 2: Hospitalisation (soins_id 83-86)
-- ============================================

INSERT INTO mutuelle_remboursements (formule_id, soins_id, type, taux_mutuelle_conventionne, taux_mutuelle_non_conventionne, forfait_conventionne, forfait_non_conventionne, nbr_max, detail) VALUES
(2, 83, 'forfait', NULL, NULL, 20.00, 20.00, NULL, 'Forfait journalier entièrement remboursé: 20€/jour (15€ en psychiatrie)'),
(2, 84, 'pourcentage', 70.00, 70.00, NULL, NULL, NULL, 'Frais de séjour - 150% BRSS (80% AMO + 70% mutuelle)'),
(2, 85, 'forfait', NULL, NULL, 60.00, 60.00, NULL, 'Chambre particulière - Court séjour: 60€/j | SSR: 45€/j | Psychiatrie: 55€/j | Ambulatoire: 30€/j'),
(2, 86, 'pourcentage', 120.00, 100.00, NULL, NULL, NULL, 'Honoraires chirurgien - Conv: 200% | Non-conv: 180%');

-- ============================================
-- Catégorie 3: Dentaire (soins_id 87-97)
-- ============================================

INSERT INTO mutuelle_remboursements (formule_id, soins_id, type, taux_mutuelle_conventionne, taux_mutuelle_non_conventionne, forfait_conventionne, forfait_non_conventionne, nbr_max, detail) VALUES
(2, 87, 'pourcentage', 40.00, 40.00, NULL, NULL, NULL, 'Soins conservateurs - 100% BRSS'),
(2, 88, 'pourcentage', 40.00, 40.00, NULL, NULL, NULL, 'Détartrage - 100% BRSS'),
(2, 89, 'pourcentage', 40.00, 40.00, NULL, NULL, NULL, 'Couronne 100% santé céramo-métallique - Entièrement remboursée'),
(2, 90, 'pourcentage', 40.00, 40.00, NULL, NULL, NULL, 'Couronne 100% santé alliage - Entièrement remboursée'),
(2, 91, 'pourcentage', 370.00, 370.00, NULL, NULL, NULL, 'Bridge - 430% BRSS (60% AMO + 370% mutuelle)'),
(2, 92, 'pourcentage', 40.00, 40.00, NULL, NULL, NULL, 'Prothèse amovible 100% santé - Entièrement remboursée'),
(2, 93, 'pourcentage', 370.00, 370.00, NULL, NULL, NULL, 'Prothèse amovible hors 100% santé - 430% BRSS'),
(2, 94, 'pourcentage', 160.00, 160.00, NULL, NULL, NULL, 'Inlay/Onlay - 220% BRSS (60% AMO + 160% mutuelle)'),
(2, 95, 'pourcentage', 250.00, 250.00, NULL, NULL, NULL, 'Orthodontie enfant - 350% BRSS (100% AMO + 250% mutuelle)'),
(2, 96, 'pourcentage', 370.00, 370.00, NULL, NULL, NULL, 'Réparations prothèses - 430% BRSS'),
(2, 97, 'pourcentage', 370.00, 370.00, NULL, NULL, NULL, 'Couronne hors panier - 430% BRSS');

-- ============================================
-- Catégorie 4: Optique (soins_id 98-102)
-- ============================================

INSERT INTO mutuelle_remboursements (formule_id, soins_id, type, taux_mutuelle_conventionne, taux_mutuelle_non_conventionne, forfait_conventionne, forfait_non_conventionne, nbr_max, detail) VALUES
-- Lunettes 100% santé: pourcentage (entièrement remboursées)
(2, 98, 'pourcentage', 40.00, 40.00, NULL, NULL, NULL, 'Lunettes 100% santé - Entièrement remboursées | Tous les 2 ans (1 an si <16 ans)'),

-- Verres hors 100% santé: forfait selon complexité
(2, 99, 'forfait', NULL, NULL, 600.00, 600.00, NULL, 'Verres hors 100% santé - Forfait 400-700€ selon complexité (verres simples: 400€, complexes: 600€, très complexes: 700€) dont 100€ monture'),
(2, 100, 'forfait', NULL, NULL, 100.00, 100.00, NULL, 'Monture hors 100% santé - Incluse dans forfait verres (100€)'),
(2, 101, 'pourcentage', 40.00, 40.00, NULL, NULL, NULL, 'Prestation appairage - 100% BRSS'),

-- Lentilles: pourcentage + forfait annuel
(2, 102, 'forfait_annuel', 40.00, 40.00, 150.00, 150.00, NULL, 'Lentilles - 100% BRSS + forfait 150€/an');

-- ============================================
-- Catégorie 5: Appareillage & Audition (soins_id 103-109)
-- ============================================

INSERT INTO mutuelle_remboursements (formule_id, soins_id, type, taux_mutuelle_conventionne, taux_mutuelle_non_conventionne, forfait_conventionne, forfait_non_conventionne, nbr_max, detail) VALUES
-- Aides auditives: pourcentage (100% santé) ou forfait (hors 100% santé)
(2, 103, 'forfait', 40.00, 40.00, 1600.00, 1600.00, NULL, 'Aides auditives <20 ans - 100% santé: entièrement remboursé | Hors 100%: 1600€/oreille/4ans'),
(2, 104, 'forfait', 40.00, 40.00, 1300.00, 1300.00, NULL, 'Aides auditives >20 ans - 100% santé: entièrement remboursé | Hors 100%: 1300€/oreille/4ans'),
(2, 105, 'forfait', NULL, NULL, 1300.00, 1300.00, NULL, 'Aides auditives hors 100% santé - Forfait 1300€/oreille/4ans'),

(2, 106, 'pourcentage', 65.00, 65.00, NULL, NULL, NULL, 'Piles aides auditives - 125% BRSS (60% AMO + 65% mutuelle)'),
(2, 107, 'pourcentage', 140.00, 140.00, NULL, NULL, NULL, 'Matelas anti-escarres - 200% BRSS (60% AMO + 140% mutuelle)'),
(2, 108, 'pourcentage', 140.00, 140.00, NULL, NULL, NULL, 'Dispositifs insulinothérapie - 200% BRSS'),
(2, 109, 'pourcentage', 140.00, 140.00, NULL, NULL, NULL, 'Orthopédie simple - 200% BRSS');

-- ============================================
-- Catégorie 6: Maternité / Naissance (soins_id 110-114)
-- ============================================

INSERT INTO mutuelle_remboursements (formule_id, soins_id, type, taux_mutuelle_conventionne, taux_mutuelle_non_conventionne, forfait_conventionne, forfait_non_conventionne, nbr_max, detail) VALUES
(2, 110, 'pourcentage', 130.00, 110.00, NULL, NULL, NULL, 'Consultations grossesse - Conv: 200% | Non-conv: 180%'),
(2, 111, 'pourcentage', 100.00, 80.00, NULL, NULL, NULL, 'Honoraires accouchement - Conv: 200% | Non-conv: 180%'),
(2, 112, 'pourcentage', 70.00, 70.00, NULL, NULL, NULL, 'Séjour maternité - 150% BRSS'),
(2, 113, 'pourcentage', 100.00, 80.00, NULL, NULL, NULL, 'Anesthésie péridurale - Conv: 200% | Non-conv: 180%'),
(2, 114, 'pourcentage', 100.00, 80.00, NULL, NULL, NULL, 'Suivi post-partum - Conv: 200% | Non-conv: 180%');

-- ============================================
-- Catégorie 7: Psychologie & Médecines douces (soins_id 115-120)
-- ============================================

INSERT INTO mutuelle_remboursements (formule_id, soins_id, type, taux_mutuelle_conventionne, taux_mutuelle_non_conventionne, forfait_conventionne, forfait_non_conventionne, nbr_max, detail) VALUES
-- Psychologie remboursée Sécu: pourcentage
(2, 115, 'pourcentage', 40.00, 40.00, NULL, NULL, 12, 'Mon soutien psy - 100% BRSS | 12 séances/an remboursées'),

-- Psychologie non remboursée: forfait
(2, 116, 'forfait', NULL, NULL, 40.00, 40.00, 6, 'Psychologue libéral - Forfait 40€/séance | Max 6 séances/an'),

-- Médecines douces: forfait 50€/séance, 5x/an
(2, 117, 'forfait', NULL, NULL, 50.00, 50.00, 5, 'Ostéopathie - Forfait 50€/séance | Max 5 séances/an'),
(2, 118, 'forfait', NULL, NULL, 50.00, 50.00, 5, 'Chiropractie - Forfait 50€/séance | Max 5 séances/an'),
(2, 119, 'forfait', NULL, NULL, 50.00, 50.00, 5, 'Acupuncture - Forfait 50€/séance | Max 5 séances/an'),
(2, 120, 'forfait', NULL, NULL, 50.00, 50.00, 5, 'Autres médecines douces - Forfait 50€/séance | Max 5 séances/an');

-- ============================================
-- Catégorie 8: Prévention & Divers (soins_id 121-133)
-- ============================================

INSERT INTO mutuelle_remboursements (formule_id, soins_id, type, taux_mutuelle_conventionne, taux_mutuelle_non_conventionne, forfait_conventionne, forfait_non_conventionne, nbr_max, detail) VALUES
-- Médicaments: pourcentage
(2, 121, 'pourcentage', 35.00, 35.00, NULL, NULL, NULL, 'Médicaments SMR majeur - 100% (65% AMO + 35% mutuelle)'),
(2, 122, 'pourcentage', 70.00, 70.00, NULL, NULL, NULL, 'Médicaments SMR modéré - 100% (30% AMO + 70% mutuelle)'),
(2, 123, 'pourcentage', 85.00, 85.00, NULL, NULL, NULL, 'Médicaments SMR faible - 100% (15% AMO + 85% mutuelle)'),
(2, 124, 'pourcentage', 0.00, 0.00, NULL, NULL, NULL, 'Médicaments ALD - 100% par AMO (mutuelle: 0%)'),

-- Substituts nicotiniques: pourcentage
(2, 125, 'pourcentage', 35.00, 35.00, NULL, NULL, NULL, 'Patchs nicotiniques - 100% (65% AMO + 35% mutuelle)'),
(2, 126, 'pourcentage', 35.00, 35.00, NULL, NULL, NULL, 'Gommes nicotiniques - 100% (65% AMO + 35% mutuelle)'),

-- Biologie: pourcentage
(2, 127, 'pourcentage', 40.00, 40.00, NULL, NULL, NULL, 'Analyses biologie - 100% (60% AMO + 40% mutuelle)'),
(2, 128, 'pourcentage', 30.00, 30.00, NULL, NULL, NULL, 'Anatomopathologie - 100% (70% AMO + 30% mutuelle)'),
(2, 129, 'pourcentage', 0.00, 0.00, NULL, NULL, NULL, 'Dépistage VIH/Hépatite - 100% par AMO'),

-- Cures thermales: pourcentage + forfait annuel
(2, 130, 'forfait_annuel', 30.00, 30.00, 100.00, 100.00, NULL, 'Honoraires cure thermale - 100% BRSS + 100€/an'),
(2, 131, 'forfait_annuel', 35.00, 35.00, 100.00, 100.00, NULL, 'Frais hydrothérapie - 100% BRSS + 100€/an'),
(2, 132, 'forfait_annuel', 20.00, 20.00, 100.00, 100.00, NULL, 'Cure avec hospitalisation - 100% BRSS + 100€/an'),

-- Prévention: pourcentage
(2, 133, 'pourcentage', 40.00, 40.00, NULL, NULL, NULL, 'Vaccinations et prévention - 100% (60% AMO + 40% mutuelle)');

-- ============================================
-- Catégorie 9: Transports médicaux (soins_id 134-135)
-- ============================================

INSERT INTO mutuelle_remboursements (formule_id, soins_id, type, taux_mutuelle_conventionne, taux_mutuelle_non_conventionne, forfait_conventionne, forfait_non_conventionne, nbr_max, detail) VALUES
(2, 134, 'pourcentage', 35.00, 35.00, NULL, NULL, NULL, 'Transport sanitaire - 100% (65% AMO + 35% mutuelle) sur prescription'),
(2, 135, 'pourcentage', 35.00, 35.00, NULL, NULL, NULL, 'Transport cure thermale - 100%');

-- ============================================
-- Fin du script
-- Total: 65 remboursements configurés
-- ============================================

-- GUIDE D'UTILISATION DES TYPES:
--
-- 1. TYPE 'pourcentage':
--    remboursement = BRSS × (taux_mutuelle / 100)
--    Exemple: Consultation spé à 50€, BRSS=31.50€, taux=130%
--    → remboursement mutuelle = 31.50 × 1.30 = 40.95€
--
-- 2. TYPE 'forfait':
--    remboursement = forfait (si nbr_max défini, limité par an/période)
--    Exemple: Ostéopathie, forfait=50€, nbr_max=5
--    → remboursement = 50€/séance (max 5 séances/an)
--
-- 3. TYPE 'forfait_annuel':
--    remboursement = (BRSS × taux) + forfait
--    Exemple: Lentilles, BRSS=39.48€, taux=40%, forfait=150€
--    → remboursement = (39.48 × 0.40) + 150 = 165.79€/an