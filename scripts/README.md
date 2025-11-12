# Build & Deployment Scripts

Automation scripts for building and deploying the Nivas app.

---

## Available Scripts

### 1. `build.sh` / `build.bat`

**Purpose:** Build Android APK and App Bundle for release

**Usage:**
```bash
# Linux/Mac
./scripts/build.sh

# Windows
scripts\build.bat
```

**What it does:**
1. Cleans previous builds
2. Gets dependencies
3. Runs code analysis
4. Formats code
5. Builds APK/Bundle based on your choice

**Options:**
- APK (single file, larger size)
- App Bundle (for Play Store, recommended)
- Split APKs (multiple files, smaller size)
- All of the above

**Output locations:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`
- Split APKs: `build/app/outputs/flutter-apk/`

---

### 2. `test.sh`

**Purpose:** Run tests and code quality checks

**Usage:**
```bash
./scripts/test.sh
```

**What it does:**
1. Gets dependencies
2. Runs code analysis
3. Checks code formatting
4. Runs tests (if any exist)
5. Checks for common issues:
   - TODO comments
   - print() statements
   - Hardcoded strings

**Note:** Comprehensive testing is pending (see docs/FEATURES_PENDING.md)

---

### 3. `deploy.sh`

**Purpose:** Deploy app to Firebase App Distribution for beta testing

**Prerequisites:**
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project configured
- Logged in to Firebase: `firebase login`

**Usage:**
```bash
./scripts/deploy.sh
```

**What it does:**
1. Checks Firebase CLI installation
2. Authenticates with Firebase
3. Prompts for:
   - Firebase App ID
   - Release notes
   - Tester groups
4. Builds release APK
5. Uploads to Firebase App Distribution
6. Notifies testers

**Example:**
```bash
$ ./scripts/deploy.sh
Firebase App ID: 1:1234567890:android:abcdef1234567890
Release notes: Beta v1.0.0 - Initial release
Tester groups: beta-testers,internal-team
```

---

## Setup Instructions

### Make Scripts Executable (Linux/Mac)

```bash
chmod +x scripts/*.sh
```

### Firebase CLI Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# List your projects
firebase projects:list
```

### Get Firebase App ID

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings
4. Under "Your apps", find your Android app
5. Copy the App ID (format: `1:1234567890:android:abcdef1234567890`)

---

## Troubleshooting

### "Flutter not found"
- Ensure Flutter is installed and in PATH
- Run: `flutter doctor` to verify installation

### "Firebase CLI not found"
- Install: `npm install -g firebase-tools`
- Or use npx: `npx firebase-tools`

### "Permission denied" (Linux/Mac)
- Make scripts executable: `chmod +x scripts/*.sh`

### "Build failed"
- Run `flutter clean` and try again
- Check `flutter doctor` for issues
- Verify Firebase configuration

### "Deployment failed"
- Verify Firebase App ID is correct
- Check you're logged in: `firebase login`
- Ensure App Distribution is enabled in Firebase Console

---

## Manual Commands

If you prefer to run commands manually:

### Build Commands
```bash
# Clean
flutter clean

# Get dependencies
flutter pub get

# Analyze
flutter analyze

# Format
flutter format .

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Build Split APKs
flutter build apk --split-per-abi --release
```

### Deploy Commands
```bash
# Build
flutter build apk --release

# Deploy to Firebase
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app <firebase-app-id> \
  --groups "beta-testers" \
  --release-notes "Your release notes"
```

---

## CI/CD Integration

These scripts can be integrated into CI/CD pipelines:

### GitHub Actions Example
```yaml
name: Build and Deploy

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{secrets.FIREBASE_APP_ID}}
          token: ${{secrets.FIREBASE_TOKEN}}
          groups: beta-testers
          file: build/app/outputs/flutter-apk/app-release.apk
```

---

## Best Practices

1. **Always test locally** before deploying
2. **Increment version number** in `pubspec.yaml` before building
3. **Write meaningful release notes** for testers
4. **Use staged rollout** for production (10% → 50% → 100%)
5. **Keep Firebase App ID secure** (don't commit to version control)
6. **Test on real devices** before distributing

---

## Next Steps

After building:
1. Test APK on real device
2. Deploy to beta testers
3. Gather feedback
4. Fix critical bugs
5. Deploy to production

See [Deployment Guide](../docs/DEPLOYMENT_GUIDE.md) for complete deployment instructions.
