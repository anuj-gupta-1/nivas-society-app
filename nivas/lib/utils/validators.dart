/// Validation utilities for user input
class Validators {
  /// Validate Indian phone number
  /// 
  /// Format: +91-XXXXXXXXXX
  /// Rules:
  /// - Must start with +91
  /// - Must have exactly 10 digits after country code
  /// - First digit must be 6, 7, 8, or 9
  /// 
  /// Examples:
  /// - Valid: +91-9876543210
  /// - Invalid: +91-5876543210 (starts with 5)
  /// - Invalid: +91-987654321 (only 9 digits)
  static bool validateIndianPhone(String phone) {
    // Remove any spaces
    phone = phone.replaceAll(' ', '');
    
    // Check format: +91-XXXXXXXXXX
    final regex = RegExp(r'^\+91-[6-9]\d{9}$');
    return regex.hasMatch(phone);
  }

  /// Format phone number to standard format
  /// 
  /// Input: "9876543210" or "+919876543210" or "+91-9876543210"
  /// Output: "+91-9876543210"
  static String formatIndianPhone(String phone) {
    // Remove all non-digit characters except +
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If starts with +91, format it
    if (phone.startsWith('+91')) {
      final number = phone.substring(3);
      return '+91-$number';
    }
    
    // If starts with 91, add +
    if (phone.startsWith('91') && phone.length == 12) {
      final number = phone.substring(2);
      return '+91-$number';
    }
    
    // If just 10 digits, add +91-
    if (phone.length == 10) {
      return '+91-$phone';
    }
    
    return phone; // Return as-is if can't format
  }

  /// Validate email address
  static bool validateEmail(String email) {
    if (email.isEmpty) return true; // Email is optional
    
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  /// Validate unit number format
  /// 
  /// Expected format: "A-1201" or "B-0504"
  /// - Block letter(s) followed by hyphen and flat number
  static bool validateUnitNumber(String unitNumber) {
    if (unitNumber.isEmpty) return false;
    
    final regex = RegExp(r'^[A-Z]+-\d{4}$');
    return regex.hasMatch(unitNumber);
  }

  /// Validate display name
  /// 
  /// Rules:
  /// - Not empty
  /// - At least 2 characters
  /// - Only letters, spaces, and common punctuation
  static bool validateDisplayName(String name) {
    if (name.trim().isEmpty) return false;
    if (name.trim().length < 2) return false;
    
    final regex = RegExp(r"^[a-zA-Z\s.'-]+$");
    return regex.hasMatch(name.trim());
  }

  /// Validate file size (in bytes)
  /// 
  /// maxSizeInMB: Maximum allowed size in megabytes
  static bool validateFileSize(int fileSizeInBytes, int maxSizeInMB) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }

  /// Validate file extension
  /// 
  /// allowedExtensions: List of allowed extensions (e.g., ['jpg', 'png', 'pdf'])
  static bool validateFileExtension(String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Get error message for phone validation
  static String? getPhoneErrorMessage(String phone) {
    if (phone.isEmpty) {
      return 'Phone number is required';
    }
    
    if (!phone.startsWith('+91')) {
      return 'Phone number must start with +91';
    }
    
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length != 12) {
      return 'Phone number must have 10 digits after +91';
    }
    
    final firstDigit = digits[2]; // After '91'
    if (!['6', '7', '8', '9'].contains(firstDigit)) {
      return 'Phone number must start with 6, 7, 8, or 9';
    }
    
    return null; // Valid
  }

  /// Get error message for email validation
  static String? getEmailErrorMessage(String email) {
    if (email.isEmpty) return null; // Email is optional
    
    if (!validateEmail(email)) {
      return 'Please enter a valid email address';
    }
    
    return null; // Valid
  }

  /// Get error message for display name validation
  static String? getDisplayNameErrorMessage(String name) {
    if (name.trim().isEmpty) {
      return 'Name is required';
    }
    
    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (!validateDisplayName(name)) {
      return 'Name can only contain letters, spaces, and basic punctuation';
    }
    
    return null; // Valid
  }
}
