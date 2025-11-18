# Firebase Setup Guide for Nivas

**Time Required:** 1-2 hours  
**Difficulty:** Medium  
**Prerequisites:** Google account

---

## Why Firebase is Required

The Nivas app uses Firebase for:
- **Authentication:** Phone number login with OTP
- **Database:** Firestore for real-time data
- **Storage:** File uploads (documents, images)
- **Messaging:** Push notifications (FCM)

**Without Firebase, the app will crash on startup.**

---

## Step-by-Step Setup

### Step 1: Create Firebase Project (10 mins)

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com
   - Click "Add project" or "Create a project"

2. **Project Details**
   - Project name: `Nivas` (or your preferred name)
   - Project ID: Will be auto-generated (e.g., `nivas-12345`)
   - Click "Continue"

3. **Google Analytics** (Optional)
   - Enable or disable as per your preference
   - Click "Create project"
   - Wait for project creation (30-60 seconds)

4. **Project Created!**
   - Click "Continue" to go to project dashboard

---

### Step 2: Add Android App (15 mins)

1. **Add Android App**
   - In Firebase Console, click the Android icon
   - Or go to: Project Settings → Your apps → Add app → Android

2. **Register App**
   - **Android package name:** `com.nivas.app`
     - ⚠️ Must match exactly! This is defined in `nivas/android/app/build.gradle`
   - **App nickname:** Nivas (optional)
   - **Debug signing certificate SHA-1:** Leave blank for now
   - Click "Register app"

3. **Download Config File**
   - Download `google-services.json`
   - **Important:** Save this file!

4. **Add Config to Project**
   ```
   Place google-services.json in:
   nivas/android/app/google-services.json
   ```
   
   **Exact location:**
   ```
   nivas-society-app/
   └── nivas/
       └── android/
           └── app/
               └── google-services.json  ← HERE
   ```

5. **Verify Placement**
   - The file should be at the same level as `build.gradle`
   - Check that it's not in a subfolder

6. **Click "Next"** in Firebase Console
   - Skip the SDK setup steps (already done in code)
   - Click "Next" → "Continue to console"

---

### Step 3: Enable Authentication (10 mins)

1. **Go to Authentication**
   - In Firebase Console sidebar: Build → Authentication
   - Click "Get started"

2. **Enable Phone Authentication**
   - Click "Sign-in method" tab
   - Find "Phone" in the list
   - Click "Phone"
   - Toggle "Enable"
   - Click "Save"

3. **Test Phone Numbers** (Optional for testing)
   - Scroll down to "Phone numbers for testing"
   - Add test numbers if you want to test without real SMS
   - Example: `+919999999999` with code `123456`
   - Click "Save"

---

### Step 4: Set Up Firestore Database (15 mins)

1. **Go to Firestore**
   - In Firebase Console sidebar: Build → Firestore Database
   - Click "Create database"

2. **Choose Location**
   - Select a location close to your users
   - For India: `asia-south1` (Mumbai)
   - Click "Next"

3. **Security Rules**
   - Choose "Start in **test mode**" for now
   - ⚠️ This allows read/write for 30 days
   - We'll add proper rules later
   - Click "Enable"

4. **Wait for Database Creation**
   - Takes 1-2 minutes
   - Database will be created with no collections

5. **Update Security Rules** (Important!)
   - Go to "Rules" tab
   - Replace with these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
    
    // Projects collection
    match /projects/{projectId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    // Project memberships
    match /project_memberships/{membershipId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated();
    }
    
    // Groups
    match /groups/{groupId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    // Spaces
    match /spaces/{spaceId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    // Threads
    match /threads/{threadId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated();
      
      // Replies subcollection
      match /replies/{replyId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated();
        allow update, delete: if isAuthenticated();
      }
    }
    
    // Group access requests
    match /group_access_requests/{requestId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated();
    }
  }
}
```

   - Click "Publish"

---

### Step 5: Set Up Storage (10 mins)

1. **Go to Storage**
   - In Firebase Console sidebar: Build → Storage
   - Click "Get started"

2. **Security Rules**
   - Choose "Start in **test mode**"
   - Click "Next"

3. **Choose Location**
   - Use same location as Firestore
   - Click "Done"

4. **Update Storage Rules**
   - Go to "Rules" tab
   - Replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      // Allow authenticated users to upload
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.resource.size < 10 * 1024 * 1024; // 10MB limit
    }
  }
}
```

   - Click "Publish"

---

### Step 6: Enable Cloud Messaging (5 mins)

1. **Go to Cloud Messaging**
   - In Firebase Console sidebar: Build → Cloud Messaging
   - Click "Get started" (if prompted)

2. **No Additional Setup Needed**
   - FCM is automatically enabled
   - The app already handles FCM token registration

---

### Step 7: Create Initial Data (Optional, 10 mins)

To test the app, you'll need at least one project. You can create it manually:

1. **Go to Firestore**
   - Click "Start collection"

2. **Create Projects Collection**
   - Collection ID: `projects`
   - Click "Next"

3. **Add First Project Document**
   - Document ID: Auto-ID
   - Add fields:
     ```
     project_id: (auto-generated ID)
     name: "Test Society"
     location: "Mumbai, India"
     phases: ["Phase 1", "Phase 2"]
     blocks: ["Block A", "Block B", "Block C"]
     created_at: (timestamp - now)
     ```
   - Click "Save"

4. **Note the Project ID**
   - Copy the auto-generated document ID
   - You'll need this to add yourself as a member

---

## Verification Checklist

Before running the app, verify:

- [ ] `google-services.json` is in `nivas/android/app/`
- [ ] Phone authentication is enabled
- [ ] Firestore database is created
- [ ] Firestore rules are updated
- [ ] Storage is enabled
- [ ] Storage rules are updated
- [ ] Cloud Messaging is enabled

---

## Testing the Setup

### Run the App

```bash
cd nivas
flutter run
```

### Expected Behavior

1. **App Starts Successfully**
   - No Firebase initialization errors
   - Shows phone entry screen

2. **Phone Authentication Works**
   - Enter phone number
   - Receive OTP (or use test number)
   - Verify OTP

3. **Profile Setup**
   - Fill in profile details
   - Upload document

4. **Verification Pending**
   - Shows pending verification screen

### Common Issues

**Issue: "Default FirebaseApp is not initialized"**
- Solution: Check `google-services.json` is in correct location
- Run: `flutter clean` then `flutter run`

**Issue: "Phone authentication not enabled"**
- Solution: Enable Phone auth in Firebase Console

**Issue: "Permission denied" in Firestore**
- Solution: Update Firestore security rules (see Step 4)

**Issue: "Storage upload failed"**
- Solution: Update Storage security rules (see Step 5)

---

## Production Considerations

### Before Beta Launch:

1. **Update Security Rules**
   - Current rules are permissive for testing
   - Add proper role-based access control
   - See `docs/DATABASE_SCHEMA.md` for detailed rules

2. **Set Up Indexes**
   - Firestore will prompt you to create indexes
   - Click the links in error messages to auto-create

3. **Configure App Check** (Optional)
   - Protects against abuse
   - Go to: Build → App Check
   - Register your app

4. **Set Up Budget Alerts**
   - Go to: Project Settings → Usage and billing
   - Set up budget alerts to avoid surprises

### Before Production Launch:

1. **Add SHA-1 Certificate**
   - Generate release keystore
   - Add SHA-1 to Firebase Console
   - Required for production phone auth

2. **Enable App Verification**
   - Set up reCAPTCHA for web
   - Configure SafetyNet for Android

3. **Review Security Rules**
   - Audit all Firestore rules
   - Audit all Storage rules
   - Test with different user roles

4. **Set Up Monitoring**
   - Enable Crashlytics
   - Set up Performance Monitoring
   - Configure Analytics

---

## Cost Estimation

### Free Tier (Spark Plan)
- **Authentication:** 10K verifications/month
- **Firestore:** 50K reads, 20K writes, 20K deletes/day
- **Storage:** 5GB storage, 1GB/day downloads
- **Cloud Messaging:** Unlimited

### Paid Tier (Blaze Plan)
- **Pay as you go** after free tier
- **Estimated for 100 users:**
  - ~$5-10/month for Firestore
  - ~$2-5/month for Storage
  - Phone auth: ~$0.01 per verification

**Recommendation:** Start with free tier, upgrade when needed

---

## Next Steps

1. ✅ Complete this Firebase setup
2. ✅ Run the app: `flutter run`
3. ✅ Test registration flow
4. ✅ Create test data
5. ✅ Test all features

**Once Firebase is set up, the app will work fully!**

---

## Need Help?

- **Firebase Docs:** https://firebase.google.com/docs
- **Flutter Firebase:** https://firebase.flutter.dev
- **Support:** Firebase Console → Support

**Estimated Total Time:** 1-2 hours for complete setup
