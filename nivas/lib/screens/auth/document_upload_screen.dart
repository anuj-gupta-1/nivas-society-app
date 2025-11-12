import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/providers/auth_provider.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/services/storage_service.dart';
import 'package:nivas/models/user.dart';
import 'package:nivas/models/project_membership.dart';
import 'package:nivas/screens/auth/verification_pending_screen.dart';
import 'package:nivas/utils/validators.dart';
import 'package:nivas/utils/constants.dart';

/// Document upload screen
/// 
/// Third step: User uploads verification document (demand letter)
class DocumentUploadScreen extends ConsumerStatefulWidget {
  final String userId;
  final String phoneNumber;
  final String name;
  final String email;
  final String unitNumber;
  final String block;
  final String phase;

  const DocumentUploadScreen({
    super.key,
    required this.userId,
    required this.phoneNumber,
    required this.name,
    required this.email,
    required this.unitNumber,
    required this.block,
    required this.phase,
  });

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  File? _selectedFile;
  String? _fileName;
  int? _fileSize;
  double _uploadProgress = 0.0;
  
  final StorageService _storageService = StorageService();
  
  // TODO: This should come from project selection
  // For now, using a default project ID
  static const String _defaultProjectId = 'default_project';

  Future<void> _showPickerOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(AppColors.primaryBlue)),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(AppColors.primaryBlue)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file, color: Color(AppColors.primaryBlue)),
                title: const Text('Choose Document'),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocument();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _handleSelectedFile(File(result.files.single.path!), result.files.single.name);
      }
    } catch (e) {
      ref.read(errorProvider.notifier).setError('Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _handleSelectedFile(File(result.files.single.path!), result.files.single.name);
      }
    } catch (e) {
      ref.read(errorProvider.notifier).setError('Failed to pick image: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.verificationDocExtensions,
      );

      if (result != null && result.files.single.path != null) {
        await _handleSelectedFile(File(result.files.single.path!), result.files.single.name);
      }
    } catch (e) {
      ref.read(errorProvider.notifier).setError('Failed to pick file: $e');
    }
  }

  Future<void> _handleSelectedFile(File file, String fileName) async {
    final fileSize = await file.length();

    // Validate file size
    if (!Validators.validateFileSize(
      fileSize,
      AppConstants.maxVerificationDocSize,
    )) {
      ref.read(errorProvider.notifier).setError(
        'File size must be less than ${AppConstants.maxVerificationDocSize}MB',
      );
      return;
    }

    setState(() {
      _selectedFile = file;
      _fileName = fileName;
      _fileSize = fileSize;
    });
  }

  Future<void> _submitRegistration() async {
    if (_selectedFile == null) {
      ref.read(errorProvider.notifier).setError(AppConstants.documentRequired);
      return;
    }

    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final firestore = ref.read(firestoreProvider);
      final authService = ref.read(authServiceProvider);
      
      // Step 1: Upload document to Firebase Storage
      final documentUrl = await _storageService.uploadVerificationDocument(
        userId: widget.userId,
        file: _selectedFile!,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      // Step 2: Create user in Firestore
      final user = User(
        userId: widget.userId,
        phoneNumber: widget.phoneNumber,
        displayName: widget.name,
        email: widget.email.isNotEmpty ? widget.email : null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(widget.userId)
          .set(user.toFirestore());

      // Step 3: Create project membership with pending status
      final membershipId = '${widget.userId}_$_defaultProjectId';
      
      final membership = ProjectMembership(
        membershipId: membershipId,
        userId: widget.userId,
        projectId: _defaultProjectId,
        displayName: widget.name,
        role: UserRole.owner,
        verificationStatus: VerificationStatus.pending,
        verificationDocUrl: documentUrl,
        unitOwnerships: [
          UnitOwnership(
            unitId: '${_defaultProjectId}_${widget.unitNumber}',
            unitNumber: widget.unitNumber,
            block: widget.block,
            phase: widget.phase,
            ownershipType: OwnershipType.primary,
          ),
        ],
        createdAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.projectMembershipsCollection)
          .doc(membershipId)
          .set(membership.toFirestore());

      // Step 4: Update last login
      await authService.updateLastLogin();

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Registration submitted successfully!');

      // Navigate to verification pending
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const VerificationPendingScreen(),
          ),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Registration failed: $e');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Verification Document',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Upload your demand letter or allotment letter for verification',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(AppColors.textSecondary),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Upload Area
              InkWell(
                onTap: isLoading ? null : _showPickerOptions,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedFile != null
                          ? Color(AppColors.success)
                          : Colors.grey[300]!,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedFile != null
                        ? Color(AppColors.success).withOpacity(0.05)
                        : Colors.grey[50],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFile != null
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        size: 64,
                        color: _selectedFile != null
                            ? Color(AppColors.success)
                            : Colors.grey[400],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      if (_selectedFile != null) ...[
                        Text(
                          _fileName ?? 'Document selected',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatFileSize(_fileSize ?? 0),
                          style: TextStyle(
                            color: Color(AppColors.textSecondary),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _showPickerOptions,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Change Document'),
                        ),
                      ] else ...[
                        const Text(
                          'Tap to upload document',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Supported: PDF, JPG, PNG, DOC\nMax size: ${AppConstants.maxVerificationDocSize}MB',
                          style: TextStyle(
                            color: Color(AppColors.textSecondary),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Upload Progress
              if (isLoading && _uploadProgress > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(AppColors.primaryBlue).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Uploading document...',
                            style: TextStyle(
                              color: Color(AppColors.textSecondary),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Color(AppColors.primaryBlue),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(AppColors.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _submitRegistration,
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
                        'Submit for Verification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
