;-- ============================================
-- Script d'ajout de la colonne icon et mise à jour des icônes
-- IDs des soins: 71 à 135
-- ============================================

-- 1. Ajouter la colonne icon si elle n'existe pas
ALTER TABLE soins ADD COLUMN IF NOT EXISTS icon TEXT;

-- ============================================
-- 2. Mise à jour des icônes par soin
-- ============================================

-- ============================================
-- Catégorie 1: Soins courants (soins_id 71-82)
-- ============================================

-- Consultations médicales
UPDATE soins SET icon = '👨‍⚕️' WHERE id = 71;  -- Consultation médecin généraliste
UPDATE soins SET icon = '👁️' WHERE id = 72;   -- Consultation spécialiste (ophtalmologie)
UPDATE soins SET icon = '🩺' WHERE id = 73;   -- Consultation spécialiste (gynécologie)
UPDATE soins SET icon = '⚕️' WHERE id = 74;   -- Consultation spécialiste (autres)
UPDATE soins SET icon = '👶' WHERE id = 75;   -- Consultation pédiatre
UPDATE soins SET icon = '🤰' WHERE id = 76;   -- Consultation sage-femme
UPDATE soins SET icon = '🦷' WHERE id = 77;   -- Consultation chirurgien-dentiste

-- Actes paramédicaux
UPDATE soins SET icon = '💉' WHERE id = 78;   -- Soins infirmiers
UPDATE soins SET icon = '🏃' WHERE id = 79;   -- Kinésithérapie
UPDATE soins SET icon = '🗣️' WHERE id = 80;   -- Orthophonie
UPDATE soins SET icon = '👀' WHERE id = 81;   -- Orthoptie
UPDATE soins SET icon = '🦶' WHERE id = 82;   -- Pédicure-podologue

-- ============================================
-- Catégorie 2: Hospitalisation (soins_id 83-86)
-- ============================================

UPDATE soins SET icon = '🛏️' WHERE id = 83;   -- Forfait journalier hospitalier
UPDATE soins SET icon = '🏥' WHERE id = 84;   -- Frais d'hospitalisation
UPDATE soins SET icon = '🚪' WHERE id = 85;   -- Chambre particulière
UPDATE soins SET icon = '⚕️' WHERE id = 86;   -- Honoraires chirurgien + anesthésiste

-- ============================================
-- Catégorie 3: Dentaire (soins_id 87-97)
-- ============================================

UPDATE soins SET icon = '🦷' WHERE id = 87;   -- Soins dentaires conservateurs
UPDATE soins SET icon = '✨' WHERE id = 88;   -- Détartrage
UPDATE soins SET icon = '👑' WHERE id = 89;   -- Prothèses fixes 100% santé (couronne céramo-métallique)
UPDATE soins SET icon = '🔩' WHERE id = 90;   -- Prothèses fixes 100% santé (couronne alliage)
UPDATE soins SET icon = '🌉' WHERE id = 91;   -- Prothèses fixes hors 100% santé (bridge)
UPDATE soins SET icon = '🦴' WHERE id = 92;   -- Prothèses amovibles 100% santé
UPDATE soins SET icon = '⚙️' WHERE id = 93;   -- Prothèses amovibles hors 100% santé
UPDATE soins SET icon = '💎' WHERE id = 94;   -- Inlay / onlay
UPDATE soins SET icon = '😬' WHERE id = 95;   -- Orthodontie enfant (< 16 ans)
UPDATE soins SET icon = '🔧' WHERE id = 96;   -- Réparations de prothèses amovibles
UPDATE soins SET icon = '🏆' WHERE id = 97;   -- Couronne hors panier C2S

-- ============================================
-- Catégorie 4: Optique (soins_id 98-102)
-- ============================================

UPDATE soins SET icon = '👓' WHERE id = 98;   -- Équipement lunettes complet 100% santé
UPDATE soins SET icon = '🔍' WHERE id = 99;   -- Verres hors 100% santé
UPDATE soins SET icon = '🕶️' WHERE id = 100;  -- Monture hors 100% santé
UPDATE soins SET icon = '⚡' WHERE id = 101;  -- Prestation d'appairage de verres
UPDATE soins SET icon = '👁️‍🗨️' WHERE id = 102;  -- Lentilles de contact remboursées

-- ============================================
-- Catégorie 5: Appareillage & Audition (soins_id 103-109)
-- ============================================

UPDATE soins SET icon = '👂' WHERE id = 103;  -- Aides auditives 100% santé (< 20 ans ou cécité)
UPDATE soins SET icon = '🔊' WHERE id = 104;  -- Aides auditives 100% santé (> 20 ans)
UPDATE soins SET icon = '📢' WHERE id = 105;  -- Aides auditives hors 100% santé (classe II)
UPDATE soins SET icon = '🔋' WHERE id = 106;  -- Piles pour aides auditives
UPDATE soins SET icon = '🛏️' WHERE id = 107;  -- Matelas / surmatelas anti-escarres
UPDATE soins SET icon = '💊' WHERE id = 108;  -- Dispositifs pour insulinothérapie
UPDATE soins SET icon = '🩼' WHERE id = 109;  -- Orthopédie simple

-- ============================================
-- Catégorie 6: Maternité / Naissance (soins_id 110-114)
-- ============================================

UPDATE soins SET icon = '🤰' WHERE id = 110;  -- Consultations de suivi de grossesse & échographies
UPDATE soins SET icon = '👶' WHERE id = 111;  -- Accouchement (honoraires accoucheur / sage-femme)
UPDATE soins SET icon = '🏥' WHERE id = 112;  -- Séjour en maternité
UPDATE soins SET icon = '💉' WHERE id = 113;  -- Anesthésie péridurale
UPDATE soins SET icon = '👩‍👶' WHERE id = 114;  -- Suivi post-partum mère / nouveau-né

-- ============================================
-- Catégorie 7: Psychologie & Médecines douces (soins_id 115-120)
-- ============================================

UPDATE soins SET icon = '🧠' WHERE id = 115;  -- Séances « Mon soutien psy »
UPDATE soins SET icon = '💭' WHERE id = 116;  -- Consultations psychologue libéral
UPDATE soins SET icon = '🙌' WHERE id = 117;  -- Séances d'ostéopathie
UPDATE soins SET icon = '💆' WHERE id = 118;  -- Séances de chiropractie
UPDATE soins SET icon = '📍' WHERE id = 119;  -- Séances d'acupuncture
UPDATE soins SET icon = '🧘' WHERE id = 120;  -- Autres médecines douces

-- ============================================
-- Catégorie 8: Prévention & Divers (soins_id 121-133)
-- ============================================

-- Médicaments
UPDATE soins SET icon = '💊' WHERE id = 121;  -- Médicaments à SMR majeur / important
UPDATE soins SET icon = '💉' WHERE id = 122;  -- Médicaments à SMR modéré
UPDATE soins SET icon = '🩹' WHERE id = 123;  -- Médicaments à SMR faible
UPDATE soins SET icon = '💉' WHERE id = 124;  -- Médicaments pris en charge à 100% (ALD)

-- Substituts nicotiniques
UPDATE soins SET icon = '🚭' WHERE id = 125;  -- Patchs nicotiniques
UPDATE soins SET icon = '🍬' WHERE id = 126;  -- Gommes / pastilles substituts nicotiniques

-- Biologie
UPDATE soins SET icon = '🧪' WHERE id = 127;  -- Analyses de biologie (actes B)
UPDATE soins SET icon = '🔬' WHERE id = 128;  -- Anatomopathologie / cytologie (actes P)
UPDATE soins SET icon = '🩸' WHERE id = 129;  -- Dépistage VIH / hépatite

-- Cures thermales
UPDATE soins SET icon = '♨️' WHERE id = 130;  -- Cure thermale libre - Honoraires médicaux
UPDATE soins SET icon = '🌊' WHERE id = 131;  -- Cure thermale libre - Frais d'hydrothérapie
UPDATE soins SET icon = '🏨' WHERE id = 132;  -- Cure thermale avec hospitalisation

-- Prévention
UPDATE soins SET icon = '💉' WHERE id = 133;  -- Vaccinations et actes de prévention

-- ============================================
-- Catégorie 9: Transports médicaux (soins_id 134-135)
-- ============================================

UPDATE soins SET icon = '🚑' WHERE id = 134;  -- Transport sanitaire
UPDATE soins SET icon = '🚐' WHERE id = 135;  -- Transport lié aux cures thermales

-- ============================================
-- Fin du script
-- 65 soins avec icônes uniques par catégorie
-- ============================================