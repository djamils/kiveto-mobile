# 🐾 Kiveto Mobile

Application Flutter (Android et iOS) du **Portal Kiveto**, l'espace des propriétaires d'animaux. Elle est cliente de l'API Portal du backend Kiveto (dépôt [djamils/kiveto](https://github.com/djamils/kiveto), contrat `openapi/portal.v1.yaml`).

> **Bootstrap terminé — phases 1 à 5 terminées ; phase 2 validée sous Windows et macOS, phases 3 à 5 sous Windows et l'émulateur Android (validation macOS / iOS et premier passage de GitHub Actions en attente).** Le dépôt contient ses fondations (conventions, BMAD, Claude Code, décisions d'architecture), le projet Flutter Android et iOS (`app.kiveto.portal`, nom affiché « Kiveto »), Flutter 3.47.9 épinglé avec FVM, le `Makefile` et les contrôles qualité : `make ci` (format, analyse, règles d'architecture, tests avec couverture, seuil de couverture, vérification des scripts, cohérence du contrat d'API), les hooks git et GitHub Actions. Le client de l'API Portal est généré par tonik depuis une copie du contrat du backend épinglée par commit (`contracts/`, `packages/kiveto_portal_api/`). La phase 5 a posé le socle de l'app : thème et kit d'interface de la maquette, navigation à 5 onglets, client HTTP avec session et rafraîchissement des jetons, erreurs, textes en français ; les écrans arrivent avec les tranches suivantes (des pages d'attente en tiennent lieu). L'état à jour est dans [CONTRIBUTING.md](./CONTRIBUTING.md#0-bootstrap-status).

---

## 📦 Prérequis

Windows 11 (Android seulement) ou macOS (Android et iOS).

| Outil | Windows 11 | macOS |
|---|---|---|
| Git | Git for Windows (Git Bash) | Xcode Command Line Tools ou Homebrew |
| GNU Make ≥ 3.81 | `winget install ezwinports.make` (Git for Windows n'inclut pas `make`) | fourni (`/usr/bin/make`) |
| FVM ≥ 4 | `choco install fvm`, ou l'archive de la release GitHub | `brew tap btwld/fvm && brew install btwld/fvm/fvm` |
| Mode développeur | Paramètres › Système › Pour les développeurs (liens symboliques de FVM) | — |
| Android Studio | SDK, cmdline-tools, un émulateur, licences acceptées, et NDK (Side by side) 28.2.13676358, la version demandée par Flutter 3.47.9 : SDK Manager › SDK Tools › NDK (Side by side) avec « Show Package Details », ou `android --no-metrics sdk install ndk/28.2.13676358` depuis `cmdline-tools/latest/bin` (sous Windows avec cmdline-tools 23.0, Gradle ne peut pas l'installer seul : `sdkmanager.bat` coupe `ndk;28.2.13676358` au `;`) | idem |
| JDK ≥ 17 | celui d'Android Studio ou un JDK installé (un JRE ne suffit pas) | idem |
| Xcode ≥ 26 | — | App Store, puis `sudo xcodebuild -license accept` et `sudo xcodebuild -runFirstLaunch` (tant que la licence n'est pas acceptée, `/usr/bin/make` et `/usr/bin/git` refusent de tourner : lancer `bash scripts/doctor.sh`), et un runtime de simulateur iOS (Xcode › Settings › Components) |
| Node ≥ 20.12 et uv | pour BMAD uniquement | idem |

Cloner le dépôt sur un disque local, dans un chemin sans espaces.

---

## 🚀 Démarrage

Dans Git Bash sous Windows, dans un terminal sous macOS :

```bash
git clone https://github.com/djamils/kiveto-mobile.git
cd kiveto-mobile
make doctor     # vérifie les prérequis et affiche comment corriger chacun
make install    # Flutter épinglé (FVM), dépendances, config/env/dev.json
make start      # lance l'app ; démarre le premier émulateur si aucun appareil ne tourne
```

`make install` vérifie les prérequis et explique comment installer ce qui manque, sans rien installer au niveau du système ; il active aussi les hooks git de ce clone (`core.hooksPath=.githooks`). Sans FVM, `make install-fvm` l'installe pour l'utilisateur courant uniquement et affiche la ligne `PATH` à ajouter. `make help` liste les autres cibles (`devices`, `clean`, `reset`, les étapes de `make ci`) et les options (`PLATFORM=ios` sous macOS, `DEVICE=`, `EMULATOR=`, `ENV=`, `RUN_ARGS=`, `V=1`…).

Avant chaque commit :

```bash
make ci         # format, analyse, règles d'architecture, tests et couverture, scripts, contrat d'API ; doit être vert
```

Le workflow GitHub Actions (`.github/workflows/ci.yml`) relancera `make ci` sur chaque pull request ; il est écrit mais n'a pas encore tourné.

Contrat de l'API Portal (détails dans [CONTRIBUTING.md](./CONTRIBUTING.md#8-the-portal-api-contract)) :

```bash
make api-sync REF=<sha> KIVETO_BACKEND_DIR=<checkout du backend>   # copie le contrat à ce commit, puis régénère le client
make api-generate   # régénère packages/kiveto_portal_api depuis contracts/portal.v1.yaml
make api-check      # la copie, contracts/SOURCE et le client concordent (dernière étape de make ci)
```

Ne jamais modifier `contracts/` ni `packages/kiveto_portal_api/` à la main.

---

## 📚 Documentation

- [CONTRIBUTING.md](./CONTRIBUTING.md) : git flow, commandes, architecture, tests, contrat d'API, BMAD, Definition of Done
- [CLAUDE.md](./CLAUDE.md) : directives non négociables pour les agents IA
- [Décisions d'architecture](./_bmad-output/planning-artifacts/architecture.md)

---

## 📄 Licence

Propriétaire - © 2026 Kiveto
