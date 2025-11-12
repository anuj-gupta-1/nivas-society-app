# Society Management App - Technical Design Document

## Executive Summary

This document outlines the technical architecture, technology stack, implementation approach, and deployment strategy for the Society Management App. The design prioritizes open-source tools, cost-effectiveness, scalability, and ease of maintenance for a hobby project that can scale to 1500+ units with 10% DAU and 30% MAU.

## Design Principles

1. **Open Source First:** Maximize use of free, open-source tools and frameworks
2. **Cost Optimization:** Start with free tiers, scale incrementally as user base grows
3. **Cross-Platform:** Single codebase for Android and iOS
4. **Scalability:** Architecture supports growth from 100 to 10,000+ users
5. **Maintainability:** Simple, well-documented code for long-term sustainability
6. **Offline-First:** Core features work without internet connectivity
7. **Real-Time:** Instant updates for discussions and notifications

## Technology Stack

### Frontend - Mobile Application

| Component | Technology | Rationale | Cost |
|-----------|-----------|-----------|------|
| **Framework** | Flutter 3.x | • Single codebase for Android/iOS<br>• Native performance<br>• Rich UI components<br>• Strong community support<br>• Hot reload for fast development | Free |
| **State Management** | Riverpod / Provider | • Simple, scalable state management<br>• Better than setState for complex apps<br>• Good documentation | Free |
| **Local Database** | Hive / SQLite | • Offline data storage<br>• Fast queries<br>• No setup required | Free |
| **HTTP Client** | Dio | • REST API calls<br>• Interceptors for auth<br>• Error handling | Free |
| **Image Handling** | cached_network_image | • Image caching<br>• Placeholder support<br>• Memory optimization | Free |
| **Rich Text Editor** | flutter_quill | • Bold, italic, links, strikethrough<br>• Mention support<br>• Customizable | Free |

### Backend - Server & Database

**Option A: Firebase (Recommended for MVP)**

| Component | Service | Features | Free Tier | Paid Tier |
|-----------|---------|----------|-----------|-----------|
| **Authentication** | Firebase Auth | Phone auth, user management | 10K verifications/month | $0.06/verification |
| **Database** | Cloud Firestore | NoSQL, real-time sync | 1GB storage, 50K reads/day | $0.18/GB, $0.06/100K reads |
| **Storage** | Cloud Storage | File/media storage | 5GB storage, 1GB/day download | $0.026/GB storage |
| **Hosting** | Firebase Hosting | Admin dashboard hosting | 10GB/month | $0.15/GB |
| **Functions** | Cloud Functions | Backend logic | 2M invocations/month | $0.40/M invocations |
| **Notifications** | FCM | Push notifications | Unlimited | Free |

**Estimated Monthly Cost (1500 users, 10% DAU, 30% MAU):**
- **Month 1-3:** $0 (within free tier)
- **Month 4-6:** $10-20/month
- **Month 7-12:** $30-50/month
- **Year 2+:** $50-100/month

**Option B: Supabase (Open Source Alternative)**

| Component | Service | Features | Free Tier | Paid Tier |
|-----------|---------|----------|-----------|-----------|
| **Authentication** | Supabase Auth | Phone/email auth | Unlimited | $25/month (Pro) |
| **Database** | PostgreSQL | Relational DB with real-time | 500MB, unlimited API requests | $25/month (8GB) |
| **Storage** | Supabase Storage | File storage | 1GB | $25/month (100GB) |
| **Functions** | Edge Functions | Deno-based serverless | 500K invocations/month | $25/month (2M) |
| **Real-time** | Realtime subscriptions | Live updates | Included | Included |

**Estimated Monthly Cost:**
- **Month 1-6:** $0 (free tier sufficient)
- **Month 7+:** $25/month (Pro plan)

**Self-Hosted Supabase (Future):**
- Host on DigitalOcean/AWS: $10-20/month
- Full control, no vendor lock-in
- Requires DevOps knowledge

### Recommended Stack for MVP

```
Flutter Mobile App (Android + iOS)
        ↓
    Firebase
    ├── Authentication (Phone number)
    ├── Cloud Firestore (Database)
    ├── Cloud Storage (Files/Media)
    ├── Cloud Functions (Backend logic)
    └── FCM (Push notifications)
```

**Why Firebase for MVP:**
- Generous free tier covers initial launch
- Zero DevOps overhead
- Real-time sync out of the box
- Excellent Flutter integration
- Easy to migrate to Supabase later if needed


## System Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Mobile Applications                      │
│  ┌──────────────────────┐    ┌──────────────────────┐      │
│  │   Android App        │    │     iOS App          │      │
│  │   (Flutter)          │    │    (Flutter)         │      │
│  └──────────────────────┘    └──────────────────────┘      │
│              │                          │                    │
│              └──────────┬───────────────┘                    │
│                         │                                    │
└─────────────────────────┼────────────────────────────────────┘
                          │
                          │ HTTPS/REST API
                          │
┌─────────────────────────▼────────────────────────────────────┐
│                   Firebase Backend                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Firebase Authentication                             │   │
│  │  - Phone number verification                         │   │
│  │  - User session management                           │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Cloud Firestore (NoSQL Database)                    │   │
│  │  Collections:                                        │   │
│  │  - users, projects, memberships, units              │   │
│  │  - groups, spaces, threads, replies                 │   │
│  │  - documents, tags, notifications                   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Cloud Storage                                       │   │
│  │  - Verification documents                            │   │
│  │  - User profile photos                               │   │
│  │  - Shared media (images, videos, docs)              │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Cloud Functions (Backend Logic)                     │   │
│  │  - User verification workflow                        │   │
│  │  - Notification triggers                             │   │
│  │  - Data validation & sanitization                   │   │
│  │  - Search indexing                                   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Firebase Cloud Messaging (FCM)                      │   │
│  │  - Push notifications                                │   │
│  │  - Real-time alerts                                  │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

### Application Architecture (Flutter)

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Screens    │  │   Widgets    │  │   Dialogs    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                  State Management Layer                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Riverpod Providers                                  │   │
│  │  - Auth Provider, User Provider                      │   │
│  │  - Project Provider, Group Provider                  │   │
│  │  - Thread Provider, Document Provider                │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                    Business Logic Layer                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Services                                            │   │
│  │  - AuthService, UserService                          │   │
│  │  - GroupService, ThreadService                       │   │
│  │  - DocumentService, NotificationService              │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Repositories│  │  Local Cache │  │  API Client  │      │
│  │  (Firestore) │  │  (Hive/SQLite│  │  (Dio)       │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└──────────────────────────────────────────────────────────────┘
```

## Database Schema Design (Firestore)

### Collection Structure

```
/users (collection)
  /{userId} (document)
    - phone_number: string
    - email: string (optional)
    - created_at: timestamp
    
/projects (collection)
  /{projectId} (document)
    - project_name: string
    - location: string
    - rera_number: string
    - total_units: number
    - phases: array
    - blocks: array
    - unit_structure: map
    - status: string
    - created_at: timestamp
    - created_by: string (userId)
    
/project_memberships (collection)
  /{membershipId} (document)
    - user_id: string
    - project_id: string
    - display_name: string
    - role: string (Owner/Group_Admin/Super_Admin)
    - verification_status: string
    - verification_doc_url: string
    - verified_at: timestamp
    - verified_by: string (userId)
    - unit_ownerships: array of maps
      [{
        unit_id: string,
        unit_number: string,
        ownership_type: string
      }]
    
/groups (collection)
  /{groupId} (document)
    - project_id: string
    - group_name: string
    - description: string
    - group_type: string (General/Private)
    - access_criteria: map
    - member_ids: array
    - admin_ids: array
    - created_by: string
    - created_at: timestamp
    
/spaces (collection)
  /{spaceId} (document)
    - group_id: string
    - project_id: string
    - space_name: string
    - space_type: string (General/Dedicated)
    - created_by: string
    - created_at: timestamp
    
/threads (collection)
  /{threadId} (document)
    - space_id: string
    - group_id: string
    - project_id: string
    - author_id: string
    - author_name: string
    - title: string
    - content: string
    - content_type: string
    - tags: array
    - is_pinned: boolean
    - reply_count: number
    - last_activity: timestamp
    - created_at: timestamp
    - updated_at: timestamp
    
  /threads/{threadId}/replies (subcollection)
    /{replyId} (document)
      - parent_reply_id: string (optional, for nested)
      - author_id: string
      - author_name: string
      - content: string
      - mentions: array of userIds
      - created_at: timestamp
      - updated_at: timestamp
      
/documents (collection)
  /{documentId} (document)
    - project_id: string
    - uploaded_by: string
    - uploader_name: string
    - source_thread_id: string
    - source_space_id: string
    - source_group_id: string
    - file_name: string
    - file_type: string
    - file_size: number
    - file_url: string
    - tags: array
    - created_at: timestamp
    
/tags (collection)
  /{tagId} (document)
    - project_id: string
    - tag_name: string
    - tag_category: string
    - usage_count: number
    - created_by: string
    - created_at: timestamp
    
/notifications (collection)
  /{notificationId} (document)
    - user_id: string
    - project_id: string
    - notification_type: string
    - title: string
    - content: string
    - source_id: string
    - source_type: string
    - is_read: boolean
    - created_at: timestamp
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isProjectMember(projectId) {
      return exists(/databases/$(database)/documents/project_memberships/$(request.auth.uid + '_' + projectId));
    }
    
    function isSuperAdmin(projectId) {
      let membership = get(/databases/$(database)/documents/project_memberships/$(request.auth.uid + '_' + projectId));
      return membership.data.role == 'Super_Admin';
    }
    
    function isGroupMember(groupId) {
      let group = get(/databases/$(database)/documents/groups/$(groupId));
      return request.auth.uid in group.data.member_ids;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && request.auth.uid == userId;
    }
    
    // Projects collection
    match /projects/{projectId} {
      allow read: if isAuthenticated() && isProjectMember(projectId);
      allow write: if isAuthenticated() && isSuperAdmin(projectId);
    }
    
    // Project memberships
    match /project_memberships/{membershipId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && isSuperAdmin(resource.data.project_id);
    }
    
    // Groups
    match /groups/{groupId} {
      allow read: if isAuthenticated() && isGroupMember(groupId);
      allow write: if isAuthenticated() && (isSuperAdmin(resource.data.project_id) || request.auth.uid in resource.data.admin_ids);
    }
    
    // Threads and replies
    match /threads/{threadId} {
      allow read: if isAuthenticated() && isGroupMember(resource.data.group_id);
      allow create: if isAuthenticated() && isGroupMember(request.resource.data.group_id);
      allow update, delete: if isAuthenticated() && (request.auth.uid == resource.data.author_id || isSuperAdmin(resource.data.project_id));
      
      match /replies/{replyId} {
        allow read: if isAuthenticated() && isGroupMember(get(/databases/$(database)/documents/threads/$(threadId)).data.group_id);
        allow create: if isAuthenticated();
        allow update, delete: if isAuthenticated() && request.auth.uid == resource.data.author_id;
      }
    }
    
    // Documents
    match /documents/{documentId} {
      allow read: if isAuthenticated() && isProjectMember(resource.data.project_id);
      allow create: if isAuthenticated();
      allow delete: if isAuthenticated() && (request.auth.uid == resource.data.uploaded_by || isSuperAdmin(resource.data.project_id));
    }
    
    // Notifications
    match /notifications/{notificationId} {
      allow read, update: if isAuthenticated() && request.auth.uid == resource.data.user_id;
      allow create: if isAuthenticated();
    }
  }
}
```


## Key Features Implementation

### 1. User Authentication & Verification

**Flow:**
```
1. User enters phone number (+91-XXXXXXXXXX)
2. App validates format (10 digits for Indian numbers)
3. User fills profile: name, unit, block, phase
4. User uploads verification document (max 2MB)
5. Document uploaded to Cloud Storage
6. User record created with status: "Pending"
7. Admin receives notification
8. Admin reviews in verification dashboard
9. Admin approves/rejects
10. User receives notification and gains access
```

**Implementation:**
```dart
// Phone validation
bool validateIndianPhone(String phone) {
  final regex = RegExp(r'^\+91-[6-9]\d{9}$');
  return regex.hasMatch(phone);
}

// Document upload
Future<String> uploadVerificationDoc(File file) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('verification_docs/${userId}_${timestamp}.${extension}');
  await ref.putFile(file);
  return await ref.getDownloadURL();
}

// Create pending user
Future<void> createPendingUser(UserData data) async {
  await FirebaseFirestore.instance
      .collection('project_memberships')
      .doc('${userId}_${projectId}')
      .set({
    'user_id': userId,
    'project_id': projectId,
    'display_name': data.name,
    'verification_status': 'Pending',
    'verification_doc_url': docUrl,
    'unit_ownerships': [
      {
        'unit_number': data.unitNumber,
        'block': data.block,
        'phase': data.phase,
      }
    ],
    'created_at': FieldValue.serverTimestamp(),
  });
}
```

### 2. User Mention System (@username)

**Flow:**
```
1. User types "@" in text field
2. App triggers autocomplete overlay
3. Fetch project members from Firestore
4. Display filtered list as user types
5. User selects from list
6. Insert mention tag with user_id
7. On post submit, extract mentioned user_ids
8. Send notifications to mentioned users
```

**Implementation:**
```dart
// Mention detection
class MentionTextEditingController extends TextEditingController {
  void detectMention() {
    final text = this.text;
    final cursorPos = selection.baseOffset;
    
    // Find @ symbol before cursor
    int atIndex = text.lastIndexOf('@', cursorPos - 1);
    if (atIndex != -1) {
      String query = text.substring(atIndex + 1, cursorPos);
      // Trigger autocomplete with query
      searchUsers(query);
    }
  }
}

// User search
Future<List<User>> searchUsers(String query) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('project_memberships')
      .where('project_id', isEqualTo: currentProjectId)
      .where('verification_status', isEqualTo: 'Approved')
      .get();
  
  return snapshot.docs
      .map((doc) => User.fromFirestore(doc))
      .where((user) => user.displayName
          .toLowerCase()
          .contains(query.toLowerCase()))
      .toList();
}

// Insert mention
void insertMention(User user) {
  final mention = '@${user.displayName}';
  // Store user_id in hidden metadata
  mentionedUsers.add(user.userId);
  // Insert visible mention text
  controller.text = controller.text.replaceRange(
    atIndex, cursorPos, mention + ' '
  );
}

// Send notifications
Future<void> notifyMentionedUsers(List<String> userIds) async {
  for (String userId in userIds) {
    await FirebaseFirestore.instance
        .collection('notifications')
        .add({
      'user_id': userId,
      'notification_type': 'mention',
      'title': '${currentUser.name} mentioned you',
      'content': threadTitle,
      'source_id': threadId,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });
    
    // Send FCM push notification
    await sendPushNotification(userId, 'You were mentioned');
  }
}
```

### 3. Group & Space Management

**Creating a Group:**
```dart
Future<void> createGroup({
  required String projectId,
  required String groupName,
  required String description,
  required String groupType, // General/Private
}) async {
  final groupRef = FirebaseFirestore.instance
      .collection('groups')
      .doc();
  
  await groupRef.set({
    'project_id': projectId,
    'group_name': groupName,
    'description': description,
    'group_type': groupType,
    'member_ids': groupType == 'General' 
        ? await getAllProjectMembers(projectId)
        : [],
    'admin_ids': [currentUserId],
    'created_by': currentUserId,
    'created_at': FieldValue.serverTimestamp(),
  });
  
  // Create default General Space
  await createSpace(
    groupId: groupRef.id,
    spaceName: 'General',
    spaceType: 'General',
  );
}
```

**Converting Thread to Dedicated Space:**
```dart
Future<void> convertThreadToSpace({
  required String threadId,
  required String groupId,
  required String spaceName,
}) async {
  // Create new dedicated space
  final spaceRef = await FirebaseFirestore.instance
      .collection('spaces')
      .add({
    'group_id': groupId,
    'space_name': spaceName,
    'space_type': 'Dedicated',
    'created_by': currentUserId,
    'created_at': FieldValue.serverTimestamp(),
  });
  
  // Move thread to new space
  await FirebaseFirestore.instance
      .collection('threads')
      .doc(threadId)
      .update({
    'space_id': spaceRef.id,
  });
  
  // Notify thread participants
  await notifyThreadParticipants(threadId, 
      'Thread moved to dedicated space: $spaceName');
}
```

### 4. Document Management with Permissions

**Upload Document:**
```dart
Future<void> uploadDocument({
  required File file,
  required String threadId,
  required String spaceId,
  required String groupId,
}) async {
  // Validate file size (2MB max)
  if (file.lengthSync() > 2 * 1024 * 1024) {
    throw Exception('File size exceeds 2MB limit');
  }
  
  // Upload to Cloud Storage
  final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
  final ref = FirebaseStorage.instance
      .ref()
      .child('documents/$projectId/$fileName');
  
  await ref.putFile(file);
  final downloadUrl = await ref.getDownloadURL();
  
  // Create document record
  await FirebaseFirestore.instance
      .collection('documents')
      .add({
    'project_id': projectId,
    'uploaded_by': currentUserId,
    'uploader_name': currentUser.displayName,
    'source_thread_id': threadId,
    'source_space_id': spaceId,
    'source_group_id': groupId,
    'file_name': file.name,
    'file_type': file.extension,
    'file_size': file.lengthSync(),
    'file_url': downloadUrl,
    'tags': [],
    'created_at': FieldValue.serverTimestamp(),
  });
}
```

**Search Documents with Permission Check:**
```dart
Future<List<Document>> searchDocuments(String query) async {
  // Get all documents in project
  final snapshot = await FirebaseFirestore.instance
      .collection('documents')
      .where('project_id', isEqualTo: currentProjectId)
      .get();
  
  List<Document> results = [];
  
  for (var doc in snapshot.docs) {
    final document = Document.fromFirestore(doc);
    
    // Check if user has access to source group
    final hasAccess = await checkGroupAccess(
        currentUserId, document.sourceGroupId);
    
    // Filter by search query
    if (document.fileName.toLowerCase().contains(query.toLowerCase())) {
      if (hasAccess) {
        // Full access - show source context
        results.add(document);
      } else {
        // Limited access - show document but hide source
        results.add(document.copyWith(
          sourceContext: 'Shared in private group',
          sourceThreadId: null,
        ));
      }
    }
  }
  
  return results;
}
```

### 5. Real-Time Updates & Notifications

**Listen to Thread Updates:**
```dart
Stream<List<Reply>> watchThreadReplies(String threadId) {
  return FirebaseFirestore.instance
      .collection('threads')
      .doc(threadId)
      .collection('replies')
      .orderBy('created_at', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Reply.fromFirestore(doc))
          .toList());
}
```

**Push Notification Setup:**
```dart
// Initialize FCM
Future<void> initializeFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  // Request permission
  await messaging.requestPermission();
  
  // Get FCM token
  String? token = await messaging.getToken();
  
  // Save token to user profile
  await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .update({'fcm_token': token});
  
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showLocalNotification(message);
  });
  
  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

// Send notification via Cloud Function
Future<void> sendNotification({
  required String userId,
  required String title,
  required String body,
  required Map<String, dynamic> data,
}) async {
  // Call Cloud Function
  await FirebaseFunctions.instance
      .httpsCallable('sendNotification')
      .call({
    'userId': userId,
    'title': title,
    'body': body,
    'data': data,
  });
}
```


## UI/UX Design Guidelines

### Screen Structure

```
App Structure:
├── Splash Screen
├── Authentication Flow
│   ├── Phone Number Entry
│   ├── Profile Setup
│   ├── Document Upload
│   └── Verification Pending
├── Project Selection (if multiple projects)
├── Main App
│   ├── Home/Feed
│   ├── Groups
│   ├── Documents
│   ├── Notifications
│   └── Profile
└── Admin Dashboard (for admins)
    ├── User Verification
    ├── Group Management
    ├── Tag Management
    └── Analytics
```

### Key Screens Design

#### 1. Home/Feed Screen
```
┌─────────────────────────────────────┐
│ [≡] Society App    [🔔] [👤]       │ Header
├─────────────────────────────────────┤
│ 📍 Prestige Lakeside [▼]            │ Project Selector
├─────────────────────────────────────┤
│ [All] [Phase 1] [Interiors] [+]    │ Group Tabs
├─────────────────────────────────────┤
│                                     │
│ 📌 Pinned: Bank Account Change      │ Pinned Thread
│ 💬 45 replies · 2 hours ago         │
│                                     │
│ ─────────────────────────────────── │
│                                     │
│ 🏗️ Soft Handover Update             │ Recent Thread
│ @Rahul shared floor plans...        │
│ 💬 23 replies · 5 hours ago         │
│                                     │
│ ─────────────────────────────────── │
│                                     │
│ 🔨 Vendor Review: ABC Interiors     │
│ Rating: ⭐⭐⭐⭐ (4.2)                │
│ 💬 12 replies · 1 day ago           │
│                                     │
└─────────────────────────────────────┘
│ [+] New Discussion                  │ FAB
└─────────────────────────────────────┘
```

#### 2. Thread Detail Screen
```
┌─────────────────────────────────────┐
│ [←] Bank Account Change      [⋮]   │ Header
├─────────────────────────────────────┤
│ 📌 Pinned by Admin                  │
│ #BankAccountChange #Important       │ Tags
├─────────────────────────────────────┤
│                                     │
│ 👤 Rahul Kumar (A-1201)             │ Original Post
│ 2 days ago                          │
│                                     │
│ Builder has changed bank account    │
│ for loan disbursement. New details: │
│                                     │
│ 📄 [Bank_Details.pdf] 245 KB        │ Attachment
│                                     │
│ 👍 24  💬 Reply  🔗 Share           │ Actions
│                                     │
│ ─────────────────────────────────── │
│                                     │
│ 👤 Priya Sharma (B-0504)            │ Reply
│ 1 day ago                           │
│                                     │
│ @Rahul thanks for sharing! Has      │
│ anyone completed the process?       │
│                                     │
│   └─ 👤 Amit Patel (A-1205)         │ Nested Reply
│      12 hours ago                   │
│                                     │
│      Yes, I completed yesterday.    │
│      Process is smooth.             │
│                                     │
└─────────────────────────────────────┘
│ [@] Type your reply...       [📎]  │ Reply Input
└─────────────────────────────────────┘
```

#### 3. Admin Verification Dashboard
```
┌─────────────────────────────────────┐
│ [←] Pending Verifications           │
├─────────────────────────────────────┤
│ 🔍 Search  [Phase ▼] [Block ▼]     │ Filters
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 👤 Rahul Kumar                  │ │ Verification Card
│ │ +91-9876543210                  │ │
│ │ Unit: A-1201, Block A, Phase 1  │ │
│ │ Submitted: 2 hours ago          │ │
│ │                                 │ │
│ │ 📄 Demand_Letter.pdf            │ │
│ │ [View Document]                 │ │
│ │                                 │ │
│ │ [✓ Approve] [✗ Reject]          │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 👤 Priya Sharma                 │ │
│ │ +91-9876543211                  │ │
│ │ Unit: B-0504, Block B, Phase 1  │ │
│ │ Submitted: 5 hours ago          │ │
│ │                                 │ │
│ │ 📄 Allotment_Letter.jpg         │ │
│ │ [View Document]                 │ │
│ │                                 │ │
│ │ [✓ Approve] [✗ Reject]          │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

### Design System

**Colors:**
```dart
class AppColors {
  // Primary
  static const primary = Color(0xFF2196F3);      // Blue
  static const primaryDark = Color(0xFF1976D2);
  static const primaryLight = Color(0xFFBBDEFB);
  
  // Accent
  static const accent = Color(0xFFFF9800);       // Orange
  
  // Neutral
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  
  // Status
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);
  static const warning = Color(0xFFFFC107);
  static const info = Color(0xFF2196F3);
  
  // Special
  static const mention = Color(0xFF1976D2);
  static const pinned = Color(0xFFFFF9C4);
}
```

**Typography:**
```dart
class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const mention = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.mention,
  );
}
```

## Offline Support Strategy

### Data Caching Approach

```dart
// Cache strategy
class CacheStrategy {
  // Always cache
  static const alwaysCache = [
    'user_profile',
    'project_details',
    'group_list',
    'space_list',
  ];
  
  // Cache with TTL (Time To Live)
  static const cacheTTL = {
    'threads': Duration(hours: 1),
    'replies': Duration(minutes: 30),
    'documents': Duration(hours: 6),
    'notifications': Duration(minutes: 15),
  };
  
  // Never cache (always fetch fresh)
  static const neverCache = [
    'verification_status',
    'admin_actions',
  ];
}
```

### Offline Queue for Actions

```dart
class OfflineQueue {
  // Queue pending actions
  Future<void> queueAction(Action action) async {
    await Hive.box('offline_queue').add({
      'type': action.type,
      'data': action.data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // Process queue when online
  Future<void> processQueue() async {
    final queue = Hive.box('offline_queue');
    
    for (var i = 0; i < queue.length; i++) {
      final action = queue.getAt(i);
      
      try {
        await executeAction(action);
        await queue.deleteAt(i);
      } catch (e) {
        // Keep in queue, retry later
        print('Failed to process action: $e');
      }
    }
  }
}
```

## Performance Optimization

### Image Optimization
```dart
// Lazy loading images
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  maxHeightDiskCache: 1000,
  maxWidthDiskCache: 1000,
  memCacheHeight: 500,
  memCacheWidth: 500,
)

// Compress before upload
Future<File> compressImage(File file) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    '${file.path}_compressed.jpg',
    quality: 85,
    minWidth: 1920,
    minHeight: 1080,
  );
  return File(result!.path);
}
```

### Pagination
```dart
// Paginated thread loading
class ThreadPagination {
  static const pageSize = 20;
  DocumentSnapshot? lastDocument;
  
  Future<List<Thread>> loadNextPage() async {
    Query query = FirebaseFirestore.instance
        .collection('threads')
        .where('space_id', isEqualTo: spaceId)
        .orderBy('last_activity', descending: true)
        .limit(pageSize);
    
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }
    
    final snapshot = await query.get();
    
    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
    }
    
    return snapshot.docs
        .map((doc) => Thread.fromFirestore(doc))
        .toList();
  }
}
```

### Search Optimization
```dart
// Algolia integration for advanced search (optional)
// For MVP, use Firestore queries with limitations

Future<List<Document>> searchDocuments(String query) async {
  // Simple prefix search
  final snapshot = await FirebaseFirestore.instance
      .collection('documents')
      .where('project_id', isEqualTo: projectId)
      .where('file_name', isGreaterThanOrEqualTo: query)
      .where('file_name', isLessThan: query + 'z')
      .limit(50)
      .get();
  
  return snapshot.docs
      .map((doc) => Document.fromFirestore(doc))
      .toList();
}

// For Phase 2: Implement Algolia for full-text search
// Cost: Free tier covers 10K searches/month
```

## Testing Strategy

### Unit Tests
```dart
// Test user validation
test('validates Indian phone number correctly', () {
  expect(validateIndianPhone('+91-9876543210'), true);
  expect(validateIndianPhone('+91-5876543210'), false);
  expect(validateIndianPhone('9876543210'), false);
});

// Test mention extraction
test('extracts mentioned users from content', () {
  final content = 'Hey @Rahul and @Priya, check this out!';
  final mentions = extractMentions(content);
  expect(mentions, ['Rahul', 'Priya']);
});
```

### Integration Tests
```dart
// Test complete user flow
testWidgets('user can create thread and reply', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Navigate to group
  await tester.tap(find.text('Phase 1 Group'));
  await tester.pumpAndSettle();
  
  // Create thread
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  await tester.enterText(find.byKey(Key('title')), 'Test Thread');
  await tester.enterText(find.byKey(Key('content')), 'Test content');
  await tester.tap(find.text('Post'));
  await tester.pumpAndSettle();
  
  // Verify thread created
  expect(find.text('Test Thread'), findsOneWidget);
});
```

### Manual Testing Checklist
- [ ] User registration and verification flow
- [ ] Phone number validation (Indian and international)
- [ ] Document upload (various formats, size limits)
- [ ] Group creation and membership
- [ ] Thread creation with mentions
- [ ] Reply with nested threading
- [ ] Document search with permissions
- [ ] Notifications (push and in-app)
- [ ] Offline mode (read cached content)
- [ ] Project switching (multi-project users)
- [ ] Admin verification dashboard
- [ ] Tag creation and filtering


## Deployment & DevOps

### Development Environment Setup

```bash
# Install Flutter
# Download from https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor

# Create new Flutter project
flutter create society_app
cd society_app

# Add dependencies
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add firebase_storage
flutter pub add firebase_messaging
flutter pub add flutter_riverpod
flutter pub add hive
flutter pub add hive_flutter
flutter pub add dio
flutter pub add cached_network_image
flutter pub add flutter_quill
flutter pub add image_picker
flutter pub add file_picker
flutter pub add flutter_local_notifications

# Run on emulator/device
flutter run
```

### Firebase Project Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project
firebase init

# Select:
# - Firestore
# - Storage
# - Functions
# - Hosting (for admin dashboard)

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage:rules

# Deploy Cloud Functions
cd functions
npm install
cd ..
firebase deploy --only functions
```

### CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Build iOS (on macOS runner)
      if: runner.os == 'macOS'
      run: flutter build ios --release --no-codesign
    
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

### Release Process

**Android Release:**
```bash
# Generate keystore (one-time)
keytool -genkey -v -keystore ~/society-app-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias society-app

# Configure signing in android/app/build.gradle
# Add key.properties file

# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Upload to Google Play Console
# https://play.google.com/console
```

**iOS Release:**
```bash
# Configure signing in Xcode
# Add provisioning profile

# Build release IPA
flutter build ios --release

# Archive and upload via Xcode
# Or use fastlane for automation

# Upload to App Store Connect
# https://appstoreconnect.apple.com
```

### Monitoring & Analytics

**Firebase Analytics Setup:**
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Log events
  Future<void> logThreadCreated(String groupId) async {
    await _analytics.logEvent(
      name: 'thread_created',
      parameters: {'group_id': groupId},
    );
  }
  
  Future<void> logUserMention(String mentionedUserId) async {
    await _analytics.logEvent(
      name: 'user_mentioned',
      parameters: {'mentioned_user': mentionedUserId},
    );
  }
  
  // Set user properties
  Future<void> setUserProperties(String role, String phase) async {
    await _analytics.setUserProperty(name: 'role', value: role);
    await _analytics.setUserProperty(name: 'phase', value: phase);
  }
}
```

**Crashlytics Setup:**
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enable Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runApp(MyApp());
}

// Log custom errors
try {
  // Some operation
} catch (e, stack) {
  FirebaseCrashlytics.instance.recordError(e, stack);
}
```

## Cost Estimation & Scaling

### Firebase Cost Breakdown (1500 users, 10% DAU, 30% MAU)

**Assumptions:**
- 150 daily active users
- 450 monthly active users
- Average 10 threads viewed per session
- Average 5 replies posted per day (across all users)
- Average 2 documents uploaded per day
- Average 20 notifications per user per day

**Month 1-3 (Free Tier):**
```
Firestore:
- Reads: ~45K/day = 1.35M/month (Free: 50K/day)
- Writes: ~5K/day = 150K/month (Free: 20K/day)
- Storage: ~500MB (Free: 1GB)
Cost: $0 (within free tier)

Storage:
- Storage: ~2GB (Free: 5GB)
- Downloads: ~10GB/month (Free: 1GB/day)
Cost: $0 (within free tier)

Functions:
- Invocations: ~100K/month (Free: 2M/month)
Cost: $0

Total: $0/month
```

**Month 4-6 (Growing):**
```
Firestore:
- Reads: 2M/month ($0.06/100K) = $1.20
- Writes: 200K/month ($0.18/100K) = $0.36
- Storage: 1.5GB ($0.18/GB) = $0.27
Cost: ~$2

Storage:
- Storage: 5GB ($0.026/GB) = $0.13
- Downloads: 30GB ($0.12/GB) = $3.60
Cost: ~$4

Functions:
- Invocations: 500K ($0.40/M) = $0.20
Cost: ~$0.20

Total: ~$6-10/month
```

**Month 7-12 (Stable):**
```
Firestore: ~$5-8/month
Storage: ~$8-12/month
Functions: ~$1-2/month
FCM: Free

Total: ~$15-25/month
```

**Year 2+ (Mature):**
```
With 1500 active users:
Firestore: ~$20-30/month
Storage: ~$20-30/month
Functions: ~$5-10/month

Total: ~$50-70/month
```

### Scaling Strategies

**When to scale:**
- Users > 5000
- DAU > 500
- Storage > 50GB
- Monthly costs > $100

**Optimization options:**
1. **Implement caching:** Reduce Firestore reads by 50%
2. **CDN for media:** Use Cloudflare (free tier) for image delivery
3. **Compress images:** Reduce storage and bandwidth costs
4. **Pagination:** Load data in chunks, not all at once
5. **Archive old data:** Move inactive threads to cold storage

**Migration path (if costs become high):**
```
Firebase → Supabase (self-hosted)
- DigitalOcean Droplet: $12/month (2GB RAM)
- Managed PostgreSQL: $15/month
- Object Storage: $5/month (250GB)
Total: ~$32/month (fixed cost, unlimited users)
```

## Security Considerations

### Data Protection
```dart
// Encrypt sensitive data before storage
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final key = Key.fromSecureRandom(32);
  final iv = IV.fromSecureRandom(16);
  final encrypter = Encrypter(AES(key));
  
  String encrypt(String text) {
    return encrypter.encrypt(text, iv: iv).base64;
  }
  
  String decrypt(String encrypted) {
    return encrypter.decrypt64(encrypted, iv: iv);
  }
}

// Encrypt phone numbers
final encryptedPhone = encryptionService.encrypt(phoneNumber);
```

### Input Validation
```dart
// Sanitize user input
String sanitizeInput(String input) {
  // Remove HTML tags
  input = input.replaceAll(RegExp(r'<[^>]*>'), '');
  
  // Remove script tags
  input = input.replaceAll(RegExp(r'<script.*?</script>'), '');
  
  // Trim whitespace
  input = input.trim();
  
  return input;
}

// Validate file uploads
bool validateFile(File file) {
  // Check file size
  if (file.lengthSync() > 2 * 1024 * 1024) {
    return false;
  }
  
  // Check file type
  final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'];
  final extension = file.path.split('.').last.toLowerCase();
  
  return allowedExtensions.contains(extension);
}
```

### Rate Limiting
```dart
// Implement rate limiting for API calls
class RateLimiter {
  final Map<String, List<DateTime>> _requests = {};
  final int maxRequests = 10;
  final Duration window = Duration(minutes: 1);
  
  bool allowRequest(String userId) {
    final now = DateTime.now();
    
    // Clean old requests
    _requests[userId]?.removeWhere(
      (time) => now.difference(time) > window
    );
    
    // Check limit
    final userRequests = _requests[userId] ?? [];
    if (userRequests.length >= maxRequests) {
      return false;
    }
    
    // Add new request
    _requests[userId] = [...userRequests, now];
    return true;
  }
}
```

## Maintenance & Support

### Backup Strategy
```bash
# Automated Firestore backup (Cloud Function)
exports.scheduledFirestoreBackup = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const client = new firestore.v1.FirestoreAdminClient();
    const projectId = process.env.GCP_PROJECT;
    const databaseName = client.databasePath(projectId, '(default)');
    
    return client.exportDocuments({
      name: databaseName,
      outputUriPrefix: `gs://${projectId}-backups`,
      collectionIds: []
    });
  });
```

### Monitoring Alerts
```javascript
// Cloud Function for monitoring
exports.monitorErrors = functions.firestore
  .document('errors/{errorId}')
  .onCreate(async (snap, context) => {
    const error = snap.data();
    
    // Send alert if critical
    if (error.severity === 'critical') {
      await sendEmailAlert(error);
      await sendSlackNotification(error);
    }
  });
```

### Update Strategy
```yaml
# Semantic versioning
version: 1.0.0+1
# Major.Minor.Patch+BuildNumber

# Release schedule
- Patch releases: Weekly (bug fixes)
- Minor releases: Monthly (new features)
- Major releases: Quarterly (breaking changes)

# Force update mechanism
# Store minimum version in Firestore
/config/app_version
  - minimum_version: "1.0.0"
  - latest_version: "1.2.0"
  - force_update: false
```

## Next Steps - Implementation Plan

### Phase 1: Foundation (Weeks 1-4)
- [ ] Setup Flutter project structure
- [ ] Configure Firebase project
- [ ] Implement authentication flow
- [ ] Create basic UI components
- [ ] Setup state management (Riverpod)
- [ ] Implement offline storage (Hive)

### Phase 2: Core Features (Weeks 5-8)
- [ ] User verification system
- [ ] Group and space management
- [ ] Thread creation and replies
- [ ] Document upload and management
- [ ] Basic search functionality
- [ ] Push notifications

### Phase 3: Advanced Features (Weeks 9-12)
- [ ] User mention system
- [ ] Tag management
- [ ] Admin dashboard
- [ ] Advanced search
- [ ] Offline queue
- [ ] Performance optimization

### Phase 4: Testing & Launch (Weeks 13-16)
- [ ] Unit and integration tests
- [ ] User acceptance testing
- [ ] Bug fixes and polish
- [ ] App store submission
- [ ] Soft launch (100 users)
- [ ] Full launch (1500 users)

---

This design document provides a complete technical blueprint for implementing the Society Management App using open-source tools and cost-effective infrastructure. The architecture is scalable, maintainable, and optimized for a hobby project that can grow into a production-ready platform.
