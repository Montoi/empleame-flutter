import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:empleame/providers/locale_provider.dart';
import 'package:empleame/screens/chat/chat_screen.dart';

enum BookingStatus { upcoming, completed, cancelled }

class Booking {
  final String id;
  final String serviceTitle;
  final String providerName;
  final String providerImage;
  final BookingStatus status;
  final String date;
  final String time;
  final String location;

  Booking({
    required this.id,
    required this.serviceTitle,
    required this.providerName,
    required this.providerImage,
    required this.status,
    required this.date,
    required this.time,
    this.location = '123 Main Street, Apt 4B',
  });
}

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _expandedId;

  final List<Booking> _allBookings = [
    Booking(
      id: '1',
      serviceTitle: 'House Cleaning',
      providerName: 'Jenny Wilson',
      providerImage:
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
      status: BookingStatus.upcoming,
      date: 'Dec 28, 2024',
      time: '09:00 AM - 11:00 AM',
    ),
    Booking(
      id: '2',
      serviceTitle: 'Plumbing Repair',
      providerName: 'Robert Fox',
      providerImage:
          'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400',
      status: BookingStatus.upcoming,
      date: 'Dec 29, 2024',
      time: '02:00 PM - 04:00 PM',
    ),
    Booking(
      id: '3',
      serviceTitle: 'Electrical Service',
      providerName: 'Devon Lane',
      providerImage:
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400',
      status: BookingStatus.completed,
      date: 'Dec 20, 2024',
      time: '10:00 AM - 12:00 PM',
    ),
    Booking(
      id: '4',
      serviceTitle: 'AC Repair',
      providerName: 'Kristin Watson',
      providerImage:
          'https://images.unsplash.com/photo-1632053002-e9a87138ce1f?w=400',
      status: BookingStatus.completed,
      date: 'Dec 18, 2024',
      time: '03:00 PM - 05:00 PM',
    ),
    Booking(
      id: '5',
      serviceTitle: 'Plumbing Repair',
      providerName: 'Chantal Shelburne',
      providerImage:
          'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400',
      status: BookingStatus.cancelled,
      date: 'Dec 15, 2024',
      time: '01:00 PM - 03:00 PM',
    ),
    Booking(
      id: '6',
      serviceTitle: 'Appliance Service',
      providerName: 'Benny Spanbauer',
      providerImage:
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400',
      status: BookingStatus.cancelled,
      date: 'Dec 12, 2024',
      time: '11:00 AM - 01:00 PM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild whenever locale changes so all tr() calls re-evaluate
    ref.watch(localeProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBookingsList(BookingStatus.upcoming),
                  _buildBookingsList(BookingStatus.completed),
                  _buildBookingsList(BookingStatus.cancelled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF7210FF),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text(
              'h',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            tr('bookings.title'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF7210FF),
        indicatorWeight: 3,
        labelColor: const Color(0xFF7210FF),
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) {
          setState(() {
            _expandedId = null;
          });
        },
        tabs: [
          Tab(text: tr('bookings.upcoming')),
          Tab(text: tr('bookings.completed')),
          Tab(text: tr('bookings.cancelled')),
        ],
      ),
    );
  }

  Widget _buildBookingsList(BookingStatus status) {
    final bookings = _allBookings.where((b) => b.status == status).toList();
    // Localized status label for empty state message
    final statusLabel = _localizedStatusLabel(status);

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              tr('bookings.emptyTitle', namedArgs: {'status': statusLabel}),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr('bookings.emptySubtitle', namedArgs: {'status': statusLabel}),
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(bookings[index]);
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final isExpanded = _expandedId == booking.id;
    final statusConfig = _getStatusConfig(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main content
          Row(
            children: [
              // Provider Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  booking.providerImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 40),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Booking Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.providerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusConfig['bg'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusConfig['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusConfig['text'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF7210FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF7210FF),
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          providerName: booking.providerName,
                          providerImage: booking.providerImage,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Expand/Collapse Button
          InkWell(
            onTap: () {
              setState(() {
                _expandedId = isExpanded ? null : booking.id;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: const Color(0xFFE2E8F0),
                size: 24,
              ),
            ),
          ),

          // Expanded Content
          if (isExpanded) ...[
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                children: [
                  _buildExpandedRow(
                    Icons.calendar_today_outlined,
                    booking.date,
                  ),
                  const SizedBox(height: 12),
                  _buildExpandedRow(Icons.access_time, booking.time),
                  const SizedBox(height: 12),
                  _buildExpandedRow(
                    Icons.location_on_outlined,
                    booking.location,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  /// Returns the localized display label for a booking status.
  String _localizedStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return tr('bookings.upcoming');
      case BookingStatus.completed:
        return tr('bookings.completed');
      case BookingStatus.cancelled:
        return tr('bookings.cancelled');
    }
  }

  Map<String, dynamic> _getStatusConfig(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return {
          'bg': const Color(0xFF7210FF).withValues(alpha: 0.1),
          'text': const Color(0xFF7210FF),
          'label': tr('bookings.upcoming'),
        };
      case BookingStatus.completed:
        return {
          'bg': const Color(0xFF10B981).withValues(alpha: 0.1),
          'text': const Color(0xFF10B981),
          'label': tr('bookings.completed'),
        };
      case BookingStatus.cancelled:
        return {
          'bg': const Color(0xFFEF4444).withValues(alpha: 0.1),
          'text': const Color(0xFFEF4444),
          'label': tr('bookings.cancelled'),
        };
    }
  }
}
