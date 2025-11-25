-- ============================================
-- Script d'insertion des soins
-- Colonnes: categorie_id, name, brss, detail
-- Note: type_brss est indiqué dans le detail (fixe ou moyen)
-- ============================================

-- Si la colonne type_brss n'existe pas, créez-la :
ALTER TABLE soins ADD COLUMN IF NOT EXISTS type_brss TEXT;

-- ============================================
-- Catégorie 1: Soins courants
-- ============================================

INSERT INTO soins (categorie_id, name, brss, detail) VALUES
(1, 'Consultation médecin généraliste', 30.00, 'Consultation chez un médecin généraliste. BRSS fixe'),
(1, 'Consultation médecin spécialiste (ophtalmologie)', 31.50, 'Consultation ophtalmologiste. BRSS fixe'),
(1, 'Consultation médecin spécialiste (gynécologie)', 37.00, 'Consultation gynécologue. BRSS fixe'),
(1, 'Consultation médecin spécialiste (autres)', 31.50, 'Autres spécialistes. BRSS moyen'),
(1, 'Consultation pédiatre', 35.00, 'Consultation pédiatre (2-6 ans). BRSS fixe'),
(1, 'Consultation / suivi par sage-femme', 30.00, 'Consultation sage-femme. BRSS moyen (26-35€)'),
(1, 'Consultation chirurgien-dentiste', 23.00, 'Consultation dentiste. BRSS fixe'),
(1, 'Soins infirmiers (injections, pansements…)', 10.00, 'Actes paramédicaux infirmiers. BRSS moyen (3,15-16,13€)'),
(1, 'Séances de kinésithérapie', 16.13, 'Kinésithérapie pour rééducation. BRSS fixe'),
(1, 'Séances d''orthophonie', 20.00, 'Rééducation orthophonique. BRSS fixe'),
(1, 'Séances d''orthoptie', 13.00, 'Rééducation orthoptique. BRSS moyen (10,10-15,60€)'),
(1, 'Séances de pédicure-podologue', 20.00, 'Soins podologiques. BRSS moyen (15-27€)');

-- ============================================
-- Catégorie 2: Hospitalisation
-- ============================================

INSERT INTO soins (categorie_id, name, brss, detail) VALUES
(2, 'Forfait journalier hospitalier', 20.00, 'Forfait journalier hospitalier. BRSS fixe'),
(2, 'Frais d''hospitalisation (séjour, bloc, examens…)', 3333.75, 'Frais hospitalisation complets. BRSS moyen'),
(2, 'Chambre particulière', 60.00, 'Chambre individuelle non prise en charge. BRSS moyen'),
(2, 'Honoraires chirurgien + anesthésiste', 500.00, 'Honoraires intervention chirurgicale. BRSS moyen (100-2000€)');

-- ============================================
-- Catégorie 3: Dentaire
-- ============================================

INSERT INTO soins (categorie_id, name, brss, detail) VALUES
(3, 'Soins dentaires conservateurs (caries, dévitalisation…)', 60.95, 'Soins conservateurs 3 faces ou plus. BRSS fixe'),
(3, 'Détartrage', 43.38, 'Détartrage professionnel. BRSS fixe'),
(3, 'Prothèses fixes 100% santé (couronne céramo-métallique)', 120.00, 'Couronne céramométallique sur incisive/canine/prémolaire. BRSS fixe'),
(3, 'Prothèses fixes 100% santé (couronne alliage)', 120.00, 'Couronne alliage non précieux. BRSS fixe'),
(3, 'Prothèses fixes hors 100% santé (bridge)', 279.50, 'Bridge (prothèse plurale). BRSS fixe'),
(3, 'Prothèses amovibles 100% santé', 365.50, 'Prothèse amovible complète bimaxillaire. BRSS fixe'),
(3, 'Prothèses amovibles hors 100% santé (châssis métallique)', 301.00, 'Prothèse amovible à châssis métallique. BRSS fixe'),
(3, 'Inlay / onlay', 100.00, 'Restauration dentaire incrusté. BRSS fixe'),
(3, 'Orthodontie enfant (< 16 ans)', 193.50, 'Traitement orthodontique (6 semestres max). BRSS fixe'),
(3, 'Réparations de prothèses amovibles', 301.00, 'Réparation prothèses amovibles. BRSS fixe'),
(3, 'Couronne hors panier C2S (céramométallique sur molaire)', 107.50, 'Couronne sur molaires hors panier C2S. BRSS fixe');

-- ============================================
-- Catégorie 4: Optique
-- ============================================

INSERT INTO soins (categorie_id, name, brss, detail) VALUES
(4, 'Équipement lunettes complet 100% santé', 78.00, 'Monture + 2 verres multifocaux classe A. BRSS fixe'),
(4, 'Verres hors 100% santé', 0.10, 'Verres hors panier (BRSS quasi nulle). BRSS fixe'),
(4, 'Monture hors 100% santé', 0.05, 'Monture hors panier (BRSS quasi nulle). BRSS fixe'),
(4, 'Prestation d''appairage de verres', 4.50, 'Appairage verres différents. BRSS fixe'),
(4, 'Lentilles de contact remboursées', 39.48, 'Lentilles (forfait annuel par œil). BRSS fixe');

-- ============================================
-- Catégorie 5: Appareillage & Audition
-- ============================================

INSERT INTO soins (categorie_id, name, brss, detail) VALUES
(5, 'Aides auditives 100% santé classe I (< 20 ans ou cécité)', 400.00, 'Aide auditive classe I jeune/cécité. BRSS fixe'),
(5, 'Aides auditives 100% santé classe I (> 20 ans)', 400.00, 'Aide auditive classe I adulte. BRSS fixe'),
(5, 'Aides auditives hors 100% santé (classe II)', 400.00, 'Aide auditive classe II. BRSS fixe'),
(5, 'Piles pour aides auditives', 1.50, 'Piles sans mercure (max 10/an). BRSS fixe'),
(5, 'Matelas / surmatelas anti-escarres', 276.84, 'Dispositifs anti-escarres. BRSS fixe'),
(5, 'Dispositifs pour insulinothérapie (pompes, matériel)', 390.91, 'Matériel diabète (pompes, lecteurs). BRSS fixe'),
(5, 'Orthopédie simple (attelles, béquilles, etc.)', 24.40, 'Dispositifs orthopédiques simples. BRSS fixe');

-- ============================================
-- Catégorie 6: Maternité / Naissance
-- ============================================

INSERT INTO soins (categorie_id, name, brss, detail) VALUES
(6, 'Consultations de suivi de grossesse & échographies', 60.00, 'Consultations prénatales et échographies. BRSS moyen (35-82€)'),
(6, 'Accouchement (honoraires accoucheur / sage-femme)', 319.50, 'Honoraires accouchement voie basse. BRSS moyen'),
(6, 'Séjour en maternité', 1500.00, 'Frais séjour maternité. BRSS moyen'),
(6, 'Anesthésie péridurale', 150.00, 'Péridurale lors accouchement. BRSS moyen'),
(6, 'Suivi post-partum mère / nouveau-né', 100.00, 'Soins post-accouchement. BRSS moyen');

-- ============================================
-- Catégorie 7: Psychologie & Médecines douces
-- ============================================

INSERT INTO soins (categorie_id, name, brss, detail) VALUES
(7, 'Séances « Mon soutien psy »', 50.00, 'Psychologie remboursée (12 séances/an). BRSS fixe'),
(7, 'Consultations psychologue libéral (hors dispositif MSS)', 60.00, 'Psychologue libéral hors dispositif. Non remboursé. BRSS moyen'),
(7, 'Séances d''ostéopathie', 60.00, 'Ostéopathie non remboursée. BRSS moyen'),
(7, 'Séances de chiropractie', 50.00, 'Chiropractie non remboursée. BRSS moyen'),
(7, 'Séances d''acupuncture', 40.00, 'Acupuncture non remboursée (sauf médicale). BRSS moyen'),
(7, 'Autres médecines douces (sophrologie, hypnose, etc.)', 60.00, 'Autres médecines douces non remboursées. BRSS moyen');

-- ============================================
-- Catégorie 8: Prévention & Divers
-- ============================================

INSERT INTO soins (categorie_id, name, brss, detail) VALUES
(8, 'Médicaments à SMR majeur / important', 30.00, 'Médicaments SMR majeur/important. BRSS moyen (prix réel variable)'),
(8, 'Médicaments à SMR modéré', 10.00, 'Médicaments SMR modéré. BRSS moyen (prix réel variable)'),
(8, 'Médicaments à SMR faible', 5.00, 'Médicaments SMR faible. BRSS moyen (prix réel variable)'),
(8, 'Médicaments pris en charge à 100% (ALD, coûteux)', 200.00, 'Médicaments irremplaçables et coûteux. BRSS moyen (prix réel variable)'),
(8, 'Patchs nicotiniques', 23.00, 'Substituts nicotiniques patchs. BRSS moyen'),
(8, 'Gommes / pastilles / autres substituts nicotiniques', 22.00, 'Substituts nicotiniques autres formes. BRSS moyen'),
(8, 'Analyses de biologie (actes B)', 20.00, 'Analyses biologie médicale. BRSS moyen (0,27-50€)'),
(8, 'Anatomopathologie / cytologie (actes P)', 150.00, 'Examens anatomopathologiques. BRSS moyen (50-252€)'),
(8, 'Dépistage VIH / hépatite pris en charge à 100%', 11.34, 'Tests dépistage VIH/hépatites. BRSS fixe'),
(8, 'Cure thermale libre - Honoraires médicaux', 80.00, 'Forfait surveillance médicale cure. BRSS fixe'),
(8, 'Cure thermale libre - Frais d''hydrothérapie', 482.97, 'Frais hydrothérapie cure. BRSS fixe'),
(8, 'Cure thermale avec hospitalisation', 1500.00, 'Cure avec hospitalisation. BRSS moyen'),
(8, 'Vaccinations et actes de prévention', 25.00, 'Vaccinations et prévention. BRSS moyen');

-- ============================================
-- Catégorie 9: Transports médicaux
-- ============================================

INSERT INTO soins (categorie_id, name, brss, detail) VALUES
(9, 'Transport sanitaire (ambulance / VSL / taxi conventionné)', 53.34, 'Transport médicalisé sur prescription. BRSS moyen'),
(9, 'Transport lié aux cures thermales', 100.00, 'Transport cure thermale. BRSS moyen');

-- ============================================
-- Fin du script
-- Total: 73 soins
-- ============================================