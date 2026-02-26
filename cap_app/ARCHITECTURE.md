
# Dossier d Architecture Technique - HealthCare App

## 1. Description du Projet

### 1.1 Objectif
HealthCare App (ou "Cap Projet App") est une application mobile de mutuelle sante moderne. Elle a pour but de simplifier la gestion des remboursements pour les adherents et de fournir des outils de simulation de frais de sante clairs et precis.

### 1.2 Perimtre Fonctionnel Actuel
*   **Authentification** : Inscription et Connexion securisees via email/mot de passe (Supabase Auth).
*   **Accueil** : Tableau de bord affichant les categories de soins disponibles et les actualites de la mutuelle.
*   **Consultation des Tarifs** : Navigation dans les categories (Dentaire, Optique, Genraliste...) pour consulter les tarifs de base (BRSS).
*   **Simulateur & Historique** : Interface de suivi des demandes de remboursement et estimations de reste a charge (Note : Donnees simulees actuellement).
*   **Profil Utilisateur** : Gestion des informations personnelles et deconnexion.

## 2. Architecture Technique

### 2.1 Stack Technologique
*   **Frontend** : Flutter (version 3.x), langage Dart.
*   **Architecture Pattern** : Feature-First / Clean Architecture simplifiee.
*   **Backend** : Supabase (Backend-as-a-Service).
    *   Auth : Gestion utilisateurs.
    *   Database : PostgreSQL.
*   **Tests** : Flutter Test (Unit & Widget), Mocktail.

### 2.2 Structure du Code
Le projet suit une structure modulaire pour faciliter la maintenance et l evolution.

- **lib/**
  - **core/** : Elements transverses
    - *supabase/* : Configuration et initialisation du client Supabase.
  - **features/** : Decoupage par fonctionnalite metier
    - *auth/* : Ecrans de Login, Register, Logique de session.
    - *History/* : Ecrans d historique et logique de simulation.
  - **screens/** : Ecrans principaux de l application
    - *home_screen.dart* : Page d accueil.
    - *profile_screen.dart* : Page de profil.
    - *category_details_screen.dart* : Affichage des listes de soins.
  - **services/** : Couche d intercation avec les donnees (Repository pattern simplifie)
    - *category_service.dart* : Appels API pour les categories et soins.
    - *profile_service.dart* : Gestion des profils utilisateurs.
  - **widgets/** : Composants graphiques reutilisables (Boutons, Barres de recherche, etc.).

## 3. Modele de Donnees

### 3.1 Base de Donnees (Supabase / PostgreSQL)
L application s appuie sur un schema relationnel.

*   **Table `categories_soins`**
    *   `id` : Identifiant unique.
    *   `name` : Nom de la categorie (ex: Dentaire).
    *   `icon` : Emoji ou icone representative.
    *   `created_at` : Date de creation.

*   **Table `soins`**
    *   `id` : Identifiant unique.
    *   `categorie_id` : Cle etrangere vers la categorie.
    *   `name` : Libelle du soin (ex: Detartrage).
    *   `brss` : Base de Remboursement Securite Sociale (Montant en euros).
    *   `detail` : Description complementaire.

*   **Table `users_public`** (Extension de la table auth.users)
    *   Permet de stocker les informations metier liees a l utilisateur (Nom, Prenom, Num Secu, etc.).

## 4. Strategie de Tests

Le projet met un accent fort sur la qualite logicielle avec un taux de couverture de code de **plus de 95%**.

### 4.1 Types de Tests
*   **Tests Unitaires** : Verification des Services et de la logique metier isolee (mock des appels Reseau).
*   **Tests de Widgets** : Verification du rendu graphique (UI) et des interactions utilisateurs (Tap, Scroll).
    *   Test des etats de chargement (Loading).
    *   Test des etats d erreur.
    *   Test d affichage des listes.

### 4.2 Outils
*   `flutter_test` : Framework standard.
*   `mocktail` : Pour simuler les dependances (SupabaseClient, Services) et eviter les tests fragiles lies au reseau.

## 5. Securite

*   **Authentification** : Gestion par Token JWT via Supabase Auth.
*   **Secrets** : Les cles d API (Anon Key) peuvent etre injectees via `--dart-define` lors de la compilation pour ne pas etre exposees en dur dans le code source.
*   **Protection des Donnees** : Utilisation de Row Level Security (RLS) cote Supabase pour s assurer que chaque utilisateur n accede qu a ses propres donnees.

## 6. Evolutions Futures
*   **Connexion Historique** : Connecter l ecran Historique a une table `simulations` reelle.
*   **Notifications** : Ajout de Push Notifications pour le suivi des remboursements.
*   **Mode Offline** : Mise en place de cache local pour consultatin hors-ligne.

