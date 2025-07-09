import 'dart:math' as math;

import 'package:codeup/controllers/auth/authController.dart';
import 'package:codeup/screens/auth/login.dart';
import 'package:codeup/screens/auth/profileSetup.dart';
import 'package:codeup/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 🚀 CodeUp Registration Arena
/// 
/// An elite signup experience featuring:
/// • Animated glass-morphism UI design
/// • Real-time form validation
/// • Smooth particle background effects
/// • Professional error handling
/// • Seamless authentication flow
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  // 📝 Form Controllers - The digital gatekeepers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 🎭 UI State Management - Control the visual narrative
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 🎬 Animation Controllers - Bringing the interface to life
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 🔐 Authentication Controller - Your gateway to the digital realm
  final authController = Get.find<AuthController>();
  final userService = Get.find<UserService>();


  @override
  void initState() {
    super.initState();
    
    // 🎨 Initialize the animation symphony
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // ✨ Fade-in magic - From invisible to magnificent
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 🌊 Slide-up choreography - Smooth entrance from below
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // 🎬 Action! Start the visual performance
    _animationController.forward();
  }

  @override
  void dispose() {
    // 🧹 Clean up the digital mess - Prevent memory leaks like a pro
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  /// 🛡️ The Registration Guardian
  /// Validates user input, creates account, and navigates to success
  Future<void> _handleSignUp() async {
    // 📋 Form validation checkpoint
    if (!_formKey.currentState!.validate()) return;

    // 🔒 Password confirmation security check
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🎭 Enter loading state - Show the user we're working
    setState(() => _isLoading = true);

    try {
      // 🚀 Launch registration sequence
      final result = await authController.signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        context: context,
      );

      if (result.user != null) {
        // 🎉 Success! Welcome to the arena - Navigate to dashboard
        Get.to(() => ProfileSetupPage(),transition: Transition.rightToLeft);
      }
    } catch (e) {
      // 🛡️ Errors are gracefully handled by AuthController
    } finally {
      // 🎭 Exit loading state - Mission complete
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌌 Cosmic background with animated particles
          const AnimatedBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        // 🪟 Glass-morphism effect - Modern UI elegance
                        color: const Color(0xFF2a2a3e).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🚀 App Logo - Your mission badge
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.rocket_launch,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 🏆 Epic Title Section
                            const Text(
                              'Join the Arena',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your coding account',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // 📧 Email Input Field - Your digital identity
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // 🔐 Password Field - Your secret key
                            CustomTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // 🔒 Confirm Password Field - Double security checkpoint
                            CustomTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm Password',
                              icon: Icons.lock_outline,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  );
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // 🚀 Mission Launch Button - Create your account
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667eea),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.rocket_launch, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Create Account',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 🌉 Alternative Path Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // 🔗 Social Authentication Arsenal
                            SocialButton(
                              text: 'Continue with GitHub',
                              icon: Icons.code,
                              onPressed: _isLoading ? null : () {},
                              backgroundColor: const Color(0xFF24292e),
                            ),
                            const SizedBox(height: 12),
                            SocialButton(
                              text: 'Continue with Google',
                              icon: Icons.g_mobiledata,
                              onPressed: _isLoading ? null : () {},
                              backgroundColor: const Color(0xFF4285f4),
                            ),
                            const SizedBox(height: 24),

                            // 🔄 Already have an account? Quick redirect
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already in the arena? ',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.offAll(() => LoginScreen());
                                  },
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Color(0xFF667eea),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 🔄 Loading Shield - Protecting user during operations
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}

/// 🎨 Premium Text Input Component
/// 
/// Features:
/// • Glass-morphism design
/// • Animated focus states
/// • Professional validation styling
/// • Customizable icons and behavior
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

/// 🌐 Social Authentication Button
/// 
/// A sleek, unified design for third-party login options
/// with consistent branding and interactive states
class SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;

  const SocialButton({
    Key? key,
    required this.text,
    required this.icon,
    this.onPressed,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🛡️ Loading State Overlay
/// 
/// Provides visual feedback during async operations
/// while preventing user interaction conflicts
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
        ),
      ),
    );
  }
}

/// 🌌 Dynamic Particle Background System
/// 
/// Creates an immersive animated environment with:
/// • 50 floating particles with unique properties
/// • Smooth physics-based movement
/// • Color gradients matching the app theme
/// • Infinite looping animation cycle
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    
    // 🎬 Master animation conductor - 20-second cosmic cycle
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // ✨ Generate particle constellation - 50 unique cosmic entities
    _particles = List.generate(50, (index) => Particle());
  }

  @override
  void dispose() {
    // 🧹 Clean animation resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 🌈 Triple-layer gradient backdrop
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(_particles, _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

/// ⚡ Individual Particle Entity
/// 
/// Each particle is a unique cosmic element with:
/// • Random position and movement vectors
/// • Individual size and opacity characteristics
/// • Color variations within the theme palette
class Particle {
  // 📍 Particle coordinates (normalized 0.0 - 1.0)
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  
  // 🔍 Visual properties
  double size = math.Random().nextDouble() * 3 + 1;
  double opacity = math.Random().nextDouble() * 0.5 + 0.2;
  
  // 🚀 Physics vectors - Movement in digital space
  double speedX = (math.Random().nextDouble() - 0.5) * 0.002;
  double speedY = (math.Random().nextDouble() - 0.5) * 0.002;
  
  // 🎨 Aesthetic DNA - Color personality
  Color color = Color.lerp(
    const Color(0xFF667eea),
    const Color(0xFF764ba2),
    math.Random().nextDouble(),
  )!;
}

/// 🎨 Particle Rendering Engine
/// 
/// Real-time canvas painter that:
/// • Updates particle positions with physics simulation
/// • Handles boundary collision detection
/// • Renders particles with smooth animations
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 🌊 Physics simulation loop for each particle
    for (var particle in particles) {
      // 🚀 Update position based on velocity
      particle.x += particle.speedX;
      particle.y += particle.speedY;

      // 🏀 Boundary collision detection and reflection
      if (particle.x < 0 || particle.x > 1) particle.speedX *= -1;
      if (particle.y < 0 || particle.y > 1) particle.speedY *= -1;

      // 🎨 Render particle with current properties
      paint.color = particle.color.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  // 🔄 Always repaint for smooth animation
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
