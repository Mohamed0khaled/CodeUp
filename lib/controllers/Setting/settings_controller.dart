import 'package:get/get.dart';
import 'package:codeup/services/user_service.dart';

/// Settings Controller
/// Manages user settings and preferences
class SettingsController extends GetxController {
  static SettingsController get to => Get.find();
  
  final UserService _userService = Get.find<UserService>();
  
  // Reactive settings
  final RxBool _notifications = true.obs;
  final RxBool _darkMode = true.obs;
  final RxBool _publicProfile = true.obs;
  final RxBool _allowFriendRequests = true.obs;
  final RxBool _showEmail = false.obs;
  final RxBool _showRealName = false.obs;
  
  // Loading states
  final RxBool _isLoading = false.obs;
  final RxMap<String, bool> _savingStates = <String, bool>{}.obs;
  
  // Getters
  bool get notifications => _notifications.value;
  bool get darkMode => _darkMode.value;
  bool get publicProfile => _publicProfile.value;
  bool get allowFriendRequests => _allowFriendRequests.value;
  bool get showEmail => _showEmail.value;
  bool get showRealName => _showRealName.value;
  bool get isLoading => _isLoading.value;
  
  bool isSaving(String key) => _savingStates[key] ?? false;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  /// Load settings from UserService
  Future<void> _loadSettings() async {
    try {
      _isLoading.value = true;
      
      // Load settings from user service
      await _userService.loadUserSettings();
      
      final settings = _userService.userSettings;
      
      _notifications.value = settings['notifications'] ?? true;
      _darkMode.value = settings['darkMode'] ?? true;
      _publicProfile.value = settings['publicProfile'] ?? true;
      _allowFriendRequests.value = settings['allowFriendRequests'] ?? true;
      _showEmail.value = settings['showEmail'] ?? false;
      _showRealName.value = settings['showRealName'] ?? false;
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to load settings: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Save setting with loading state
  Future<void> _saveSetting(String key, bool value) async {
    try {
      _savingStates[key] = true;
      
      // Update the setting via UserService
      await _userService.updateUserSetting(key, value);
      
      // Update local reactive state
      switch (key) {
        case 'notifications':
          _notifications.value = value;
          break;
        case 'darkMode':
          _darkMode.value = value;
          break;
        case 'publicProfile':
          _publicProfile.value = value;
          break;
        case 'allowFriendRequests':
          _allowFriendRequests.value = value;
          break;
        case 'showEmail':
          _showEmail.value = value;
          break;
        case 'showRealName':
          _showRealName.value = value;
          break;
      }
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to save setting: $e');
    } finally {
      _savingStates[key] = false;
    }
  }
  
  /// Toggle notifications
  Future<void> toggleNotifications() async {
    await _saveSetting('notifications', !_notifications.value);
  }
  
  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    await _saveSetting('darkMode', !_darkMode.value);
  }
  
  /// Toggle public profile
  Future<void> togglePublicProfile() async {
    await _saveSetting('publicProfile', !_publicProfile.value);
  }
  
  /// Toggle friend requests
  Future<void> toggleFriendRequests() async {
    await _saveSetting('allowFriendRequests', !_allowFriendRequests.value);
  }
  
  /// Toggle show email
  Future<void> toggleShowEmail() async {
    await _saveSetting('showEmail', !_showEmail.value);
  }
  
  /// Toggle show real name
  Future<void> toggleShowRealName() async {
    await _saveSetting('showRealName', !_showRealName.value);
  }
  
  /// Refresh settings
  Future<void> refreshSettings() async {
    await _loadSettings();
  }
}
