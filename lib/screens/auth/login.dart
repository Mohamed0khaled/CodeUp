import 'package:codeup/controllers/auth/authController.dart';
import 'package:codeup/routes.dart';
import 'package:codeup/screens/auth/signup.dart';
import 'package:codeup/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = AuthController();
  final userService = Get.find<UserService>();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGithubLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _floatingController.repeat(reverse: true);
  }

  void CreateNewUser(){
    userService.initializeNewUser(email: _emailController.text.trim());
    // 🛡️ Initialize user service with email
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1200;
    final isDesktop = screenSize.width >= 1200;
    final isMobile = screenSize.width < 600;

    // Responsive values
    final horizontalPadding = isMobile ? 24.0 : (isTablet ? 48.0 : 64.0);
    final maxWidth = isDesktop ? 400.0 : (isTablet ? 500.0 : double.infinity);
    final logoSize = isMobile ? 80.0 : (isTablet ? 100.0 : 120.0);
    final titleFontSize = isMobile ? 28.0 : (isTablet ? 32.0 : 36.0);
    final subtitleFontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
    final buttonHeight = isMobile ? 52.0 : (isTablet ? 56.0 : 60.0);
    final socialButtonHeight = isMobile ? 48.0 : (isTablet ? 52.0 : 56.0);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1B2E),
      body: Stack(
        children: [
          // Background floating elements
          _buildFloatingElements(),
          
          // Main content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: isMobile ? 20 : (isTablet ? 30 : 40)),

                      // Logo and Welcome Section
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset("assets/images/logo.png",
                                      width: logoSize + 20,
                                      height: logoSize + 20,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 16),

                                  // Welcome Text
                                  Text(
                                    'Welcome Back!',
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Sign in to continue',
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: isMobile ? 48 : (isTablet ? 56 : 64)),
                      
                      // Form Section
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                // Email/Username Field
                                _buildTextField(
                                  controller: _emailController,
                                  hint: 'Email or Username',
                                  icon: Icons.person_outline,
                                  isPassword: false,
                                  isTablet: isTablet,
                                  isDesktop: isDesktop,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Password Field
                                _buildTextField(
                                  controller: _passwordController,
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  isTablet: isTablet,
                                  isDesktop: isDesktop,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _handleForgotPassword,
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: const Color(0xFF06B6D4),
                                        fontSize: isMobile ? 14 : 16,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: isMobile ? 24 : (isTablet ? 28 : 32)),
                                
                                // Launch Session Button
                                _buildPrimaryButton(
                                  text: _isLoading ? 'Launching...' : 'Launch Session',
                                  icon: _isLoading ? Icons.refresh : Icons.rocket_launch,
                                  onPressed: _isLoading ? null : _handleEmailLogin,
                                  isLoading: _isLoading,
                                  height: buttonHeight,
                                  fontSize: isMobile ? 16 : (isTablet ? 17 : 18),
                                ),
                                
                                SizedBox(height: isMobile ? 24 : (isTablet ? 28 : 32)),
                                
                                // OR Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white12,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: isMobile ? 12 : 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white12,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: isMobile ? 24 : (isTablet ? 28 : 32)),
                                
                                // Social Login Buttons
                                _buildSocialButton(
                                  text: _isGithubLoading ? 'Connecting...' : 'Continue with GitHub',
                                  icon: _isGithubLoading ? Icons.refresh : Icons.code,
                                  onPressed: _isGithubLoading ? null : _handleGitHubLogin,
                                  isLoading: _isGithubLoading,
                                  height: socialButtonHeight,
                                  fontSize: isMobile ? 16 : (isTablet ? 17 : 18),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                _buildSocialButton(
                                  text: _isGoogleLoading ? 'Connecting...' : 'Continue with Google',
                                  icon: _isGoogleLoading ? Icons.refresh : Icons.g_mobiledata,
                                  onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                                  isLoading: _isGoogleLoading,
                                  height: socialButtonHeight,
                                  fontSize: isMobile ? 16 : (isTablet ? 17 : 18),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: isMobile ? 40 : (isTablet ? 60 : 80)),
                      
                      // Bottom Section
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'New to the arena? ',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: isMobile ? 14 : 16,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.to(() => SignupPage());
                                      },
                                      child: Text(
                                        'Join Now',
                                        style: TextStyle(
                                          color: const Color(0xFF06B6D4),
                                          fontSize: isMobile ? 14 : 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                Text(
                                  'DevSpace v2.1.0 • Secure Gaming Environment',
                                  style: TextStyle(
                                    color: Colors.white24,
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
      ),);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isPassword,
    bool isTablet = false,
    bool isDesktop = false,
  }) {
    final fontSize = isDesktop ? 18.0 : (isTablet ? 17.0 : 16.0);
    final verticalPadding = isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0);
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2640),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white38,
            fontSize: fontSize,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white38,
            size: isDesktop ? 24 : (isTablet ? 22 : 20),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38,
                    size: isDesktop ? 24 : (isTablet ? 22 : 20),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: verticalPadding,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required IconData icon,
    required Future<void> Function()? onPressed,
    bool isLoading = false,
    double height = 52.0,
    double fontSize = 16.0,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF06B6D4),
                  Color(0xFF8B5CF6),
                ],
              )
            : LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.grey.shade600,
                  Colors.grey.shade700,
                ],
              ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onPressed != null
            ? () async {
                await onPressed();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: fontSize + 4,
                height: fontSize + 4,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(
                icon,
                color: Colors.white,
                size: fontSize + 4,
              ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required Future<void> Function()? onPressed,
    bool isLoading = false,
    double height = 48.0,
    double fontSize = 16.0,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2640),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed != null
            ? () async {
                await onPressed();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: fontSize + 4,
                height: fontSize + 4,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(
                icon,
                color: Colors.white,
                size: fontSize + 4,
              ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isLargeScreen = screenWidth >= 600;
        
        return AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Top left elements
                if (isLargeScreen) ...[
                  Positioned(
                    top: 80 + (_floatingAnimation.value * 20),
                    left: 20,
                    child: _buildFloatingIcon(Icons.code, const Color(0xFF06B6D4)),
                  ),
                  
                  Positioned(
                    top: 120 + (_floatingAnimation.value * -15),
                    left: 60,
                    child: _buildFloatingIcon(Icons.terminal, const Color(0xFF8B5CF6)),
                  ),
                  
                  // Top right elements
                  Positioned(
                    top: 100 + (_floatingAnimation.value * 25),
                    right: 30,
                    child: _buildFloatingIcon(Icons.bug_report, const Color(0xFF10B981)),
                  ),
                  
                  Positioned(
                    top: 140 + (_floatingAnimation.value * -10),
                    right: 70,
                    child: _buildFloatingIcon(Icons.play_arrow, const Color(0xFFF59E0B)),
                  ),
                  
                  // Bottom elements
                  Positioned(
                    bottom: 200 + (_floatingAnimation.value * 30),
                    left: 40,
                    child: _buildFloatingIcon(Icons.settings, const Color(0xFFEF4444)),
                  ),
                  
                  Positioned(
                    bottom: 180 + (_floatingAnimation.value * -20),
                    right: 50,
                    child: _buildFloatingIcon(Icons.rocket_launch, const Color(0xFF06B6D4)),
                  ),
                ] else ...[
                  // Simplified floating elements for mobile
                  Positioned(
                    top: 60 + (_floatingAnimation.value * 15),
                    left: 20,
                    child: _buildFloatingIcon(Icons.code, const Color(0xFF06B6D4)),
                  ),
                  
                  Positioned(
                    top: 80 + (_floatingAnimation.value * -10),
                    right: 20,
                    child: _buildFloatingIcon(Icons.terminal, const Color(0xFF8B5CF6)),
                  ),
                  
                  Positioned(
                    bottom: 150 + (_floatingAnimation.value * 20),
                    left: 30,
                    child: _buildFloatingIcon(Icons.rocket_launch, const Color(0xFF06B6D4)),
                  ),
                  
                  Positioned(
                    bottom: 130 + (_floatingAnimation.value * -15),
                    right: 30,
                    child: _buildFloatingIcon(Icons.play_arrow, const Color(0xFFF59E0B)),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeScreen = screenWidth >= 600;
        final iconSize = isLargeScreen ? 12.0 : 10.0;
        final containerSize = isLargeScreen ? 16.0 : 12.0;
        
        return Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(containerSize / 2),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: color,
          ),
        );
      },
    );
  }

  /// Handle email/password login
  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Enhanced validation
    if (email.isEmpty) {
      _showErrorSnackBar('Please enter your email address');
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorSnackBar('Please enter a valid email address');
      return;
    }

    if (password.isEmpty) {
      _showErrorSnackBar('Please enter your password');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authController.signInWithEmailPassword(
        email: email,
        password: password,
        context: context,
      );

      if (result.user != null) {
        // Navigate to dashboard on successful login
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle Google login
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final result = await _authController.signInWithGoogle(context: context);

      if (result.user != null) {
        // Wait a moment to ensure all data is loaded
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Navigate to dashboard on successful login
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  /// Handle GitHub login
  Future<void> _handleGitHubLogin() async {
    setState(() {
      _isGithubLoading = true;
    });

    try {
      final result = await _authController.signInWithGitHub(context: context);

      if (result.user != null) {
        // Navigate to dashboard on successful login
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGithubLoading = false;
        });
      }
    }
  }

  /// Handle forgot password
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorSnackBar('Please enter your email address');
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorSnackBar('Please enter a valid email address');
      return;
    }

    await _authController.sendPasswordResetEmail(
      email: email,
      context: context,
    );
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}