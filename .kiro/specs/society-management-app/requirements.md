# Society Management App - Comprehensive Requirements Document

## Executive Summary

A comprehensive mobile application designed for under-construction apartment communities (1000+ residents) to replace chaotic WhatsApp/Telegram group communications with structured, organized, and searchable community management platform. The app serves apartment owners during construction-to-registration phases with hierarchical discussion spaces, document management, and community-driven vendor marketplace.

**Target Market:** Under-construction apartment communities in India (Phase 1: Bangalore market)
**Primary Users:** Apartment owners/residents (1400 units across 2 phases)
**Platform:** Cross-platform mobile (Android + iOS)
**Architecture:** Owner-led, admin-moderated community platform

## Project Context & Background

### Current Problem Statement
- **Scale Challenge:** 1000+ residents across WhatsApp/Telegram groups create information chaos
- **Information Loss:** Critical updates get buried in endless chat streams
- **Repetitive Queries:** Same questions asked multiple times daily (demand letters, processes, vendor recommendations)
- **Fragmented Communication:** Builder communications reach different owners with varying information
- **Vendor Discovery:** No structured way to share and evaluate service providers
- **Document Scatter:** Important files (legal docs, floor plans) shared randomly across multiple platforms

### Business Opportunity
- **Immediate Need:** Phase 1 (700 units) approaching soft handover, Phase 2 (700 units) under construction
- **Market Gap:** Existing solutions (MyGate, Adda) focus on established societies, not construction phase
- **Scalability:** Solution applicable to multiple under-construction communities across India
- **Future Revenue:** Subscription model (₹50-100/unit/month) + vendor partnerships

## Glossary & Key Terminology

| Term | Definition |
|------|------------|
| **Society_App** | The complete mobile application system for society management |
| **Owner** | Verified apartment owner/resident (primary user type) |
| **Super_Admin** | Top-level administrator with full system access and control |
| **Group_Admin** | Administrator with management rights for specific groups |
| **General_Group** | Default community space accessible to all verified owners |
| **Private_Group** | Restricted access groups (Phase-specific, Block-specific, Interest-based) |
| **Space** | Discussion area within groups (can be general or topic-specific) |
| **Thread** | Individual conversation within a space with replies and sub-discussions |
| **Tag** | Admin-created labels for categorizing discussions (CourtCase, BankChange, etc.) |
| **Document_Repository** | Centralized file storage with metadata and search capabilities |
| **Verification_Process** | Multi-step owner authentication (phone + unit details + document upload) |
| **Media_Gallery** | Unified view of all shared images, videos, documents across spaces |
| **User_ID** | System-generated UUID serving as globally unique, immutable user identifier |
| **Project** | Individual society/apartment complex managed within the platform |
| **Project_Membership** | Association between a user and project with role and unit ownership details |
| **User_Mention** | Tagging functionality to notify specific users in discussions (@username) |

## Competitive Analysis

### Market Landscape

| Platform | Target Audience | Key Features | Strengths | Gaps for Under-Construction Communities |
|----------|----------------|--------------|-----------|----------------------------------------|
| **MyGate** | Established societies | Visitor management, delivery tracking, facility booking, payments | Strong visitor management, wide adoption | No construction-phase features, no structured discussions, limited document management |
| **Adda (NoBroker)** | Residential communities | Community feed, polls, facility booking, accounting | Good community engagement features | Focused on operational societies, no phase-based organization, limited vendor marketplace |
| **NoBroker Society** | Apartment complexes | Accounting, visitor management, complaints | Integrated with NoBroker ecosystem | No discussion forums, no construction tracking, limited community features |
| **WhatsApp/Telegram** | General communication | Instant messaging, media sharing, groups | Universal adoption, familiar UX | Information chaos at scale, no organization, poor searchability, no verification |
| **ApnaComplex** | Gated communities | Accounting, facility booking, notices | Comprehensive society management | Complex UI, no construction phase support, expensive for new societies |

### Our Competitive Advantage

| Feature | Our App | MyGate | Adda | WhatsApp/Telegram |
|---------|---------|--------|------|-------------------|
| **Construction Phase Support** | ✅ Core focus | ❌ | ❌ | ❌ |
| **Structured Discussions (Spaces/Groups)** | ✅ | ❌ | Partial | ❌ |
| **Document Management with Context** | ✅ | Partial | Partial | ❌ |
| **Community-Driven Vendor Marketplace** | ✅ | ❌ | ❌ | ❌ |
| **Phase-Based Organization** | ✅ | ❌ | ❌ | ❌ |
| **Multi-Project Support** | ✅ | ✅ | ✅ | ❌ |
| **Free/Low-Cost for New Communities** | ✅ | ❌ | ❌ | ✅ |
| **Thread-Based Conversations** | ✅ | ❌ | Partial | ❌ |

### Market Positioning

**Primary Differentiation:** Only platform designed specifically for under-construction apartment communities with structured communication, phase-aware features, and community-driven vendor discovery.

**Target Segment:** 1000+ unit under-construction projects in Tier 1/2 Indian cities during construction-to-registration phases (12-36 month window).

**Migration Path:** Start as construction-phase platform → Evolve into full society management → Compete with MyGate/Adda post-occupation.

## Core User Types & Roles

### User Hierarchy & Permissions

| User Type | Access Level | Capabilities | Verification Required |
|-----------|--------------|--------------|---------------------|
| **Owner** | Standard User | • Access General Group<br>• Request Private Group access<br>• Post, reply, share media<br>• Search & view documents<br>• Follow threads/spaces | Phone + Unit Details + Document |
| **Group Admin** | Group Manager | • All Owner capabilities<br>• Manage specific groups<br>• Create spaces within groups<br>• Approve group membership<br>• Pin posts, moderate content | Owner verification + Admin assignment |
| **Super Admin** | System Manager | • All Group Admin capabilities<br>• Create/delete any group<br>• Manage all users & admins<br>• Create tags<br>• System configuration | Owner verification + Super Admin rights |

### User Registration & Profile Structure

| Field | Type | Required | Editable | Purpose |
|-------|------|----------|----------|---------|
| User ID (UUID) | String | Auto-generated | ❌ No | Globally unique, immutable identifier |
| Phone Number | String (+CC-Number) | Yes | ❌ No | Primary identifier (e.g., "+91-9876543210") |
| Full Name | String | Yes | ❌ No | Legal name for verification |
| Display Name | String | Yes | ✅ Yes (per project) | Project-specific display name for mentions |
| Unit Number | String | Yes | ❌ No | Flat identification (e.g., "A-1201") |
| Block | String | Yes | ❌ No | Building block (e.g., "Block A") |
| Phase | String | Yes | ❌ No | Construction phase (Phase 1/Phase 2) |
| Email | String | No | ✅ Yes | Optional secondary contact |
| Verification Document | File | Yes | ❌ No | Demand letter/ownership proof (max 2MB) |
| Profile Photo | Image | No | ✅ Yes | Optional user avatar |

### User Identity & Multi-Tenancy Architecture

#### Global User Model

```
User (System Level - Globally Unique)
├── user_id: UUID (immutable, system-generated)
├── phone_number: "+[CountryCode]-[Number]" (immutable)
│   └── Validation: Indian numbers (+91) must be exactly 10 digits
├── email: optional (editable)
├── created_at: timestamp
└── project_memberships: Array of project associations
```

#### Project Membership Model

```
Project_Membership (Many-to-Many Relationship)
├── membership_id: UUID
├── user_id: FK → Users
├── project_id: FK → Projects
├── display_name: String (project-specific, editable)
├── role: "Owner" | "Group_Admin" | "Super_Admin"
├── verification_status: "Pending" | "Approved" | "Rejected"
├── verification_document_url: String
├── verified_at: timestamp
├── verified_by: FK → Users (admin who approved)
└── unit_ownerships: Array of unit associations
```

#### Unit Ownership Model

```
Unit_Ownership (Supports Multiple Units per User, Multiple Owners per Unit)
├── ownership_id: UUID
├── membership_id: FK → Project_Memberships
├── unit_id: FK → Units
├── ownership_type: "Primary" | "Co-owner" | "Joint"
├── verified_document_url: String
└── created_at: timestamp
```

### Multi-Project, Multi-Unit, Multi-Owner Scenarios

#### Scenario A: One User, Multiple Units (Investor)
```
User: Rahul Kumar (user_id: abc-123)
└── Project: Prestige Lakeside
    ├── Display Name: "Rahul Kumar"
    ├── Units: ["A-1201", "A-1205", "B-0504"]
    └── Role: Owner

User Experience:
- Single login, sees aggregated notifications from all units
- Can filter discussions by specific unit
- Admin privileges apply to all owned units
- Future: Voting rights = one vote per unit
```

#### Scenario B: One Unit, Multiple Owners (Co-ownership)
```
Unit: A-1201
├── Owner 1: Rahul Kumar (Primary)
├── Owner 2: Priya Kumar (Co-owner)
└── Owner 3: Rahul's Father (Joint)

User Experience:
- Each co-owner registers separately with same unit number
- All get verified independently
- Shared unit context but separate profiles
- All receive unit-specific notifications
```

#### Scenario C: One User, Multiple Projects
```
User: Rahul Kumar (user_id: abc-123)
├── Project 1: Prestige Lakeside
│   ├── Display Name: "Rahul Kumar"
│   ├── Units: ["A-1201", "B-0504"]
│   └── Role: Owner + Super_Admin
└── Project 2: Brigade Meadows
    ├── Display Name: "Rahul K"
    ├── Units: ["Tower2-1505"]
    └── Role: Owner

User Experience:
- Mandatory project selection on app launch
- Project switcher in app header/menu
- Complete data isolation between projects
- Separate groups, documents, discussions per project
```

### Phone Number Validation Rules

| Country | Format | Validation Rules | Example |
|---------|--------|------------------|---------|
| **India (+91)** | +91-XXXXXXXXXX | • Exactly 10 digits after country code<br>• Must start with 6, 7, 8, or 9<br>• No spaces or special characters | +91-9876543210 ✅<br>+91-5876543210 ❌ |
| **International** | +[CC]-[Number] | • Validate based on country code<br>• Future enhancement | +1-2025551234 (US) |

**Storage Format:** E.164 international format (+CC-Number)
**Display Format:** Country-specific formatting with spaces
**Uniqueness:** One phone number = one global user account

## Information Architecture & Content Organization

### Three-Tier Content Structure

```
Society Community
├── General Group (Public - All Owners)
│   ├── General Space (Default discussions)
│   └── Dedicated Spaces (Admin-created topics)
│       ├── "Bank Account Change"
│       ├── "Court Case Updates"
│       └── "Demand Letter Process"
│
└── Private Groups (Admin-controlled access)
    ├── Phase 1 Group
    │   ├── General Space
    │   └── Dedicated Spaces
    ├── Phase 2 Group
    ├── Interiors Group
    │   ├── General Space
    │   ├── "Contractor ABC Reviews"
    │   ├── "Vendor Directory"
    │   └── "Design Ideas"
    ├── Resale Group
    └── Block-specific Groups
```

### Content Flow & Space Evolution

| Stage | Description | Admin Action | User Experience |
|-------|-------------|--------------|-----------------|
| **Initial Discussion** | All conversations start in General Space | Monitor popular topics | Users post freely in general area |
| **Topic Identification** | Recurring themes emerge (bank changes, court cases) | Identify conversion candidates | Users see repeated discussions |
| **Space Creation** | Admin converts popular threads to dedicated spaces | Create dedicated space, move relevant threads | Users get organized topic-specific areas |
| **Ongoing Management** | Dedicated spaces handle specific topics | Moderate, pin important posts | Users find information easily |

## Detailed Feature Requirements

### Requirement 1: User Authentication & Verification System

**User Story:** As a potential apartment owner, I want to securely join the community app so that I can access verified information and participate in authentic discussions with fellow owners.

#### Acceptance Criteria

1. WHEN a new user downloads the app, THE Society_App SHALL require phone number entry for initial registration
2. WHEN user provides phone number, THE Society_App SHALL collect unit details (Phase, Block, Flat Number) and full name
3. WHEN basic details are complete, THE Society_App SHALL require demand letter screenshot upload for ownership verification
4. WHILE verification is pending, THE Society_App SHALL provide read-only access to General Group discussions
5. WHEN Super Admin approves verification, THE Society_App SHALL grant full access and add user to General Group
6. WHERE verification is rejected, THE Society_App SHALL provide rejection reason and allow re-submission

#### Technical Specifications
- **Authentication Method:** Phone number (no OTP initially - future enhancement)
- **Document Upload:** Support JPG, PNG, PDF, DOC, DOCX formats (max 2MB per file)
- **Verification Queue:** Admin dashboard for pending approvals
- **Profile Completion:** Mandatory fields validation before app access
- **User ID Generation:** System-generated UUID on first registration
- **Phone Validation:** Country code + number format with Indian number validation
- **Data Immutability:** Phone, name, unit details cannot be edited post-verification

#### Admin Verification Dashboard Requirements

**User Story:** As a Super Admin, I want to review and approve pending user verifications so that only legitimate owners can access the community.

**Dashboard Features:**

| Feature | Specification | Purpose |
|---------|---------------|---------|
| **Pending Queue** | List view with filters (date, phase, block) | Efficient verification workflow |
| **User Details Display** | Name, phone, unit, block, phase | Quick verification context |
| **Document Viewer** | Inline preview for images/PDFs, download for DOC | Review ownership proof |
| **Verification Actions** | Approve/Reject buttons with confirmation | Clear admin actions |
| **Rejection Reason** | Text field for rejection explanation | User feedback for re-submission |
| **Verification History** | Audit log of all verifications | Accountability and tracking |
| **Bulk Actions** | Select multiple for batch approval | Efficiency for large communities |

**Acceptance Criteria:**
1. WHEN admin accesses verification dashboard, THE Society_App SHALL display all pending verifications with user details
2. WHEN admin clicks on verification entry, THE Society_App SHALL show full user details and document preview
3. WHEN admin approves verification, THE Society_App SHALL grant user access and send notification
4. WHEN admin rejects verification, THE Society_App SHALL require rejection reason and notify user
5. THE Society_App SHALL maintain complete audit trail of all verification actions

### Requirement 2: Hierarchical Group & Space Management

**User Story:** As a Super Admin, I want to create and manage different groups and spaces so that discussions remain organized and relevant information reaches the right audience.

#### Acceptance Criteria

1. THE Society_App SHALL provide one default General Group accessible to all verified owners
2. WHEN Super Admin creates private groups, THE Society_App SHALL require group name, description, and access criteria
3. THE Society_App SHALL allow Group Admins to create spaces within their managed groups
4. WHEN Admin converts popular threads to dedicated spaces, THE Society_App SHALL migrate relevant discussions and notify participants
5. THE Society_App SHALL maintain group membership lists with join/leave audit trails

#### Group Types & Examples

| Group Type | Access Control | Examples | Use Cases |
|------------|----------------|----------|-----------|
| **General Group** | All verified owners | Default community space | General discussions, announcements |
| **Phase Groups** | Phase-specific owners | Phase 1 Group, Phase 2 Group | Phase-specific updates, handover discussions |
| **Interest Groups** | Request-based access | Interiors Group, Resale Group | Specialized discussions, vendor sharing |
| **Location Groups** | Block/floor residents | Block A Group, Tower 1 Group | Localized issues, neighbor coordination |

### Requirement 3: Advanced Discussion & Threading System

**User Story:** As an owner, I want to participate in organized discussions with proper threading so that I can follow conversations easily and find relevant information quickly.

#### Acceptance Criteria

1. THE Society_App SHALL support threaded conversations with unlimited reply depth within spaces
2. WHEN users post content, THE Society_App SHALL support text, images, videos, documents, and polls
3. THE Society_App SHALL provide rich text formatting (bold, italic, strikethrough, links)
4. WHEN users reply to posts, THE Society_App SHALL maintain conversation threading and notification chains
5. THE Society_App SHALL allow users to follow specific threads for targeted notifications

#### Content Types & Capabilities

| Content Type | Supported Formats | Size Limits | Special Features |
|--------------|-------------------|-------------|------------------|
| **Text Posts** | Rich text, markdown | No limit | User mentions (@username), hashtags, formatting (bold, italic, strikethrough, links) |
| **Images** | JPG, PNG, GIF | 10MB per image | Gallery view, zoom, download |
| **Videos** | MP4, MOV | 50MB per video | Inline playback, thumbnail |
| **Documents** | PDF, DOC, DOCX, XLS | 25MB per file | Preview, download, search indexing |
| **Polls** | Multiple choice, single select | 10 options max | Real-time results, expiry dates |

### Requirement 3.1: User Mention & Tagging System

**User Story:** As an owner, I want to mention/tag other community members in discussions so that they get notified about relevant conversations and can respond to direct queries.

#### Acceptance Criteria

1. WHEN user types "@" in any text field, THE Society_App SHALL trigger autocomplete with project member list
2. WHEN user searches for names, THE Society_App SHALL provide fuzzy search on display names within current project
3. WHEN multiple users have same display name, THE Society_App SHALL show unit number for disambiguation
4. WHEN user selects a mention, THE Society_App SHALL insert formatted mention tag and notify mentioned user
5. WHEN mentioned user receives notification, THE Society_App SHALL send immediate push notification regardless of other settings

#### User Mention Technical Specifications

| Aspect | Specification | Implementation Notes |
|--------|---------------|---------------------|
| **Trigger Character** | @ symbol | Standard across platforms |
| **Search Scope** | Current project members only | Privacy and relevance |
| **Autocomplete** | Fuzzy search on display names | Shows top 10 matches |
| **Disambiguation** | Display name + unit number | "Rahul Kumar (A-1201)" |
| **Mention Format** | @[display_name] with user_id link | Clickable, navigates to profile |
| **Notification** | Immediate push, cannot be disabled | Critical for direct communication |
| **Privacy** | Only show users in accessible groups | Respect group permissions |
| **Display** | Highlighted text with distinct color | Visual distinction from regular text |

### Requirement 4: Community-Driven Vendor Marketplace

**User Story:** As an owner planning interiors, I want to discover trusted vendors through community recommendations so that I can make informed decisions based on real experiences from fellow residents.

#### Acceptance Criteria

1. THE Society_App SHALL maintain community-generated vendor directory within relevant groups (Interiors, Maintenance, etc.)
2. WHEN owners share vendor experiences, THE Society_App SHALL support detailed reviews with ratings, photos, and cost information
3. THE Society_App SHALL create dedicated spaces for popular vendors based on community discussions
4. THE Society_App SHALL enable quote sharing and comparison within vendor-specific spaces
5. WHERE multiple owners need similar services, THE Society_App SHALL facilitate group buying coordination discussions

#### Vendor Information Structure

| Information Type | Details | User Contribution | Admin Role |
|------------------|---------|-------------------|------------|
| **Basic Details** | Name, contact, services | Any owner can add | Verify accuracy |
| **Reviews & Ratings** | 1-5 stars, detailed feedback | Owners who used service | Monitor for authenticity |
| **Photos & Work Samples** | Before/after images | Service recipients | Ensure appropriate content |
| **Quotes & Pricing** | Cost estimates, packages | Multiple owners | No moderation needed |
| **Group Buying** | Bulk discount opportunities | Interested owners | Facilitate coordination |

### Requirement 5: Intelligent Document Management & Search

**User Story:** As an owner, I want to easily find and access important documents shared across different discussions so that I don't miss critical information regardless of where it was originally posted.

#### Acceptance Criteria

1. THE Society_App SHALL maintain centralized document repository with metadata (author, source space, upload date, tags)
2. WHEN documents are shared in any space, THE Society_App SHALL make them searchable in unified media gallery
3. THE Society_App SHALL provide document access based on user's group permissions (restricted space documents remain restricted)
4. WHEN users search documents, THE Society_App SHALL show results with source context and access permissions
5. THE Society_App SHALL support document categorization using admin-created tags

#### Document Access & Permissions Logic

| Scenario | User Access | Document Visibility | Source Context |
|----------|-------------|-------------------|----------------|
| **Public Space Document** | All verified owners | Full access | Shows source space/thread |
| **Private Group Document** | Group members only | Full access | Shows source space/thread |
| **Restricted Document Search** | Non-group members | Document visible, source hidden | "Shared in private group" |
| **Admin Documents** | Based on group access | Varies by group | Clear admin attribution |

### Requirement 6: Tag-Based Content Organization

**User Story:** As a Super Admin, I want to create and manage content tags so that discussions can be categorized and users can find relevant information efficiently.

#### Acceptance Criteria

1. THE Society_App SHALL allow Super Admins to create society-wide tags for content categorization
2. WHEN users create posts, THE Society_App SHALL provide tag selection from admin-created list
3. THE Society_App SHALL enable tag-based filtering and search across all accessible content
4. THE Society_App SHALL display tag usage statistics to help admins understand popular topics
5. THE Society_App SHALL support multiple tags per post for comprehensive categorization

#### Suggested Tag Categories

| Category | Example Tags | Use Cases |
|----------|--------------|-----------|
| **Process-Related** | DemandLetter, SoftHandover, Registration, LoanProcess | Official procedures |
| **Issues & Updates** | CourtCase, BankAccountChange, BuilderUpdate, DelayNotice | Important announcements |
| **Services & Vendors** | Interiors, Inspection, Legal, MovingServices | Service discussions |
| **Amenities & Facilities** | Parking, Clubhouse, Gym, SwimmingPool | Facility-related topics |
| **Community** | Events, Resale, Complaints, Suggestions | Social interactions |

### Requirement 7: Notification & Subscription Management

**User Story:** As an owner, I want to control what notifications I receive so that I stay informed about important updates without being overwhelmed by irrelevant discussions.

#### Acceptance Criteria

1. THE Society_App SHALL provide granular notification settings for groups, spaces, and individual threads
2. WHEN users join groups, THE Society_App SHALL set default notification preferences with option to customize
3. THE Society_App SHALL support notification frequency options (immediate, hourly digest, daily summary)
4. WHEN users are mentioned or replied to, THE Society_App SHALL send direct notifications regardless of other settings
5. THE Society_App SHALL provide notification history and read/unread status tracking

#### Notification Levels & Options

| Notification Type | Default Setting | User Control | Frequency Options |
|-------------------|-----------------|--------------|-------------------|
| **Direct Mentions** | Always on | Cannot disable | Immediate only |
| **Thread Replies** | On for followed threads | Full control | Immediate, hourly, daily |
| **Group Posts** | Daily digest | Full control | Off, immediate, hourly, daily |
| **Admin Announcements** | Always on | Cannot disable | Immediate only |
| **New Group Invitations** | Always on | Cannot disable | Immediate only |

### Requirement 8: Cross-Platform Mobile Application

**User Story:** As an owner using different mobile devices, I want consistent app experience across platforms so that I can participate in community discussions regardless of my device choice.

#### Acceptance Criteria

1. THE Society_App SHALL provide native mobile applications for Android and iOS platforms with feature parity
2. THE Society_App SHALL synchronize all user data, preferences, and content across devices in real-time
3. THE Society_App SHALL support offline reading of previously loaded content with sync upon reconnection
4. THE Society_App SHALL optimize performance for varying device specifications and network conditions
5. THE Society_App SHALL maintain consistent UI/UX patterns following platform-specific design guidelines

#### Technical Architecture Requirements

| Component | Specification | Rationale |
|-----------|---------------|-----------|
| **Development Framework** | Flutter (cross-platform) | Single codebase, native performance |
| **Backend Services** | Firebase/Supabase | Real-time sync, authentication, storage |
| **Database** | Cloud Firestore | NoSQL flexibility, real-time updates |
| **File Storage** | Cloud Storage | Scalable document/media handling |
| **Push Notifications** | FCM (Firebase Cloud Messaging) | Cross-platform notification delivery |
| **Offline Support** | Local SQLite cache | Essential content available offline |

## Project Management & Administration

### Project Creation & Structure

**User Story:** As the app owner, I want to create and configure new society projects so that communities can be onboarded to the platform.

#### Project Entity Model

```
Project
├── project_id: UUID (immutable)
├── project_name: String (e.g., "Prestige Lakeside Habitat")
├── location: String (e.g., "Bangalore, Karnataka")
├── rera_number: String (optional, for verification)
├── total_units: Integer (e.g., 1400)
├── phases: Array ["Phase 1", "Phase 2"]
├── blocks: Array ["A", "B", "C", "D", "E"]
├── unit_structure: JSON {
│   "Phase 1": {
│     "Block A": ["A-0101", "A-0102", ..., "A-1205"],
│     "Block B": [...]
│   },
│   "Phase 2": {...}
│ }
├── super_admins: Array of user_ids
├── status: "Under Construction" | "Near Completion" | "Completed"
├── created_at: timestamp
└── created_by: user_id (app owner)
```

#### Project Creation Workflow

| Step | Actor | Action | System Behavior |
|------|-------|--------|-----------------|
| **1. Project Setup** | App Owner | Create project with basic details | Generate project_id, initialize structure |
| **2. Unit Configuration** | App Owner | Define phases, blocks, unit numbers | Create unit master list |
| **3. Admin Assignment** | App Owner | Designate initial Super Admins | Grant admin privileges |
| **4. Project Activation** | App Owner | Activate project for user registration | Make project visible to new users |
| **5. User Onboarding** | Owners | Register and select project | Verification queue for admins |

#### Project Selection UX

**User Flow:**
```
1. User opens app after login
2. IF user belongs to multiple projects:
   ├── Show project selector screen
   ├── Display: Project name, role, unit count, unread notifications
   ├── User selects project
   └── App loads project-specific context
3. IF user belongs to single project:
   └── Directly load project
4. Project switcher always available in app menu/header
```

**Context Isolation:**
- All groups, spaces, discussions are project-scoped
- Documents are project-specific with metadata
- Notifications include project identifier
- Search is limited to current project
- User roles and permissions are project-specific

## Implementation Phases & Roadmap

### MVP Phase 1 (Months 1-3)
**Core Communication Platform**

| Feature Category | Included Features | Success Metrics |
|------------------|-------------------|-----------------|
| **User Management** | Registration, verification, basic profiles | 80% owner adoption |
| **Basic Groups** | General Group + 3-5 private groups | Active daily discussions |
| **Simple Spaces** | General spaces + 2-3 dedicated spaces per group | Reduced WhatsApp usage |
| **Document Sharing** | Basic upload/download with search | Document findability |
| **Mobile Apps** | Android + iOS with core features | Cross-platform usage |

### Phase 2 (Months 4-6)
**Enhanced Organization & Discovery**

| Feature Category | New Features | Enhancement Goals |
|------------------|--------------|-------------------|
| **Advanced Spaces** | Admin-created spaces, thread conversion | Better topic organization |
| **Tagging System** | Admin-managed tags, tag-based search | Improved content discovery |
| **Rich Content** | Polls, rich text formatting, video support | Enhanced engagement |
| **Vendor Marketplace** | Community reviews, quote sharing | Vendor discovery platform |
| **Advanced Search** | Full-text search, filter combinations | Information accessibility |

### Phase 2 (Months 4-6)
**Enhanced Organization & Discovery**

| Feature Category | New Features | Enhancement Goals |
|------------------|--------------|-------------------|
| **Advanced Spaces** | Admin-created spaces, thread conversion | Better topic organization |
| **Tagging System** | Admin-managed tags, tag-based search | Improved content discovery |
| **Rich Content** | Polls, rich text formatting, video support | Enhanced engagement |
| **Vendor Marketplace** | Community reviews, quote sharing | Vendor discovery platform |
| **Advanced Search** | Full-text search, filter combinations | Information accessibility |

### Future Enhancements (Months 7+)
**Automation & Advanced Features**

| Feature Category | Future Features | Strategic Value |
|------------------|-----------------|-----------------|
| **Smart Automation** | Auto-group suggestions, FAQ generation | Reduced admin workload |
| **Analytics Dashboard** | Usage analytics, engagement metrics | Data-driven improvements |
| **Integration APIs** | Third-party service connections | Ecosystem expansion |
| **Multi-Society Platform** | Self-service society onboarding | Business scalability |
| **Advanced Notifications** | Smart digest, AI-powered summaries | User experience optimization |

## Future Enhancements Wishlist

### Authentication & Security
- **OTP-based phone verification** for enhanced security
- **Biometric authentication** (fingerprint, face ID) for quick access
- **Two-factor authentication** for admin accounts
- **Session management** with device tracking and remote logout

### User Management
- **User-suggested space creation** with admin approval workflow
- **Automated group suggestions** based on user profile (phase, block, interests)
- **Bulk user import** from Excel/CSV for faster onboarding
- **User transfer workflow** for flat resale scenarios (revoke old owner, verify new owner)
- **Tenant management** separate from owner accounts with limited permissions

### Content & Communication
- **Voice messages** for quick communication
- **Video calls** for community meetings or admin discussions
- **Scheduled posts** for announcements and reminders
- **Post templates** for common scenarios (vendor reviews, complaints)
- **Content moderation tools** with flagging and reporting
- **Translation support** for multilingual communities

### Document Management
- **OCR on uploaded documents** to extract unit numbers automatically
- **Document versioning** to track changes over time
- **Folder organization** with custom categories
- **Document expiry reminders** for time-sensitive files
- **Bulk document upload** for admins
- **Document approval workflow** for official communications

### Vendor Marketplace
- **Vendor onboarding** allowing vendors to create profiles and respond to queries
- **Bulk discount requests** with vendor bidding system
- **Service booking** directly through app
- **Payment integration** for advance bookings
- **Vendor verification badges** for trusted service providers
- **Cross-society vendor ratings** for multi-project vendors

### Analytics & Insights
- **Admin analytics dashboard** with engagement metrics, popular topics, active users
- **Content analytics** showing most viewed documents, popular spaces
- **User activity reports** for community health monitoring
- **Sentiment analysis** on discussions to identify concerns
- **Predictive insights** for common queries and trending topics

### Community Features
- **Events management** for society gatherings, meetings, festivals
- **Polling & voting** for community decisions
- **Complaint management** with status tracking and resolution
- **Facility booking** for clubhouse, gym, party hall (post-occupation)
- **Visitor management** integration (post-occupation)
- **Delivery tracking** for packages and couriers (post-occupation)

### Financial Management (Post-Occupation)
- **Maintenance billing** and payment tracking
- **Expense tracking** for common area maintenance
- **Fund management** for society corpus
- **Payment reminders** and receipts
- **Financial reports** for transparency

### Integration & Automation
- **WhatsApp/Telegram bot** for notifications and quick queries
- **Email integration** for document sharing and notifications
- **Calendar integration** for events and reminders
- **RERA integration** for project status updates
- **Builder portal integration** for official communications (if builder cooperates)

### Advanced Search & Discovery
- **AI-powered search** with natural language queries
- **Smart FAQ generation** from popular discussions
- **Automatic tagging** using ML for content categorization
- **Related content suggestions** based on user interests
- **Search filters** by date, author, group, content type

### Scalability & Platform Features
- **Self-service project onboarding** for new societies
- **White-label solution** for builder partnerships
- **API marketplace** for third-party integrations
- **Mobile web version** for desktop access
- **Progressive Web App (PWA)** for lightweight access
- **Multi-language support** for pan-India expansion

### Privacy & Compliance
- **GDPR compliance** for data protection
- **Data export** functionality for users
- **Account deletion** with data cleanup
- **Privacy controls** for profile visibility
- **Audit logs** for all admin actions
- **Data retention policies** with automatic cleanup

## Technical Architecture & Database Schema

### Core Database Entities & Relationships

```
┌─────────────────┐
│     Users       │ (Global, cross-project)
├─────────────────┤
│ user_id (PK)    │
│ phone_number    │ (Unique, immutable)
│ email           │
│ created_at      │
└─────────────────┘
        │
        │ 1:N
        ▼
┌─────────────────────────┐
│  Project_Memberships    │ (Junction table)
├─────────────────────────┤
│ membership_id (PK)      │
│ user_id (FK)            │
│ project_id (FK)         │
│ display_name            │
│ role                    │
│ verification_status     │
│ verification_doc_url    │
│ verified_at             │
│ verified_by (FK)        │
└─────────────────────────┘
        │
        │ 1:N
        ▼
┌─────────────────────────┐
│   Unit_Ownerships       │
├─────────────────────────┤
│ ownership_id (PK)       │
│ membership_id (FK)      │
│ unit_id (FK)            │
│ ownership_type          │
│ verified_doc_url        │
│ created_at              │
└─────────────────────────┘
        │
        │ N:1
        ▼
┌─────────────────────────┐
│        Units            │
├─────────────────────────┤
│ unit_id (PK)            │
│ project_id (FK)         │
│ unit_number             │
│ block                   │
│ phase                   │
│ floor                   │
└─────────────────────────┘

┌─────────────────────────┐
│       Projects          │
├─────────────────────────┤
│ project_id (PK)         │
│ project_name            │
│ location                │
│ rera_number             │
│ total_units             │
│ phases (JSON)           │
│ blocks (JSON)           │
│ unit_structure (JSON)   │
│ status                  │
│ created_at              │
│ created_by (FK)         │
└─────────────────────────┘
        │
        │ 1:N
        ▼
┌─────────────────────────┐
│        Groups           │
├─────────────────────────┤
│ group_id (PK)           │
│ project_id (FK)         │
│ group_name              │
│ description             │
│ group_type              │ (General/Private)
│ access_criteria (JSON)  │
│ created_by (FK)         │
│ created_at              │
└─────────────────────────┘
        │
        │ 1:N
        ▼
┌─────────────────────────┐
│        Spaces           │
├─────────────────────────┤
│ space_id (PK)           │
│ group_id (FK)           │
│ space_name              │
│ space_type              │ (General/Dedicated)
│ created_by (FK)         │
│ created_at              │
└─────────────────────────┘
        │
        │ 1:N
        ▼
┌─────────────────────────┐
│       Threads           │
├─────────────────────────┤
│ thread_id (PK)          │
│ space_id (FK)           │
│ author_id (FK)          │
│ title                   │
│ content                 │
│ content_type            │
│ tags (JSON)             │
│ is_pinned               │
│ created_at              │
│ updated_at              │
└─────────────────────────┘
        │
        │ 1:N
        ▼
┌─────────────────────────┐
│       Replies           │
├─────────────────────────┤
│ reply_id (PK)           │
│ thread_id (FK)          │
│ parent_reply_id (FK)    │ (for nested replies)
│ author_id (FK)          │
│ content                 │
│ mentions (JSON)         │ (array of user_ids)
│ created_at              │
│ updated_at              │
└─────────────────────────┘

┌─────────────────────────┐
│      Documents          │
├─────────────────────────┤
│ document_id (PK)        │
│ project_id (FK)         │
│ uploaded_by (FK)        │
│ source_thread_id (FK)   │
│ source_space_id (FK)    │
│ file_name               │
│ file_type               │
│ file_size               │
│ file_url                │
│ tags (JSON)             │
│ created_at              │
└─────────────────────────┘

┌─────────────────────────┐
│         Tags            │
├─────────────────────────┤
│ tag_id (PK)             │
│ project_id (FK)         │
│ tag_name                │
│ tag_category            │
│ created_by (FK)         │
│ created_at              │
└─────────────────────────┘

┌─────────────────────────┐
│    Notifications        │
├─────────────────────────┤
│ notification_id (PK)    │
│ user_id (FK)            │
│ project_id (FK)         │
│ notification_type       │
│ content                 │
│ source_id               │ (thread/reply/group)
│ is_read                 │
│ created_at              │
└─────────────────────────┘
```

### Key Relationships Summary

| Relationship | Type | Description |
|--------------|------|-------------|
| User ↔ Project | Many-to-Many | Via Project_Memberships junction table |
| User ↔ Unit | Many-to-Many | Via Unit_Ownerships (supports multiple units per user, multiple owners per unit) |
| Project → Groups | One-to-Many | Each project has multiple groups |
| Group → Spaces | One-to-Many | Each group contains multiple spaces |
| Space → Threads | One-to-Many | Each space has multiple discussion threads |
| Thread → Replies | One-to-Many | Each thread has multiple replies (with nested support) |
| Document → Thread/Space | Many-to-One | Documents linked to source for context |

### Data Isolation & Security

| Aspect | Implementation | Purpose |
|--------|----------------|---------|
| **Project Isolation** | All queries filtered by project_id | Complete data separation between societies |
| **Group Permissions** | Membership validation before content access | Privacy for private groups |
| **Document Access** | Permission check based on source space/group | Respect original sharing context |
| **User Privacy** | Phone numbers visible only to admins | Prevent spam and harassment |
| **Audit Trails** | Timestamp and creator tracking on all entities | Accountability and debugging |

## Success Metrics & KPIs

### User Adoption Metrics
- **Registration Rate:** 80% of eligible owners within 3 months
- **Daily Active Users:** 40% of registered users
- **Group Participation:** Average 3+ groups per active user
- **Content Creation:** 50+ posts/discussions per day

### Engagement Quality Metrics
- **WhatsApp Migration:** 70% reduction in society-related WhatsApp messages
- **Information Findability:** 80% of queries resolved through search/FAQ
- **Vendor Discovery:** 60% of interior/service decisions influenced by app recommendations
- **Document Usage:** 90% of important documents accessed through app vs. scattered sharing

### Technical Performance Metrics
- **App Performance:** <3 second load times, 99.5% uptime
- **Cross-Platform Consistency:** Feature parity maintained across Android/iOS
- **Search Effectiveness:** <2 seconds for document/discussion search results
- **Offline Capability:** 100% of cached content accessible offline

### Scale Targets (Based on 1500 Units)
- **Expected Users:** 1500-2000 registered owners (accounting for co-ownership)
- **Daily Active Users (DAU):** 150-200 users (10% of registered base)
- **Monthly Active Users (MAU):** 450-600 users (30% of registered base)
- **Peak Concurrent Users:** 50-100 users during critical announcements
- **Storage Requirements:** ~50-100 GB for documents/media (first year)
- **Bandwidth:** ~500 GB/month for media delivery

## Appendix: User Stories Summary

### Authentication & User Management
1. As a potential apartment owner, I want to securely join the community app so that I can access verified information
2. As a Super Admin, I want to review and approve pending user verifications so that only legitimate owners can access the community
3. As a user with multiple flats, I want to associate all my units with my account so that I can manage them from a single login
4. As a co-owner of a unit, I want independent app access so that both owners can participate in community discussions
5. As a user in multiple projects, I want to easily switch between projects so that I can manage my involvement in different societies

### Group & Space Management
6. As a Super Admin, I want to create and manage different groups and spaces so that discussions remain organized
7. As a Group Admin, I want to manage my assigned groups and create spaces within them so that I can facilitate organized discussions
8. As an owner, I want to request access to relevant private groups so that I can participate in discussions specific to my interests
9. As an admin, I want to convert popular discussion threads into dedicated spaces so that recurring topics get proper organization

### Communication & Discussion
10. As an owner, I want to participate in organized discussions with proper threading so that I can follow conversations easily
11. As an owner, I want to share various content types (text, images, videos, documents, polls) so that I can effectively communicate
12. As an owner, I want to mention/tag other community members in discussions so that they get notified about relevant conversations

### Document & Information Management
13. As an owner, I want to easily find and access important documents shared across different discussions so that I don't miss critical information
14. As an owner, I want to search through all accessible content and documents so that I can quickly find relevant information
15. As a Super Admin, I want to create and manage content tags so that discussions can be categorized efficiently

### Vendor Discovery
16. As an owner planning interiors, I want to discover trusted vendors through community recommendations so that I can make informed decisions
17. As an owner who used a service, I want to share my vendor experience and ratings so that I can help fellow community members
18. As an owner, I want to participate in group buying discussions so that I can potentially get better rates through bulk purchases

### Notifications & Preferences
19. As an owner, I want to control what notifications I receive so that I stay informed without being overwhelmed
20. As an owner, I want to follow specific threads or spaces so that I get targeted updates about topics that matter to me

### Cross-Platform Experience
21. As an owner using different mobile devices, I want consistent app experience across platforms so that I can participate regardless of device choice
22. As an owner with limited connectivity, I want to access previously loaded content offline so that I can stay informed even without internet

---

This comprehensive requirements document provides the foundation for building a robust, scalable society management platform that addresses real community needs while positioning for future growth and expansion. The document captures technical architecture, competitive positioning, implementation roadmap, and extensive future enhancement possibilities to guide development through multiple phases.