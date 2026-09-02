# CampusTrust

CampusTrust helps students and staff at Uganda Martyrs University, Nkozi find and contact trusted local service providers such as electricians, plumbers, boda riders and peer tutors. Providers are curated; community reviews provide the trust signal.

## Product map

- **Tier 1:** browse by category, search providers, open a provider profile, call/WhatsApp a provider, read reviews.
- **Tier 2:** authenticated review submission and provider application.
- **Tier 3:** Google sign-in profile/session controls.
- Provider records are read-only to clients. Reviews are immutable after submission.

The rebuild keeps the original core directory and review workflows, improves mobile touch targets, loading/empty/error states, input validation, and adds an adaptive first-visit install prompt. Provider rating aggregates are not client writable; the profile calculates the visible aggregate from reviews. A trusted Firebase Cloud Function should maintain denormalized aggregates at scale (deferred rather than trusting a client transaction).

## Run locally

This is a Flutter project. Install Flutter 3.24+ and run:

```sh
flutter pub get
flutter run -d chrome
# or
flutter run -d android
```

Firebase is required for directory, authentication, and reviews. Regenerate `lib/firebase_options.dart` with FlutterFire when changing Firebase apps or adding a real web app registration:

```sh
dart pub global activate flutterfire_cli
flutterfire configure --project=campustrust-umu-v3-1fb07 --platforms=android,ios,web
```

Do not put server credentials in the app. Firebase client configuration is intentionally public; Firestore rules are the authorization boundary.

## Netlify deployment

1. Register a **Web app** in Firebase and run the FlutterFire command above.
2. Enable Google Authentication and add the Netlify production and preview domains to Firebase Auth authorized domains.
3. Create Firestore indexes for provider category + ratingAverage and review providerId + timestamp when prompted by Firebase.
4. Deploy `firestore.rules` using the Firebase CLI after selecting the correct project:

   ```sh
   firebase deploy --only firestore:rules,firestore:indexes
   ```

5. In Netlify, connect this repository and use the committed `netlify.toml`. Build command is `flutter build web --release --web-renderer canvaskit`; publish directory is `build/web`.
6. Verify the generated web Firebase options are committed as configuration, not secrets. No environment variables are required by the current Flutter client. If a future backend is added, keep production values in Netlify Site configuration and provide a safe `.env.example`.

### Post-deploy checks

- Open the HTTPS URL and verify the manifest, icons, and `flutter_service_worker.js` in DevTools.
- Test category/search reads, provider calls, Google sign-in, and review submission.
- Test the install card in Chromium, Safari on iOS (Share → Add to Home Screen), and a browser without install support.
- Use DevTools offline mode to confirm the app shell loads. Firebase-backed content requires a prior cache and may be unavailable offline; the UI must not claim a review was saved until Firestore confirms it.

## Trust, safety, and privacy

The product uses **Listed provider** language. A listing is not a guarantee of identity, safety, price, availability, or service quality. The directory owner must review provider applications, reconfirm contact details, pause unsafe listings, and respond to review complaints. See [`docs/TRUST_MODEL.md`](docs/TRUST_MODEL.md) for the minimum operating process. Do not launch publicly without a named operator and a support/reporting channel.

The app currently collects Google display name/email for authenticated reviews and publishes provider contact details and review authors publicly. Do not collect application documents in this Flutter client; the external Tally workflow must have its own access and retention policy.

## Security and data notes

Provider documents are publicly readable but cannot be written from the client. Reviews can only be created by an authenticated user, must belong to that user, have a 1–5 integer rating, and are immutable. Existing provider/review data is not destructively migrated. Before operating on production data, export a Firestore backup and deploy rule changes separately from any aggregate function.

## Validation status

The repository was statically audited and the PWA/install path was implemented. Flutter and Android SDK binaries are not available in this execution environment, so `flutter analyze`, `flutter test`, production build, Firebase deploy, and real-device/browser installation were not run here. Run those commands in CI or a Flutter-equipped workstation before release.
