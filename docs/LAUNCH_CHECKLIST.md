# CampusTrust launch checklist

Run this checklist in Flutter/Firebase-enabled CI or a workstation. A source file or configuration is not evidence that a workflow passed.

## Automated

- [ ] `flutter pub get`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build web --release --web-renderer canvaskit`
- [ ] Firebase Emulator Suite adversarial rules tests

## Firebase

- [ ] Register the production Firebase Web app and regenerate `lib/firebase_options.dart` with FlutterFire.
- [ ] Enable Google sign-in.
- [ ] Add every Netlify production/preview domain to Firebase Auth authorized domains.
- [ ] Deploy `firebase deploy --only firestore:rules,firestore:indexes`.
- [ ] Confirm the deployed project ID is `campustrust-umu-v3-1fb07`.
- [ ] Confirm the operator mailbox `campustrust@umu.ac.ug` exists and is monitored.

## Netlify/PWA

- [ ] Netlify build succeeds with `netlify.toml`.
- [ ] `build/web` contains `index.html`, `manifest.json`, icons, and `flutter_service_worker.js`.
- [ ] Reload a deep link; it must not return a 404.
- [ ] Test Chromium install CTA and standalone relaunch.
- [ ] Test iOS Safari Share → Add to Home Screen.
- [ ] Test unsupported-browser guidance.
- [ ] Perform a release A/release B service-worker update test.
- [ ] Test shell startup with DevTools offline mode.

## Real user journeys

- [ ] Android: browse, search, provider detail, phone, WhatsApp, Google sign-in, review, install.
- [ ] iOS: browse, search, provider detail, phone, WhatsApp, Google sign-in, review, install.
- [ ] Verify malformed numbers show an actionable error.
- [ ] Verify failed queries have retry, not a misleading empty state.
- [ ] Verify duplicate review attempts are rejected.
- [ ] Verify a user cannot modify providers or another user’s review using the emulator.

## Operator readiness

- [ ] Name the person/team responsible for provider curation.
- [ ] Define what evidence is checked before listing a provider.
- [ ] Define stale-listing review cadence.
- [ ] Define provider suspension/removal procedure.
- [ ] Define review and safety-report response target.
- [ ] Review Tally’s collected fields, document access, retention, and applicant notice.
