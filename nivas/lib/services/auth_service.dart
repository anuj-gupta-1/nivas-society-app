import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nivas/models/user.dart';
import 'package:nivas/services/hive_service.dart';
import 'package:nivas/utils/constants.dart';

/// Service for handling user authentication
/// 
/// Manages:
/// - Phone authentication with Firebase
/// - User session management
/// - FCM token registration
/// - Login/logout flows
class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Get current Firebase user
  firebase_auth.User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Stream of authentication state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Send OTP to phone number
  /// 
  /// Returns verification ID that will be used to verify OTP
  Future<String> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    String? verificationId;

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (firebase_auth.FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
        onCodeSent(verId);
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );

    return verificationId ?? '';
  }

  /// Verify OTP code
  /// 
  /// Signs in user if OTP is correct
  Future<firebase_auth.UserCredential> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    final credential = firebase_auth.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    
    // Register FCM token after successful login
    await _registerFCMToken();
    
    return userCredential;
  }

  /// Sign in with phone credential (for auto-verification)
  Future<firebase_auth.UserCredential> signInWithCredential(
    firebase_auth.PhoneAuthCredential credential,
  ) async {
    final userCredential = await _auth.signInWithCredential(credential);
    
    // Register FCM token after successful login
    await _registerFCMToken();
    
    return userCredential;
  }

  /// Register FCM token for push notifications
  Future<void> _registerFCMToken() async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      // Request notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        final token = await _messaging.getToken();
        
        if (token != null) {
          // Store token in Firestore
          await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
            'fcm_token': token,
            'fcm_token_updated_at': FieldValue.serverTimestamp(),
          });
        }
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _firestore.collection(AppConstants.usersCollection).doc(userId).update({
          'fcm_token': newToken,
          'fcm_token_updated_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Failed to register FCM token: $e');
    }
  }

  /// Create new user in Firestore after authentication
  /// 
  /// This is called after phone verification during registration
  Future<void> createUser({
    required String userId,
    required String phoneNumber,
    required String displayName,
  }) async {
    final user = User(
      userId: userId,
      phoneNumber: phoneNumber,
      displayName: displayName,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .set(user.toFirestore());

    // Cache user data locally
    await UserCache.saveUser(user.toFirestore());
  }

  /// Update user's last login timestamp
  Future<void> updateLastLogin() async {
    final userId = currentUserId;
    if (userId == null) return;

    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'last_login_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get user data from Firestore
  Future<User?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      return User.fromFirestore(doc);
    } catch (e) {
      print('Failed to get user data: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    
    if (displayName != null) {
      updates['display_name'] = displayName;
    }
    
    if (photoUrl != null) {
      updates['photo_url'] = photoUrl;
    }

    if (updates.isNotEmpty) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    // Clear FCM token
    final userId = currentUserId;
    if (userId != null) {
      await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
        'fcm_token': null,
      });
    }

    // Sign out from Firebase
    await _auth.signOut();

    // Clear local cache
    await HiveService.clearAll();
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    final userId = currentUserId;
    if (userId == null) return;

    // Delete user data from Firestore
    await _firestore.collection(AppConstants.usersCollection).doc(userId).delete();

    // Delete all user's project memberships
    final memberships = await _firestore
        .collection(AppConstants.projectMembershipsCollection)
        .where('user_id', isEqualTo: userId)
        .get();

    for (final doc in memberships.docs) {
      await doc.reference.delete();
    }

    // Delete Firebase Auth account
    await _auth.currentUser?.delete();

    // Clear local cache
    await HiveService.clearAll();
  }

  /// Re-authenticate user (required for sensitive operations)
  Future<void> reauthenticate({
    required String verificationId,
    required String otp,
  }) async {
    final credential = firebase_auth.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    await _auth.currentUser?.reauthenticateWithCredential(credential);
  }

  /// Check if user exists in Firestore
  Future<bool> userExists(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    return doc.exists;
  }

  /// Link phone number to existing account
  Future<void> linkPhoneNumber({
    required String verificationId,
    required String otp,
  }) async {
    final credential = firebase_auth.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    await _auth.currentUser?.linkWithCredential(credential);
  }

  /// Unlink phone number from account
  Future<void> unlinkPhoneNumber() async {
    await _auth.currentUser?.unlink(firebase_auth.PhoneAuthProvider.PROVIDER_ID);
  }

  /// Get current user's phone number
  String? get currentUserPhoneNumber => _auth.currentUser?.phoneNumber;

  /// Refresh current user data
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}
