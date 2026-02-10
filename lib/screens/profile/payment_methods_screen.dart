import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentMethods = [
      {'name': 'PayPal', 'type': 'wallet', 'connected': true},
      {'name': 'Google Pay', 'type': 'wallet', 'connected': true},
      {'name': 'Apple Pay', 'type': 'wallet', 'connected': true},
      {
        'name': 'Mastercard',
        'type': 'card',
        'lastFour': '4679',
        'connected': true,
      },
    ];

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
          'Payment',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.more_horiz, color: Color(0xFF0F172A)),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            itemCount: paymentMethods.length,
            itemBuilder: (context, index) {
              final method = paymentMethods[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7210FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        method['type'] == 'wallet'
                            ? Icons.account_balance_wallet
                            : Icons.credit_card,
                        color: const Color(0xFF7210FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        method['type'] == 'card' && method['lastFour'] != null
                            ? '•••• •••• •••• ${method['lastFour']}'
                            : method['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      method['connected'] == true
                          ? 'Connected'
                          : 'Not Connected',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7210FF),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Add new card
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7210FF),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF7210FF).withValues(alpha: 0.3),
                ),
                child: const Text(
                  'Add New Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
