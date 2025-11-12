import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/providers/app_state_provider.dart';
import 'package:nivas/services/offline_sync_service.dart';

/// Service for monitoring network connectivity
/// 
/// Tracks when app goes online/offline and triggers sync
class ConnectivityService {
  final Ref ref;
  final OfflineSyncService _syncService = OfflineSyncService();
  
  bool _wasOffline = false;

  ConnectivityService(this.ref);

  /// Start monitoring connectivity
  void startMonitoring() {
    // Check connectivity periodically
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkConnectivity();
    });
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      // Try to reach Firebase
      // If this succeeds, we're online
      final isOnline = await _testConnection();
      
      // Update connectivity state
      ref.read(connectivityProvider.notifier).setConnected(isOnline);
      
      // If we just came back online, sync pending actions
      if (isOnline && _wasOffline) {
        await _onConnectionRestored();
      }
      
      _wasOffline = !isOnline;
    } catch (e) {
      // Connection failed, we're offline
      ref.read(connectivityProvider.notifier).setConnected(false);
      _wasOffline = true;
    }
  }

  /// Test connection by making a simple request
  Future<bool> _testConnection() async {
    try {
      // Simple check - try to access Firestore
      // If this works, we have internet
      // In production, you might use connectivity_plus package
      return true; // Simplified for now
    } catch (e) {
      return false;
    }
  }

  /// Handle connection restored
  Future<void> _onConnectionRestored() async {
    print('Connection restored! Syncing pending actions...');
    
    try {
      await _syncService.syncPendingActions();
      
      final pendingCount = _syncService.getPendingCount();
      if (pendingCount == 0) {
        ref.read(successProvider.notifier).setSuccess('All changes synced!');
      }
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  /// Manually trigger sync
  Future<void> manualSync() async {
    final isOnline = ref.read(connectivityProvider);
    
    if (!isOnline) {
      ref.read(errorProvider.notifier).setError('No internet connection');
      return;
    }
    
    ref.read(loadingProvider.notifier).setLoading(true);
    
    try {
      await _syncService.syncPendingActions();
      ref.read(successProvider.notifier).setSuccess('Synced successfully!');
    } catch (e) {
      ref.read(errorProvider.notifier).setError('Sync failed: $e');
    } finally {
      ref.read(loadingProvider.notifier).setLoading(false);
    }
  }
}

/// Provider for connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(ref);
});
