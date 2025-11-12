# API Documentation

**Project:** Nivas - Society Management App  
**Backend:** Firebase Services  
**Last Updated:** 2024

---

## Overview

Nivas uses Firebase as its backend, providing:
- **Authentication:** Phone-based auth with OTP
- **Database:** Firestore for real-time data
- **Storage:** Firebase Storage for files
- **Messaging:** FCM for push notifications (ready)

This document describes how the app interacts with Firebase services.

---

## Firebase Authentication

### Phone Authentication Flow

#### 1. Send OTP
```dart
// Service: auth_service.dart
Future<void> verifyPhoneNumber(String phoneNumber) async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      // Auto-verification (Android only)
      await FirebaseAuth.instance.signInWithCredential(credential);
    },
    verificationFailed: (FirebaseAuthException e) {
      throw Exception('Verification failed: ${e.message}');
    },
    codeSent: (String verificationId, int? resendToken) {
      // Store verificationId for OTP verification
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      // Auto-retrieval timeout
    },
    timeout: const Duration(seconds: 60),
  );
}
```

#### 2. Verify OTP
```dart
Future<UserCredential> verifyOTP(String verificationId, String otp) async {
  final credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: otp,
  );
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
```

#### 3. Get Current User
```dart
User? getCurrentUser() {
  return FirebaseAuth.instance.currentUser;
}
```

#### 4. Sign Out
```dart
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}
```

### FCM Token Management

```dart
// Register FCM token
Future<void> registerFCMToken(String userId) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'fcm_token': token});
  }
}
```

---

## Firestore Database

### Collections

#### Users Collection: `/users/{userId}`

**Create User**
```dart
Future<void> createUser(User user) async {
  await FirebaseFirestore.instance
    .collection('users')
    .doc(user.userId)
    .set(user.toFirestore());
}
```

**Get User**
```dart
Future<User?> getUser(String userId) async {
  final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();
  
  return doc.exists ? User.fromFirestore(doc) : null;
}
```

**Update User**
```dart
Future<void> updateUser(String userId, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update(data);
}
```

#### Project Memberships: `/project_memberships/{membershipId}`

**Create Membership**
```dart
Future<void> createMembership(ProjectMembership membership) async {
  final docId = '${membership.userId}_${membership.projectId}';
  await FirebaseFirestore.instance
    .collection('project_memberships')
    .doc(docId)
    .set(membership.toFirestore());
}
```

**Get User's Projects**
```dart
Stream<List<ProjectMembership>> getUserProjects(String userId) {
  return FirebaseFirestore.instance
    .collection('project_memberships')
    .where('user_id', isEqualTo: userId)
    .where('verification_status', isEqualTo: 'approved')
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => ProjectMembership.fromFirestore(doc))
      .toList());
}
```

**Get Pending Verifications**
```dart
Stream<List<ProjectMembership>> getPendingVerifications(String projectId) {
  return FirebaseFirestore.instance
    .collection('project_memberships')
    .where('project_id', isEqualTo: projectId)
    .where('verification_status', isEqualTo: 'pending')
    .orderBy('created_at', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => ProjectMembership.fromFirestore(doc))
      .toList());
}
```

**Approve/Reject Verification**
```dart
Future<void> updateVerificationStatus({
  required String userId,
  required String projectId,
  required String status,
  required String adminId,
  String? rejectionReason,
}) async {
  final docId = '${userId}_${projectId}';
  await FirebaseFirestore.instance
    .collection('project_memberships')
    .doc(docId)
    .update({
      'verification_status': status,
      'verified_at': FieldValue.serverTimestamp(),
      'verified_by': adminId,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
    });
}
```

#### Groups: `/groups/{groupId}`

**Create Group**
```dart
Future<void> createGroup(Group group) async {
  await FirebaseFirestore.instance
    .collection('groups')
    .doc(group.groupId)
    .set(group.toFirestore());
}
```

**Get User's Groups**
```dart
Stream<List<Group>> getUserGroups(String projectId, String userId) {
  return FirebaseFirestore.instance
    .collection('groups')
    .where('project_id', isEqualTo: projectId)
    .where('member_ids', arrayContains: userId)
    .orderBy('last_activity_at', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => Group.fromFirestore(doc))
      .toList());
}
```

**Add Member to Group**
```dart
Future<void> addMemberToGroup(String groupId, String userId) async {
  await FirebaseFirestore.instance
    .collection('groups')
    .doc(groupId)
    .update({
      'member_ids': FieldValue.arrayUnion([userId]),
      'member_count': FieldValue.increment(1),
    });
}
```

#### Spaces: `/spaces/{spaceId}`

**Create Space**
```dart
Future<void> createSpace(Space space) async {
  await FirebaseFirestore.instance
    .collection('spaces')
    .doc(space.spaceId)
    .set(space.toFirestore());
}
```

**Get Spaces in Group**
```dart
Stream<List<Space>> getGroupSpaces(String groupId) {
  return FirebaseFirestore.instance
    .collection('spaces')
    .where('group_id', isEqualTo: groupId)
    .orderBy('created_at', descending: false)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => Space.fromFirestore(doc))
      .toList());
}
```

#### Threads: `/threads/{threadId}`

**Create Thread**
```dart
Future<void> createThread(Thread thread) async {
  final batch = FirebaseFirestore.instance.batch();
  
  // Create thread
  final threadRef = FirebaseFirestore.instance
    .collection('threads')
    .doc(thread.threadId);
  batch.set(threadRef, thread.toFirestore());
  
  // Update space thread count
  final spaceRef = FirebaseFirestore.instance
    .collection('spaces')
    .doc(thread.spaceId);
  batch.update(spaceRef, {
    'thread_count': FieldValue.increment(1),
    'last_activity_at': FieldValue.serverTimestamp(),
  });
  
  // Update group activity
  final groupRef = FirebaseFirestore.instance
    .collection('groups')
    .doc(thread.groupId);
  batch.update(groupRef, {
    'last_activity_at': FieldValue.serverTimestamp(),
  });
  
  await batch.commit();
}
```

**Get Threads in Space**
```dart
Stream<List<Thread>> getSpaceThreads(String spaceId) {
  return FirebaseFirestore.instance
    .collection('threads')
    .where('space_id', isEqualTo: spaceId)
    .orderBy('is_pinned', descending: true)
    .orderBy('last_activity_at', descending: true)
    .limit(20)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => Thread.fromFirestore(doc))
      .toList());
}
```

**Delete Thread**
```dart
Future<void> deleteThread(String threadId, String spaceId) async {
  final batch = FirebaseFirestore.instance.batch();
  
  // Delete thread
  final threadRef = FirebaseFirestore.instance
    .collection('threads')
    .doc(threadId);
  batch.delete(threadRef);
  
  // Update space thread count
  final spaceRef = FirebaseFirestore.instance
    .collection('spaces')
    .doc(spaceId);
  batch.update(spaceRef, {
    'thread_count': FieldValue.increment(-1),
  });
  
  await batch.commit();
}
```

#### Replies: `/threads/{threadId}/replies/{replyId}`

**Create Reply**
```dart
Future<void> createReply(String threadId, Reply reply) async {
  final batch = FirebaseFirestore.instance.batch();
  
  // Create reply
  final replyRef = FirebaseFirestore.instance
    .collection('threads')
    .doc(threadId)
    .collection('replies')
    .doc(reply.replyId);
  batch.set(replyRef, reply.toFirestore());
  
  // Update thread reply count and activity
  final threadRef = FirebaseFirestore.instance
    .collection('threads')
    .doc(threadId);
  batch.update(threadRef, {
    'reply_count': FieldValue.increment(1),
    'last_activity_at': FieldValue.serverTimestamp(),
  });
  
  await batch.commit();
}
```

**Get Thread Replies**
```dart
Stream<List<Reply>> getThreadReplies(String threadId) {
  return FirebaseFirestore.instance
    .collection('threads')
    .doc(threadId)
    .collection('replies')
    .orderBy('created_at', ascending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => Reply.fromFirestore(doc))
      .toList());
}
```

#### Group Access Requests: `/group_access_requests/{requestId}`

**Create Access Request**
```dart
Future<void> createAccessRequest({
  required String groupId,
  required String userId,
  String? message,
}) async {
  await FirebaseFirestore.instance
    .collection('group_access_requests')
    .add({
      'group_id': groupId,
      'user_id': userId,
      'message': message,
      'status': 'pending',
      'requested_at': FieldValue.serverTimestamp(),
    });
}
```

**Get Pending Requests**
```dart
Stream<List<Map<String, dynamic>>> getPendingRequests(String groupId) {
  return FirebaseFirestore.instance
    .collection('group_access_requests')
    .where('group_id', isEqualTo: groupId)
    .where('status', isEqualTo: 'pending')
    .orderBy('requested_at', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => {...doc.data(), 'id': doc.id})
      .toList());
}
```

**Approve/Reject Request**
```dart
Future<void> respondToRequest({
  required String requestId,
  required String status,
  required String adminId,
  String? responseMessage,
}) async {
  await FirebaseFirestore.instance
    .collection('group_access_requests')
    .doc(requestId)
    .update({
      'status': status,
      'responded_at': FieldValue.serverTimestamp(),
      'responded_by': adminId,
      if (responseMessage != null) 'response_message': responseMessage,
    });
}
```

---

## Firebase Storage

### Upload Document

```dart
// Service: storage_service.dart
Future<String> uploadDocument({
  required File file,
  required String userId,
  required String fileName,
}) async {
  final ref = FirebaseStorage.instance
    .ref()
    .child('verification_documents')
    .child(userId)
    .child(fileName);
  
  final uploadTask = ref.putFile(file);
  final snapshot = await uploadTask;
  final downloadUrl = await snapshot.ref.getDownloadURL();
  
  return downloadUrl;
}
```

### Upload Thread Attachment

```dart
Future<String> uploadThreadAttachment({
  required File file,
  required String projectId,
  required String groupId,
  required String threadId,
  required String fileName,
}) async {
  final ref = FirebaseStorage.instance
    .ref()
    .child('thread_attachments')
    .child(projectId)
    .child(groupId)
    .child(threadId)
    .child(fileName);
  
  final uploadTask = ref.putFile(file);
  final snapshot = await uploadTask;
  final downloadUrl = await snapshot.ref.getDownloadURL();
  
  return downloadUrl;
}
```

### Delete File

```dart
Future<void> deleteFile(String fileUrl) async {
  final ref = FirebaseStorage.instance.refFromURL(fileUrl);
  await ref.delete();
}
```

---

## Firebase Cloud Messaging (FCM)

### Initialize FCM

```dart
// In main.dart
Future<void> initializeFCM() async {
  // Request permission (iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  // Get FCM token
  final token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');
  
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
    // Show in-app notification
  });
  
  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.title}');
}
```

### Send Notification (Server-side)

**Note:** Notifications are sent from Firebase Cloud Functions or backend server.

```javascript
// Example Cloud Function (Node.js)
const admin = require('firebase-admin');

async function sendNotification(userId, title, body, data) {
  // Get user's FCM token
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();
  
  const fcmToken = userDoc.data().fcm_token;
  
  if (!fcmToken) return;
  
  // Send notification
  await admin.messaging().send({
    token: fcmToken,
    notification: {
      title: title,
      body: body,
    },
    data: data,
  });
}

// Example: Notify on mention
exports.onThreadCreated = functions.firestore
  .document('threads/{threadId}')
  .onCreate(async (snap, context) => {
    const thread = snap.data();
    const mentionedUserIds = thread.mentioned_user_ids || [];
    
    for (const userId of mentionedUserIds) {
      await sendNotification(
        userId,
        'You were mentioned',
        `${thread.author_name} mentioned you in "${thread.title}"`,
        {
          type: 'mention',
          thread_id: context.params.threadId,
        }
      );
    }
  });
```

---

## Batch Operations

### Batch Write Example

```dart
Future<void> batchUpdateExample() async {
  final batch = FirebaseFirestore.instance.batch();
  
  // Update multiple documents
  final ref1 = FirebaseFirestore.instance.collection('threads').doc('thread1');
  batch.update(ref1, {'is_pinned': true});
  
  final ref2 = FirebaseFirestore.instance.collection('threads').doc('thread2');
  batch.update(ref2, {'is_pinned': false});
  
  // Commit all changes atomically
  await batch.commit();
}
```

### Transaction Example

```dart
Future<void> transactionExample() async {
  final docRef = FirebaseFirestore.instance
    .collection('groups')
    .doc('group123');
  
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(docRef);
    
    if (!snapshot.exists) {
      throw Exception('Group does not exist');
    }
    
    final currentCount = snapshot.data()!['member_count'] as int;
    transaction.update(docRef, {'member_count': currentCount + 1});
  });
}
```

---

## Error Handling

### Common Firebase Errors

```dart
try {
  // Firebase operation
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'invalid-phone-number':
      throw Exception('Invalid phone number format');
    case 'invalid-verification-code':
      throw Exception('Invalid OTP code');
    case 'session-expired':
      throw Exception('Verification session expired');
    default:
      throw Exception('Authentication error: ${e.message}');
  }
} on FirebaseException catch (e) {
  switch (e.code) {
    case 'permission-denied':
      throw Exception('You do not have permission to perform this action');
    case 'not-found':
      throw Exception('Document not found');
    case 'already-exists':
      throw Exception('Document already exists');
    case 'unavailable':
      throw Exception('Service temporarily unavailable');
    default:
      throw Exception('Firebase error: ${e.message}');
  }
} catch (e) {
  throw Exception('Unexpected error: $e');
}
```

---

## Rate Limits & Quotas

### Firestore Limits
- **Writes:** 10,000 per second per database
- **Reads:** 50,000 per second per database
- **Document Size:** 1 MB max
- **Collection Depth:** 100 levels max

### Storage Limits
- **File Size:** 5 GB max per file
- **Upload Speed:** Depends on network
- **Download Speed:** CDN-backed, very fast

### Authentication Limits
- **SMS:** 10 per phone number per day (free tier)
- **Verification:** 60 seconds timeout

---

## Best Practices

### 1. Use Batch Writes
- Combine multiple writes into one batch
- Reduces network calls
- Atomic operations

### 2. Implement Pagination
- Don't load all data at once
- Use `limit()` and `startAfter()`
- Improves performance

### 3. Cache Aggressively
- Use Firestore offline persistence
- Cache with Hive for additional layer
- Reduces reads and costs

### 4. Denormalize Data
- Store frequently accessed data together
- Avoid multiple lookups
- Trade storage for speed

### 5. Use Indexes
- Create composite indexes for complex queries
- Firestore will prompt you to create them
- Improves query performance

### 6. Handle Errors Gracefully
- Always wrap Firebase calls in try-catch
- Provide user-friendly error messages
- Log errors for debugging

---

## Testing

### Firebase Emulator

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize emulators
firebase init emulators

# Start emulators
firebase emulators:start
```

### Connect to Emulator in App

```dart
// In main.dart (debug mode only)
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
}
```

---

## Monitoring

### Firebase Console
- Monitor usage in Firebase Console
- Check for errors in Crashlytics
- View analytics in Firebase Analytics

### Performance Monitoring

```dart
// Track custom traces
final trace = FirebasePerformance.instance.newTrace('load_threads');
await trace.start();
// ... operation
await trace.stop();
```

---

**For more details:**
- [Database Schema](DATABASE_SCHEMA.md) - Data structure
- [Architecture](ARCHITECTURE.md) - System design
- [Development Guide](DEVELOPMENT_GUIDE.md) - How to develop
- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Security rules
