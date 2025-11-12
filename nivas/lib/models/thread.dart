import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a discussion thread
/// 
/// Threads are the main discussion units within spaces
class Thread {
  final String threadId;
  final String spaceId;
  final String groupId;
  final String projectId;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final List<String> tagIds;
  final List<String> mentionedUserIds;
  final List<ThreadAttachment> attachments;
  final bool isPinned;
  final int replyCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActivityAt;

  const Thread({
    required this.threadId,
    required this.spaceId,
    required this.groupId,
    required this.projectId,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.tagIds,
    required this.mentionedUserIds,
    required this.attachments,
    required this.isPinned,
    required this.replyCount,
    required this.createdAt,
    this.updatedAt,
    this.lastActivityAt,
  });

  /// Create from Firestore document
  factory Thread.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Thread(
      threadId: doc.id,
      spaceId: data['space_id'] as String,
      groupId: data['group_id'] as String,
      projectId: data['project_id'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      authorId: data['author_id'] as String,
      authorName: data['author_name'] as String,
      tagIds: List<String>.from(data['tag_ids'] as List? ?? []),
      mentionedUserIds: List<String>.from(data['mentioned_user_ids'] as List? ?? []),
      attachments: (data['attachments'] as List?)
              ?.map((e) => ThreadAttachment.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      isPinned: data['is_pinned'] as bool? ?? false,
      replyCount: data['reply_count'] as int? ?? 0,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
      lastActivityAt: data['last_activity_at'] != null
          ? (data['last_activity_at'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'space_id': spaceId,
      'group_id': groupId,
      'project_id': projectId,
      'title': title,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'tag_ids': tagIds,
      'mentioned_user_ids': mentionedUserIds,
      'attachments': attachments.map((e) => e.toMap()).toList(),
      'is_pinned': isPinned,
      'reply_count': replyCount,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'last_activity_at': lastActivityAt != null
          ? Timestamp.fromDate(lastActivityAt!)
          : null,
    };
  }

  /// Get content preview (first 100 characters)
  String get contentPreview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  /// Copy with updated fields
  Thread copyWith({
    String? title,
    String? content,
    List<String>? tagIds,
    List<String>? mentionedUserIds,
    List<ThreadAttachment>? attachments,
    bool? isPinned,
    int? replyCount,
    DateTime? updatedAt,
    DateTime? lastActivityAt,
  }) {
    return Thread(
      threadId: threadId,
      spaceId: spaceId,
      groupId: groupId,
      projectId: projectId,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId,
      authorName: authorName,
      tagIds: tagIds ?? this.tagIds,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
      attachments: attachments ?? this.attachments,
      isPinned: isPinned ?? this.isPinned,
      replyCount: replyCount ?? this.replyCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}

/// Represents an attachment in a thread
class ThreadAttachment {
  final String url;
  final String fileName;
  final String fileType; // image, video, document
  final int fileSize;

  const ThreadAttachment({
    required this.url,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
  });

  factory ThreadAttachment.fromMap(Map<String, dynamic> map) {
    return ThreadAttachment(
      url: map['url'] as String,
      fileName: map['file_name'] as String,
      fileType: map['file_type'] as String,
      fileSize: map['file_size'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
    };
  }
}
