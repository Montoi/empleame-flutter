import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:empleame/models/user_model.dart';
import 'package:empleame/widgets/common/user_role_tag.dart';

class AppHeader extends StatelessWidget {
  final String userName;
  final String greeting;
  final String? profileImageUrl;
  final UserRole? role;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBookmarkTap;

  const AppHeader({
    super.key,
    required this.userName,
    this.greeting = 'Buenos días',
    this.profileImageUrl,
    this.role,
    this.onNotificationTap,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: profileImageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) =>
                          const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (ctx, url, err) => Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 12),
          // Greeting and Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const Text(' 👋'),
                  ],
                ),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (role != null) UserRoleTag(role: role!),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(Icons.notifications_outlined),
            style: IconButton.styleFrom(
              side: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onBookmarkTap,
            icon: const Icon(Icons.bookmark_border),
            style: IconButton.styleFrom(
              side: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
