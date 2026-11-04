# iOS step 2 — build and walk the app on the Mac

Brief for a Claude Code session opened **on the user's Mac**, in this repository. Written on
2026-11-04 by the session that ran the Android effort and iOS step 1 (`feature/ios-support`) on
Windows, where no iOS build is possible. Everything iOS-specific in the app was built and tested
on Windows only; this step is the first real iOS build.

The user starts this session and is present: ask them when something is theirs to decide.

## Goal

Build the app for iOS on this Mac, then walk every screen on an **iPhone simulator**, plus an
**iPad simulator** for the share sheets. The goal is a working iOS app against the local backend,
with each check of the list below recorded as passed or failed. Fix the defects you find, or
record them, as the rules below say.

**Out of scope, by the user's decision (2026-11-04):**
- **The user's physical iPhone.** It waits for the paid Apple Developer membership. Do not sign
  the app with a free personal team: that could reserve the bundle id `app.kiveto.portal` for
  that team.
- **Step 3:** universal links, the Team ID, signing, TestFlight, the App Store.

## Read first

- `CLAUDE.md` and `CONTRIBUTING.md` (§ 0, § 5 « iOS (macOS) »): the rules are mandatory.
  - Branch per change, `make ci` green before every commit, Conventional Commits.
  - Commit or push only when the user asks.
  - Never hand-edit `contracts/` or `packages/kiveto_portal_api/`, and never edit `CLAUDE.md`
    without the user.
- `_bmad-output/implementation-artifacts/spec-ios-support.md`: what step 1 built and why.
- The iOS entries of `_bmad-output/implementation-artifacts/deferred-work.md`.
- `_bmad-output/planning-artifacts/architecture.md` § 7, « Local backend ».

## The local backend on this Mac

- It is the Kiveto Symfony repo: a separate clone on this Mac, with its own `CLAUDE.md`. Read that
  file before running anything there.
- **Bring it up:**
  - `git pull` on its `master`; it should be at `8cf96439` or later;
  - its Docker stack up, publishing port 81;
  - its workers started (`make worker-start`): they log the dev SMS.
- **Its database** is this Mac's own, not the Windows one. It may predate the latest migrations or
  fixtures.
  - Check with the backend's own commands which of them apply.
  - Never run its `make reset-db` / `load-fixtures` without the user's explicit go-ahead.
- **Check that it answers:** step 4.0 below.

### Demo accounts (backend fixtures)

| Phone | Account |
|---|---|
| +33612345678 | Julien Girard. Linked to Paris (pet Oslo) and Lyon (pet Pixel), profile and terms accepted. |
| +33622334455 | Roussel, pending invitation. Link token `demo-portal-invitation-roussel-pending-0001`. |
| +33644556677 | Account whose only link was revoked (no clinic). |
| +33612345680 | Marchand. Verified e-mail and a ready data export. |
| +33612345681 | Rey. Pending e-mail change. |

Keep lasting writes off Julien where you can, and tell the user about each one. The demo data is
shared with their own tests.

### SMS codes (dev)

No SMS is sent in dev. The workers log each code in the backend's `var/log/dev.log`, which can be
several GB, so read only its end. From the backend folder:

```bash
tail -c 5000000 var/log/dev.log | grep -a dev_sms | grep -a -F "SMS to +33612345678" | tail -n 3
```

- **Rate limit:** 3 codes per hour and 10 per day per number. Reuse a signed-in session: the
  Keychain keeps it across `make start`.
- **If you hit `otp_rate_limited`:** clear the limiters, dev only. Adapt the container name with
  `docker compose ps`:

  ```bash
  docker exec kiveto-php-fpm-1 php bin/console cache:pool:clear cache.rate_limiter
  docker exec kiveto-php-fpm-1 php bin/console dbal:run-sql "DELETE FROM shared__rate_limiter_cache"
  ```

These dev codes are test values of the user's own app on a local backend.

## Driving the simulator

There is no `adb input` for the simulator. What `xcrun simctl` does:

| Action | Command |
|---|---|
| Screenshot | `xcrun simctl io booted screenshot <file>.png` |
| Open a link | `xcrun simctl openurl booted "<url>"` |
| Dark mode | `xcrun simctl ui booted appearance dark` |
| Location | `xcrun simctl location booted set 48.8566,2.3522` |
| Kill the app | `xcrun simctl terminate booted app.kiveto.portal` |
| Uninstall the app | `xcrun simctl uninstall booted app.kiveto.portal` |

For taps and typing, use this Claude app's computer use (the Simulator window) if it is available.
If not, ask the user to tap.

Keep the screenshots outside the repository, for example in `~/kiveto-ios-walk/`, and name them by
checklist item.

## How to record and fix

- **The report:** `_bmad-output/implementation-artifacts/ios-walk-report.md`. For each item below:
  passed, failed (what you saw, the screenshot name) or not checked (why).
- **A defect you can fix:**
  - its own branch (`fix/ios-<slug>`), with a test;
  - `make ci` green, then a commit;
  - merge or push only when the user says so.
- **Anything else:** an entry in `deferred-work.md`, in the format of the existing entries.
- **When done:** commit the report on a `chore/ios-walk-report` branch, or with the last fix, so the
  Windows session can read it after a `git pull`.

## Checklist

It was written by the step-1 agent, who could not build for iOS. Commands assume the repository
root.

### 4.0 Before the first build

```bash
git checkout master && git pull                     # master has feature/ios-support merged
make doctor                                          # Xcode >= 26, licence accepted, a simulator runtime
make install                                         # creates config/env/dev.ios.json; keeps the phase-2 dev.json
cat config/env/dev.ios.json                          # http://127.0.0.1:81, portal.kiveto.local
fvm flutter config --list | grep -i swift            # Swift Package Manager must be on (the default since 3.44)
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: portal.kiveto.local' \
  http://127.0.0.1:81/api/portal/v1/legal/terms/current   # 200: the backend runs on THIS Mac
```

- The backend must run on the Mac (its Docker stack on port 81). If it runs elsewhere (the Windows PC's WSL), put that
  machine's LAN address in `dev.ios.json` (and open its firewall); `make start` refuses only `10.0.2.2`.
- OTP codes: see « SMS codes (dev) » above.

### 4.1 Build, network, the « always » code path

```bash
make start PLATFORM=ios                              # boots the first iPhone simulator, BYPASS_PERMISSION_LOCATION_ALWAYS=1
# or a named one: make start PLATFORM=ios SIMULATOR="iPhone 17 Pro"
```

- [ ] First build: SPM resolves every plugin package (network), including **pdfium_flutter's binary target**
  `PDFium-chromium-8125-20261029-150241.xcframework.zip` from `github.com/espresso3389/pdfium-xcframework` (checksum
  pinned by its `Package.swift`). Note the build time and any warning about the XCFramework or its simulator slice.
- [ ] The app starts on 7 (or the home if a session exists) and the first API call works over plain http to
  `127.0.0.1:81` (dart:io is not subject to App Transport Security: if a call fails with an ATS error, that claim is wrong —
  note it, do not add `NSAllowsArbitraryLoads`).
- [ ] **`requestAlwaysAuthorization` compiled out**: find the built app (`find build/ios -name Runner.app -maxdepth 4`),
  then `grep -c requestAlwaysAuthorization` on `Runner.app/Runner` and, if present, `Runner.app/Runner.debug.dylib`:
  expect **0**, with `requestWhenInUseAuthorization` present (positive control). If it is still there: Xcode › File ›
  Packages › Reset Package Caches, `make clean`, `rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*`, build again with
  `make start PLATFORM=ios`; note whether SPM's cached manifest evaluation was the cause.

### 4.2 Screens and platform behaviour

- [ ] **DM Sans with its `opsz` axis**: 7's title (display), body, labels; compare with the Android shots
  (`shots-final/01-fresh-install-welcome.png`): 600/700 drawn by the `wght` axis (not a synthetic bold), small text with
  the small optical size (wider spacing), no fallback font anywhere (San Francisco would show as narrower letters).
- [ ] **Icon**: home screen, Spotlight and Settings: the K badge on indigo, no black corners (the 1024 has no alpha), the
  name « Kiveto ». No AppIcon warning in the build log.
- [ ] **Launch screen and status bar**: cold launch in light and in dark mode (`xcrun simctl ui booted appearance dark`):
  dark status-bar content on the white launch screen and on every screen afterwards (7, the home on canvas, a sheet, the
  PDF viewer).
- [ ] **Safe areas and the notch / Dynamic Island**: the tops of 7, 1, 2, 4, 5, 6, 10, 11 and the flows clear the island;
  the bottom nav, the sticky bars (3, 14, 15, 17) and the sheets sit above the home indicator (`kivetoBottomPadding`).
  Rotate to landscape once (Android allows it too): no overflow stripe on 7 and 1.
- [ ] **Keyboards** (no return key on the phone and number pads):
  - 7: the phone pad; « Recevoir le code » reachable (scroll); a drag on the page closes the pad.
  - 8: the OTP number pad; QuickType offers the code from Messages only on a device (simulator: type it); the 6th digit
    submits; the submit button sits above the keyboard; a drag closes the pad.
  - 9: names (« Suivant »), e-mail (« OK » closes it).
  - 0: the code field and the e-mail field; the consent and « Activer mon espace » reachable; a drag closes the pad.
  - 15 (questionnaire) and 17 (renewal): a multiline field, a drag closes the keyboard; the bottom button reachable.
  - Sheets: the e-mail change and account deletion codes (6), the pet change weight (decimal pad) and chip number (2):
    every control visible above the keyboard; a drag closes the pad when the sheet scrolls.
- [ ] **Swipe-back** from the left edge: works on the pushed pages (a pet's sheet from Animaux, the booking steps 12 → 13 →
  3 → 14, a clinic sheet 11 and its two steps, 15, 17, the reschedule); does nothing on 8, 9, 0, 14's and the reschedule's
  success views, 14 while sending (PopScope `canPop: false`) — their own controls lead out. No page should end blank or
  half-popped.
- [ ] **`tel:`** on the simulator (no phone app): « Appeler » on 13's emergency line, on an unlisted clinic card (10) and
  on 11 → the SnackBar « Impossible de lancer l'appel. », no crash.
- [ ] **Location**: « Autour de moi » (10) → iOS's when-in-use prompt with « Kiveto utilise votre position pour trouver les
  cliniques autour de vous. » and no « always » option; with Simulator › Features › Location › Custom (48.8566, 2.3522)
  Paris shows about 3 km away. Refuse once: the SnackBar; « Précise : non » (approximate) still finds Paris.
- [ ] **Terms link** (7 › 9 consent): opens `http://portal.kiveto.local/cgu` in Safari's in-app view — it loads only if
  the Mac's `/etc/hosts` maps the dev host (same limit as Android).

### 4.3 Keychain and reinstall

- [ ] Sign in as Julien (+33612345678); kill the app (`xcrun simctl terminate booted app.kiveto.portal`) and relaunch:
  still signed in (Keychain `first_unlock_this_device`).
- [ ] `xcrun simctl uninstall booted app.kiveto.portal`, then `make start PLATFORM=ios`: the app starts **signed out** on
  7 (the marker went with the uninstall, the Keychain tokens are cleared before the session is read).
- [ ] The device id survived: sign in again and check in the backend database that the new session's device id equals
  the one before the uninstall (the app never logs it).
- [ ] Relaunch after that sign-in: still signed in (the marker now exists).

### 4.4 The dev invitation link

```bash
xcrun simctl openurl booted "kiveto-dev://portal.kiveto.local/invitation#t=demo-portal-invitation-roussel-pending-0001"
```

- [ ] Warm (app running, on 7): iOS may ask « Ouvrir dans « Kiveto » ? » once; screen 0 opens with « Invitation :
  Clinique Vétérinaire de Paris » and sends a code; the token never shows.
- [ ] Cold (app terminated): the same link launches the app straight on 0.
- [ ] Signed in as Julien: the link opens 0 with « Revenir à l'accueil ».
- [ ] Stop before « Activer mon espace » (it would accept Roussel's invitation on the demo data).

### 4.5 Share sheets and iPad

- [ ] iPhone: « Ajouter à mon calendrier » on a card of 4 → the share sheet with `rendez-vous-<date>.ics` and « Ajouter au
  calendrier »; adding it creates the event at the clinic's time.
- [ ] iPad simulator (`xcrun simctl shutdown all`, then `make start PLATFORM=ios SIMULATOR="<an iPad name from make devices>"`; with a
  simulator already booted `make start` picks it, or takes `DEVICE=<udid>`): the same action, then 14's
  and the reschedule's success buttons (only if a write is acceptable on the demo data), and the export's « Télécharger »
  (Marchand +33612345680, who has a ready export): each sheet is a **popover anchored to the tapped control**, not
  centred, and no failure SnackBar. Rotate the iPad once with a sheet closed: layouts hold in landscape and split view.

### 4.6 PDFium (pdfrx's iOS XCFramework, never built before)

- [ ] Documents (5): open PAR-2026-000066 (already read, so no new read row on the demo data): the PDF renders, zoom and
  scroll work; Animaux › Oslo › « Carnet PDF »: the vaccination booklet renders.
- [ ] No crash or missing-symbol error at launch or at the first PDF (the XCFramework's arm64 simulator slice).

### 4.7 Release configuration (no signing needed)

```bash
BYPASS_PERMISSION_LOCATION_ALWAYS=1 fvm flutter build ios --release --no-codesign \
  --dart-define-from-file=config/env/dev.ios.json
plutil -p build/ios/iphoneos/Runner.app/Info.plist | grep -A6 CFBundleURLTypes
```

- [ ] The release `Info.plist` has no `kiveto-dev` (an empty `CFBundleURLSchemes` item is expected; record it for step 3's
  App Store validation — deferred). The debug build's plist (`build/ios/iphonesimulator/Runner.app/Info.plist`) has
  `kiveto-dev`. `UIStatusBarStyle` is `UIStatusBarStyleDarkContent` in both.
- [ ] `grep -c requestAlwaysAuthorization` on the release binary: 0.

### 4.8 Physical iPhone — not now

Not now: the user decided on 2026-11-04 to wait for the paid Apple Developer membership. It comes
with step 3, signed by the paid team.

### 4.9 Out of this step (step 3)

- universal links: Associated Domains, and the Apple Team ID in the backend's
  `apple-app-site-association`;
- the paid program's signing;
- the privacy manifest and export compliance;
- App Store validation of the empty release URL scheme;
- a CI job, which must set `BYPASS_PERMISSION_LOCATION_ALWAYS=1`.

## Done

- every item of 4.0–4.7 recorded in `ios-walk-report.md`;
- the defects fixed on branches with `make ci` green, or recorded in `deferred-work.md`;
- a short summary for the user: what works on iOS, what failed, what is left for step 3.
