import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppImage extends StatelessWidget {
  final String? imageUrl;
  final String fallbackUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData errorIcon;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.fallbackUrl = 'https://picsum.photos/400/300', // Or a local asset
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.errorIcon = Icons.broken_image_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final validUrl = (imageUrl != null && imageUrl!.isNotEmpty)
        ? imageUrl!
        : fallbackUrl;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: validUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => _ShimmerPlaceholder(
          width: width,
          height: height,
        ),
        errorWidget: (context, url, error) => _ErrorPlaceholder(
          width: width,
          height: height,
          icon: errorIcon,
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  const _ShimmerPlaceholder({this.width, this.height});

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: const Color(0xFFE2E8F0),
      end: const Color(0xFFF8FAFC),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) => Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        color: _colorAnimation.value,
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final IconData icon;

  const _ErrorPlaceholder({
    this.width,
    this.height,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      color: const Color(0xFFF1F5F9), // Slate 100
      child: Center(
        child: Icon(
          icon,
          color: const Color(0xFF94A3B8), // Slate 400
          size: 28,
        ),
      ),
    );
  }
}
