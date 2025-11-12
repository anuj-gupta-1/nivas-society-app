import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivas/models/space.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/project_provider.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/utils/constants.dart';

/// Create space screen (Group Admin only)
/// 
/// Allows group admins to create new dedicated spaces
class CreateSpaceScreen extends ConsumerStatefulWidget {
  final String groupId;

  const CreateSpaceScreen({
    super.key,
    required this.groupId,
  });

  @override
  ConsumerState<CreateSpaceScreen> createState() => _CreateSpaceScreenState();
}

class _CreateSpaceScreenState extends ConsumerState<CreateSpaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createSpace() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final userId = ref.read(currentUserIdProvider);
      final projectId = ref.read(currentProjectIdProvider);
      
      if (userId == null || projectId == null) {
        throw Exception('User or project not found');
      }

      final firestore = ref.read(firestoreProvider);
      
      // Create space
      final spaceRef = firestore.collection(AppConstants.spacesCollection).doc();
      final spaceId = spaceRef.id;
      
      final space = Space(
        spaceId: spaceId,
        groupId: widget.groupId,
        projectId: projectId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: SpaceType.dedicated,
        createdBy: userId,
        createdAt: DateTime.now(),
        threadCount: 0,
      );

      await spaceRef.set(space.toFirestore());

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Space created successfully!');

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed to create space: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Space'),
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
                        'Spaces help organize threads by specific topics or purposes',
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
            
            // Space Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Space Name *',
                hintText: 'e.g., Maintenance Issues',
                prefixIcon: const Icon(Icons.space_dashboard),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a space name';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'What is this space for?',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value != null && value.trim().length > 500) {
                  return 'Description must be less than 500 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Space Type Info
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
                  Row(
                    children: [
                      Icon(
                        Icons.space_dashboard,
                        color: Color(AppColors.primaryBlue),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dedicated Space',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(AppColors.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will be a dedicated space for focused discussions on a specific topic.',
                    style: TextStyle(
                      color: Color(AppColors.textSecondary),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Create Button
            ElevatedButton(
              onPressed: isLoading ? null : _createSpace,
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
                      'Create Space',
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
