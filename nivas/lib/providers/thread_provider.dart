import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/models/thread.dart';
import 'package:nivas/models/reply.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/utils/constants.dart';

/// Provider for threads in a space
/// 
/// Returns threads ordered by pinned status and last activity
final spaceThreadsProvider = StreamProvider.family<List<Thread>, String>((ref, spaceId) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.threadsCollection)
      .where('space_id', isEqualTo: spaceId)
      .orderBy('is_pinned', descending: true)
      .orderBy('last_activity_at', descending: true)
      .limit(20) // Pagination
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Thread.fromFirestore(doc)).toList();
  });
});

/// Provider for a specific thread
/// 
/// Usage: ref.watch(threadProvider(threadId))
final threadProvider = StreamProvider.family<Thread?, String>((ref, threadId) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.threadsCollection)
      .doc(threadId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return Thread.fromFirestore(doc);
  });
});

/// Provider for user's threads
/// 
/// Returns threads created by current user
final userThreadsProvider = StreamProvider<List<Thread>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value([]);
  }
  
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.threadsCollection)
      .where('author_id', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Thread.fromFirestore(doc)).toList();
  });
});

/// Provider to check if user is thread author
/// 
/// Usage: ref.watch(isThreadAuthorProvider(threadId))
final isThreadAuthorProvider = Provider.family<bool, String>((ref, threadId) {
  final userId = ref.watch(currentUserIdProvider);
  final threadAsync = ref.watch(threadProvider(threadId));
  
  if (userId == null) return false;
  
  return threadAsync.when(
    data: (thread) => thread?.authorId == userId,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for replies in a thread
/// 
/// Returns replies ordered chronologically
final threadRepliesProvider = StreamProvider.family<List<Reply>, String>((ref, threadId) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.threadsCollection)
      .doc(threadId)
      .collection(AppConstants.repliesSubcollection)
      .orderBy('created_at', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Reply.fromFirestore(doc)).toList();
  });
});

/// Provider for a specific reply
/// 
/// Usage: ref.watch(replyProvider((threadId, replyId)))
final replyProvider = StreamProvider.family<Reply?, ({String threadId, String replyId})>((ref, params) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection(AppConstants.threadsCollection)
      .doc(params.threadId)
      .collection(AppConstants.repliesSubcollection)
      .doc(params.replyId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return Reply.fromFirestore(doc);
  });
});

/// Provider to check if user is reply author
/// 
/// Usage: ref.watch(isReplyAuthorProvider((threadId, replyId)))
final isReplyAuthorProvider = Provider.family<bool, ({String threadId, String replyId})>((ref, params) {
  final userId = ref.watch(currentUserIdProvider);
  final replyAsync = ref.watch(replyProvider(params));
  
  if (userId == null) return false;
  
  return replyAsync.when(
    data: (reply) => reply?.authorId == userId,
    loading: () => false,
    error: (_, __) => false,
  );
});
