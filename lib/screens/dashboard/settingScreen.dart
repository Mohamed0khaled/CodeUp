import 'package:codeup/routes.dart';
import 'package:codeup/services/user_service.dart';
import 'package:codeup/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;

  final userService = Get.find<UserService>();

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _initAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _glowController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Container(
        decoration: _buildTechBackground(),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Obx(() {
                        if (userService.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        return Column(
                          children: [
                            _buildUserProfile(),
                            const SizedBox(height: 24),
                            _buildPreferencesSection(),
                            const SizedBox(height: 20),
                            _buildSecuritySection(),
                            const SizedBox(height: 20),
                            _buildSupportSection(),
                            const SizedBox(height: 20),
                            _buildAccountSection(),
                            const SizedBox(height: 40),
                          ],
                        );
                      }),
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

  BoxDecoration _buildTechBackground() {
    return BoxDecoration(
      gradient: const RadialGradient(
        center: Alignment.topRight,
        radius: 1.5,
        colors: [
          Color(0xFF1A1A2E),
          Color(0xFF0A0A0F),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.cyan.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'SETTINGS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              fontFamily: 'Orbitron',
              shadows: [
                Shadow(
                  color: Colors.cyan.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 4 * _floatAnimation.value),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.teal],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.2),
                  Colors.blue.withOpacity(0.2),
                  Colors.cyan.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.cyan.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout based on available width
                final isWideScreen = constraints.maxWidth > 400;
                
                if (isWideScreen) {
                  // Wide screen layout - horizontal
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        _buildProfileImage(),
                        const SizedBox(width: 20),
                        Expanded(child: _buildProfileInfo()),
                        const SizedBox(width: 16),
                        _buildEditButton(),
                      ],
                    ),
                  );
                } else {
                  // Narrow screen layout - vertical
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildProfileImage(),
                            const SizedBox(width: 16),
                            Expanded(child: _buildProfileInfo()),
                          ],
                        ),
                        
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.cyan, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Obx(() => ProfileImageWidget(
            imageUrl: userService.bestProfileImageUrl,
            fallbackText: userService.displayName,
            size: 86, // Slightly smaller to account for gradient border
            borderWidth: 0, // No border since container has gradient
            backgroundColor: Colors.transparent,
            textColor: Colors.white,
            fontSize: 36,
            loadingIndicatorColor: Colors.cyan,
            onTap: () {
              _showImageUpdateDialog();
            },
          )),
        ),
        if (userService.currentUser?.isVerified == true)
          Positioned(
            right: 2,
            bottom: 5,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF0A0A0F),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.verified,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => Text(
          userService.displayName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
            shadows: [
              Shadow(
                color: Colors.cyan.withOpacity(0.5),
                blurRadius: 5,
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        )),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (userService.currentUser?.isPremiumUser == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.teal],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                userService.userLevel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.indigo],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                '${userService.xpPoints} XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
            _buildEditButton(),
            
          ],
        )),
        
      ],
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showEditProfileDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.edit,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      'PREFERENCES',
      Icons.tune,
      Colors.cyan,
      [
        _buildLanguageSelector(),
        _buildToggleItem(
          'Notifications',
          Icons.notifications,
          userService.notificationsEnabled,
          (value) async {
            final success = await userService.updateNotificationSettings(enabled: value);
            if (success) {
              Get.snackbar(
                'Settings',
                'Notifications ${value ? 'enabled' : 'disabled'}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.cyan,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            } else {
              Get.snackbar(
                'Error',
                'Failed to update notification settings',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            }
          },
          isSaving: false,
        ),
        _buildToggleItem(
          'Sound Effects',
          Icons.volume_up,
          userService.soundEffectsEnabled,
          (value) async {
            final success = await userService.updatePreferences(soundEffects: value);
            if (success) {
              Get.snackbar(
                'Settings',
                'Sound effects ${value ? 'enabled' : 'disabled'}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.cyan,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            } else {
              Get.snackbar(
                'Error',
                'Failed to update sound effects setting',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            }
          },
          isSaving: false,
        ),
        _buildToggleItem(
          'Dark Mode',
          Icons.dark_mode,
          userService.theme == 'dark',
          (value) async {
            final success = await userService.updatePreferences(theme: value ? 'dark' : 'light');
            if (success) {
              Get.snackbar(
                'Settings',
                'Dark mode ${value ? 'enabled' : 'disabled'}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.cyan,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            } else {
              Get.snackbar(
                'Error',
                'Failed to update theme setting',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            }
          },
          isSaving: false,
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      'SECURITY',
      Icons.security,
      Colors.purple,
      [
        _buildMenuItem(
          'Change Password',
          Icons.lock,
          Colors.purple,
          () => _showChangePasswordDialog(),
        ),
        _buildMenuItem(
          'Two-Factor Auth',
          Icons.verified_user,
          Colors.purple,
          () => _showTwoFactorDialog(),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      'SUPPORT',
      Icons.help,
      Colors.green,
      [
        _buildMenuItem(
          'Help & FAQ',
          Icons.help_outline,
          Colors.green,
          () => _showHelpFAQ(),
        ),
        _buildMenuItem(
          'Contact Us',
          Icons.message,
          Colors.green,
          () => _showContactDialog(),
        ),
        _buildMenuItem(
          'Report a Bug',
          Icons.bug_report,
          Colors.green,
          () => _showBugReportDialog(),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      'ACCOUNT',
      Icons.account_circle,
      Colors.red,
      [
        _buildMenuItem(
          'Log Out',
          Icons.logout,
          Colors.orange,
          () => _showLogoutDialog(),
        ),
        _buildMenuItem(
          'Delete Account',
          Icons.delete_forever,
          Colors.red,
          () => _showDeleteAccountDialog(),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Color accentColor, List<Widget> children) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: accentColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontFamily: 'Orbitron',
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...children,
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector() {
    final currentLanguage = userService.language;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.language,
            color: Colors.cyan,
            size: 24,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Language',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showLanguageSelector();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyan.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentLanguage,
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.cyan,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged, {
    required bool isSaving,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? Colors.cyan : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isSaving)
            const SizedBox(
              width: 50,
              height: 28,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(!value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 50,
                height: 28,
                decoration: BoxDecoration(
                  gradient: value
                      ? const LinearGradient(colors: [Colors.cyan, Colors.blue])
                      : LinearGradient(colors: [Colors.grey[600]!, Colors.grey[700]!]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: value
                      ? [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final availableLanguages = ['English', 'Spanish', 'French', 'German', 'Japanese', 'Chinese'];
    final currentLanguage = userService.language;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF0A0A0F),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Language',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...availableLanguages.map(
              (lang) => ListTile(
                leading: Icon(
                  Icons.language,
                  color: currentLanguage == lang ? Colors.cyan : Colors.grey,
                ),
                title: Text(
                  lang,
                  style: TextStyle(
                    color: currentLanguage == lang ? Colors.cyan : Colors.white,
                    fontWeight: currentLanguage == lang ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: currentLanguage == lang
                    ? const Icon(Icons.check, color: Colors.cyan)
                    : null,
                onTap: () async {
                  final success = await userService.updatePreferences(language: lang);
                  Navigator.pop(context);
                  
                  if (success) {
                    Get.snackbar(
                      'Language Changed',
                      'Language changed to $lang',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.cyan,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      'Failed to change language',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.purple.withOpacity(0.3)),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple.withOpacity(0.5)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple.withOpacity(0.5)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple.withOpacity(0.5)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                Get.snackbar(
                  'Error',
                  'New passwords do not match',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
                return;
              }

              // TODO: Implement password change via UserService
              Get.snackbar(
                'Success',
                'Password change requested - this feature will be implemented with UserService',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
              Navigator.pop(context);
            },
            child: const Text('Change Password', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog() {
    final twoFactorEnabled = userService.twoFactorEnabled;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.purple.withOpacity(0.3)),
        ),
        title: Text(
          twoFactorEnabled ? 'Disable Two-Factor Auth' : 'Enable Two-Factor Auth',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          twoFactorEnabled
              ? 'Are you sure you want to disable two-factor authentication? This will reduce your account security.'
              : 'Two-factor authentication adds an extra layer of security to your account.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final success = await userService.updateSecuritySettings(
                twoFactorEnabled: !twoFactorEnabled,
              );
              Navigator.pop(context);
              
              if (success) {
                Get.snackbar(
                  'Success',
                  'Two-factor authentication ${!twoFactorEnabled ? 'enabled' : 'disabled'}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to update two-factor authentication settings',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              }
            },
            child: Text(
              twoFactorEnabled ? 'Disable' : 'Enable',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpFAQ() async {
    final faqs = [
      {'question': 'How do I reset my password?', 'answer': 'Go to Settings > Security > Change Password to update your password.'},
      {'question': 'How do I contact support?', 'answer': 'Use the Contact Us option in the Support section of Settings.'},
      {'question': 'How do I enable notifications?', 'answer': 'Go to Settings > Preferences > Notifications to manage your notification settings.'},
      {'question': 'Is my data secure?', 'answer': 'Yes, we use industry-standard encryption to protect your data.'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green.withOpacity(0.3)),
        ),
        title: const Text(
          'Help & FAQ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              return ExpansionTile(
                title: Text(
                  faqs[index]['question']!,
                  style: const TextStyle(color: Colors.white),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      faqs[index]['answer']!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green.withOpacity(0.3)),
        ),
        title: const Text(
          'Contact Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe your issue...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.withOpacity(0.5)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (messageController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a message',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
                return;
              }
              
              final ticketId = await userService.createSupportTicket(
                subject: 'Support Request',
                message: messageController.text,
              );
              Navigator.pop(context);
              
              if (ticketId != null) {
                Get.snackbar(
                  'Success',
                  'Support ticket created with ID: $ticketId',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to create support ticket',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              }
            },
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green.withOpacity(0.3)),
        ),
        title: const Text(
          'Report a Bug',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe the bug...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.withOpacity(0.5)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (descriptionController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please describe the bug',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
                return;
              }
              
              final bugId = await userService.submitBugReport(
                description: descriptionController.text,
              );
              Navigator.pop(context);
              
              if (bugId != null) {
                Get.snackbar(
                  'Success',
                  'Bug report submitted with ID: $bugId',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to submit bug report',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.orange.withOpacity(0.3)),
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out? You will need to sign in again to access your account.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading indicator using GetX
              Get.dialog(
                PopScope(
                  canPop: false,
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Signing out...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );
              
              try {
                // Sign out from Firebase
                await FirebaseAuth.instance.signOut();
                
                // Close loading dialog - use Get.back() which is safer
                Get.back();
                
                // Navigate to login screen and clear all previous routes
                Get.offAllNamed(AppRoutes.login);
              } catch (e) {
                // Close loading dialog safely
                try {
                  Get.back();
                } catch (_) {
                  // If Get.back() fails, we're already navigated away
                }
                
                // Show error message
                Get.snackbar(
                  'Error',
                  'Error signing out: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action cannot be undone. All your progress and data will be permanently deleted.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter Password to Confirm',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final password = passwordController.text;
              
              if (password.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter your password',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
                return;
              }
              
              Navigator.pop(context);
              
              // Show loading dialog using GetX
              Get.dialog(
                PopScope(
                  canPop: false,
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Deleting account...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );
              
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && user.email != null) {
                  // Re-authenticate user before deleting account
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: password,
                  );
                  
                  await user.reauthenticateWithCredential(credential);
                  
                  // Delete user account from Firebase
                  await user.delete();
                  
                  // Close loading dialog using Get.back()
                  Get.back();
                  
                  // Navigate to login screen and clear all previous routes
                  Get.offAllNamed(AppRoutes.login);
                  
                  // Show success message
                  Get.snackbar(
                    'Account Deleted',
                    'Your account has been successfully deleted',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                } else {
                  throw Exception('No user signed in');
                }
              } catch (e) {
                // Close loading dialog safely
                try {
                  Get.back();
                } catch (_) {
                  // If Get.back() fails, we're already navigated away
                }
                
                String errorMessage = 'Failed to delete account';
                if (e is FirebaseAuthException) {
                  switch (e.code) {
                    case 'wrong-password':
                      errorMessage = 'Incorrect password';
                      break;
                    case 'too-many-requests':
                      errorMessage = 'Too many attempts. Please try again later';
                      break;
                    case 'requires-recent-login':
                      errorMessage = 'Please log out and log back in before deleting your account';
                      break;
                    default:
                      errorMessage = 'Authentication failed: ${e.message}';
                  }
                }
                
                // Show error message
                Get.snackbar(
                  'Error',
                  errorMessage,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 4),
                );
              }
            },
            child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final displayNameController = TextEditingController(text: userService.displayName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blue.withOpacity(0.3)),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final result = await userService.updateProfileImageAsBase64();
                      if (result != null) {
                        Get.snackbar(
                          'Success',
                          'Profile image updated',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      }
                    },
                    child: const Text('Change Photo', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (displayNameController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Display name cannot be empty',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
                return;
              }
              
              final success = await userService.updateDisplayName(displayNameController.text);
              Navigator.pop(context);
              
              if (success) {
                Get.snackbar(
                  'Success',
                  'Profile updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to update profile',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Show dialog for updating profile image
  void _showImageUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1B2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.cyan.withOpacity(0.3)),
          ),
          title: const Text(
            'Update Profile Picture',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Choose how you want to update your profile picture.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateProfileImage();
              },
              child: const Text(
                'Choose from Gallery',
                style: TextStyle(color: Colors.cyan),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeProfileImage();
              },
              child: const Text(
                'Remove Picture',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Update profile image from gallery
  Future<void> _updateProfileImage() async {
    try {
      // Show loading dialog
      Get.dialog(
        PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Processing image...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final userService = UserService.to;
      // Use base64 method instead of Firebase Storage
      final imageUrl = await userService.updateProfileImageAsBase64();
      
      // Close loading dialog
      Get.back();
      
      if (imageUrl != null) {
        Get.snackbar(
          'Success',
          'Profile picture updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile picture. Image may be too large.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      try {
        Get.back();
      } catch (_) {}
      
      Get.snackbar(
        'Error',
        'Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Remove profile image
  Future<void> _removeProfileImage() async {
    try {
      // Show loading dialog
      Get.dialog(
        PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Removing image...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final userService = UserService.to;
      final success = await userService.updateUserProfile(profileImageUrl: '');
      
      // Close loading dialog
      Get.back();
      
      if (success) {
        Get.snackbar(
          'Success',
          'Profile picture removed successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to remove profile picture.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      try {
        Get.back();
      } catch (_) {}
      
      Get.snackbar(
        'Error',
        'Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
