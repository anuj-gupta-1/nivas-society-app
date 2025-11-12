# Nivas - Society Management App

**Status:** ✅ MVP Complete - Ready for Beta Launch

A complete Flutter-based society management application with real-time discussions, group management, and admin controls.

## 🎯 What It Does

Nivas helps residential societies manage their community discussions and member verification:

- **User Registration** - Phone OTP verification with document upload
- **Admin Verification** - Dashboard to approve/reject new members
- **Group Management** - Create and manage discussion groups
- **Space Organization** - Organize discussions by topics
- **Threading System** - Create threads and nested replies
- **Real-time Updates** - Instant synchronization across devices
- **Offline Support** - Works offline, syncs when online
- **Multi-Project** - Support for multiple societies

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Firebase project configured
- Android Studio / VS Code

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd nivas

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Setup

1. Create a Firebase project
2. Add Android/iOS apps to Firebase
3. Download and add configuration files:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
4. Enable Firebase services:
   - Authentication (Phone)
   - Firestore Database
   - Storage
   - Cloud Messaging

## 📱 Features

### For Users
- ✅ Phone number registration with OTP
- ✅ Profile setup with unit details
- ✅ Document upload for verification
- ✅ Browse and join groups
- ✅ Create discussion threads
- ✅ Reply to threads (with nesting)
- ✅ Real-time updates
- ✅ Offline mode
- ✅ User profile
- ✅ Settings & logout

### For Admins
- ✅ Verification dashboard
- ✅ Approve/reject users
- ✅ Create groups (general/private)
- ✅ Manage group members
- ✅ Create spaces
- ✅ Delete threads
- ✅ Verification history

## 🏗️ Architecture

### Tech Stack
- **Frontend:** Flutter & Dart
- **Backend:** Firebase (Auth, Firestore, Storage, FCM)
- **State Management:** Riverpod
- **Local Storage:** Hive
- **Real-time:** Firestore Streams

### Project Structure
```
nivas/
├── lib/
│   ├── models/          # Data models
│   ├── providers/       # Riverpod providers
│   ├── screens/         # UI screens
│   │   ├── auth/       # Registration & login
│   │   ├── admin/      # Admin dashboard
│   │   ├── home/       # Home, profile, settings
│   │   ├── project/    # Project selection
│   │   ├── group/      # Group management
│   │   ├── space/      # Space management
│   │   └── thread/     # Threads & replies
│   ├── services/        # Business logic
│   ├── widgets/         # Reusable widgets
│   └── utils/           # Constants & helpers
└── firebase/            # Firebase config
```

## 📊 Statistics

- **10+ major tasks completed**
- **31+ sub-tasks done**
- **30+ files created**
- **6000+ lines of code**
- **100% MVP features complete**

## 🎯 Roadmap

### ✅ Completed (MVP)
- User registration & verification
- Group & space management
- Thread & reply system
- Admin dashboard
- Navigation & settings
- Offline support

### 🔜 Coming Soon (Post-Beta)
- Push notifications
- Search functionality
- Media attachments
- Rich text editor
- Tag system
- Analytics

### 💡 Future Ideas
- Document repository
- Content moderation
- User analytics
- Export features
- Dark mode

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

### Manual Testing Checklist
- [ ] User registration flow
- [ ] Admin verification
- [ ] Group creation & joining
- [ ] Thread creation & replies
- [ ] Navigation drawer
- [ ] Profile screen
- [ ] Logout & re-login
- [ ] Offline mode

## 🚀 Deployment

### Android
```bash
# Build release APK
flutter build apk --release

# Build app bundle
flutter build appbundle --release
```

### iOS
```bash
# Build release IPA
flutter build ios --release
```

## 📖 Documentation

- [MVP Status](MVP_STATUS.md) - Complete feature breakdown
- [Launch Checklist](LAUNCH_CHECKLIST.md) - Pre-launch tasks
- [Final Summary](FINAL_SUMMARY.md) - Project overview
- [Session Progress](SESSION_PROGRESS.md) - Development timeline

## 🤝 Contributing

This is a complete MVP ready for beta testing. Future contributions welcome for:
- Bug fixes
- Feature enhancements
- UI/UX improvements
- Documentation

## 📄 License

© 2024 Nivas. All rights reserved.

## 🙏 Acknowledgments

Built with Flutter, Firebase, and lots of ☕

---

**Status:** ✅ Ready for Beta Launch
**Version:** 1.0.0
**Last Updated:** 2024

For questions or support, please open an issue.
