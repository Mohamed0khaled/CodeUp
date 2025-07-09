import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// Custom Auth Error Handler with top-positioned animated notifications
class AuthErrorHandler {
  static OverlayEntry? _currentOverlay;

  static void showError(
    BuildContext context,
    String errorCode,
    String message,
  ) {
    final errorInfo = _getErrorInfo(errorCode);
    _showTopNotification(
      context,
      TopAnimatedErrorWidget(
        icon: errorInfo.icon,
        title: errorInfo.title,
        message: message,
        color: errorInfo.color,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _showTopNotification(context, TopAnimatedSuccessWidget(message: message));
  }

  static void _showTopNotification(BuildContext context, Widget child) {
    // Remove any existing overlay
    _currentOverlay?.remove();
    _currentOverlay = null;

    // Create new overlay
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(color: Colors.transparent, child: child),
      ),
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);

    // Auto-remove after duration
    Future.delayed(const Duration(seconds: 4), () {
      _currentOverlay?.remove();
      _currentOverlay = null;
    });
  }

  static _ErrorInfo _getErrorInfo(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return _ErrorInfo(
          icon: Icons.email_outlined,
          title: 'Email Already Used',
          color: Colors.orange,
        );
      case 'weak-password':
        return _ErrorInfo(
          icon: Icons.lock_outline,
          title: 'Weak Password',
          color: Colors.red,
        );
      case 'invalid-email':
        return _ErrorInfo(
          icon: Icons.alternate_email,
          title: 'Invalid Email',
          color: Colors.purple,
        );
      case 'user-not-found':
        return _ErrorInfo(
          icon: Icons.person_off_outlined,
          title: 'User Not Found',
          color: Colors.indigo,
        );
      case 'wrong-password':
        return _ErrorInfo(
          icon: Icons.key_off_outlined,
          title: 'Wrong Password',
          color: Colors.red,
        );
      case 'user-disabled':
        return _ErrorInfo(
          icon: Icons.block,
          title: 'Account Disabled',
          color: Colors.grey,
        );
      case 'too-many-requests':
        return _ErrorInfo(
          icon: Icons.timer_off,
          title: 'Too Many Attempts',
          color: Colors.deepOrange,
        );
      case 'network-request-failed':
        return _ErrorInfo(
          icon: Icons.wifi_off,
          title: 'Network Error',
          color: Colors.blue,
        );
      default:
        return _ErrorInfo(
          icon: Icons.error_outline,
          title: 'Authentication Error',
          color: Colors.red,
        );
    }
  }
}

class _ErrorInfo {
  final IconData icon;
  final String title;
  final Color color;

  _ErrorInfo({required this.icon, required this.title, required this.color});
}


class TopAnimatedErrorWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const TopAnimatedErrorWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  }) : super(key: key);

  @override
  State<TopAnimatedErrorWidget> createState() => _TopAnimatedErrorWidgetState();
}

class _TopAnimatedErrorWidgetState extends State<TopAnimatedErrorWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _shakeController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1), // Changed from bottom to top
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    HapticFeedback.mediumImpact();
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _shakeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated Icon
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    4 * _shakeAnimation.value * (1 - _shakeAnimation.value),
                    0,
                  ),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 24),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            // Error Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopAnimatedSuccessWidget extends StatefulWidget {
  final String message;

  const TopAnimatedSuccessWidget({Key? key, required this.message})
    : super(key: key);

  @override
  State<TopAnimatedSuccessWidget> createState() =>
      _TopAnimatedSuccessWidgetState();
}

class _TopAnimatedSuccessWidgetState extends State<TopAnimatedSuccessWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _checkController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1), // Changed from bottom to top
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    HapticFeedback.lightImpact();
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _checkController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated Check Icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedBuilder(
                animation: _checkAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Success Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Success!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
