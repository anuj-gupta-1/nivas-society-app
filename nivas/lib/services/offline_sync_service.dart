import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivas/services/hive_service.dart';

/// Service for syncing offline actions when connection is restored
class OfflineSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Process all pending actions in offline queue
  Future<void> syncPendingActions() async {
    final actions = OfflineQueue.getAllActions();
    
    if (actions.isEmpty) return;
    
    for (final action in actions) {
      try {
        await _processAction(action);
        // Remove from queue if successful
        await OfflineQueue.removeAction(action['id']);
      } catch (e) {
        // Keep in queue if failed, will retry later
        print('Failed to sync action: $e');
      }
    }
  }

  /// Process a single action
  Future<void> _processAction(Map<String, dynamic> action) async {
    final type = action['type'] as String;
    
    switch (type) {
      case 'create_thread':
        await _createThread(action['data']);
        break;
      case 'create_reply':
        await _createReply(action['data']);
        break;
      case 'update_user':
        await _updateUser(action['data']);
        break;
      case 'upload_document':
        await _uploadDocument(action['data']);
        break;
      default:
        print('Unknown action type: $type');
    }
  }

  /// Create thread (will be implemented later)
  Future<void> _createThread(Map<String, dynamic> data) async {
    // TODO: Implement when we build threads
    await _firestore.collection('threads').add(data);
  }

  /// Create reply (will be implemented later)
  Future<void> _createReply(Map<String, dynamic> data) async {
    // TODO: Implement when we build replies
    final threadId = data['thread_id'];
    await _firestore
        .collection('threads')
        .doc(threadId)
        .collection('replies')
        .add(data);
  }

  /// Update user
  Future<void> _updateUser(Map<String, dynamic> data) async {
    final userId = data['user_id'];
    await _firestore.collection('users').doc(userId).update(data);
  }

  /// Upload document (will be implemented later)
  Future<void> _uploadDocument(Map<String, dynamic> data) async {
    // TODO: Implement when we build document upload
    await _firestore.collection('documents').add(data);
  }

  /// Get pending actions count
  int getPendingCount() {
    return OfflineQueue.getSize();
  }
}
