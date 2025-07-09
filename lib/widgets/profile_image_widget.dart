import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

/// A reusable profile image widget that handles loading states, errors, and fallbacks
class ProfileImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final VoidCallback? onTap;
  final bool showLoadingIndicator;
  final Color? loadingIndicatorColor;

  const ProfileImageWidget({
    Key? key,
    this.imageUrl,
    required this.fallbackText,
    this.size = 60,
    this.borderColor,
    this.borderWidth = 3,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 24,
    this.onTap,
    this.showLoadingIndicator = true,
    this.loadingIndicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((size - borderWidth) / 2),
        child: _buildImageContent(context),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }

  Widget _buildImageContent(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Check if it's a base64 image
      if (imageUrl!.startsWith('data:image/')) {
        return Image.memory(
          _base64ToBytes(imageUrl!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Base64 image decode error: $error');
            return _buildFallbackWidget();
          },
        );
      } else {
        // Regular network image
        return Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: showLoadingIndicator
              ? (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: backgroundColor ?? Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          loadingIndicatorColor ?? Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  );
                }
              : null,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Network image load error: $error');
            return _buildFallbackWidget();
          },
        );
      }
    } else {
      return _buildFallbackWidget();
    }
  }
  
  /// Convert base64 data URL to bytes
  Uint8List _base64ToBytes(String base64String) {
    // Remove data URL prefix if present
    final base64Data = base64String.split(',').last;
    return base64Decode(base64Data);
  }

  Widget _buildFallbackWidget() {
    return Container(
      color: backgroundColor ?? Colors.grey[300],
      child: Center(
        child: Text(
          _getFallbackText(),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getFallbackText() {
    if (fallbackText.isEmpty) return 'U';
    
    // Extract first letter of each word, up to 2 letters
    final words = fallbackText.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return fallbackText[0].toUpperCase();
    }
  }
}
