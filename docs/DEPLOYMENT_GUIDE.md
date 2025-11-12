# Deployment Guide

**Project:** Nivas - Society Management App  
**For:** Deploying to production and beta testing  
**Last Updated:** 2024

---

## Pre-Deployment Checklist

### Code Quality
- [ ] All features tested manually
- [ ] No console errors or warnings
- [ ] Code formatted: `flutter format .`
- [ ] Code analyzed: `flutter analyze`
- [ ] All TODOs addressed or documented

### Configuration
- [ ] Firebase project configured (Production)
- [ ] App name and package name finalized
- [ ] App icons added
- [ ] Splash screen configured
- [ ] Version number updated in `pubspec.yaml`
- [ ] Build number incremented

### Security
- [ ] Firebase Security Rules reviewed
- [ ] API keys secured (not in version control)
- [ ] Sensitive data encrypted
- [ ] Admin permissions verified

### Documentation
- [ ] README.md updated
- [ ] CHANGELOG.md created
- [ ] User guide prepared (optional)
- [ ] Known issues documented

---

## Build Configuration

### Update Version

Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+build_number
```

Version format: `MAJOR.MINOR.PATCH+BUILD`
- **MAJOR:** Breaking changes
- **MINOR:** New features
- **PATCH:** Bug fixes
- **BUILD:** Incremental build number

### App Configuration

#### Android (`android/app/build.gradle`)
```gradle
android {
    defaultConfig {
        applicationId "com.example.nivas"  // Change this
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1  // Increment for each release
        versionName "1.0.0"
    }
}
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

---

## Building the App

### Android Build

#### Debug Build (for testing)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

#### Release Build (for production)
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```
Outputs:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

#### Split APKs by ABI (smaller size)
```bash
flutter build apk --split-per-abi --release
```
Generates separate APKs for:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit Intel)

### iOS Build

#### Prerequisites
- macOS with Xcode installed
- Apple Developer account
- Provisioning profiles configured

#### Debug Build
```bash
flutter build ios --debug
```

#### Release Build
```bash
flutter build ios --release
```

#### Build for App Store
```bash
flutter build ipa --release
```
Output: `build/ios/ipa/nivas.ipa`

---

## Code Signing (Android)

### Generate Keystore

```bash
keytool -genkey -v -keystore ~/nivas-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias nivas
```

Save keystore details:
- **Keystore password:** [SECURE]
- **Key alias:** nivas
- **Key password:** [SECURE]

### Configure Signing

Create `android/key.properties`:
```properties
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=nivas
storeFile=<path-to-keystore>/nivas-release-key.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

**⚠️ IMPORTANT:** Add `key.properties` to `.gitignore`!

---

## Beta Testing

### Option 1: Firebase App Distribution

#### Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init hosting
```

#### Deploy to Firebase App Distribution
```bash
# Build release APK
flutter build apk --release

# Upload to Firebase
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <firebase-app-id> \
  --groups "beta-testers" \
  --release-notes "Beta version 1.0.0 - Initial release"
```

#### Invite Testers
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Navigate to App Distribution
3. Add testers by email
4. Create tester groups
5. Distribute build to groups

### Option 2: Google Play Internal Testing

#### Setup
1. Go to [Google Play Console](https://play.google.com/console)
2. Create app
3. Complete store listing
4. Set up internal testing track

#### Upload Build
```bash
# Build App Bundle
flutter build appbundle --release

# Upload via Play Console
# Or use fastlane for automation
```

#### Invite Testers
1. Create internal testing track
2. Add testers by email
3. Share testing link
4. Testers download from Play Store

### Option 3: Direct APK Distribution

#### Build and Share
```bash
# Build release APK
flutter build apk --release

# Share APK file directly
# Users need to enable "Install from Unknown Sources"
```

**⚠️ Note:** Not recommended for production, only for quick testing.

---

## Production Deployment

### Google Play Store

#### Prerequisites
- [ ] Google Play Developer account ($25 one-time fee)
- [ ] App signed with release keystore
- [ ] Privacy policy URL
- [ ] App screenshots (phone, tablet)
- [ ] Feature graphic (1024x500)
- [ ] App icon (512x512)

#### Steps

1. **Create App in Play Console**
   - Go to [Google Play Console](https://play.google.com/console)
   - Click "Create app"
   - Fill in app details

2. **Complete Store Listing**
   - App name: "Nivas - Society Management"
   - Short description (80 chars)
   - Full description (4000 chars)
   - Screenshots (at least 2)
   - Feature graphic
   - App icon
   - Category: Productivity / Social
   - Content rating questionnaire
   - Privacy policy URL

3. **Set Up App Content**
   - Target audience
   - Content rating
   - Privacy policy
   - App access (if login required)
   - Ads declaration

4. **Upload App Bundle**
   ```bash
   flutter build appbundle --release
   ```
   - Go to Production → Releases
   - Create new release
   - Upload `app-release.aab`
   - Add release notes
   - Review and rollout

5. **Review and Publish**
   - Complete all required sections
   - Submit for review
   - Wait for approval (1-7 days)

### Apple App Store

#### Prerequisites
- [ ] Apple Developer account ($99/year)
- [ ] App signed with distribution certificate
- [ ] Privacy policy URL
- [ ] App screenshots (various sizes)
- [ ] App icon (1024x1024)

#### Steps

1. **Create App in App Store Connect**
   - Go to [App Store Connect](https://appstoreconnect.apple.com/)
   - Click "My Apps" → "+"
   - Fill in app information

2. **Configure App**
   - Bundle ID: com.example.nivas
   - SKU: unique identifier
   - App name
   - Privacy policy URL
   - Category: Productivity / Social Networking
   - Age rating

3. **Prepare Metadata**
   - App description
   - Keywords
   - Screenshots (iPhone, iPad)
   - App preview video (optional)
   - Support URL
   - Marketing URL (optional)

4. **Build and Upload**
   ```bash
   flutter build ipa --release
   ```
   - Use Xcode or Transporter to upload IPA
   - Select build in App Store Connect
   - Add "What's New" text

5. **Submit for Review**
   - Complete all sections
   - Submit for review
   - Wait for approval (1-7 days)

---

## Firebase Configuration

### Production Environment

#### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isUser(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isProjectMember(projectId) {
      return isAuthenticated() && 
        exists(/databases/$(database)/documents/project_memberships/$(request.auth.uid + '_' + projectId));
    }
    
    function isSuperAdmin(projectId) {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/project_memberships/$(request.auth.uid + '_' + projectId)).data.role == 'superAdmin';
    }
    
    function isGroupMember(groupId) {
      return isAuthenticated() && 
        request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.member_ids;
    }
    
    function isGroupAdmin(groupId) {
      return isAuthenticated() && 
        request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.admin_ids;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isUser(userId);
    }
    
    // Projects collection
    match /projects/{projectId} {
      allow read: if isProjectMember(projectId);
      allow write: if isSuperAdmin(projectId);
    }
    
    // Project memberships
    match /project_memberships/{membershipId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isUser(membershipId.split('_')[0]) || isSuperAdmin(membershipId.split('_')[1]);
    }
    
    // Groups
    match /groups/{groupId} {
      allow read: if isProjectMember(resource.data.project_id);
      allow create: if isAuthenticated() && isSuperAdmin(request.resource.data.project_id);
      allow update, delete: if isGroupAdmin(groupId) || isSuperAdmin(resource.data.project_id);
    }
    
    // Spaces
    match /spaces/{spaceId} {
      allow read: if isGroupMember(resource.data.group_id);
      allow create: if isAuthenticated() && isGroupAdmin(request.resource.data.group_id);
      allow update, delete: if isGroupAdmin(resource.data.group_id);
    }
    
    // Threads
    match /threads/{threadId} {
      allow read: if isGroupMember(resource.data.group_id);
      allow create: if isAuthenticated() && isGroupMember(request.resource.data.group_id);
      allow update, delete: if isUser(resource.data.author_id) || isGroupAdmin(resource.data.group_id);
      
      // Replies subcollection
      match /replies/{replyId} {
        allow read: if isGroupMember(get(/databases/$(database)/documents/threads/$(threadId)).data.group_id);
        allow create: if isAuthenticated() && isGroupMember(get(/databases/$(database)/documents/threads/$(threadId)).data.group_id);
        allow update, delete: if isUser(resource.data.author_id) || isGroupAdmin(get(/databases/$(database)/documents/threads/$(threadId)).data.group_id);
      }
    }
    
    // Group access requests
    match /group_access_requests/{requestId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isGroupAdmin(resource.data.group_id);
    }
  }
}
```

#### Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Verification documents
    match /verification_documents/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Thread attachments
    match /thread_attachments/{projectId}/{groupId}/{threadId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // User profile photos
    match /profile_photos/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Deploy Security Rules
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# Deploy all
firebase deploy
```

---

## Monitoring & Analytics

### Firebase Analytics

Already integrated via `firebase_core`. Track custom events:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

// Log events
await analytics.logEvent(
  name: 'thread_created',
  parameters: {
    'group_id': groupId,
    'space_id': spaceId,
  },
);
```

### Crashlytics (Recommended)

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_crashlytics: ^3.0.0
```

Initialize in `main.dart`:
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runApp(MyApp());
}
```

### Performance Monitoring

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_performance: ^0.9.0
```

Track custom traces:
```dart
import 'package:firebase_performance/firebase_performance.dart';

final trace = FirebasePerformance.instance.newTrace('load_threads');
await trace.start();
// ... load threads
await trace.stop();
```

---

## Post-Deployment

### Monitor

1. **Firebase Console**
   - Check for errors in Crashlytics
   - Monitor user engagement in Analytics
   - Review performance metrics

2. **Play Console / App Store Connect**
   - Monitor crash reports
   - Read user reviews
   - Check download statistics

3. **User Feedback**
   - Set up feedback channel (email, form)
   - Monitor beta tester feedback
   - Track feature requests

### Update Strategy

#### Hotfix (Critical Bugs)
1. Fix bug immediately
2. Increment patch version (1.0.0 → 1.0.1)
3. Build and deploy ASAP
4. Notify users if necessary

#### Minor Update (New Features)
1. Develop features
2. Test thoroughly
3. Increment minor version (1.0.0 → 1.1.0)
4. Deploy to beta first
5. Roll out to production

#### Major Update (Breaking Changes)
1. Plan carefully
2. Communicate with users
3. Increment major version (1.0.0 → 2.0.0)
4. Provide migration guide
5. Gradual rollout

---

## Rollback Plan

### If Critical Issue Found

1. **Immediate Action**
   - Halt rollout in Play Console (if gradual)
   - Communicate issue to users
   - Start hotfix development

2. **Rollback (Play Store)**
   - Cannot rollback, must push new version
   - Quickly fix and release patch version
   - Use staged rollout (10% → 50% → 100%)

3. **Rollback (Firebase App Distribution)**
   - Distribute previous working version
   - Notify testers

---

## Automation Scripts

See `/scripts` folder for:
- `build.sh` - Build release APK/AAB
- `deploy.sh` - Deploy to Firebase
- `test.sh` - Run tests

---

## Checklist: First Production Release

- [ ] All MVP features tested
- [ ] Firebase production project configured
- [ ] Security rules deployed
- [ ] App signed with release keystore
- [ ] Version set to 1.0.0+1
- [ ] Store listing completed
- [ ] Screenshots and graphics ready
- [ ] Privacy policy published
- [ ] Beta testing completed
- [ ] Critical bugs fixed
- [ ] App bundle built
- [ ] Uploaded to Play Console
- [ ] Submitted for review
- [ ] Monitoring tools configured
- [ ] Support email set up
- [ ] Launch announcement prepared

---

**Good luck with your launch! 🚀**
