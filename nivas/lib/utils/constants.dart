/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Nivas';
  static const String appTagline = 'Society Management Made Simple';
  
  // File Upload Limits
  static const int maxVerificationDocSize = 2; // MB
  static const int maxImageSize = 10; // MB
  static const int maxVideoSize = 50; // MB
  static const int maxDocumentSize = 25; // MB
  
  // Allowed File Extensions
  static const List<String> verificationDocExtensions = ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'];
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> videoExtensions = ['mp4', 'mov'];
  static const List<String> documentExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];
  
  // Pagination
  static const int threadsPerPage = 20;
  static const int repliesPerPage = 50;
  static const int documentsPerPage = 30;
  
  // Cache Duration
  static const Duration userCacheDuration = Duration(hours: 24);
  static const Duration projectCacheDuration = Duration(hours: 24);
  static const Duration threadCacheDuration = Duration(hours: 1);
  static const Duration documentCacheDuration = Duration(hours: 6);
  
  // Notification Settings
  static const Duration notificationDebounce = Duration(seconds: 5);
  
  // Phone Number
  static const String defaultCountryCode = '+91';
  static const String countryCodeDisplay = '+91';
  
  // Firestore Collection Names
  static const String usersCollection = 'users';
  static const String projectsCollection = 'projects';
  static const String projectMembershipsCollection = 'project_memberships';
  static const String groupsCollection = 'groups';
  static const String spacesCollection = 'spaces';
  static const String threadsCollection = 'threads';
  static const String repliesSubcollection = 'replies';
  static const String documentsCollection = 'documents';
  static const String tagsCollection = 'tags';
  static const String notificationsCollection = 'notifications';
  static const String groupAccessRequestsCollection = 'group_access_requests';
  
  // Storage Paths
  static const String verificationDocsPath = 'verification_docs';
  static const String profilePhotosPath = 'profile_photos';
  static const String documentsPath = 'documents';
  static const String imagesPath = 'images';
  static const String videosPath = 'videos';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String authError = 'Authentication error. Please login again.';
  static const String permissionError = 'You don\'t have permission to perform this action.';
  static const String notFoundError = 'Resource not found.';
  
  // Success Messages
  static const String verificationSubmitted = 'Verification submitted successfully. Please wait for admin approval.';
  static const String threadCreated = 'Thread created successfully.';
  static const String replyPosted = 'Reply posted successfully.';
  static const String documentUploaded = 'Document uploaded successfully.';
  
  // Validation Messages
  static const String phoneRequired = 'Phone number is required';
  static const String nameRequired = 'Name is required';
  static const String unitRequired = 'Unit number is required';
  static const String blockRequired = 'Block is required';
  static const String phaseRequired = 'Phase is required';
  static const String documentRequired = 'Verification document is required';
}

/// App Colors (will be used in theme)
class AppColors {
  // Primary Colors
  static const int primaryBlue = 0xFF2196F3;
  static const int primaryDark = 0xFF1976D2;
  static const int primaryLight = 0xFFBBDEFB;
  
  // Accent Colors
  static const int accentOrange = 0xFFFF9800;
  
  // Neutral Colors
  static const int background = 0xFFF5F5F5;
  static const int surface = 0xFFFFFFFF;
  static const int textPrimary = 0xFF212121;
  static const int textSecondary = 0xFF757575;
  
  // Status Colors
  static const int success = 0xFF4CAF50;
  static const int error = 0xFFF44336;
  static const int warning = 0xFFFFC107;
  static const int info = 0xFF2196F3;
  
  // Special Colors
  static const int mention = 0xFF1976D2;
  static const int pinned = 0xFFFFF9C4;
}

/// App Text Sizes
class AppTextSizes {
  static const double heading1 = 24.0;
  static const double heading2 = 20.0;
  static const double heading3 = 18.0;
  static const double body = 16.0;
  static const double caption = 14.0;
  static const double small = 12.0;
}

/// App Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
