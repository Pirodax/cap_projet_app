# Mutuellia — Cap Projet App

Application Flutter de simulation de remboursements de soins medicaux.
Permet aux utilisateurs d'estimer les remboursements Securite sociale + mutuelle selon leur couverture.

## Stack technique

- **Frontend** : Flutter 3.27.4 (Web, Android, iOS, Windows, macOS, Linux)
- **Backend** : Supabase (PostgreSQL + Auth + Row Level Security)
- **Hosting** : Firebase Hosting (CDN, HTTPS, CI/CD)

## Installation

```bash
cd cap_app
flutter pub get
flutter run -d chrome
```

## Commandes utiles

```bash
flutter analyze          # Analyse statique du code
flutter test             # Tests unitaires
flutter build web        # Build web production
```

## Architecture

```
lib/
  app.dart                    # Routes, theme, MainPage (IndexedStack)
  core/supabase/              # Initialisation Supabase
  features/
    auth/screens/             # SignIn, SignUp
    Home/models/              # RemboursementInfo, RemboursementResult
    Home/services/            # RemboursementCalculator
    History/                  # HistoriquePage
  screens/                    # HomeScreen, ProfileScreen, SoinDetailScreen...
  services/                   # CategoryService, SimulationHistoryService, ProfileService
  widgets/                    # BottomNavBar, Search_Bar
```

## Base de donnees

9 tables PostgreSQL sur Supabase avec RLS :
- Tables de reference (soins, categories, mutuelles, formules, regimes) : lecture publique
- Tables utilisateur (user_infos, simulation_history) : acces restreint via `auth.uid() = user_id`

Voir [SQL_TABLE.md](../SQL_TABLE.md) et [RLS_POLICIES.md](../RLS_POLICIES.md) pour les details.

## CI/CD

2 workflows GitHub Actions :
- **Merge sur main** : build + tests + deploy Firebase Hosting (live)
- **Pull Request** : build + tests + deploy preview URL

## Docker

```bash
docker-compose up --build    # Lance l'app sur http://localhost:8080
```

## Equipe

Equipe_412 — ESIEA 4A (9 contributeurs)
