import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfilePictureWidget extends StatelessWidget {
  final String? profilePictureUrl;
  final double size;
  final bool isEditable;
  final VoidCallback? onEditPressed;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Widget? customPlaceholder;
  final String? displayName;
  final String? email;
  final BoxShape shape;
  final bool showBorder;
  final double borderWidth;
  final Color? borderColor;

  const ProfilePictureWidget({
    super.key,
    this.profilePictureUrl,
    required this.size,
    this.isEditable = false,
    this.onEditPressed,
    this.placeholder,
    this.errorWidget,
    this.customPlaceholder,
    this.displayName,
    this.email,
    this.shape = BoxShape.circle,
    this.showBorder = false,
    this.borderWidth = 2.0,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (profilePictureUrl == null || profilePictureUrl!.isEmpty) {
      return _buildFallbackWidget(context);
    }

    Widget imageWidget;
    
    if (kIsWeb) {
      imageWidget = Image.network(
        profilePictureUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Check if this is a CORS/fetch error
          if (error.toString().contains('Failed to fetch') ||
              error.toString().contains('statusCode: 0')) {
            // Show a special error widget for CORS issues
            return Container(
              width: size,
              height: size,
              color: Theme.of(context).colorScheme.errorContainer,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: size * 0.3,
                    ),
                    SizedBox(height: size * 0.1),
                    Text(
                      'Image not accessible\nfrom web browser',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: size * 0.12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return errorWidget ?? _buildErrorWidget(context);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(context, loadingProgress);
        },
      );
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: profilePictureUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingWidget(context, null),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(context),
      );
    }

    // Apply shape clipping
    Widget result = _applyShapeClipping(imageWidget);

    // Apply border if requested
    if (showBorder) {
      result = Container(
        decoration: BoxDecoration(
          shape: shape,
          border: Border.all(
            color: borderColor ?? Theme.of(context).colorScheme.primary,
            width: borderWidth,
          ),
        ),
        child: result,
      );
    }

    return result;
  }

  Widget _applyShapeClipping(Widget child) {
    if (shape == BoxShape.circle) {
      return ClipOval(child: child);
    } else if (shape == BoxShape.rectangle) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: child,
      );
    }
    return child;
  }

  Widget _buildFallbackWidget(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _getInitials();

    Widget fallbackWidget;
    
    if (initials.isNotEmpty) {
      fallbackWidget = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: shape,
          color: _getInitialsColor(theme),
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      fallbackWidget = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: shape,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          Icons.person,
          size: size * 0.5,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Apply border if requested
    if (showBorder) {
      fallbackWidget = Container(
        decoration: BoxDecoration(
          shape: shape,
          border: Border.all(
            color: borderColor ?? Theme.of(context).colorScheme.primary,
            width: borderWidth,
          ),
        ),
        child: fallbackWidget,
      );
    }

    return fallbackWidget;
  }

  Widget _buildLoadingWidget(BuildContext context, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) {
      return placeholder ?? _buildPlaceholder(context);
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _getInitials();

    Widget errorWidget;
    
    if (initials.isNotEmpty) {
      errorWidget = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: shape,
          color: _getInitialsColor(theme),
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      errorWidget = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: shape,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          Icons.person,
          size: size * 0.5,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Apply border if requested
    if (showBorder) {
      errorWidget = Container(
        decoration: BoxDecoration(
          shape: shape,
          border: Border.all(
            color: borderColor ?? Theme.of(context).colorScheme.primary,
            width: borderWidth,
          ),
        ),
        child: errorWidget,
      );
    }

    return errorWidget;
  }

  String _getInitials() {
    if (displayName != null && displayName!.isNotEmpty) {
      final names = displayName!.trim().split(' ');
      if (names.length >= 2) {
        final initials = '${names[0][0]}${names[1][0]}'.toUpperCase();
        return initials;
      } else if (names.length == 1) {
        final initials = names[0][0].toUpperCase();
        return initials;
      }
    } else if (email != null && email!.isNotEmpty) {
      final initials = email![0].toUpperCase();
      return initials;
    }
    return '';
  }

  Color _getInitialsColor(ThemeData theme) {
    // Generate a consistent color based on the display name or email
    final seed = displayName ?? email ?? 'default';
    final hash = seed.hashCode;

    // Use predefined colors for better visual consistency
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    final color = colors[hash.abs() % colors.length];
    return color;
  }
}

// Large profile picture widget for profile pages
class LargeProfilePictureWidget extends StatelessWidget {
  final String? profilePictureUrl;
  final String? displayName;
  final String? email;
  final double size;
  final bool isEditable;
  final VoidCallback? onEditPressed;

  const LargeProfilePictureWidget({
    super.key,
    this.profilePictureUrl,
    this.displayName,
    this.email,
    this.size = 120.0,
    this.isEditable = false,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePictureWidget(
      profilePictureUrl: profilePictureUrl,
      displayName: displayName,
      email: email,
      size: size,
      isEditable: isEditable,
      onEditPressed: onEditPressed,
      showBorder: true,
      borderWidth: 3.0,
    );
  }
}

// Small profile picture widget for lists and headers
class SmallProfilePictureWidget extends StatelessWidget {
  final String? profilePictureUrl;
  final String? displayName;
  final String? email;
  final double size;

  const SmallProfilePictureWidget({
    super.key,
    this.profilePictureUrl,
    this.displayName,
    this.email,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePictureWidget(
      profilePictureUrl: profilePictureUrl,
      displayName: displayName,
      email: email,
      size: size,
      isEditable: false,
    );
  }
}
