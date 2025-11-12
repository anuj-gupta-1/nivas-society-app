import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a reply to a thread
/// 
/// Replies can be nested (reply to a reply)
class Reply {
  final String replyId;
  final String threadId;
  final String content;
  final String authorId;
  final String authorName;
  final String? parentReplyId; // For nested replies
  final List<String> mentionedUserIds;
  final List<ReplyAttachment> attachments;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Reply({
    required this.replyId,
    required this.threadId,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.parentReplyId,
    required this.mentionedUserIds,
    required this.attachments,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from Firestore document
  factory Reply.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reply(
      replyId: doc.id,
      threadId: data['thread_id'] as String,
      content: data['content'] as String,
      authorId: data['author_id'] as String,
      authorName: data['author_name'] as String,
      parentReplyId: data['parent_reply_id'] as String?,
      mentionedUserIds: List<String>.from(data['mentioned_user_ids'] as List? ?? []),
      attachments: (data['attachments'] as List?)
              ?.map((e) => ReplyAttachment.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'thread_id': threadId,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'parent_reply_id': parentReplyId,
      'mentioned_user_ids': mentionedUserIds,
      'attachments': attachments.map((e) => e.toMap()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Check if this is a nested reply
  bool get isNested => parentReplyId != null;

  /// Copy with updated fields
  Reply copyWith({
    String? content,
    List<String>? mentionedUserIds,
    List<ReplyAttachment>? attachments,
    DateTime? updatedAt,
  }) {
    return Reply(
      replyId: replyId,
      threadId: threadId,
      content: content ?? this.content,
      authorId: authorId,
      authorName: authorName,
      parentReplyId: parentReplyId,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Represents an attachment in a reply
class ReplyAttachment {
  final String url;
  final String fileName;
  final String fileType; // image, video, document
  final int fileSize;

  const ReplyAttachment({
    required this.url,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
  });

  factory ReplyAttachment.fromMap(Map<String, dynamic> map) {
    return ReplyAttachment(
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
