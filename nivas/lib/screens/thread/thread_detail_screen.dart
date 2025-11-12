import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivas/models/thread.dart';
import 'package:nivas/models/reply.dart';
import 'package:nivas/providers/thread_provider.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/group_provider.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/utils/constants.dart';

/// Thread detail screen
/// 
/// Shows full thread content and all replies
class ThreadDetailScreen extends ConsumerStatefulWidget {
  final String threadId;

  const ThreadDetailScreen({
    super.key,
    required this.threadId,
  });

  @override
  ConsumerState<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends ConsumerState<ThreadDetailScreen> {
  final _replyController = TextEditingController();
  String? _replyingToId;
  String? _replyingToName;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _postReply() async {
    final content = _replyController.text.trim();
    
    if (content.isEmpty) {
      ref.read(errorProvider.notifier).setError('Please enter a reply');
      return;
    }

    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final userId = ref.read(currentUserIdProvider);
      final currentUser = await ref.read(currentUserProvider.future);
      
      if (userId == null || currentUser == null) {
        throw Exception('User not found');
      }

      final firestore = ref.read(firestoreProvider);
      
      // Create reply
      final replyRef = firestore
          .collection(AppConstants.threadsCollection)
          .doc(widget.threadId)
          .collection(AppConstants.repliesSubcollection)
          .doc();
      
      final reply = Reply(
        replyId: replyRef.id,
        threadId: widget.threadId,
        content: content,
        authorId: userId,
        authorName: currentUser.displayName,
        parentReplyId: _replyingToId,
        mentionedUserIds: _extractMentions(content),
        attachments: [], // TODO: Implement attachments
        createdAt: DateTime.now(),
      );

      await replyRef.set(reply.toFirestore());

      // Update thread reply count and last activity
      await firestore
          .collection(AppConstants.threadsCollection)
          .doc(widget.threadId)
          .update({
        'reply_count': FieldValue.increment(1),
        'last_activity_at': FieldValue.serverTimestamp(),
      });

      // TODO: Send notifications to thread author and mentioned users

      _replyController.clear();
      setState(() {
        _replyingToId = null;
        _replyingToName = null;
      });

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Reply posted!');
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed to post reply: $e');
    }
  }

  List<String> _extractMentions(String content) {
    final mentionPattern = RegExp(r'@(\w+)');
    final matches = mentionPattern.allMatches(content);
    return matches.map((m) => m.group(1)!).toList();
  }

  void _setReplyingTo(String replyId, String authorName) {
    setState(() {
      _replyingToId = replyId;
      _replyingToName = authorName;
    });
    _replyController.text = '@$authorName ';
  }

  void _cancelReplyingTo() {
    setState(() {
      _replyingToId = null;
      _replyingToName = null;
    });
    _replyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final threadAsync = ref.watch(threadProvider(widget.threadId));
    final repliesAsync = ref.watch(threadRepliesProvider(widget.threadId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread'),
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
        actions: [
          _buildThreadActions(context),
        ],
      ),
      body: Column(
        children: [
          // Thread Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Original Thread
                threadAsync.when(
                  data: (thread) {
                    if (thread == null) {
                      return const Center(child: Text('Thread not found'));
                    }
                    return _buildThreadCard(thread);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
                
                const SizedBox(height: 24),
                
                // Replies Section
                repliesAsync.when(
                  data: (replies) {
                    if (replies.isEmpty) {
                      return _buildNoReplies();
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${replies.length} ${replies.length == 1 ? 'Reply' : 'Replies'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...replies.map((reply) => _buildReplyCard(reply)),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
              ],
            ),
          ),
          
          // Reply Input
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildThreadActions(BuildContext context) {
    final isAuthor = ref.watch(isThreadAuthorProvider(widget.threadId));
    final threadAsync = ref.watch(threadProvider(widget.threadId));
    
    return PopupMenuButton<String>(
      onSelected: (value) => _handleThreadAction(value, threadAsync.value),
      itemBuilder: (context) {
        final items = <PopupMenuItem<String>>[];
        
        // TODO: Check if user is admin for pin/unpin
        // items.add(const PopupMenuItem(
        //   value: 'pin',
        //   child: Text('Pin Thread'),
        // ));
        
        if (isAuthor) {
          items.add(const PopupMenuItem(
            value: 'edit',
            child: Text('Edit Thread'),
          ));
          items.add(const PopupMenuItem(
            value: 'delete',
            child: Text('Delete Thread'),
          ));
        }
        
        items.add(const PopupMenuItem(
          value: 'follow',
          child: Text('Follow Thread'),
        ));
        
        return items;
      },
    );
  }

  void _handleThreadAction(String action, Thread? thread) {
    if (thread == null) return;
    
    switch (action) {
      case 'pin':
        _pinThread(thread);
        break;
      case 'edit':
        _editThread(thread);
        break;
      case 'delete':
        _deleteThread(thread);
        break;
      case 'follow':
        _followThread(thread);
        break;
    }
  }

  Future<void> _pinThread(Thread thread) async {
    // TODO: Implement pin/unpin
    ref.read(successProvider.notifier).setSuccess('Pin feature coming soon');
  }

  Future<void> _editThread(Thread thread) async {
    // TODO: Implement edit
    ref.read(successProvider.notifier).setSuccess('Edit feature coming soon');
  }

  Future<void> _deleteThread(Thread thread) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Thread'),
        content: const Text('Are you sure you want to delete this thread? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.error),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final firestore = ref.read(firestoreProvider);
      
      // Delete thread
      await firestore
          .collection(AppConstants.threadsCollection)
          .doc(thread.threadId)
          .delete();

      // Update space thread count
      await firestore
          .collection(AppConstants.spacesCollection)
          .doc(thread.spaceId)
          .update({
        'thread_count': FieldValue.increment(-1),
      });

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Thread deleted');

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed to delete: $e');
    }
  }

  Future<void> _followThread(Thread thread) async {
    // TODO: Implement follow/unfollow
    ref.read(successProvider.notifier).setSuccess('Follow feature coming soon');
  }

  Widget _buildThreadCard(Thread thread) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(AppColors.primaryBlue).withOpacity(0.1),
                  child: Text(
                    thread.authorName[0].toUpperCase(),
                    style: TextStyle(
                      color: Color(AppColors.primaryBlue),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _formatDateTime(thread.createdAt),
                        style: TextStyle(
                          color: Color(AppColors.textSecondary),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (thread.isPinned)
                  Icon(Icons.push_pin, color: Color(AppColors.warning), size: 20),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Title
            Text(
              thread.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Content
            Text(
              thread.content,
              style: const TextStyle(fontSize: 15),
            ),
            
            // Attachments
            if (thread.attachments.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...thread.attachments.map((attachment) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, size: 20, color: Color(AppColors.textSecondary)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          attachment.fileName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoReplies() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.comment_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No replies yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to reply!',
            style: TextStyle(
              fontSize: 14,
              color: Color(AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(Reply reply) {
    return Card(
      margin: EdgeInsets.only(
        bottom: 12,
        left: reply.isNested ? 32 : 0,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(AppColors.primaryBlue).withOpacity(0.1),
                  radius: 14,
                  child: Text(
                    reply.authorName[0].toUpperCase(),
                    style: TextStyle(
                      color: Color(AppColors.primaryBlue),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _formatDateTime(reply.createdAt),
                        style: TextStyle(
                          color: Color(AppColors.textSecondary),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.reply, size: 18),
                  onPressed: () => _setReplyingTo(reply.replyId, reply.authorName),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Content
            Text(
              reply.content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    final isLoading = ref.watch(loadingProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Replying To Indicator
          if (_replyingToName != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(AppColors.primaryBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.reply, size: 16, color: Color(AppColors.primaryBlue)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to $_replyingToName',
                      style: TextStyle(
                        color: Color(AppColors.primaryBlue),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: _cancelReplyingTo,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Input Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  decoration: InputDecoration(
                    hintText: 'Write a reply...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: isLoading ? null : _postReply,
                icon: Icon(
                  Icons.send,
                  color: isLoading ? Colors.grey : Color(AppColors.primaryBlue),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Color(AppColors.primaryBlue).withOpacity(0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
