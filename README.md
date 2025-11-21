# Priority Quadrant To-Do

Cross-platform Flutter client + Node.js/Express backend that organizes tasks
with the Eisenhower matrix and ingests action items from Gmail, WhatsApp, and
SMS.

## Project Layout

- `app/`: Flutter client (Android, iOS, Web) that visualizes tasks in priority
  quadrants, breaks them into steps, and triggers ingestion jobs.
- `backend/`: Node.js/TypeScript API that stores tasks in Firestore and turns
  Gmail, WhatsApp Business, and Twilio SMS messages into actionable items.

## Running the Flutter App

```bash
cd app
flutter pub get
flutter run -d chrome   # or android/ios device id
```

Set the `apiBaseUrl` in `lib/main.dart` if your backend does not run on
`http://localhost:8080`.

## Running the Backend

```bash
cd backend
npm install
cp .env.example .env            # fill Google, Meta, Twilio secrets
npm run dev                     # hot reload via tsx
```

The backend expects a Firestore project accessible via
`GOOGLE_APPLICATION_CREDENTIALS`. Tasks live in the `tasks` collection, enabling
real-time sync via Firestore listeners if you choose to add them later.

## Deploying

- **Frontend**: Deploy with Firebase Hosting (Flutter web) or ship the same code
  as Android/iOS builds through Play/App Store.
- **Backend**: Deploy to Firebase Functions, Cloud Run, or AWS Amplify. Ensure
  OAuth redirect URIs and webhooks are configured for Gmail/WhatsApp/Twilio.

## Next Steps

- Add auth (Firebase Auth + Google OAuth) so ingestion uses per-user tokens.
- Persist webhook callbacks from WhatsApp/Twilio instead of polling.
- Write integration tests for ingestion services and widget tests for Flutter
  flows.
