import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last updated: February 10, 2026',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Information We Collect',
              'We collect information you provide directly to us, including your name, email address, phone number, payment information, and service preferences. We also automatically collect certain information about your device and usage patterns.',
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our services, process transactions, send you technical notices and support messages, respond to your comments and questions, and communicate with you about products, services, and events.',
            ),
            _buildSection(
              '3. Information Sharing',
              'We do not share your personal information with third parties except as described in this policy. We may share information with service providers who perform services on our behalf, such as payment processing and data analysis.',
            ),
            _buildSection(
              '4. Data Security',
              'We take reasonable measures to help protect your personal information from loss, theft, misuse, unauthorized access, disclosure, alteration, and destruction. However, no internet or email transmission is ever fully secure or error-free.',
            ),
            _buildSection(
              '5. Your Rights',
              'You have the right to access, update, or delete your personal information at any time through your account settings. You may also contact us to request that we delete your account and associated data.',
            ),
            _buildSection(
              '6. Children\'s Privacy',
              'Our services are not directed to children under 13, and we do not knowingly collect personal information from children under 13. If we learn that we have collected personal information from a child under 13, we will take steps to delete such information.',
            ),
            _buildSection(
              '7. Changes to This Policy',
              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page and updating the "Last updated" date.',
            ),
            _buildSection(
              '8. Contact Us',
              'If you have any questions about this privacy policy, please contact us at privacy@trabaja.com or through our in-app support.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7210FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF7210FF)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For more information, please visit our website or contact our support team.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
