# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Cap Projet App** is a Flutter application for healthcare reimbursement calculations. It helps users estimate medical care reimbursements from French social security (Sécurité sociale) and mutual insurance (mutuelle) based on different practitioner types and coverage plans.

- **Frontend**: Flutter 3+ (multi-platform: Android, iOS, Web, Windows, macOS, Linux)
- **Backend**: Supabase (PostgreSQL database + authentication)
- **Hosting**: Firebase (web deployment)

**Important**: The Flutter project root is `cap_app/`, not `cap_projet_app/`.

## Essential Commands

All commands must be run from the Flutter project root:

```bash
cd cap_projet_app/cap_app
```

### Development
```bash
flutter pub get              # Install dependencies
flutter run                  # Run on default device
flutter run -d chrome        # Run on web (Chrome)
flutter run -d <device-id>   # Run on specific device
flutter devices              # List available devices
```

### Code Quality
```bash
flutter analyze              # Analyze code for issues
flutter format .             # Format code
flutter clean                # Clean build artifacts
```

### Building
```bash
# Web
flutter build web

# Android
flutter build apk --release
flutter build appbundle

# Windows
flutter build windows
```

### Web Deployment (Firebase Hosting)
```bash
flutter build web
firebase deploy --only hosting
```

### Testing
```bash
flutter test                          # Run all tests
flutter test test/widget_test.dart    # Run specific test
```

## Project Architecture

### Directory Structure

```
cap_projet_app/
├── cap_app/                         # Flutter project root (pubspec.yaml here)
│   ├── lib/
│   │   ├── main.dart                # Entry point (Firebase + Supabase init)
│   │   ├── app.dart                 # App config, routes, theme, MainPage
│   │   ├── core/supabase/           # Supabase initialization
│   │   ├── features/
│   │   │   ├── auth/screens/        # Sign in/up screens
│   │   │   ├── Home/                # Models, screens, services for reimbursement
│   │   │   └── History/             # Simulation history feature
│   │   ├── screens/                 # Shared screens (home, profile, category)
│   │   ├── widgets/                 # Shared UI components
│   │   └── services/                # Shared services
│   ├── web/                         # Web platform files
│   └── supabase/migrations/         # SQL migrations
├── SQL_TABLE.md                     # Database schema reference
└── RLS_POLICIES.md                  # Row Level Security policies
```

### Key Patterns

1. **Feature-Based Organization**: Features under `lib/features/<name>/` with screens, models, services
2. **Service Layer**: Business logic in stateless service classes (e.g., `RemboursementCalculator`)
3. **Three-Tab Navigation**: Home, History, Profile via `IndexedStack` in `MainPage`
4. **Named Routes**: `/` (SignIn), `/signup` (SignUp), `/main` (MainPage)

## Database Schema (Supabase)

### Tables Overview

| Table | Description | Access |
|-------|-------------|--------|
| `user_infos` | User profile with mutuelle/regime selection | User's own data only |
| `simulation_history` | Saved reimbursement simulations | User's own data only |
| `soins` | Healthcare services with BRSS rates | Public read |
| `categories_soins` | Categories of healthcare services | Public read |
| `mutuelles` | Insurance companies | Public read |
| `mutuelle_formules` | Insurance plans per company | Public read |
| `mutuelle_remboursements` | Reimbursement rates per plan/service | Public read |
| `assurance_maladie_regimes` | Social security regimes | Public read |
| `assurance_maladie_remboursements` | Social security rates per regime/service | Public read |

### Key Relationships

```
user_infos
├── mutuelle_id → mutuelles
├── mutuelle_formule_id → mutuelle_formules
└── regime_assurance_maladie_id → assurance_maladie_regimes

soins
└── categorie_id → categories_soins

mutuelle_remboursements
├── formule_id → mutuelle_formules
└── soins_id → soins

assurance_maladie_remboursements
├── regimes_id → assurance_maladie_regimes
└── soins_id → soins

simulation_history
├── user_id → auth.users
└── soin_id → soins
```

### Mutuelle Remboursement Types

The `mutuelle_remboursements.type` field determines calculation method:
- `pourcentage`: Uses `taux_mutuelle_conventionne` / `taux_mutuelle_non_conventionne` (% of BRSS)
- `forfait`: Uses `forfait_conventionne` / `forfait_non_conventionne` (fixed amount per service)
- `forfait_annuel`: Annual limit with `nbr_max` count

### RLS Policies Summary

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| Reference tables (soins, mutuelles, etc.) | Public | - | - | - |
| `user_infos` | Own only | Own only | Own only | - |
| `simulation_history` | Own only | Own only | Own only | Own only |

All user-specific data is protected by `auth.uid() = user_id` policies.

## Core Business Logic

### Reimbursement Calculation

**Input Model (`RemboursementInfo`)**:
- `prixFacture`: Invoice price charged by practitioner
- `brss`: Base de remboursement Sécurité sociale (reference tariff)
- `tauxSecu`: Social security rate (e.g., 70%)
- `isMajeur`: Adult flag (affects 1€ participation fee)
- `typeMutuelle`: Calculation type (pourcentage/forfait/forfait_annuel)
- `taux/forfait` values for conventionné and non-conventionné

**Calculation Logic (`RemboursementCalculator`)**:
1. Determine if `estConventionne` (price <= BRSS)
2. Calculate Sécu: `BRSS × tauxSecu - 1€` (if adult)
3. Calculate Mutuelle based on type and conventionné status
4. Return `RemboursementResult` with total and breakdown

### Querying for Reimbursement Data

To calculate reimbursements, the app needs:
1. `soins` record (for `brss`, `type_brss`)
2. `assurance_maladie_remboursements` (for `taux_assurance_maladie`, filtered by `soins_id` + `regimes_id`)
3. `mutuelle_remboursements` (for rates/forfaits, filtered by `soins_id` + `formule_id`)

User's `regime_id` and `formule_id` come from `user_infos`.

## Dependencies

```yaml
supabase_flutter: ^2.10.3    # Backend and authentication
firebase_core: ^4.4.0        # Firebase for web hosting
google_fonts: ^6.2.0         # Typography
intl: ^0.20.2                # Date formatting
```
