# Architecture Overview

**App:** Nivas - Society Management App  
**Architecture:** Clean Architecture with Flutter + Firebase  
**State Management:** Riverpod  
**Database:** Firestore (NoSQL)  
**Storage:** Firebase Storage  
**Authentication:** Firebase Auth (Phone)  

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │   Screens   │ │   Widgets   │ │    Riverpod Providers   │ │
│  │             │ │             │ │                         │ │
│  │ - Auth      │ │ - Reusable  │ │ - State Management      │ │
│  │ - Admin     │ │ - Custom    │ │ - Data Streams          │ │
│  │ - Groups    │ │ - Common    │ │ - Business Logic        │ │
│  │ - Threads   │ │             │ │                         │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     BUSINESS LAYER                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │  Services   │ │   Models    │ │       Utilities         │ │
│  │             │ │             │ │                         │ │
│  │ - Auth      │ │ - User      │ │ - Constants             │ │
│  │ - Storage   │ │ - Project   │ │ - Validators            │ │
│  │ - Offline   │ │ - Group     │ │ - Helpers               │ │
│  │ - Sync      │ │ - Thread    │ │                         │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │  Firebase   │ │    Hive     │ │      Connectivity       │ │
│  │             │ │             │ │                         │ │
│  │ - Auth      │ │ - Cache     │ │ - Network Monitor       │ │
│  │ - Firestore │ │ - Offline   │ │ - Sync Queue            │ │
│  │ - Storage   │ │ - Queue     │ │ - Auto Retry            │ │
│  │ - FCM       │ │             │ │                         │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure

```
nivas/
├── lib/
│   ├── main.dart                 # App entry point
│   │
│   ├── models/                   # Data Models
│   │   ├── user.dart            # User information
│   │   ├── project.dart         # Society/project data
│   │   ├── project_membership.dart # User-project relationships
│   │   ├── group.dart           # Discussion groups
│   │   ├── space.dart           # Topic spaces
│   │   ├── thread.dart          # Discussion threads
│   │   └── reply.dart           # Thread replies
│   │
│   ├── providers/               # Riverpod State Management
│   │   ├── app_state_provider.dart    # Global app state
│   │   ├── auth_provider.dart         # Authentication state
│   │   ├── user_provider.dart         # User data
│   │   ├── project_provider.dart      # Project context
│   │   ├── group_provider.dart        # Group data
│   │   └── thread_provider.dart       # Thread & reply data
│   │
│   ├── services/                # Business Logic
│   │   ├── auth_service.dart          # Authentication operations
│   │   ├── storage_service.dart       # File upload/download
│   │   ├── hive_service.dart          # Local storage
│   │   ├── offline_sync_service.dart  # Offline queue
│   │   └── connectivity_service.dart  # Network monitoring
│   │
│   ├── screens/                 # UI Screens
│   │   ├── auth/               # Authentication flow
│   │   │   ├── phone_entry_screen.dart
│   │   │   ├── otp_verification_screen.dart
│   │   │   ├── profile_setup_screen.dart
│   │   │   ├── document_upload_screen.dart
│   │   │   └── verification_pending_screen.dart
│   │   │
│   │   ├── admin/              # Admin dashboard
│   │   │   ├── admin_dashboard_screen.dart
│   │   │   ├── admin_verification_screen.dart
│   │   │   └── verification_history_screen.dart
│   │   │
│   │   ├── home/               # Main navigation
│   │   │   ├── home_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── settings_screen.dart
│   │   │
│   │   ├── project/            # Project management
│   │   │   └── project_selection_screen.dart
│   │   │
│   │   ├── group/              # Group management
│   │   │   ├── groups_list_screen.dart
│   │   │   ├── create_group_screen.dart
│   │   │   ├── group_settings_screen.dart
│   │   │   └── group_access_requests_screen.dart
│   │   │
│   │   ├── space/              # Space management
│   │   │   ├── spaces_list_screen.dart
│   │   │   └── create_space_screen.dart
│   │   │
│   │   └── thread/             # Discussion system
│   │       ├── threads_list_screen.dart
│   │       ├── create_thread_screen.dart
│   │       └── thread_detail_screen.dart
│   │
│   ├── widgets/                # Reusable Components
│   │   └── project_switcher.dart
│   │
│   └── utils/                  # Utilities
│       ├── constants.dart      # App constants
│       └── validators.dart     # Form validation
│
├── docs/                       # Documentation
│   ├── README.md
│   ├── FEATURES_COMPLETED.md
│   ├── FEATURES_PENDING.md
│   ├── ARCHITECTURE.md
│   ├── ARCHITECTURE_DECISIONS.md
│   ├── DEVELOPMENT_GUIDE.md
│   ├── DEPLOYMENT_GUIDE.md
│   └── DATABASE_SCHEMA.md
│
├── scripts/                    # Build & deployment scripts
│   ├── build.sh
│   ├── build.bat
│   ├── test.sh
│   ├── deploy.sh
│   └── README.md
│
└── README.md                   # Quick start guide
```

## Data Flow Architecture

### 1. User Interaction Flow
```
User Action → Screen → Provider → Service → Firebase → Stream Update → UI Refresh
```

**Example: Creating a Thread**
1. User taps "Create Thread" → `threads_list_screen.dart`
2. Navigates to → `create_thread_screen.dart`
3. User submits form → Calls `thread_provider.dart`
4. Provider calls → `auth_service.dart` (for user info)
5. Creates thread in → Firebase Firestore
6. Firestore stream updates → `thread_provider.dart`
7. UI automatically refreshes → `threads_list_screen.dart`

### 2. Real-time Data Flow
```
Firestore Change → Stream Provider → Consumer Widget → UI Update
```

**Example: New Reply Notification**
1. User A posts reply → Firestore `/threads/{id}/replies`
2. Stream detects change → `threadRepliesProvider`
3. All listening widgets → Auto-update
4. User B sees new reply → Real-time

### 3. Offline Data Flow
```
User Action → Offline Queue → Network Available → Sync to Firebase
```

**Example: Offline Thread Creation**
1. User creates thread offline → `offline_sync_service.dart`
2. Action queued locally → Hive storage
3. Network comes back → Auto-sync triggered
4. Thread created in Firestore → UI updates

## State Management (Riverpod)

### Provider Types Used

#### 1. StreamProvider - Real-time Data
```dart
// Example: Live thread list
final spaceThreadsProvider = StreamProvider.family<List<Thread>, String>((ref, spaceId) {
  return firestore
    .collection('threads')
    .where('space_id', isEqualTo: spaceId)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => Thread.fromFirestore(doc)).toList());
});
```

#### 2. StateNotifierProvider - Mutable State
```dart
// Example: Current project context
final currentProjectIdProvider = StateNotifierProvider<CurrentProjectNotifier, String?>((ref) {
  return CurrentProjectNotifier();
});
```

#### 3. Provider - Computed Values
```dart
// Example: Permission checks
final isGroupAdminProvider = Provider.family<bool, String>((ref, groupId) {
  final userId = ref.watch(currentUserIdProvider);
  final group = ref.watch(groupProvider(groupId));
  return group.value?.isAdmin(userId) ?? false;
});
```

#### 4. FutureProvider - Async Operations
```dart
// Example: User data loading
final currentUserProvider = FutureProvider<User?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return await getUserData(userId);
});
```

### State Management Patterns

#### 1. Global State
- **App State:** Loading, error, success messages
- **Auth State:** Current user, authentication status
- **Project Context:** Current project, switching

#### 2. Feature State
- **Groups:** User's groups, available groups, permissions
- **Threads:** Thread lists, replies, real-time updates
- **Admin:** Pending verifications, admin actions

#### 3. Local State
- **Form State:** Input validation, submission status
- **UI State:** Selected items, expanded sections
- **Navigation State:** Current screen, drawer state

## Database Architecture (Firestore)

### Collection Structure
```
/users/{userId}
/projects/{projectId}
/project_memberships/{membershipId}
/groups/{groupId}
/spaces/{spaceId}
/threads/{threadId}
  /{threadId}/replies/{replyId}
/group_access_requests/{requestId}
```

See [Database Schema](DATABASE_SCHEMA.md) for complete details.

### Query Patterns

#### 1. Real-time Queries
```dart
// Live thread updates
firestore
  .collection('threads')
  .where('space_id', isEqualTo: spaceId)
  .orderBy('is_pinned', descending: true)
  .orderBy('last_activity_at', descending: true)
  .snapshots()
```

#### 2. Permission-based Queries
```dart
// User's accessible groups
firestore
  .collection('groups')
  .where('project_id', isEqualTo: projectId)
  .where('member_ids', arrayContains: userId)
  .snapshots()
```

#### 3. Paginated Queries
```dart
// Thread pagination
firestore
  .collection('threads')
  .where('space_id', isEqualTo: spaceId)
  .orderBy('created_at', descending: true)
  .limit(20)
  .snapshots()
```

## Security Architecture

### Authentication Flow
```
1. Phone Number Entry → Firebase Auth
2. OTP Verification → User Creation
3. Profile Setup → Firestore User Document
4. Document Upload → Firebase Storage
5. Admin Verification → Project Membership Approval
6. Access Granted → App Features Unlocked
```

### Permission Levels

#### 1. Super Admin
- Create/delete groups
- Verify new users
- Manage all members
- Full project control

#### 2. Group Admin
- Create spaces
- Manage group members
- Approve access requests
- Delete threads/replies

#### 3. Owner (Regular User)
- Create threads
- Post replies
- Request group access
- View accessible content

### Firestore Security Rules

See [Deployment Guide](DEPLOYMENT_GUIDE.md) for complete security rules.

**Key Principles:**
- Users can only read/write their own data
- Project members can access project data
- Group members can access group content
- Admins have elevated permissions
- All writes are validated server-side

## Offline Architecture

### Components

#### 1. Hive Service (`hive_service.dart`)
- Local key-value storage
- Caches user data
- Stores offline queue
- Fast read/write operations

#### 2. Offline Sync Service (`offline_sync_service.dart`)
- Queues actions when offline
- Auto-syncs when online
- Retry logic with exponential backoff
- Conflict resolution

#### 3. Connectivity Service (`connectivity_service.dart`)
- Monitors network status
- Triggers sync on reconnection
- Provides connectivity state to UI

### Offline Flow

```
1. User Action (offline)
   ↓
2. Save to Hive Queue
   ↓
3. Show in UI (optimistic update)
   ↓
4. Network Restored
   ↓
5. Sync Queue to Firebase
   ↓
6. Update UI with server response
```

## Performance Optimizations

### 1. Data Denormalization
- Store user names in threads (avoid lookups)
- Store project IDs in nested collections
- Cache counts (reply_count, member_count)

### 2. Lazy Loading
- Paginate large lists
- Load data on demand
- Use ListView.builder for efficiency

### 3. Caching Strategy
- Cache frequently accessed data
- Use Firestore offline persistence
- Hive for additional caching

### 4. Real-time Optimization
- Limit listeners to active screens
- Unsubscribe when not needed
- Use snapshots() only when necessary

## Scalability Considerations

### Database Scaling
- **Firestore:** Scales automatically
- **Indexes:** Create composite indexes for complex queries
- **Sharding:** Not needed until millions of documents

### Storage Scaling
- **Firebase Storage:** Scales automatically
- **CDN:** Built-in for fast delivery
- **Compression:** Implement for images/videos

### Cost Optimization
- Aggressive caching reduces reads
- Pagination reduces data transfer
- Offline-first reduces network calls
- Efficient queries minimize costs

See [Architecture Decisions](ARCHITECTURE_DECISIONS.md) for cost analysis.

## Technology Stack

### Frontend
- **Flutter:** 3.0+ (Cross-platform framework)
- **Dart:** 3.0+ (Programming language)
- **Material Design 3:** UI components

### State Management
- **Riverpod:** 2.0+ (State management)
- **Flutter Hooks:** For widget lifecycle

### Backend
- **Firebase Auth:** Phone authentication
- **Firestore:** NoSQL database
- **Firebase Storage:** File storage
- **FCM:** Push notifications (ready)

### Local Storage
- **Hive:** Key-value database
- **Shared Preferences:** Simple settings

### Utilities
- **Connectivity Plus:** Network monitoring
- **Image Picker:** Photo selection
- **File Picker:** Document selection

## Development Principles

### 1. Clean Architecture
- Separation of concerns
- Dependency injection via Riverpod
- Testable business logic

### 2. Offline-First
- App works without internet
- Automatic synchronization
- Optimistic UI updates

### 3. Real-time Collaboration
- Live updates via Firestore streams
- Multi-device synchronization
- Instant notifications

### 4. Security-First
- Server-side validation
- Role-based access control
- Secure authentication

### 5. Scalable Design
- Multi-project architecture
- Efficient data structures
- Performance optimizations

## Future Architecture Enhancements

### Planned Improvements
1. **Push Notifications:** FCM integration
2. **Search:** Algolia or Firestore search
3. **Analytics:** Firebase Analytics
4. **Crashlytics:** Error tracking
5. **Performance Monitoring:** Firebase Performance

### Potential Migrations
1. **Supabase:** If Firestore costs become high
2. **Custom Backend:** For advanced features
3. **GraphQL:** For complex queries
4. **Redis:** For caching layer

See [Features Pending](FEATURES_PENDING.md) for roadmap.

---

**For more details:**
- [Architecture Decisions](ARCHITECTURE_DECISIONS.md) - Why these choices?
- [Database Schema](DATABASE_SCHEMA.md) - Data structure
- [Development Guide](DEVELOPMENT_GUIDE.md) - How to develop
- [Deployment Guide](DEPLOYMENT_GUIDE.md) - How to deploy
