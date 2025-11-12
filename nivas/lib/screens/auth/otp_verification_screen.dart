import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/providers/auth_provider.dart';
import 'package:nivas/screens/auth/profile_setup_screen.dart';
import 'package:nivas/utils/constants.dart';

/// OTP verification screen
/// 
/// Verifies the OTP sent to user's phone number
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      ref.read(errorProvider.notifier).setError('Please enter complete OTP');
      return;
    }

    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final authService = ref.read(authServiceProvider);
      
      // Verify OTP
      final userCredential = await authService.verifyOTP(
        verificationId: widget.verificationId,
        otp: _otp,
      );

      final userId = userCredential.user?.uid;
      if (userId == null) {
        throw Exception('Failed to get user ID');
      }

      // Check if user already exists
      final userExists = await authService.userExists(userId);

      ref.read(loadingProvider.notifier).setLoading(false);

      if (!mounted) return;

      if (userExists) {
        // User exists, navigate to home (will be implemented later)
        ref.read(successProvider.notifier).setSuccess('Welcome back!');
        // TODO: Navigate to home screen
      } else {
        // New user, navigate to profile setup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileSetupScreen(
              phoneNumber: widget.phoneNumber,
              userId: userId,
            ),
          ),
        );
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).setLoading(false);
      ref.read(errorProvider.notifier).setError('Invalid OTP. Please try again.');
    }
  }

  Future<void> _resendOtp() async {
    ref.read(loadingProvider.notifier).setLoading(true);

    try {
      final authService = ref.read(authServiceProvider);
      
      await authService.sendOTP(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (verificationId) {
          ref.read(loadingProvider.notifier).setLoading(false);
          ref.read(successProvider.notifier).setSuccess('OTP sent successfully!');
          
          // Update verification ID
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: widget.phoneNumber,
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
      ref.read(errorProvider.notifier).setError('Failed to resend OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(AppColors.textPrimary)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Verify OTP',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Enter the 6-digit code sent to',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(AppColors.textSecondary),
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                widget.phoneNumber,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Color(AppColors.primaryBlue),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          // Move to next field
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            // Last field, hide keyboard
                            _focusNodes[index].unfocus();
                            // Auto-verify when all digits entered
                            _verifyOtp();
                          }
                        } else {
                          // Move to previous field on backspace
                          if (index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        }
                      },
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
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
                        'Verify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(
                      color: Color(AppColors.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : _resendOtp,
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        color: Color(AppColors.primaryBlue),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Info Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(AppColors.primaryBlue).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(AppColors.primaryBlue),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The OTP is valid for 60 seconds',
                        style: TextStyle(
                          color: Color(AppColors.textSecondary),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
