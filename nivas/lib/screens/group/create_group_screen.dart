import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivas/models/group.dart';
import 'package:nivas/models/space.dart';
import 'package:nivas/providers/auth_provider.dart';
import 'package:nivas/providers/user_provider.dart';
import 'package:nivas/providers/project_provider.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/utils/constants.dart';

/// Create group screen (Super Admin only)
/// 
/// Allows super admins to create new groups
class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  GroupType _selectedType = GroupType.private;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
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
      
      // Create group
      final groupRef = firestore.collection(AppConstants.groupsCollection).doc();
      final groupId = groupRef.id;
      
      final group = Group(
        groupId: groupId,
        projectId: projectId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        memberIds: [userId], // Creator is first member
        adminIds: [userId], // Creator is admin
        createdBy: userId,
        createdAt: DateTime.now(),
        memberCount: 1,
      );

      await groupRef.set(group.toFirestore());

      // Create default General Space
      final spaceRef = firestore.collection(AppConstants.spacesCollection).doc();
      final spaceId = spaceRef.id;
      
      final generalSpace = Space(
        spaceId: spaceId,
        groupId: groupId,
        projectId: projectId,
        name: 'General',
        description: 'General discussion space',
        type: SpaceType.general,
        createdBy: userId,
        createdAt: DateTime.now(),
        threadCount: 0,
      );

      await spaceRef.set(generalSpace.toFirestore());

      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(successProvider.notifier).setSuccess('Group created successfully!');

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed to create group: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
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
                        'Groups help organize discussions by topic or community',
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
            
            // Group Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Group Name *',
                hintText: 'e.g., Maintenance Committee',
                prefixIcon: const Icon(Icons.group),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a group name';
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
                hintText: 'What is this group about?',
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
            
            // Group Type Section
            Text(
              'Group Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // General Type Option
            _buildTypeOption(
              type: GroupType.general,
              title: 'General Group',
              description: 'All verified users can access this group',
              icon: Icons.public,
              color: Color(AppColors.success),
            ),
            
            const SizedBox(height: 12),
            
            // Private Type Option
            _buildTypeOption(
              type: GroupType.private,
              title: 'Private Group',
              description: 'Users must request access to join',
              icon: Icons.lock,
              color: Color(AppColors.primaryBlue),
            ),
            
            const SizedBox(height: 32),
            
            // Create Button
            ElevatedButton(
              onPressed: isLoading ? null : _createGroup,
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
                      'Create Group',
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

  Widget _buildTypeOption({
    required GroupType type,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isSelected ? color : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Color(AppColors.textSecondary),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}
