# Development Guide

**Project:** Nivas - Society Management App  
**For:** Developers joining the project  
**Last Updated:** 2024

---

## Prerequisites

### Required Software
- **Flutter SDK:** 3.0+ ([Install Guide](https://flutter.dev/docs/get-started/install))
- **Dart SDK:** 3.0+ (comes with Flutter)
- **Android Studio / VS Code:** With Flutter plugins
- **Git:** For version control
- **Firebase CLI:** For Firebase operations

### Recommended Tools
- **Flutter DevTools:** For debugging
- **Android Emulator / iOS Simulator:** For testing
- **Postman:** For API testing (if needed)

### Knowledge Requirements
- **Flutter/Dart:** Intermediate level
- **Riverpod:** State management
- **Firebase:** Auth, Firestore, Storage
- **Material Design:** UI/UX principles

---

## Getting Started

### 1. Clone the Repository
```bash
git clone <repository-url>
cd nivas
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Option A: Use Existing Firebase Project
1. Get `google-services.json` (Android) from team
2. Get `GoogleService-Info.plist` (iOS) from team
3. Place in respective directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

#### Option B: Create New Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project
3. Add Android app (package: `com.example.nivas`)
4. Add iOS app (bundle ID: `com.example.nivas`)
5. Download config files
6. Enable services:
   - Authentication → Phone
   - Firestore Database
   - Storage
   - Cloud Messaging

### 4. Run the App
```bash
# Check devices
flutter devices

# Run on connected device
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

---

## Project Structure

```
nivas/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   ├── providers/                # Riverpod state management
│   ├── services/                 # Business logic
│   ├── screens/                  # UI screens
│   │   ├── auth/                # Authentication flow
│   │   ├── admin/               # Admin dashboard
│   │   ├── home/                # Main navigation
│   │   ├── project/             # Project management
│   │   ├── group/               # Group management
│   │   ├── space/               # Space management
│   │   └── thread/              # Discussion system
│   ├── widgets/                  # Reusable components
│   └── utils/                    # Utilities
├── android/                      # Android-specific code
├── ios/                          # iOS-specific code
├── docs/                         # Documentation
└── scripts/                      # Build & deployment scripts
```

---

## Development Workflow

### 1. Feature Development

#### Step 1: Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

#### Step 2: Understand Requirements
- Read relevant docs in `/docs`
- Check `.kiro/specs/society-management-app/`
- Review related code

#### Step 3: Implement Feature
- Follow existing patterns
- Use Riverpod for state management
- Follow Material Design guidelines
- Add error handling
- Consider offline support

#### Step 4: Test Locally
```bash
# Run app
flutter run

# Check for issues
flutter analyze

# Format code
flutter format .
```

#### Step 5: Commit & Push
```bash
git add .
git commit -m "feat: your feature description"
git push origin feature/your-feature-name
```

### 2. Code Style Guidelines

#### Dart/Flutter Conventions
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `lowerCamelCase` for variables and functions
- Use `UpperCamelCase` for classes
- Use `snake_case` for file names

#### File Organization
```dart
// 1. Imports (grouped)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';

// 2. Constants
const kPadding = 16.0;

// 3. Providers (if any)
final myProvider = Provider((ref) => ...);

// 4. Main widget
class MyScreen extends ConsumerWidget {
  // ...
}

// 5. Helper widgets (private)
class _HelperWidget extends StatelessWidget {
  // ...
}
```

#### Naming Conventions
- **Screens:** `*_screen.dart` (e.g., `home_screen.dart`)
- **Widgets:** `*_widget.dart` or descriptive name
- **Providers:** `*_provider.dart`
- **Services:** `*_service.dart`
- **Models:** Singular noun (e.g., `user.dart`, `thread.dart`)

### 3. State Management Patterns

#### Reading Providers
```dart
// In ConsumerWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for changes
    final user = ref.watch(currentUserProvider);
    
    // Read once (no rebuild)
    final userId = ref.read(currentUserIdProvider);
    
    // Listen to changes
    ref.listen(authStateProvider, (previous, next) {
      // Handle state change
    });
    
    return Container();
  }
}
```

#### Creating Providers
```dart
// Stream provider for real-time data
final threadsProvider = StreamProvider.family<List<Thread>, String>((ref, spaceId) {
  return firestore
    .collection('threads')
    .where('space_id', isEqualTo: spaceId)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => Thread.fromFirestore(doc)).toList());
});

// State notifier for mutable state
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  
  void increment() => state++;
}

final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});
```

### 4. Firebase Patterns

#### Firestore Queries
```dart
// Real-time stream
Stream<List<Thread>> getThreads(String spaceId) {
  return firestore
    .collection('threads')
    .where('space_id', isEqualTo: spaceId)
    .orderBy('last_activity_at', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => Thread.fromFirestore(doc)).toList());
}

// One-time read
Future<User?> getUser(String userId) async {
  final doc = await firestore.collection('users').doc(userId).get();
  return doc.exists ? User.fromFirestore(doc) : null;
}

// Write data
Future<void> createThread(Thread thread) async {
  await firestore.collection('threads').doc(thread.threadId).set(thread.toFirestore());
}
```

#### Error Handling
```dart
try {
  await firestore.collection('threads').doc(threadId).set(data);
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    throw Exception('You do not have permission to perform this action');
  } else if (e.code == 'not-found') {
    throw Exception('Thread not found');
  } else {
    throw Exception('Failed to create thread: ${e.message}');
  }
} catch (e) {
  throw Exception('An unexpected error occurred: $e');
}
```

### 5. Offline Support

#### Using Offline Sync Service
```dart
// Queue action for offline sync
await ref.read(offlineSyncServiceProvider).queueAction(
  'create_thread',
  {
    'thread_id': threadId,
    'space_id': spaceId,
    'title': title,
    'content': content,
  },
);

// Check connectivity
final isOnline = ref.watch(connectivityProvider);
if (!isOnline) {
  // Show offline indicator
}
```

#### Caching with Hive
```dart
// Save to cache
await ref.read(hiveServiceProvider).saveUser(user);

// Read from cache
final cachedUser = await ref.read(hiveServiceProvider).getUser(userId);
```

---

## Testing

### Manual Testing Checklist

#### Authentication Flow
- [ ] Phone number entry with validation
- [ ] OTP verification
- [ ] Profile setup
- [ ] Document upload
- [ ] Verification pending screen
- [ ] Admin approval/rejection
- [ ] Login after approval

#### Admin Flow
- [ ] Admin dashboard access (Super Admin only)
- [ ] View pending verifications
- [ ] Approve user with document review
- [ ] Reject user with reason
- [ ] View verification history

#### Group Management
- [ ] View groups list (My Groups + Available)
- [ ] Create group (Super Admin only)
- [ ] Request access to private group
- [ ] Approve/reject access requests (Group Admin)
- [ ] Group settings and member management

#### Discussion Flow
- [ ] View spaces in group
- [ ] Create space (Group Admin)
- [ ] View threads in space
- [ ] Create thread with mentions
- [ ] View thread details
- [ ] Post reply
- [ ] Post nested reply
- [ ] Delete thread (author/admin)

#### Offline Support
- [ ] Create thread offline
- [ ] Post reply offline
- [ ] Auto-sync when online
- [ ] Offline indicator shown

#### Multi-Project
- [ ] Switch between projects
- [ ] Data isolation per project
- [ ] Different roles in different projects

### Running Tests (Future)
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

---

## Common Tasks

### Adding a New Screen

1. **Create screen file:**
```dart
// lib/screens/feature/my_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Screen')),
      body: const Center(child: Text('Hello World')),
    );
  }
}
```

2. **Add navigation:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const MyScreen()),
);
```

### Adding a New Model

1. **Create model file:**
```dart
// lib/models/my_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MyModel {
  final String id;
  final String name;
  final DateTime createdAt;

  MyModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // From Firestore
  factory MyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MyModel(
      id: doc.id,
      name: data['name'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
```

### Adding a New Provider

1. **Create provider file:**
```dart
// lib/providers/my_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/my_model.dart';

final myDataProvider = StreamProvider<List<MyModel>>((ref) {
  return FirebaseFirestore.instance
    .collection('my_collection')
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => MyModel.fromFirestore(doc))
      .toList());
});
```

2. **Use in widget:**
```dart
final myData = ref.watch(myDataProvider);

myData.when(
  data: (items) => ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ListTile(
      title: Text(items[index].name),
    ),
  ),
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

---

## Debugging

### Common Issues

#### 1. Firebase Connection Issues
```bash
# Check Firebase configuration
flutter pub run firebase_core:check

# Verify google-services.json exists
ls android/app/google-services.json
```

#### 2. Build Errors
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

#### 3. Hot Reload Not Working
- Restart app: `r` in terminal
- Hot restart: `R` in terminal
- Full restart: Stop and run again

#### 4. Provider Not Updating
- Check if using `watch` instead of `read`
- Verify provider is returning new instance
- Check if `==` operator is overridden

### Debugging Tools

#### Flutter DevTools
```bash
# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

#### Logging
```dart
import 'package:flutter/foundation.dart';

// Debug print
debugPrint('My debug message');

// Conditional logging
if (kDebugMode) {
  print('Debug only message');
}
```

#### Firebase Emulator (Optional)
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize emulators
firebase init emulators

# Start emulators
firebase emulators:start
```

---

## Performance Optimization

### Best Practices

1. **Use `const` constructors** where possible
2. **Avoid rebuilding entire trees** - use `Consumer` or `watch` selectively
3. **Implement pagination** for large lists
4. **Cache images** using `CachedNetworkImage`
5. **Lazy load data** - don't load everything at once
6. **Dispose controllers** properly
7. **Use `ListView.builder`** instead of `ListView` for long lists

### Performance Monitoring
```dart
// Measure widget build time
import 'package:flutter/foundation.dart';

@override
Widget build(BuildContext context) {
  return PerformanceOverlay.allEnabled(
    child: MyApp(),
  );
}
```

---

## Resources

### Documentation
- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod Docs](https://riverpod.dev/)
- [Firebase Flutter](https://firebase.flutter.dev/)
- [Material Design](https://material.io/design)

### Project Docs
- [Architecture Overview](ARCHITECTURE.md)
- [Architecture Decisions](ARCHITECTURE_DECISIONS.md)
- [Features Completed](FEATURES_COMPLETED.md)
- [Features Pending](FEATURES_PENDING.md)

### Community
- [Flutter Discord](https://discord.gg/flutter)
- [Riverpod Discord](https://discord.gg/riverpod)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

## Getting Help

1. **Check documentation** in `/docs` folder
2. **Review similar code** in the project
3. **Search issues** on GitHub (if applicable)
4. **Ask team members** on Slack/Discord
5. **Stack Overflow** for general Flutter questions

---

**Happy Coding! 🚀**
