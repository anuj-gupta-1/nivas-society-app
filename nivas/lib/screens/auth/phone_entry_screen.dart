import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/providers/auth_provider.dart';
import 'package:nivas/screens/auth/otp_verification_screen.dart';
import 'package:nivas/utils/validators.dart';
import 'package:nivas/utils/constants.dart';

/// Phone number entry screen
/// 
/// First step in registration process
class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  String _phoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Format phone number
    final formattedPhone = Validators.formatIndianPhone(_phoneNumber);
    
    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final authService = ref.read(authServiceProvider);
      
      // Send OTP
      await authService.sendOTP(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId) {
          ref.read(loadingProvider.notifier).setLoading(false);
          
          if (!mounted) return;
          
          // Navigate to OTP verification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: formattedPhone,
                verificationId: verificationId,
              ),
            ),
          );
        },
        onError: (error) {
          ref.read(loadingProvider.notifier).setLoading(false);
          ref.read(errorProvider.notifier).setError(error);
        },
      );
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Failed to send OTP. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // App Logo/Name
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.primaryBlue),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  AppConstants.appTagline,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Color(AppColors.textSecondary),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 60),
                
                // Title
                Text(
                  'Welcome!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Enter your phone number to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Color(AppColors.textSecondary),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Phone Number Input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '9876543210',
                    prefixText: '+91-',
                    prefixStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLength: 10,
                  onChanged: (value) {
                    setState(() {
                      _phoneNumber = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.phoneRequired;
                    }
                    
                    final fullPhone = '+91-$value';
                    final error = Validators.getPhoneErrorMessage(fullPhone);
                    return error;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Continue Button
                ElevatedButton(
                  onPressed: isLoading ? null : _onContinue,
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
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                
                const Spacer(),
                
                // Info Text
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Color(AppColors.textSecondary),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
