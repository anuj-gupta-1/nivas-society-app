import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Service for handling Firebase Storage operations
/// 
/// Manages file uploads and downloads
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload verification document
  /// 
  /// Returns the download URL of the uploaded file
  Future<String> uploadVerificationDocument({
    required String userId,
    required File file,
    required Function(double progress) onProgress,
  }) async {
    try {
      // Generate unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = 'verification_${userId}_$timestamp$extension';
      
      // Create reference to storage location
      final ref = _storage.ref().child('verification_documents/$fileName');
      
      // Upload file with progress tracking
      final uploadTask = ref.putFile(file);
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
      
      // Wait for upload to complete
      await uploadTask;
      
      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Upload profile photo
  /// 
  /// Returns the download URL of the uploaded photo
  Future<String> uploadProfilePhoto({
    required String userId,
    required File file,
    required Function(double progress) onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = 'profile_${userId}_$timestamp$extension';
      
      final ref = _storage.ref().child('profile_photos/$fileName');
      
      final uploadTask = ref.putFile(file);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
      
      await uploadTask;
      
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  /// Upload thread attachment (image, video, document)
  /// 
  /// Returns the download URL of the uploaded file
  Future<String> uploadThreadAttachment({
    required String projectId,
    required String threadId,
    required File file,
    required Function(double progress) onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = 'attachment_${threadId}_$timestamp$extension';
      
      final ref = _storage.ref().child('projects/$projectId/attachments/$fileName');
      
      final uploadTask = ref.putFile(file);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
      
      await uploadTask;
      
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload attachment: $e');
    }
  }

  /// Delete file from storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }
}
