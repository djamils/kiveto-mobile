# 🐾 Kiveto Mobile

Application Flutter (Android et iOS) du **Portal Kiveto**, l'espace des propriétaires d'animaux. Elle est cliente de l'API Portal du backend Kiveto (dépôt [djamils/kiveto](https://github.com/djamils/kiveto), contrat `openapi/portal.v1.yaml`).

> **Bootstrap en cours — phase 1 sur 6.** Le dépôt ne contient encore que ses fondations : conventions, BMAD, Claude Code et décisions d'architecture. Le projet Flutter, le `Makefile` et les contrôles qualité arrivent dans les phases suivantes ; l'état à jour est dans [CONTRIBUTING.md](./CONTRIBUTING.md#0-bootstrap-status).

---

## 📦 Prérequis

Windows 11 (Android seulement) ou macOS (Android et iOS).

| Outil | Windows 11 | macOS |
|---|---|---|
| Git | Git for Windows (Git Bash) | Xcode Command Line Tools ou Homebrew |
| GNU Make ≥ 3.81 | `winget install ezwinports.make` (Git for Windows n'inclut pas `make`) | fourni (`/usr/bin/make`) |
| FVM ≥ 4 | `choco install fvm`, ou l'archive de la release GitHub | `brew tap btwld/fvm && brew install btwld/fvm/fvm` |
| Mode développeur | Paramètres › Système › Pour les développeurs (liens symboliques de FVM) | — |
| Android Studio | SDK, cmdline-tools, un émulateur, licences acceptées | idem |
| JDK ≥ 17 | celui d'Android Studio ou un JDK installé (un JRE ne suffit pas) | idem |
| Xcode ≥ 26 | — | App Store |
| Node ≥ 20.12 et uv | pour BMAD uniquement | idem |

Cloner le dépôt sur un disque local, dans un chemin sans espaces.

---

## 🚀 Démarrage (à partir de la phase 2)

```bash
git clone https://github.com/djamils/kiveto-mobile.git
cd kiveto-mobile
make install
make start
make ci
```

`make install` vérifie les prérequis et explique comment installer ce qui manque, sans rien installer au niveau du système.

---

## 📚 Documentation

- [CONTRIBUTING.md](./CONTRIBUTING.md) : git flow, commandes, architecture, tests, contrat d'API, BMAD, Definition of Done
- [CLAUDE.md](./CLAUDE.md) : directives non négociables pour les agents IA
- [Décisions d'architecture](./_bmad-output/planning-artifacts/architecture.md)

---

## 📄 Licence

Propriétaire - © 2026 Kiveto
