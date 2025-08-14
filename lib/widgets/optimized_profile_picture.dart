import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Optimized profile picture widget with automatic caching
class OptimizedProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BoxShape shape;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showBorder;
  final double borderWidth;
  final Color? borderColor;

  const OptimizedProfilePicture({
    super.key,
    required this.imageUrl,
    required this.size,
    this.shape = BoxShape.circle,
    this.placeholder,
    this.errorWidget,
    this.showBorder = false,
    this.borderWidth = 2.0,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackWidget(context);
    }

    // Use CachedNetworkImage for better performance
    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultError(),
      // Optimize memory usage
      memCacheWidth: size.toInt(),
      memCacheHeight: size.toInt(),
      // Add fade-in animation
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );

    // Apply shape and border
    Widget result = ClipOval(
      child: imageWidget,
    );

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

  Widget _buildFallbackWidget(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        color: Colors.grey[300],
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        color: Colors.grey[300],
      ),
      child: Icon(
        Icons.error_outline,
        size: size * 0.3,
        color: Colors.red[600],
      ),
    );
  }
}

/// Small optimized profile picture for lists and compact views
class SmallOptimizedProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? displayName;
  final String? email;

  const SmallOptimizedProfilePicture({
    super.key,
    this.imageUrl,
    required this.size,
    this.displayName,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildInitialsWidget(context);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildInitialsWidget(context),
      errorWidget: (context, url, error) => _buildInitialsWidget(context),
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsWidget(BuildContext context) {
    final initials = _getInitials();
    final backgroundColor = _getBackgroundColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (displayName != null && displayName!.isNotEmpty) {
      final names = displayName!.trim().split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else if (names.length == 1) {
        return names[0][0].toUpperCase();
      }
    }
    
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    
    return '?';
  }

  Color _getBackgroundColor() {
    // Generate consistent color based on display name or email
    final seed = displayName ?? email ?? 'default';
    final hash = seed.hashCode;
    
    // Create a pleasant color palette
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
    ];
    
    return colors[hash.abs() % colors.length];
  }
}
