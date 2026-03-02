import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PhotosSection extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onSeeAll;

  const PhotosSection({
    super.key,
    required this.photos,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fotos y Videos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: const Text(
                  'Ver todo',
                  style: TextStyle(
                    color: Color(0xFF7210FF),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dynamic layout based on photo count
          if (photos.isNotEmpty) _buildDynamicGrid(photos),
        ],
      ),
    );
  }

  Widget _buildDynamicGrid(List<String> list) {
    if (list.length == 1) {
      return _PhotoTile(url: list[0], height: 220);
    }
    if (list.length == 2) {
      return Row(
        children: [
          Expanded(child: _PhotoTile(url: list[0], height: 160)),
          const SizedBox(width: 10),
          Expanded(child: _PhotoTile(url: list[1], height: 160)),
        ],
      );
    }
    if (list.length == 3) {
      return Row(
        children: [
          Expanded(child: _PhotoTile(url: list[0], height: 220)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                _PhotoTile(url: list[1], height: 105),
                const SizedBox(height: 10),
                _PhotoTile(url: list[2], height: 105),
              ],
            ),
          ),
        ],
      );
    }
    // 4 or more (use staggered 2-column)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _PhotoTile(url: list[0], height: 160),
              const SizedBox(height: 10),
              _PhotoTile(url: list[2], height: 110),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              _PhotoTile(url: list[1], height: 110),
              const SizedBox(height: 10),
              _PhotoTile(url: list[3], height: 160),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String url;
  final double height;

  const _PhotoTile({required this.url, required this.height});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (ctx, url) =>
          Container(height: height, color: Colors.grey[200]),
      errorWidget: (ctx, url, err) => Container(
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      ),
    ),
  );
}
