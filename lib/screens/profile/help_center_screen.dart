import 'package:flutter/material.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int? _expandedFAQ;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book a service?',
      'answer':
          'Browse services on the home page, select the service you need, choose a provider, pick your preferred date and time, and confirm your booking. You\'ll receive a confirmation notification.',
    },
    {
      'question': 'How can I cancel or reschedule a booking?',
      'answer':
          'Go to your bookings page, select the booking you want to modify, and choose either "Reschedule" or "Cancel". Please note that cancellation policies may apply depending on timing.',
    },
    {
      'question': 'What payment methods do you accept?',
      'answer':
          'We accept all major credit cards (Visa, Mastercard, American Express), debit cards, and digital wallets including Apple Pay and Google Pay.',
    },
    {
      'question': 'How do I become a service provider?',
      'answer':
          'Download the Provider app, complete the registration form, upload required documents (ID, certifications), and wait for verification. The process typically takes 2-3 business days.',
    },
    {
      'question': 'Is my payment information secure?',
      'answer':
          'Yes, we use industry-standard encryption and comply with PCI DSS standards. We never store your full card details on our servers.',
    },
    {
      'question': 'How do I contact customer support?',
      'answer':
          'You can reach us via in-app chat (24/7), email at support@trabaja.com, or call our hotline. Average response time is under 2 hours.',
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.calendar_month,
      'title': 'Bookings',
      'description': 'Manage and track your bookings',
      'color': const Color(0xFF7210FF),
    },
    {
      'icon': Icons.credit_card,
      'title': 'Payments',
      'description': 'Billing and payment issues',
      'color': const Color(0xFF10B981),
    },
    {
      'icon': Icons.person_outline,
      'title': 'Account',
      'description': 'Profile and account settings',
      'color': const Color(0xFFF59E0B),
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'Safety',
      'description': 'Safety guidelines and tips',
      'color': const Color(0xFFEF4444),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          // Hero Section
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7210FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(48),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    size: 48,
                    color: Color(0xFF7210FF),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'How can we help you?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find answers to common questions or contact our support team',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Categories
          const Text(
            'Browse Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          ..._categories.map(
            (category) => Container(
              margin: const EdgeInsets.only(bottom: 12),
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
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: category['color'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                title: Text(
                  category['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  category['description'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF64748B),
                ),
                onTap: () {},
              ),
            ),
          ),
          const SizedBox(height: 32),

          // FAQs
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
            child: Column(
              children: _faqs.asMap().entries.map((entry) {
                final index = entry.key;
                final faq = entry.value;
                final isExpanded = _expandedFAQ == index;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _expandedFAQ = isExpanded ? null : index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: index < _faqs.length - 1
                          ? const Border(
                              bottom: BorderSide(color: Color(0xFFE2E8F0)),
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                faq['question']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: const Color(0xFF64748B),
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 12),
                          Text(
                            faq['answer']!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),

          // Contact Support
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF7210FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Still need help?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Our support team is available 24/7 to assist you',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Live Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7210FF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Email Us'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7210FF),
                    side: const BorderSide(color: Color(0xFF7210FF), width: 2),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
