# cap_projet_app
# Flutter — Mémo rapide

> Un README minimal pour lancer, diagnostiquer et builder une app Flutter.

## Vérifier l’installation

```bash
flutter doctor -v
flutter --version
flutter doctor --android-licenses   # Android uniquement
```

## Créer & lancer un projet

```bash
flutter create my_app
cd my_app
flutter run                      # device par défaut
flutter run -d emulator-5554     # device spécifique
```

## Appareils & émulateurs

```bash
flutter devices                      # liste les devices
flutter emulators                    # liste les AVD
flutter emulators --launch <ID>      # lance un AVD (ex: Pixel_9_API_35_loodo)
```

Option Android direct :

```bash
emulator -list-avds
emulator -avd <NOM_AVD>
```

## Dépendances

```bash
flutter pub get
flutter pub upgrade
flutter pub outdated
```

## Nettoyage & diagnostics

```bash
flutter clean
flutter analyze
flutter format .          # formate tout le projet
flutter run -v            # logs verbeux
```

## Build Android

```bash
flutter build apk --debug
flutter build apk --release
flutter build appbundle           # AAB pour Play Store
```

## Channels & mises à jour

```bash
flutter channel
flutter channel stable
flutter upgrade
```

## Raccourcis VS Code

* F5 : Run/Debug
* Ctrl/Cmd + Shift + P → “Flutter: Launch Emulator”, “Flutter: Select Device”

## Tips rapides

* Si l’app ne se lance pas :

  ```bash
  adb kill-server && adb start-server
  flutter devices
  flutter run
  ```
* Si Gradle/Kotlin bloque :

  ```bash
  flutter clean
  flutter pub get
  ```
