import 'package:hive_flutter/hive_flutter.dart';
import 'package:nivas/utils/constants.dart';

/// Service for managing Hive local storage
/// 
/// Hive is used for:
/// - Offline data caching
/// - Fast data access
/// - Offline queue for pending actions
class HiveService {
  // Box names (like table names in a database)
  static const String userBox = 'user_box';
  static const String projectBox = 'project_box';
  static const String cacheBox = 'cache_box';
  static const String offlineQueueBox = 'offline_queue_box';
  static const String settingsBox = 'settings_box';

  /// Initialize Hive
  /// 
  /// Call this once when app starts
  static Future<void> init() async {
    // Initialize Hive with Flutter
    await Hive.initFlutter();
    
    // Open all boxes (creates them if they don't exist)
    await Hive.openBox(userBox);
    await Hive.openBox(projectBox);
    await Hive.openBox(cacheBox);
    await Hive.openBox(offlineQueueBox);
    await Hive.openBox(settingsBox);
  }

  /// Get a box by name
  static Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  /// Clear all data (for logout)
  static Future<void> clearAll() async {
    await Hive.box(userBox).clear();
    await Hive.box(projectBox).clear();
    await Hive.box(cacheBox).clear();
    await Hive.box(offlineQueueBox).clear();
    // Don't clear settings - user preferences persist
  }

  /// Close all boxes (for app shutdown)
  static Future<void> close() async {
    await Hive.close();
  }
}

/// User cache operations
class UserCache {
  static final Box _box = HiveService.getBox(HiveService.userBox);

  /// Save user data
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    await _box.put('current_user', userData);
    await _box.put('user_cached_at', DateTime.now().toIso8601String());
  }

  /// Get cached user data
  static Map<String, dynamic>? getUser() {
    return _box.get('current_user') as Map<String, dynamic>?;
  }

  /// Check if user cache is expired
  static bool isCacheExpired() {
    final cachedAt = _box.get('user_cached_at') as String?;
    if (cachedAt == null) return true;
    
    final cacheTime = DateTime.parse(cachedAt);
    final now = DateTime.now();
    final difference = now.difference(cacheTime);
    
    return difference > AppConstants.userCacheDuration;
  }

  /// Clear user cache
  static Future<void> clear() async {
    await _box.clear();
  }
}

/// Project cache operations
class ProjectCache {
  static final Box _box = HiveService.getBox(HiveService.projectBox);

  /// Save current project ID
  static Future<void> saveCurrentProjectId(String projectId) async {
    await _box.put('current_project_id', projectId);
  }

  /// Get current project ID
  static String? getCurrentProjectId() {
    return _box.get('current_project_id') as String?;
  }

  /// Save project data
  static Future<void> saveProject(String projectId, Map<String, dynamic> projectData) async {
    await _box.put('project_$projectId', projectData);
    await _box.put('project_${projectId}_cached_at', DateTime.now().toIso8601String());
  }

  /// Get cached project data
  static Map<String, dynamic>? getProject(String projectId) {
    return _box.get('project_$projectId') as Map<String, dynamic>?;
  }

  /// Check if project cache is expired
  static bool isProjectCacheExpired(String projectId) {
    final cachedAt = _box.get('project_${projectId}_cached_at') as String?;
    if (cachedAt == null) return true;
    
    final cacheTime = DateTime.parse(cachedAt);
    final now = DateTime.now();
    final difference = now.difference(cacheTime);
    
    return difference > AppConstants.projectCacheDuration;
  }

  /// Clear project cache
  static Future<void> clear() async {
    await _box.clear();
  }
}

/// Generic cache operations
class GenericCache {
  static final Box _box = HiveService.getBox(HiveService.cacheBox);

  /// Save data with key
  static Future<void> save(String key, dynamic data) async {
    await _box.put(key, data);
    await _box.put('${key}_cached_at', DateTime.now().toIso8601String());
  }

  /// Get cached data
  static dynamic get(String key) {
    return _box.get(key);
  }

  /// Check if cache is expired
  static bool isCacheExpired(String key, Duration maxAge) {
    final cachedAt = _box.get('${key}_cached_at') as String?;
    if (cachedAt == null) return true;
    
    final cacheTime = DateTime.parse(cachedAt);
    final now = DateTime.now();
    final difference = now.difference(cacheTime);
    
    return difference > maxAge;
  }

  /// Delete specific cache
  static Future<void> delete(String key) async {
    await _box.delete(key);
    await _box.delete('${key}_cached_at');
  }

  /// Clear all cache
  static Future<void> clear() async {
    await _box.clear();
  }
}

/// Offline queue for pending actions
class OfflineQueue {
  static final Box _box = HiveService.getBox(HiveService.offlineQueueBox);

  /// Add action to queue
  static Future<void> addAction(Map<String, dynamic> action) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    action['id'] = id;
    action['queued_at'] = DateTime.now().toIso8601String();
    await _box.put(id, action);
  }

  /// Get all pending actions
  static List<Map<String, dynamic>> getAllActions() {
    return _box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Remove action from queue
  static Future<void> removeAction(String id) async {
    await _box.delete(id);
  }

  /// Clear all actions
  static Future<void> clear() async {
    await _box.clear();
  }

  /// Get queue size
  static int getSize() {
    return _box.length;
  }
}

/// App settings storage
class SettingsCache {
  static final Box _box = HiveService.getBox(HiveService.settingsBox);

  /// Save setting
  static Future<void> saveSetting(String key, dynamic value) async {
    await _box.put(key, value);
  }

  /// Get setting
  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _box.get(key, defaultValue: defaultValue);
  }

  /// Delete setting
  static Future<void> deleteSetting(String key) async {
    await _box.delete(key);
  }
}
