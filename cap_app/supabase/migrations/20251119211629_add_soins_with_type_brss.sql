-- ============================================
-- Script d'insertion des soins
-- Colonnes: categorie_id, name, brss, type_brss, detail
-- ============================================

-- Si la colonne type_brss n'existe pas, créez-la :
-- ALTER TABLE soins ADD COLUMN IF NOT EXISTS type_brss TEXT;

-- ============================================
-- Catégorie 1: Soins courants
-- ============================================

INSERT INTO soins (categorie_id, name, brss, type_brss, detail) VALUES
(1, 'Consultation médecin généraliste', 30.00, 'fixe', 'Consultation chez un médecin généraliste'),
(1, 'Consultation médecin spécialiste (ophtalmologie)', 31.50, 'fixe', 'Consultation ophtalmologiste'),
(1, 'Consultation médecin spécialiste (gynécologie)', 37.00, 'fixe', 'Consultation gynécologue'),
(1, 'Consultation médecin spécialiste (autres)', 31.50, 'moyen', 'Autres spécialistes'),
(1, 'Consultation pédiatre', 35.00, 'fixe', 'Consultation pédiatre (2-6 ans)'),
(1, 'Consultation / suivi par sage-femme', 30.00, 'moyen', 'Consultation sage-femme (fourchette 26-35€)'),
(1, 'Consultation chirurgien-dentiste', 23.00, 'fixe', 'Consultation dentiste'),
(1, 'Soins infirmiers (injections, pansements…)', 10.00, 'moyen', 'Actes paramédicaux infirmiers (fourchette 3,15-16,13€)'),
(1, 'Séances de kinésithérapie', 16.13, 'fixe', 'Kinésithérapie pour rééducation'),
(1, 'Séances d''orthophonie', 20.00, 'fixe', 'Rééducation orthophonique'),
(1, 'Séances d''orthoptie', 13.00, 'moyen', 'Rééducation orthoptique (fourchette 10,10-15,60€)'),
(1, 'Séances de pédicure-podologue', 20.00, 'moyen', 'Soins podologiques (fourchette 15-27€)');

-- ============================================
-- Catégorie 2: Hospitalisation
-- ============================================

INSERT INTO soins (categorie_id, name, brss, type_brss, detail) VALUES
(2, 'Forfait journalier hospitalier', 20.00, 'fixe', 'Forfait journalier hospitalier'),
(2, 'Frais d''hospitalisation (séjour, bloc, examens…)', 3333.75, 'moyen', 'Frais hospitalisation complets'),
(2, 'Chambre particulière', 60.00, 'moyen', 'Chambre individuelle non prise en charge'),
(2, 'Honoraires chirurgien + anesthésiste', 500.00, 'moyen', 'Honoraires intervention chirurgicale (fourchette 100-2000€)');

-- ============================================
-- Catégorie 3: Dentaire
-- ============================================

INSERT INTO soins (categorie_id, name, brss, type_brss, detail) VALUES
(3, 'Soins dentaires conservateurs (caries, dévitalisation…)', 60.95, 'fixe', 'Soins conservateurs 3 faces ou plus'),
(3, 'Détartrage', 43.38, 'fixe', 'Détartrage professionnel'),
(3, 'Prothèses fixes 100% santé (couronne céramo-métallique)', 120.00, 'fixe', 'Couronne céramométallique sur incisive/canine/prémolaire'),
(3, 'Prothèses fixes 100% santé (couronne alliage)', 120.00, 'fixe', 'Couronne alliage non précieux'),
(3, 'Prothèses fixes hors 100% santé (bridge)', 279.50, 'fixe', 'Bridge (prothèse plurale)'),
(3, 'Prothèses amovibles 100% santé', 365.50, 'fixe', 'Prothèse amovible complète bimaxillaire'),
(3, 'Prothèses amovibles hors 100% santé (châssis métallique)', 301.00, 'fixe', 'Prothèse amovible à châssis métallique'),
(3, 'Inlay / onlay', 100.00, 'fixe', 'Restauration dentaire incrusté'),
(3, 'Orthodontie enfant (< 16 ans)', 193.50, 'fixe', 'Traitement orthodontique (6 semestres max)'),
(3, 'Réparations de prothèses amovibles', 301.00, 'fixe', 'Réparation prothèses amovibles'),
(3, 'Couronne hors panier C2S (céramométallique sur molaire)', 107.50, 'fixe', 'Couronne sur molaires hors panier C2S');

-- ============================================
-- Catégorie 4: Optique
-- ============================================

INSERT INTO soins (categorie_id, name, brss, type_brss, detail) VALUES
(4, 'Équipement lunettes complet 100% santé', 78.00, 'fixe', 'Monture + 2 verres multifocaux classe A'),
(4, 'Verres hors 100% santé', 0.10, 'fixe', 'Verres hors panier (BRSS quasi nulle)'),
(4, 'Monture hors 100% santé', 0.05, 'fixe', 'Monture hors panier (BRSS quasi nulle)'),
(4, 'Prestation d''appairage de verres', 4.50, 'fixe', 'Appairage verres différents'),
(4, 'Lentilles de contact remboursées', 39.48, 'fixe', 'Lentilles (forfait annuel par œil)');

-- ============================================
-- Catégorie 5: Appareillage & Audition
-- ============================================

INSERT INTO soins (categorie_id, name, brss, type_brss, detail) VALUES
(5, 'Aides auditives 100% santé classe I (< 20 ans ou cécité)', 400.00, 'fixe', 'Aide auditive classe I jeune/cécité'),
(5, 'Aides auditives 100% santé classe I (> 20 ans)', 400.00, 'fixe', 'Aide auditive classe I adulte'),
(5, 'Aides auditives hors 100% santé (classe II)', 400.00, 'fixe', 'Aide auditive classe II'),
(5, 'Piles pour aides auditives', 1.50, 'fixe', 'Piles sans mercure (max 10/an)'),
(5, 'Matelas / surmatelas anti-escarres', 276.84, 'fixe', 'Dispositifs anti-escarres'),
(5, 'Dispositifs pour insulinothérapie (pompes, matériel)', 390.91, 'fixe', 'Matériel diabète (pompes, lecteurs)'),
(5, 'Orthopédie simple (attelles, béquilles, etc.)', 24.40, 'fixe', 'Dispositifs orthopédiques simples');

-- ============================================
-- Catégorie 6: Maternité / Naissance
-- ============================================

INSERT INTO soins (categorie_id, name, brss, type_brss, detail) VALUES
(6, 'Consultations de suivi de grossesse & échographies', 60.00, 'moyen', 'Consultations prénatales et échographies (fourchette 35-82€)'),
(6, 'Accouchement (honoraires accoucheur / sage-femme)', 319.50, 'moyen', 'Honoraires accouchement voie basse'),
(6, 'Séjour en maternité', 1500.00, 'moyen', 'Frais séjour maternité'),
(6, 'Anesthésie péridurale', 150.00, 'moyen', 'Péridurale lors accouchement'),
(6, 'Suivi post-partum mère / nouveau-né', 100.00, 'moyen', 'Soins post-accouchement');

-- ============================================
-- Catégorie 7: Psychologie & Médecines douces
-- ============================================

INSERT INTO soins (categorie_id, name, brss, type_brss, detail) VALUES
(7, 'Séances « Mon soutien psy »', 50.00, 'fixe', 'Psychologie remboursée (12 séances/an)'),
(7, 'Consultations psychologue libéral (hors dispositif MSS)', 60.00, 'moyen', 'Psychologue libéral hors dispositif. Non remboursé'),
(7, 'Séances d''ostéopathie', 60.00, 'moyen', 'Ostéopathie non remboursée'),
(7, 'Séances de chiropractie', 50.00, 'moyen', 'Chiropractie non remboursée'),
(7, 'Séances d''acupuncture', 40.00, 'moyen', 'Acupuncture non remboursée (sauf médicale)'),
(7, 'Autres médecines douces (sophrologie, hypnose, etc.)', 60.00, 'moyen', 'Autres médecines douces non remboursées');

-- ============================================
-- Catégorie 8: Prévention & Divers
-- ============================================

INSERT INTO soins (categorie_id, name, brss, type_brss, detail) VALUES
(8, 'Médicaments à SMR majeur / important', 30.00, 'moyen', 'Médicaments SMR majeur/important (prix réel variable)'),
(8, 'Médicaments à SMR modéré', 10.00, 'moyen', 'Médicaments SMR modéré (prix réel variable)'),
(8, 'Médicaments à SMR faible', 5.00, 'moyen', 'Médicaments SMR faible (prix réel variable)'),
(8, 'Médicaments pris en charge à 100% (ALD, coûteux)', 200.00, 'moyen', 'Médicaments irremplaçables et coûteux (prix réel variable)'),
(8, 'Patchs nicotiniques', 23.00, 'moyen', 'Substituts nicotiniques patchs'),
(8, 'Gommes / pastilles / autres substituts nicotiniques', 22.00, 'moyen', 'Substituts nicotiniques autres formes'),
(8, 'Analyses de biologie (actes B)', 20.00, 'moyen', 'Analyses biologie médicale (fourchette 0,27-50€)'),
(8, 'Anatomopathologie / cytologie (actes P)', 150.00, 'moyen', 'Examens anatomopathologiques (fourchette 50-252€)'),
(8, 'Dépistage VIH / hépatite pris en charge à 100%', 11.34, 'fixe', 'Tests dépistage VIH/hépatites'),
(8, 'Cure thermale libre - Honoraires médicaux', 80.00, 'fixe', 'Forfait surveillance médicale cure'),
(8, 'Cure thermale libre - Frais d''hydrothérapie', 482.97, 'fixe', 'Frais hydrothérapie cure'),
(8, 'Cure thermale avec hospitalisation', 1500.00, 'moyen', 'Cure avec hospitalisation'),
(8, 'Vaccinations et actes de prévention', 25.00, 'moyen', 'Vaccinations et prévention');

-- ============================================
-- Catégorie 9: Transports médicaux
-- ============================================

INSERT INTO soins (categorie_id, name, brss, type_brss, detail) VALUES
(9, 'Transport sanitaire (ambulance / VSL / taxi conventionné)', 53.34, 'moyen', 'Transport médicalisé sur prescription'),
(9, 'Transport lié aux cures thermales', 100.00, 'moyen', 'Transport cure thermale');

-- ============================================
-- Fin du script
-- Total: 73 soins avec colonne type_brss (fixe ou moyen)
-- ============================================