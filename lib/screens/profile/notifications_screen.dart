import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Grouping data locally for the UI
    final List<NotificationSection> sections = [
      NotificationSection(
        title: 'Today',
        items: [
          NotificationItem(
            id: '1',
            title: 'Payment Successful!',
            description: 'You have made a services payment',
            icon: Icons.account_balance_wallet_outlined,
            iconBg: const Color(0xFF7C3AED), // Violet
            type: 'payment',
          ),
          NotificationItem(
            id: '2',
            title: 'New Category Services!',
            description: 'Now the plumbing service is available',
            icon: Icons.grid_view_outlined,
            iconBg: const Color(0xFFFB7185), // Rose
            type: 'category',
          ),
        ],
      ),
      NotificationSection(
        title: 'Yesterday',
        items: [
          NotificationItem(
            id: '3',
            title: "Today's Special Offers",
            description: 'You get a special promo today!',
            icon: Icons.card_giftcard_outlined,
            iconBg: const Color(0xFFFBBF24), // Amber
            type: 'offer',
          ),
        ],
      ),
      NotificationSection(
        title: 'December 22, 2024',
        items: [
          NotificationItem(
            id: '4',
            title: 'Credit Card Connected!',
            description: 'Credit Card has been linked!',
            icon: Icons.credit_card_outlined,
            iconBg: const Color(0xFF7C3AED), // Violet
            type: 'security',
          ),
          NotificationItem(
            id: '5',
            title: 'Account Setup Successful!',
            description: 'Your account has been created!',
            icon: Icons.person_outline,
            iconBg: const Color(0xFF34D399), // Emerald
            type: 'account',
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: false,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Center(
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(20),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
              ),
            ),
          ),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        itemCount: sections.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ...section.items.map((item) => _NotificationCard(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Main Icon Circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 24),
                ),
                // Decorative Dots
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: item.iconBg.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 0,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: item.iconBg.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: -8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.iconBg.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data Models
class NotificationSection {
  final String title;
  final List<NotificationItem> items;

  NotificationSection({required this.title, required this.items});
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconBg;
  final String type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.type,
  });
}
