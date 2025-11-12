# Architecture Decisions Record (ADR)

**Project:** Nivas - Society Management App  
**Purpose:** Document key technical decisions, rationale, and trade-offs

---

## ADR-001: State Management - Riverpod

**Date:** 2024  
**Status:** ✅ Implemented  
**Decision Makers:** Development Team

### Context
Flutter offers multiple state management solutions: Provider, Riverpod, Bloc, GetX, MobX, Redux.

### Decision
**Chose Riverpod** for state management.

### Rationale
1. **Compile-time Safety:** Catches errors at compile time, not runtime
2. **No BuildContext Required:** Can read providers anywhere without context
3. **Better Testing:** Providers are easily mockable and testable
4. **Real-time Streams:** Excellent integration with Firestore streams
5. **Scalability:** Handles complex state dependencies well
6. **Modern:** Latest evolution of Provider with lessons learned
7. **Community:** Strong community support and documentation

### Alternatives Considered
- **Provider:** Older, requires BuildContext, less type-safe
- **Bloc:** Too verbose for this project size, steeper learning curve
- **GetX:** Too magical, harder to debug, less predictable
- **MobX:** Requires code generation, more boilerplate

### Consequences
- **Positive:** Clean code, easy debugging, excellent real-time support
- **Negative:** Learning curve for developers new to Riverpod
- **Mitigation:** Comprehensive provider documentation in codebase

---

## ADR-002: Local Storage - Hive

**Date:** 2024  
**Status:** ✅ Implemented  
**Decision Makers:** Development Team

### Context
Need local storage for offline support and caching. Options: SharedPreferences, Hive, SQLite, Isar, ObjectBox.

### Decision
**Chose Hive** for local storage.

### Rationale
1. **Performance:** Fast key-value storage, optimized for Flutter
2. **No Native Dependencies:** Pure Dart, works on all platforms
3. **Type Safety:** Strongly typed with adapters
4. **Lightweight:** Small package size, minimal overhead
5. **Easy to Use:** Simple API, minimal boilerplate
6. **Offline Queue:** Perfect for queuing offline actions
7. **Encryption:** Built-in encryption support for sensitive data

### Alternatives Considered
- **SharedPreferences:** Too simple, not suitable for complex objects
- **SQLite:** Overkill for our use case, requires SQL knowledge
- **Isar:** Newer, less mature, more complex than needed
- **ObjectBox:** Native dependencies, larger package size

### Consequences
- **Positive:** Fast, reliable offline support, easy to implement
- **Negative:** Not a relational database (but we don't need one)
- **Trade-off:** Good enough for caching and offline queue

---

## ADR-003: Backend - Firebase Suite

**Date:** 2024  
**Status:** ✅ Implemented  
**Decision Makers:** Development Team

### Context
Need backend for authentication, database, storage, and notifications. Options: Firebase, Supabase, AWS Amplify, Custom Backend.

### Decision
**Chose Firebase** (Auth, Firestore, Storage, FCM).

### Rationale
1. **Real-time Database:** Firestore provides real-time updates out of the box
2. **Authentication:** Phone auth with OTP built-in
3. **Scalability:** Scales automatically with usage
4. **Security:** Robust security rules at database level
5. **Storage:** Integrated file storage for documents/media
6. **Push Notifications:** FCM for notifications
7. **Cost-Effective:** Free tier generous, pay-as-you-grow
8. **Developer Experience:** Excellent Flutter integration
9. **Time to Market:** Fastest to implement

### Alternatives Considered
- **Supabase:** PostgreSQL-based, more complex queries, but less real-time
- **AWS Amplify:** More complex setup, steeper learning curve
- **Custom Backend:** Too much development time, maintenance overhead

### Consequences
- **Positive:** Fast development, real-time updates, automatic scaling
- **Negative:** Vendor lock-in, limited complex queries
- **Cost Consideration:** See ADR-010 for cost analysis

---

## ADR-004: Discussion Hierarchy - Groups → Spaces → Threads

**Date:** 2024  
**Status:** ✅ Implemented  
**Decision Makers:** Product Team

### Context
Need to organize discussions in a scalable, intuitive way.

### Decision
**Three-level hierarchy:** Groups → Spaces → Threads → Replies

### Rationale
1. **Groups:** Top-level organization (e.g., "Maintenance", "Events")
2. **Spaces:** Topic-based sub-organization (e.g., "Plumbing", "Electrical")
3. **Threads:** Individual discussions with replies
4. **Scalability:** Can handle hundreds of discussions without clutter
5. **Flexibility:** Users can organize content logically
6. **Permissions:** Can control access at group level

### Alternatives Considered
- **Flat Structure:** All threads in one list (too cluttered)
- **Two Levels:** Groups → Threads (not enough organization)
- **Four Levels:** Too complex, confusing for users

### Consequences
- **Positive:** Clean organization, scalable, intuitive
- **Negative:** Slightly more navigation depth
- **User Feedback:** Will validate with beta users

---

## ADR-005: Reply System - Nested Replies

**Date:** 2024  
**Status:** ✅ Implemented  
**Decision Makers:** Development Team

### Context
Need to support conversations within threads. Options: flat replies, nested replies, threaded conversations.

### Decision
**Nested replies** with parent_reply_id tracking.

### Rationale
1. **Context:** Replies maintain conversation context
2. **Clarity:** Easy to see who's replying to whom
3. **Engagement:** Encourages focused discussions
4. **Visual:** Indentation shows reply hierarchy
5. **Flexibility:** Can reply to any reply

### Alternatives Considered
- **Flat Replies:** Loses context, hard to follow conversations
- **Fully Threaded:** Too complex, confusing UI

### Implementation
- Store `parent_reply_id` in reply document
- Visual indentation in UI (max 3 levels)
- Chronological ordering within each level

### Consequences
- **Positive:** Clear conversations, better engagement
- **Negative:** Slightly more complex data structure
- **Performance:** Minimal impact, replies are subcollections

---

## ADR-006: Authentication - Phone-Based

**Date:** 2024  
**Status:** ✅ Implemented  
**Decision Makers:** Product Team

### Context
Need secure authentication suitable for Indian users. Options: Email, Phone, Social Login.

### Decision
**Phone-based authentication** with OTP verification.

### Rationale
1. **User Preference:** Phone numbers more common than emails in India
2. **Verification:** Easy to verify with OTP
3. **Trust:** Phone numbers feel more secure to users
4. **Unique Identifier:** One phone = one account
5. **Firebase Support:** Built-in phone auth with OTP

### Alternatives Considered
- **Email:** Less common, users forget passwords
- **Social Login:** Privacy concerns, not everyone has accounts
- **Username/Password:** Users forget passwords, less secure

### Consequences
- **Positive:** High user adoption, secure, easy to use
- **Negative:** Requires SMS costs (minimal with Firebase)
- **Security:** Additional admin verification layer added

---

## ADR-007: Admin Verification - Manual Approval

**Date:** 2024  
**Status:** ✅ Implemented  
**Decision Makers:** Product Team

### Context
Need to ensure only legitimate residents access the society app.

### Decision
**Manual admin verification** with document upload.

### Rationale
1. **Security:** Prevents unauthorized access
2. **Trust:** Ensures community integrity
3. **Flexibility:** Admins can verify based on local knowledge
4. **Audit Trail:** Complete history of approvals/rejections
5. **Document Proof:** Users upload ownership documents

### Alternatives Considered
- **Automatic Verification:** Not reliable, can be gamed
- **No Verification:** Security risk, spam potential
- **Third-party Verification:** Too expensive, not necessary

### Consequences
- **Positive:** Secure, trusted community
- **Negative:** Manual work for admins, slight delay for users
- **Mitigation:** Fast verification process, clear status updates

---

## ADR-008: Offline Support - Queue-Based Sync

**Date:** 2024  
**Status:** ✅ Implemented  
**Decision Makers:** Development Team

### Context
Indian users often face connectivity issues. Need robust offline support.

### Decision
**Offline-first architecture** with action queue and auto-sync.

### Rationale
1. **User Experience:** App works even without internet
2. **Reliability:** Actions never lost, queued locally
3. **Automatic:** Syncs when connection restored
4. **Transparency:** Users see offline status
5. **Data Caching:** Hive caches frequently accessed data

### Implementation
- `offline_sync_service.dart` - Queue management
- `connectivity_service.dart` - Network monitoring
- `hive_service.dart` - Local caching
- Auto-retry with exponential backoff

### Consequences
- **Positive:** Excellent UX, works in poor connectivity
- **Negative:** Slightly more complex sync logic
- **Performance:** Minimal overhead, efficient caching

---

## ADR-009: Multi-Project Support - Project Context

**Date:** 2024  
**Status:** ✅ Implemented  
**Decision Makers:** Product Team

### Context
Users may belong to multiple societies (e.g., own properties in different locations).

### Decision
**Multi-project architecture** with project context switching.

### Rationale
1. **Flexibility:** Users can manage multiple societies
2. **Scalability:** Platform can serve multiple societies
3. **Data Isolation:** Each project's data is separate
4. **Business Model:** Can onboard multiple societies
5. **User Convenience:** Switch between projects easily

### Implementation
- `project_provider.dart` - Current project context
- `project_switcher.dart` - UI for switching
- All queries filtered by `project_id`
- User can have different roles in different projects

### Consequences
- **Positive:** Scalable business model, flexible for users
- **Negative:** Slightly more complex data model
- **Performance:** Minimal impact, efficient queries

---

## ADR-010: Cost & Scaling Strategy

**Date:** 2024  
**Status:** 📋 Planned  
**Decision Makers:** Product Team

### Context
Need to understand costs and plan for scaling as user base grows.

### Firebase Cost Analysis

#### Free Tier (Spark Plan)
- **Firestore:** 50K reads, 20K writes, 20K deletes per day
- **Storage:** 5GB storage, 1GB download per day
- **Authentication:** Unlimited
- **Hosting:** 10GB storage, 360MB/day transfer
- **Functions:** 125K invocations, 40K GB-seconds

#### Estimated Costs at Scale

**100 Users (1 Society):**
- **Firestore:** ~$0-5/month (within free tier)
- **Storage:** ~$0-2/month (documents only)
- **Total:** ~$0-7/month ✅ FREE TIER

**500 Users (5 Societies):**
- **Firestore:** ~$10-20/month (reads/writes)
- **Storage:** ~$5-10/month (documents + some media)
- **Total:** ~$15-30/month

**2,000 Users (20 Societies):**
- **Firestore:** ~$50-100/month
- **Storage:** ~$20-40/month (with media)
- **Functions:** ~$10-20/month (notifications)
- **Total:** ~$80-160/month

**10,000 Users (100 Societies):**
- **Firestore:** ~$300-500/month
- **Storage:** ~$100-200/month
- **Functions:** ~$50-100/month
- **Total:** ~$450-800/month

### Cost Optimization Strategies

1. **Caching:** Aggressive local caching reduces reads
2. **Pagination:** Load data in chunks, not all at once
3. **Offline-First:** Reduces unnecessary network calls
4. **Image Compression:** Reduce storage and bandwidth costs
5. **Query Optimization:** Efficient queries, proper indexing
6. **CDN:** Use Firebase Hosting CDN for static assets

### Scaling Considerations

#### Database Scaling
- **Firestore:** Scales automatically, no manual intervention
- **Sharding:** Not needed until millions of documents
- **Indexes:** Create composite indexes for complex queries
- **Denormalization:** Already implemented for performance

#### Storage Scaling
- **Firebase Storage:** Scales automatically
- **CDN:** Built-in CDN for fast delivery
- **Compression:** Implement image compression before upload
- **Cleanup:** Periodic cleanup of unused files

#### Performance Scaling
- **Real-time Listeners:** Limit to active screens only
- **Pagination:** Implemented for large lists
- **Lazy Loading:** Load data as needed
- **Background Sync:** Sync in background, not blocking UI

### Revenue Model Considerations

**Freemium Model:**
- Free for small societies (<50 users)
- Paid tiers for larger societies
- Premium features (analytics, integrations)

**Per-Society Pricing:**
- ₹500-1000/month per society (50-100 users)
- ₹2000-3000/month for large societies (200+ users)
- Covers Firebase costs + profit margin

**Break-even Analysis:**
- 10 societies @ ₹1000/month = ₹10,000/month revenue
- Covers costs for ~500-1000 users
- Profitable from day one with proper pricing

### Monitoring & Alerts

**Set up alerts for:**
- Daily Firebase costs exceeding threshold
- Storage usage approaching limits
- Firestore read/write spikes
- Function execution errors
- User growth rate

### Future Optimization

**If costs become significant:**
1. **Migrate to Supabase:** PostgreSQL-based, potentially cheaper
2. **Custom Backend:** More control, but more maintenance
3. **Hybrid Approach:** Firebase for real-time, custom for storage
4. **Caching Layer:** Redis for frequently accessed data

### Consequences
- **Positive:** Predictable costs, scales automatically
- **Negative:** Costs grow with usage (but so does revenue)
- **Mitigation:** Aggressive caching, optimization, proper pricing

---

## ADR-011: Testing Strategy - Lightweight MVP

**Date:** 2024  
**Status:** ⚠️ Minimal (Pending Comprehensive)  
**Decision Makers:** Development Team

### Context
Need to balance speed to market with code quality.

### Decision
**Lightweight testing for MVP**, comprehensive testing post-beta.

### Rationale
1. **Speed:** Get to market faster for user feedback
2. **Validation:** Real user feedback more valuable than extensive tests
3. **Iteration:** Will refactor based on actual usage patterns
4. **Resources:** Limited development time for MVP

### Current Testing
- Manual testing of all user flows
- Firebase emulator for local testing
- Real device testing (Android)

### Post-Beta Testing Plan
- **Unit Tests:** Core business logic (services, providers)
- **Widget Tests:** Critical UI components
- **Integration Tests:** End-to-end user flows
- **Performance Tests:** Load testing, stress testing
- **Security Tests:** Penetration testing, security audit

### Consequences
- **Positive:** Faster MVP launch, real user feedback
- **Negative:** Potential bugs in production
- **Mitigation:** Beta testing with small user group first

---

## ADR-012: UI/UX - Material Design 3

**Date:** 2024  
**Status:** ✅ Implemented  
**Decision Makers:** Design Team

### Context
Need consistent, modern UI that feels native to Android users.

### Decision
**Material Design 3** with custom color scheme.

### Rationale
1. **Familiarity:** Android users know Material Design
2. **Components:** Rich set of pre-built components
3. **Accessibility:** Built-in accessibility features
4. **Consistency:** Consistent across the app
5. **Modern:** Latest design language from Google

### Color Scheme
- **Primary:** Teal (community, trust)
- **Secondary:** Orange (energy, warmth)
- **Accent:** Deep Orange (calls to action)
- **Background:** White/Light grey (clean, readable)

### Consequences
- **Positive:** Professional look, familiar to users
- **Negative:** Less unique than custom design
- **Trade-off:** Speed and familiarity over uniqueness

---

## ADR-013: Notification Strategy - FCM Ready

**Date:** 2024  
**Status:** 🔄 Infrastructure Ready, Implementation Pending  
**Decision Makers:** Development Team

### Context
Need push notifications for user engagement.

### Decision
**Firebase Cloud Messaging (FCM)** with server-side triggers.

### Current Status
- FCM tokens registered in `auth_service.dart`
- Infrastructure ready
- Implementation deferred to post-beta

### Planned Implementation
- **Triggers:** Mentions, replies, admin actions
- **Types:** Push notifications, in-app notifications
- **Preferences:** User-configurable in settings
- **Badge Counts:** Unread notification counts

### Consequences
- **Positive:** Infrastructure ready, easy to implement
- **Negative:** Deferred to post-beta (not critical for MVP)
- **Timeline:** 3-4 days post-beta

---

## Summary of Key Decisions

| Decision | Status | Impact | Rationale |
|----------|--------|--------|-----------|
| Riverpod | ✅ Done | High | Best for real-time, type-safe |
| Hive | ✅ Done | Medium | Fast, offline support |
| Firebase | ✅ Done | High | Real-time, scalable, fast |
| Nested Replies | ✅ Done | Medium | Better conversations |
| Phone Auth | ✅ Done | High | User preference in India |
| Manual Verification | ✅ Done | High | Security, trust |
| Offline-First | ✅ Done | High | Poor connectivity support |
| Multi-Project | ✅ Done | High | Scalable business model |
| Lightweight Testing | ⚠️ Partial | Medium | Speed to market |
| FCM Ready | 🔄 Pending | Medium | Post-beta implementation |

---

**Document Maintenance:**
- Update this document when making significant architectural decisions
- Include context, alternatives, and consequences
- Reference ADR numbers in code comments for traceability
