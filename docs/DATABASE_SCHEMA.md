# Database Schema Documentation

**Project:** Nivas - Society Management App  
**Database:** Firebase Firestore (NoSQL)  
**Last Updated:** 2024

---

## Overview

Firestore is a NoSQL document database organized into collections and documents. Each document contains fields (key-value pairs) and can have subcollections.

### Key Concepts
- **Collection:** Group of documents (e.g., `/users`)
- **Document:** Individual record with unique ID (e.g., `/users/user123`)
- **Subcollection:** Collection nested within a document (e.g., `/threads/{id}/replies`)
- **Field:** Key-value pair within a document

---

## Collections Structure

```
/users
/projects
/project_memberships
/groups
/spaces
/threads
  /{threadId}/replies
/group_access_requests
```

---

## Collection: `/users`

**Purpose:** Store user profile information

### Document ID
`{userId}` - Firebase Auth UID

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | string | ✅ | Firebase Auth UID (same as document ID) |
| `phone_number` | string | ✅ | User's phone number with country code |
| `display_name` | string | ✅ | User's full name |
| `email` | string | ❌ | User's email address (optional) |
| `photo_url` | string | ❌ | Profile photo URL |
| `fcm_token` | string | ❌ | Firebase Cloud Messaging token for notifications |
| `created_at` | timestamp | ✅ | Account creation timestamp |
| `last_login_at` | timestamp | ✅ | Last login timestamp |

### Example Document
```json
{
  "user_id": "abc123xyz",
  "phone_number": "+919876543210",
  "display_name": "Rajesh Kumar",
  "email": "rajesh@example.com",
  "photo_url": "https://storage.googleapis.com/...",
  "fcm_token": "fcm_token_here",
  "created_at": "2024-01-15T10:30:00Z",
  "last_login_at": "2024-01-20T08:15:00Z"
}
```

### Indexes
- `phone_number` (for lookup)
- `created_at` (for sorting)

### Security Rules
- **Read:** Any authenticated user
- **Write:** Only the user themselves

---

## Collection: `/projects`

**Purpose:** Store society/project information

### Document ID
`{projectId}` - Auto-generated or custom

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `project_id` | string | ✅ | Unique project identifier |
| `name` | string | ✅ | Project/society name |
| `location` | string | ✅ | Physical location/address |
| `phases` | array[string] | ✅ | List of phases (e.g., ["Phase 1", "Phase 2"]) |
| `blocks` | array[string] | ✅ | List of blocks (e.g., ["Block A", "Block B"]) |
| `created_at` | timestamp | ✅ | Project creation timestamp |
| `created_by` | string | ✅ | User ID of creator |

### Example Document
```json
{
  "project_id": "proj_greenvalley",
  "name": "Green Valley Apartments",
  "location": "Sector 62, Noida, UP",
  "phases": ["Phase 1", "Phase 2"],
  "blocks": ["Block A", "Block B", "Block C"],
  "created_at": "2024-01-01T00:00:00Z",
  "created_by": "admin_user_id"
}
```

### Indexes
- `name` (for search)
- `created_at` (for sorting)

### Security Rules
- **Read:** Project members only
- **Write:** Super Admins only

---

## Collection: `/project_memberships`

**Purpose:** Link users to projects with roles and verification status

### Document ID
`{userId}_{projectId}` - Composite key

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | string | ✅ | User's Firebase Auth UID |
| `project_id` | string | ✅ | Project identifier |
| `display_name` | string | ✅ | User's name (denormalized for quick access) |
| `role` | string | ✅ | User role: "owner", "groupAdmin", "superAdmin" |
| `verification_status` | string | ✅ | Status: "pending", "approved", "rejected" |
| `verification_doc_url` | string | ❌ | URL to uploaded verification document |
| `verified_at` | timestamp | ❌ | Timestamp of verification |
| `verified_by` | string | ❌ | User ID of admin who verified |
| `rejection_reason` | string | ❌ | Reason if rejected |
| `unit_ownerships` | array[object] | ✅ | List of owned units |
| `created_at` | timestamp | ✅ | Membership creation timestamp |

### Unit Ownership Object
```json
{
  "phase": "Phase 1",
  "block": "Block A",
  "unit_number": "101"
}
```

### Example Document
```json
{
  "user_id": "abc123xyz",
  "project_id": "proj_greenvalley",
  "display_name": "Rajesh Kumar",
  "role": "owner",
  "verification_status": "approved",
  "verification_doc_url": "https://storage.googleapis.com/.../doc.pdf",
  "verified_at": "2024-01-16T12:00:00Z",
  "verified_by": "admin_user_id",
  "rejection_reason": null,
  "unit_ownerships": [
    {
      "phase": "Phase 1",
      "block": "Block A",
      "unit_number": "101"
    }
  ],
  "created_at": "2024-01-15T10:30:00Z"
}
```

### Indexes
- Composite: `project_id` + `verification_status` (for admin dashboard)
- Composite: `user_id` + `project_id` (for user's projects)
- `verified_at` (for sorting)

### Security Rules
- **Read:** Any authenticated user
- **Create:** Any authenticated user (for registration)
- **Update:** User themselves or Super Admin

---

## Collection: `/groups`

**Purpose:** Discussion groups within a project

### Document ID
`{groupId}` - Auto-generated

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `project_id` | string | ✅ | Parent project ID |
| `name` | string | ✅ | Group name |
| `description` | string | ✅ | Group description |
| `type` | string | ✅ | Type: "general" or "private" |
| `member_ids` | array[string] | ✅ | List of member user IDs |
| `admin_ids` | array[string] | ✅ | List of admin user IDs |
| `created_by` | string | ✅ | Creator user ID |
| `member_count` | number | ✅ | Total member count (denormalized) |
| `last_activity_at` | timestamp | ❌ | Last activity timestamp |
| `created_at` | timestamp | ✅ | Group creation timestamp |

### Example Document
```json
{
  "project_id": "proj_greenvalley",
  "name": "Maintenance Issues",
  "description": "Discuss maintenance and repair issues",
  "type": "general",
  "member_ids": ["user1", "user2", "user3"],
  "admin_ids": ["admin1"],
  "created_by": "admin1",
  "member_count": 3,
  "last_activity_at": "2024-01-20T15:30:00Z",
  "created_at": "2024-01-10T09:00:00Z"
}
```

### Indexes
- Composite: `project_id` + `type` (for filtering)
- `member_ids` (array-contains for user's groups)
- `last_activity_at` (for sorting)

### Security Rules
- **Read:** Project members
- **Create:** Super Admins only
- **Update/Delete:** Group Admins or Super Admins

---

## Collection: `/spaces`

**Purpose:** Topic-based spaces within groups

### Document ID
`{spaceId}` - Auto-generated

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `group_id` | string | ✅ | Parent group ID |
| `project_id` | string | ✅ | Parent project ID (denormalized) |
| `name` | string | ✅ | Space name |
| `description` | string | ✅ | Space description |
| `type` | string | ✅ | Type: "general" or "dedicated" |
| `created_by` | string | ✅ | Creator user ID |
| `thread_count` | number | ✅ | Total thread count (denormalized) |
| `last_activity_at` | timestamp | ❌ | Last activity timestamp |
| `created_at` | timestamp | ✅ | Space creation timestamp |

### Example Document
```json
{
  "group_id": "group123",
  "project_id": "proj_greenvalley",
  "name": "Plumbing Issues",
  "description": "Discuss plumbing related problems",
  "type": "dedicated",
  "created_by": "admin1",
  "thread_count": 15,
  "last_activity_at": "2024-01-20T14:00:00Z",
  "created_at": "2024-01-12T10:00:00Z"
}
```

### Indexes
- `group_id` (for listing spaces in a group)
- Composite: `group_id` + `type` (for filtering)
- `last_activity_at` (for sorting)

### Security Rules
- **Read:** Group members
- **Create:** Group Admins
- **Update/Delete:** Group Admins

---

## Collection: `/threads`

**Purpose:** Discussion threads within spaces

### Document ID
`{threadId}` - Auto-generated

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `space_id` | string | ✅ | Parent space ID |
| `group_id` | string | ✅ | Parent group ID (denormalized) |
| `project_id` | string | ✅ | Parent project ID (denormalized) |
| `title` | string | ✅ | Thread title |
| `content` | string | ✅ | Thread content/body |
| `author_id` | string | ✅ | Author user ID |
| `author_name` | string | ✅ | Author name (denormalized) |
| `tag_ids` | array[string] | ❌ | List of tag IDs (future feature) |
| `mentioned_user_ids` | array[string] | ❌ | List of mentioned user IDs |
| `attachments` | array[object] | ❌ | List of attachments (future feature) |
| `is_pinned` | boolean | ✅ | Whether thread is pinned |
| `reply_count` | number | ✅ | Total reply count (denormalized) |
| `created_at` | timestamp | ✅ | Thread creation timestamp |
| `updated_at` | timestamp | ❌ | Last update timestamp |
| `last_activity_at` | timestamp | ❌ | Last activity (reply) timestamp |

### Attachment Object (Future)
```json
{
  "type": "image",
  "url": "https://storage.googleapis.com/.../image.jpg",
  "name": "photo.jpg",
  "size": 1024000
}
```

### Example Document
```json
{
  "space_id": "space123",
  "group_id": "group123",
  "project_id": "proj_greenvalley",
  "title": "Water leakage in Block A",
  "content": "There is water leakage on the 3rd floor. @admin1 please check.",
  "author_id": "user1",
  "author_name": "Rajesh Kumar",
  "tag_ids": [],
  "mentioned_user_ids": ["admin1"],
  "attachments": [],
  "is_pinned": false,
  "reply_count": 5,
  "created_at": "2024-01-20T10:00:00Z",
  "updated_at": null,
  "last_activity_at": "2024-01-20T15:30:00Z"
}
```

### Indexes
- Composite: `space_id` + `is_pinned` + `last_activity_at` (for listing)
- `author_id` (for user's threads)
- `mentioned_user_ids` (array-contains for mentions)

### Security Rules
- **Read:** Group members
- **Create:** Group members
- **Update/Delete:** Author or Group Admins

---

## Subcollection: `/threads/{threadId}/replies`

**Purpose:** Replies to threads (supports nesting)

### Document ID
`{replyId}` - Auto-generated

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `thread_id` | string | ✅ | Parent thread ID |
| `content` | string | ✅ | Reply content |
| `author_id` | string | ✅ | Author user ID |
| `author_name` | string | ✅ | Author name (denormalized) |
| `parent_reply_id` | string | ❌ | Parent reply ID (for nested replies) |
| `mentioned_user_ids` | array[string] | ❌ | List of mentioned user IDs |
| `attachments` | array[object] | ❌ | List of attachments (future feature) |
| `created_at` | timestamp | ✅ | Reply creation timestamp |
| `updated_at` | timestamp | ❌ | Last update timestamp |

### Example Document
```json
{
  "thread_id": "thread123",
  "content": "I'll send someone to check today. @user1",
  "author_id": "admin1",
  "author_name": "Admin User",
  "parent_reply_id": null,
  "mentioned_user_ids": ["user1"],
  "attachments": [],
  "created_at": "2024-01-20T11:00:00Z",
  "updated_at": null
}
```

### Nested Reply Example
```json
{
  "thread_id": "thread123",
  "content": "Thank you! When can I expect them?",
  "author_id": "user1",
  "author_name": "Rajesh Kumar",
  "parent_reply_id": "reply123",
  "mentioned_user_ids": [],
  "attachments": [],
  "created_at": "2024-01-20T11:30:00Z",
  "updated_at": null
}
```

### Indexes
- `created_at` (for chronological ordering)
- `parent_reply_id` (for nested replies)

### Security Rules
- **Read:** Group members (inherited from thread)
- **Create:** Group members
- **Update/Delete:** Author or Group Admins

---

## Collection: `/group_access_requests`

**Purpose:** Track requests to join private groups

### Document ID
`{requestId}` - Auto-generated

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `group_id` | string | ✅ | Target group ID |
| `user_id` | string | ✅ | Requesting user ID |
| `message` | string | ❌ | Optional message from user |
| `status` | string | ✅ | Status: "pending", "approved", "rejected" |
| `requested_at` | timestamp | ✅ | Request timestamp |
| `responded_at` | timestamp | ❌ | Response timestamp |
| `responded_by` | string | ❌ | Admin user ID who responded |
| `response_message` | string | ❌ | Optional response message |

### Example Document
```json
{
  "group_id": "group123",
  "user_id": "user2",
  "message": "I'm a resident of Block B and would like to join.",
  "status": "approved",
  "requested_at": "2024-01-18T09:00:00Z",
  "responded_at": "2024-01-18T10:30:00Z",
  "responded_by": "admin1",
  "response_message": "Welcome to the group!"
}
```

### Indexes
- Composite: `group_id` + `status` (for admin view)
- Composite: `user_id` + `status` (for user's requests)

### Security Rules
- **Read:** Any authenticated user
- **Create:** Any authenticated user
- **Update:** Group Admins only

---

## Data Relationships

### Hierarchy
```
Project
  └── Project Memberships (users in project)
  └── Groups
      └── Spaces
          └── Threads
              └── Replies
```

### Denormalization Strategy

**Why Denormalize?**
- Firestore charges per document read
- Reduce number of queries needed
- Improve performance

**What We Denormalize:**
1. **User names** in threads/replies (avoid user lookup)
2. **Project ID** in groups/spaces/threads (easier querying)
3. **Counts** (reply_count, member_count, thread_count)
4. **Group ID** in threads (avoid space lookup)

**Trade-off:**
- More storage space
- Need to update multiple places
- But: Faster reads, lower costs

---

## Query Patterns

### Common Queries

#### 1. Get User's Projects
```dart
firestore
  .collection('project_memberships')
  .where('user_id', isEqualTo: userId)
  .where('verification_status', isEqualTo: 'approved')
  .get()
```

#### 2. Get Groups in Project
```dart
firestore
  .collection('groups')
  .where('project_id', isEqualTo: projectId)
  .orderBy('last_activity_at', descending: true)
  .snapshots()
```

#### 3. Get User's Groups
```dart
firestore
  .collection('groups')
  .where('project_id', isEqualTo: projectId)
  .where('member_ids', arrayContains: userId)
  .snapshots()
```

#### 4. Get Threads in Space
```dart
firestore
  .collection('threads')
  .where('space_id', isEqualTo: spaceId)
  .orderBy('is_pinned', descending: true)
  .orderBy('last_activity_at', descending: true)
  .limit(20)
  .snapshots()
```

#### 5. Get Replies for Thread
```dart
firestore
  .collection('threads')
  .doc(threadId)
  .collection('replies')
  .orderBy('created_at', ascending: true)
  .snapshots()
```

#### 6. Get Pending Verifications
```dart
firestore
  .collection('project_memberships')
  .where('project_id', isEqualTo: projectId)
  .where('verification_status', isEqualTo: 'pending')
  .orderBy('created_at', descending: true)
  .snapshots()
```

---

## Performance Considerations

### Indexes Required

Firestore automatically creates single-field indexes. Composite indexes must be created manually:

1. **project_memberships:**
   - `project_id` + `verification_status` + `created_at`
   - `user_id` + `verification_status`

2. **groups:**
   - `project_id` + `last_activity_at`
   - `member_ids` (array) + `last_activity_at`

3. **threads:**
   - `space_id` + `is_pinned` + `last_activity_at`
   - `author_id` + `created_at`

4. **replies:**
   - `created_at` (auto-created)

### Pagination

For large lists, use pagination:

```dart
// First page
var query = firestore
  .collection('threads')
  .where('space_id', isEqualTo: spaceId)
  .orderBy('created_at', descending: true)
  .limit(20);

// Next page
var lastDoc = previousSnapshot.docs.last;
var nextQuery = query.startAfterDocument(lastDoc);
```

### Caching

- Firestore has built-in offline persistence
- Use Hive for additional caching
- Cache frequently accessed data (user info, project info)

---

## Migration Strategy

### Adding New Fields

**Safe approach:**
1. Add field as optional
2. Update code to handle null values
3. Backfill existing documents (if needed)
4. Make field required in new documents

### Changing Field Types

**Example: String to Array**
1. Add new field with array type
2. Migrate data gradually
3. Update code to use new field
4. Delete old field after migration

### Renaming Fields

**Approach:**
1. Add new field
2. Copy data from old to new
3. Update code to use new field
4. Delete old field

---

## Backup Strategy

### Automated Backups

Firebase offers automated backups (paid feature):
- Daily backups
- Retention period configurable
- Point-in-time recovery

### Manual Export

```bash
# Export entire database
gcloud firestore export gs://[BUCKET_NAME]

# Import from backup
gcloud firestore import gs://[BUCKET_NAME]/[EXPORT_FOLDER]
```

---

## Cost Optimization

### Read Optimization
- Use caching aggressively
- Implement pagination
- Limit real-time listeners
- Use `get()` instead of `snapshots()` when real-time not needed

### Write Optimization
- Batch writes when possible
- Avoid unnecessary updates
- Use transactions for atomic operations

### Storage Optimization
- Don't store large files in Firestore (use Storage)
- Clean up old data periodically
- Archive inactive data

---

**For more details, see:**
- [Architecture Decisions](ARCHITECTURE_DECISIONS.md) - Why these choices?
- [Development Guide](DEVELOPMENT_GUIDE.md) - How to query?
- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Security rules
