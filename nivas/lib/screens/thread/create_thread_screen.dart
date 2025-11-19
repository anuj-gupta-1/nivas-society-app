import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivas/models/thread.dart';
import 'package:nivas/models/space.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/project_provider.dart';
import 'package:nivas/providers/group_provider.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/utils/constants.dart';

/// Create thread screen
/// 
/// Allows users to create new discussion threads
class CreateThreadScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const CreateThreadScreen({
    super.key,
    required this.spaceId,
  });

  @override
  ConsumerState<CreateThreadScreen> createState() => _CreateThreadScreenState();
}

class _CreateThreadScreenState extends ConsumerState<CreateThreadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createThread() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final authState = await ref.read(authStateProvider.future);
      final userId = authState?.uid;
      final projectId = ref.read(currentProjectIdProvider);
      
      if (userId == null || projectId == null) {
        throw Exception('User or project not found');
      }

      // Get user's membership to get display name
      final membership = await ref.read(projectMembershipProvider(projectId).future);
      if (membership == null) {
        throw Exception('User membership not found');
      }

      // Get space details
      final spaceAsync = await ref.read(spaceProvider(widget.spaceId).future);
      if (spaceAsync == null) {
        throw Exception('Space not found');
      }

      final firestore = ref.read(firestoreProvider);
      
      // Create thread
      final threadRef = firestore.collection(AppConstants.threadsCollection).doc();
      final threadId = threadRef.id;
      
      final thread = Thread(
        threadId: threadId,
        spaceId: widget.spaceId,
        groupId: spaceAsync.groupId,
        projectId: projectId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: userId,
        authorName: membership.displayName,
        tagIds: [], // TODO: Implement tag selection
        mentionedUserIds: _extractMentions(_contentController.text),
        attachments: [], // TODO: Implement attachments
        isPinned: false,
        replyCount: 0,
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );

      await threadRef.set(thread.toFirestore());

      // Update space thread count
      await firestore
          .collection(AppConstants.spacesCollection)
          .doc(widget.spaceId)
          .update({
        'thread_count': FieldValue.increment(1),
        'last_activity_at': FieldValue.serverTimestamp(),
      });

      // Update group last activity
      await firestore
          .collection(AppConstants.groupsCollection)
          .doc(spaceAsync.groupId)
          .update({
        'last_activity_at': FieldValue.serverTimestamp(),
      });

      // TODO: Send notifications to mentioned users

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Thread created successfully!');

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed to create thread: $e');
    }
  }

  List<String> _extractMentions(String content) {
    // Simple mention extraction - looks for @username patterns
    // TODO: Implement proper mention detection with user lookup
    final mentionPattern = RegExp(r'@(\w+)');
    final matches = mentionPattern.allMatches(content);
    return matches.map((m) => m.group(1)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Thread'),
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Card
            Card(
              color: Color(AppColors.primaryBlue).withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(AppColors.primaryBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Start a discussion that others can reply to',
                        style: TextStyle(
                          color: Color(AppColors.textSecondary),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Thread Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: 'What is this thread about?',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                if (value.trim().length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Thread Content
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content *',
                hintText: 'Share your thoughts...\n\nTip: Use @username to mention someone',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 100),
                  child: Icon(Icons.description),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter content';
                }
                if (value.trim().length < 10) {
                  return 'Content must be at least 10 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // TODO: Add rich text formatting toolbar
            // TODO: Add tag selector
            // TODO: Add attachment options
            
            // Placeholder for future features
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Rich text formatting (bold, italic, links)\n'
                    '• Tag selection\n'
                    '• Media attachments\n'
                    '• User mention autocomplete',
                    style: TextStyle(
                      color: Color(AppColors.textSecondary),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Create Button
            ElevatedButton(
              onPressed: isLoading ? null : _createThread,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.primaryBlue),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Post Thread',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
