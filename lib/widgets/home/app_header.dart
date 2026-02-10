import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String userName;
  final String greeting;
  final String? profileImageUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBookmarkTap;

  const AppHeader({
    super.key,
    required this.userName,
    this.greeting = 'Buenos días',
    this.profileImageUrl,
    this.onNotificationTap,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl!)
                : null,
            child: profileImageUrl == null
                ? Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  )
                : null,
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
                Text(
                  userName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
