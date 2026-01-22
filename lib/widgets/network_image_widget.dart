import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// A widget that handles network images with proper error handling
class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final IconData? errorIcon;
  final double? borderRadius;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.errorIcon,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget defaultErrorWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
      ),
      child: Icon(
        errorIcon ?? Icons.broken_image_outlined,
        color: colorScheme.primary,
        size: (height != null && height! < 100) ? height! * 0.4 : 48,
      ),
    );

    Widget defaultPlaceholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      ),
    );

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? defaultPlaceholder;
      },
      errorBuilder: (context, error, stackTrace) {
        // Log error for debugging but don't crash
        debugPrint('NetworkImage error: $error');
        debugPrint('Image URL: $imageUrl');
        return errorWidget ?? defaultErrorWidget;
      },
    );
  }
}

/// A widget for network images used in DecorationImage (for Container backgrounds)
class NetworkDecorationImage extends StatelessWidget {
  final String imageUrl;
  final Widget child;
  final BoxFit fit;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const NetworkDecorationImage({
    super.key,
    required this.imageUrl,
    required this.child,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('NetworkDecorationImage error: $error');
        debugPrint('Image URL: $imageUrl');
        return Container(
          color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          child: errorWidget ?? const Icon(Icons.broken_image_outlined),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return Container(
          color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }
}
