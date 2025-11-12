import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide loading state
/// 
/// Use this to show global loading indicators
class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);
  
  void setLoading(bool isLoading) {
    state = isLoading;
  }
}

final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier();
});

/// App-wide error state
/// 
/// Use this to show global error messages
class ErrorNotifier extends StateNotifier<String?> {
  ErrorNotifier() : super(null);
  
  void setError(String? error) {
    state = error;
  }
  
  void clearError() {
    state = null;
  }
}

final errorProvider = StateNotifierProvider<ErrorNotifier, String?>((ref) {
  return ErrorNotifier();
});

/// App-wide success message state
/// 
/// Use this to show success snackbars/toasts
class SuccessNotifier extends StateNotifier<String?> {
  SuccessNotifier() : super(null);
  
  void setSuccess(String? message) {
    state = message;
  }
  
  void clearSuccess() {
    state = null;
  }
}

final successProvider = StateNotifierProvider<SuccessNotifier, String?>((ref) {
  return SuccessNotifier();
});

/// Network connectivity state
/// 
/// Tracks if the app has internet connection
class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true); // Assume connected initially
  
  void setConnected(bool isConnected) {
    state = isConnected;
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

/// Provider to check if app is in offline mode
final isOfflineProvider = Provider<bool>((ref) {
  return !ref.watch(connectivityProvider);
});
