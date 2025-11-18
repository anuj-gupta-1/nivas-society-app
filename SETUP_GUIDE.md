# Setup Guide - Getting Started with Nivas

## Prerequisites

### 1. Install Flutter
If you haven't installed Flutter yet:

**Windows:**
1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter` (or your preferred location)
3. Add to PATH:
   - Search "Environment Variables" in Windows
   - Edit "Path" variable
   - Add: `C:\src\flutter\bin`
4. Verify: Open new terminal and run `flutter --version`

**Quick Install (using Git):**
```bash
git clone https://github.com/flutter/flutter.git -b stable C:\src\flutter
```

### 2. Install Android Studio
1. Download: https://developer.android.com/studio
2. Install Android SDK (API 34)
3. Install Android SDK Command-line Tools
4. Accept licenses: `flutter doctor --android-licenses`

### 3. Verify Setup
```bash
flutter doctor
```

Should show:
- ✓ Flutter
- ✓ Android toolchain
- ✓ Android Studio

---

## Running the App

### 1. Navigate to Project
```bash
cd nivas
```

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Clean Build (if needed)
```bash
flutter clean
flutter pub get
```

### 4. Run on Device/Emulator
```bash
# List available devices
flutter devices

# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>
```

---

## Fixing the Gradle Error

The error you encountered was due to Android Gradle Plugin version mismatch. 

**Already Fixed in Latest Commit:**
- ✅ Downgraded AGP from 8.1.0 to 7.3.0
- ✅ Set explicit compileSdkVersion to 34
- ✅ Set minSdkVersion to 21
- ✅ Added multiDexEnabled

**If you still get errors:**

1. **Clean the project:**
```bash
cd nivas
flutter clean
rm -rf android/.gradle
rm -rf android/app/build
flutter pub get
```

2. **Update Flutter:**
```bash
flutter upgrade
flutter doctor
```

3. **Try running again:**
```bash
flutter run
```

---

## Common Issues

### Issue: "Flutter not found"
**Solution:** Add Flutter to PATH (see Prerequisites above)

### Issue: "Android licenses not accepted"
**Solution:** 
```bash
flutter doctor --android-licenses
```
Press 'y' to accept all

### Issue: "No devices found"
**Solution:** 
- Connect Android phone via USB (enable USB debugging)
- Or start Android Emulator from Android Studio

### Issue: "Gradle build failed"
**Solution:**
```bash
cd nivas/android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## Firebase Setup (Required for Full Functionality)

The app needs Firebase to work. See `docs/DEPLOYMENT_GUIDE.md` for detailed Firebase setup.

**Quick Firebase Setup:**

1. Go to https://console.firebase.google.com
2. Create new project: "Nivas"
3. Add Android app:
   - Package name: `com.nivas.app`
   - Download `google-services.json`
   - Place in: `nivas/android/app/google-services.json`
4. Enable services:
   - Authentication → Phone
   - Firestore Database
   - Storage

---

## Next Steps

Once the app runs successfully:

1. **Test Registration Flow**
   - Enter phone number
   - Verify OTP
   - Complete profile
   - Upload document

2. **Test Admin Features**
   - Login as admin
   - Verify pending users
   - Create groups

3. **Test Discussion System**
   - Create threads
   - Post replies
   - Test real-time updates

---

## Need Help?

- Check `docs/DEVELOPMENT_GUIDE.md` for detailed development info
- Check `docs/DEPLOYMENT_GUIDE.md` for deployment steps
- Check `README.md` for project overview

## Quick Commands Reference

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Run tests
flutter test

# Check for issues
flutter doctor -v

# Clean build
flutter clean
```
