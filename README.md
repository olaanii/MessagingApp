# 💬 MessagingApp

A premium, real-time messaging application built with **Flutter** and **Firebase** — featuring end-to-end phone-based authentication, contact discovery, group chat, stories, and a polished "Velvet Shadows" dark UI.

---

## ✨ Features

- **Phone Authentication** — Secure OTP-based sign-in via Firebase Auth
- **Contact Syncing** — Automatically discovers which of your phone contacts are on the app
- **1-on-1 Chat** — Real-time messaging with typing indicators and offline queuing
- **Group Chat** — Create groups with multiple members selected from your contacts
- **Moments (Stories)** — Share photo/video moments that expire after 24 hours
- **Push Notifications** — Firebase Cloud Messaging (FCM) for background alerts
- **Block & Report** — User safety compliance for App Store guidelines
- **Offline Support** — Messages queued locally via Hive and synced on reconnect
- **Dark Mode** — Premium "Velvet Shadows" aesthetic with glassmorphism effects

---

## 🏗️ Architecture

```
lib/
├── core/              # Shared utilities, env config
├── data/
│   ├── local/         # Hive offline storage
│   └── services/      # Firebase, messaging, contacts, media
├── domain/
│   └── models/        # UserModel, MessageModel, ContactModel, etc.
└── presentation/
    ├── auth/          # Phone entry, OTP, profile setup
    ├── chat/          # Inbox, chat detail, contacts, group creation
    ├── settings/      # Profile, logout, block/report
    └── theme/         # App-wide theme & design tokens
```

**State Management:** `provider` + `ChangeNotifier`  
**Navigation:** `go_router`  
**Backend:** Firebase Auth, Cloud Firestore, Firebase Storage, FCM

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0`
- Firebase project with Auth, Firestore, and Storage enabled
- An `.env` file with your Firebase credentials (see `.env.example`)

### Setup

```bash
# Clone the repo
git clone https://github.com/olaanii/MessagingApp.git
cd MessagingApp/chat

# Install dependencies
flutter pub get

# Generate env config
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Environment Variables

Create a `.env` file in the project root (never commit this file):

```env
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your_project_id
```

---

## 🔐 Security

Sensitive files are excluded from version control:

- `.env` — raw secrets
- `lib/core/env/env.g.dart` — generated secrets
- `lib/firebase_options.dart` — Firebase config
- `android/app/google-services.json`
- `ios/GoogleService-Info.plist`

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `firebase_auth` | Phone OTP authentication |
| `cloud_firestore` | Real-time database |
| `firebase_messaging` | Push notifications |
| `flutter_contacts` | Device contact access |
| `go_router` | Declarative navigation |
| `provider` | State management |
| `hive` | Offline message queue |
| `envied` | Secure env variable access |

---

## 📄 License

MIT © [olaanii](https://github.com/olaanii)
