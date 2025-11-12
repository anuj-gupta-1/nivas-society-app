import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/screens/auth/document_upload_screen.dart';
import 'package:nivas/utils/validators.dart';
import 'package:nivas/utils/constants.dart';

/// Profile setup screen
/// 
/// Second step: User enters name, unit, block, phase
class ProfileSetupScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String userId;

  const ProfileSetupScreen({
    super.key,
    required this.phoneNumber,
    required this.userId,
  });

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _emailController = TextEditingController();
  
  String? _selectedBlock;
  String? _selectedPhase;
  
  // TODO: These should come from project data
  final List<String> _blocks = ['Block A', 'Block B', 'Block C', 'Block D', 'Block E'];
  final List<String> _phases = ['Phase 1', 'Phase 2'];

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBlock == null || _selectedPhase == null) {
      ref.read(errorProvider.notifier).setError('Please select block and phase');
      return;
    }

    // Navigate to document upload
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentUploadScreen(
          userId: widget.userId,
          phoneNumber: widget.phoneNumber,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          unitNumber: _unitController.text.trim(),
          block: _selectedBlock!,
          phase: _selectedPhase!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Tell us about yourself',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'This information will be used for verification',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Color(AppColors.textSecondary),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Phone Number (Read-only)
                TextFormField(
                  initialValue: widget.phoneNumber,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Full Name
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'Rahul Kumar',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    return Validators.getDisplayNameErrorMessage(value ?? '');
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Email (Optional)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email (Optional)',
                    hintText: 'rahul@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    return Validators.getEmailErrorMessage(value ?? '');
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Unit Number
                TextFormField(
                  controller: _unitController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Unit Number *',
                    hintText: 'A-1201',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.unitRequired;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Block Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedBlock,
                  decoration: InputDecoration(
                    labelText: 'Block *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: _blocks.map((block) {
                    return DropdownMenuItem(
                      value: block,
                      child: Text(block),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBlock = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return AppConstants.blockRequired;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Phase Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedPhase,
                  decoration: InputDecoration(
                    labelText: 'Phase *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: _phases.map((phase) {
                    return DropdownMenuItem(
                      value: phase,
                      child: Text(phase),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPhase = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return AppConstants.phaseRequired;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Continue Button
                ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.primaryBlue),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
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
      ),
    );
  }
}
