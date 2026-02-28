import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DetailHeader extends StatelessWidget {
  /// Provide [imageUrl] for remote images or [imageFile] for local File images.
  final String? imageUrl;
  final File? imageFile;
  final VoidCallback onBack;
  final VoidCallback onShare;

  const DetailHeader({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.onBack,
    required this.onShare,
  }) : assert(
         imageUrl != null || imageFile != null,
         'Provide either imageUrl or imageFile',
       );

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 340,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero image — local File or remote URL
          if (imageFile != null)
            Image.file(imageFile!, fit: BoxFit.cover)
          else
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (ctx, url, err) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 48),
              ),
            ),

          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4],
                ),
              ),
            ),
          ),

          // Back & Share buttons
          Positioned(
            top: topInset + 12,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _IconBtn(icon: Icons.chevron_left, onTap: onBack),
                _IconBtn(icon: Icons.share_outlined, onTap: onShare),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    ),
  );
}
