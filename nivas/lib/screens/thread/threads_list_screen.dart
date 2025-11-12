import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/models/thread.dart';
import 'package:nivas/models/space.dart';
import 'package:nivas/providers/thread_provider.dart';
import 'package:nivas/providers/group_provider.dart';
import 'package:nivas/screens/thread/create_thread_screen.dart';
import 'package:nivas/screens/thread/thread_detail_screen.dart';
import 'package:nivas/utils/constants.dart';

/// Threads list screen within a space
/// 
/// Shows all threads with pinned threads at top
class ThreadsListScreen extends ConsumerWidget {
  final String spaceId;

  const ThreadsListScreen({
    super.key,
    required this.spaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaceAsync = ref.watch(spaceProvider(spaceId));
    final threadsAsync = ref.watch(spaceThreadsProvider(spaceId));

    return Scaffold(
      appBar: AppBar(
        title: spaceAsync.when(
          data: (space) => Text(space?.name ?? 'Threads'),
          loading: () => const Text('Threads'),
          error: (_, __) => const Text('Threads'),
        ),
        backgroundColor: Color(AppColors.primaryBlue),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(spaceThreadsProvider(spaceId));
        },
        child: threadsAsync.when(
          data: (threads) {
            if (threads.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: threads.length,
              itemBuilder: (context, index) {
                return _buildThreadCard(context, ref, threads[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading threads',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateThreadScreen(spaceId: spaceId),
            ),
          );

          if (result == true) {
            ref.invalidate(spaceThreadsProvider(spaceId));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Thread'),
        backgroundColor: Color(AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Threads Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start a discussion by creating the first thread',
              style: TextStyle(
                color: Color(AppColors.textSecondary),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadCard(BuildContext context, WidgetRef ref, Thread thread) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ThreadDetailScreen(threadId: thread.threadId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(AppColors.primaryBlue).withOpacity(0.1),
                    radius: 16,
                    child: Text(
                      thread.authorName[0].toUpperCase(),
                      style: TextStyle(
                        color: Color(AppColors.primaryBlue),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          thread.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(thread.createdAt),
                          style: TextStyle(
                            color: Color(AppColors.textSecondary),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (thread.isPinned)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(AppColors.warning).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.push_pin,
                            size: 12,
                            color: Color(AppColors.warning),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pinned',
                            style: TextStyle(
                              color: Color(AppColors.warning),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                thread.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Content Preview
              Text(
                thread.contentPreview,
                style: TextStyle(
                  color: Color(AppColors.textSecondary),
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Attachments Indicator
              if (thread.attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 14,
                      color: Color(AppColors.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${thread.attachments.length} attachment${thread.attachments.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Color(AppColors.textSecondary),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Footer Row
              Row(
                children: [
                  _buildStatChip(
                    Icons.comment,
                    '${thread.replyCount}',
                  ),
                  const SizedBox(width: 16),
                  if (thread.lastActivityAt != null)
                    _buildStatChip(
                      Icons.access_time,
                      'Active ${_formatTimeAgo(thread.lastActivityAt!)}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Color(AppColors.textSecondary)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Color(AppColors.textSecondary),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
