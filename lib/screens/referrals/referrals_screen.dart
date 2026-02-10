import 'package:flutter/material.dart';
import 'dart:math' as math;

class ReferralsScreen extends StatelessWidget {
  const ReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 8),

              // Circular Gauge Card
              _buildGaugeCard(context),
              const SizedBox(height: 24),

              // Invites Tracker Card
              _buildInvitesCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF7210FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.nightlight_round,
            color: Color(0xFF7210FF),
            size: 24,
          ),
        ),
        const Text(
          'Referrals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF333333)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildGaugeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Circular Gauge
          _buildCircularGauge(),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              _buildRoundButton(Icons.sentiment_satisfied_alt),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    side: const BorderSide(color: Color(0xFF7210FF), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Invite Friends',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7210FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildRoundButton(Icons.share),
            ],
          ),
          const SizedBox(height: 32),

          // Footer Stats
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Today, 06:00',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit, size: 14, color: Colors.grey[400]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start Invite',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Today, 22:00',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'End Invite',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularGauge() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Progress
          CustomPaint(
            size: const Size(280, 280),
            painter: _CircularGaugePainter(
              progress: 1.0, // 100% - fills entire arc
            ),
          ),

          // Center Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TOTAL REFERRALS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '12',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Keep going',
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
              const SizedBox(height: 2),
              const Text(
                '+ 2 this week',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Target: 20',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.edit, size: 14, color: Color(0xFF0F172A)),
                  ],
                ),
              ),
            ],
          ),

          // Corner Icons
          Positioned(
            top: 30,
            left: 30,
            child: _buildCornerIcon(
              Icons.local_fire_department,
              const Color(0xFFF97316),
            ),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: _buildCornerIcon(
              Icons.local_fire_department,
              const Color(0xFFFB923C),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: _buildCornerIcon(Icons.water_drop, const Color(0xFF7210FF)),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: _buildCornerIcon(Icons.bolt, const Color(0xFFEAB308)),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerIcon(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildRoundButton(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(icon, size: 24, color: Colors.grey[400]),
    );
  }

  Widget _buildInvitesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Invites Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Icon(Icons.arrow_forward, color: Color(0xFF60A5FA)),
            ],
          ),
          const SizedBox(height: 24),

          // Content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        '5',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'left',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '/ 10 daily limit',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '50% completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),

              // Right side with water drop
              Row(
                children: [
                  CustomPaint(
                    size: const Size(60, 80),
                    painter: _WaterDropPainter(),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF60A5FA)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom painter for circular gauge
class _CircularGaugePainter extends CustomPainter {
  final double progress;

  _CircularGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 120.0;
    final strokeWidth = 24.0;

    // Background arc (90% of circle)
    final backgroundPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background arc (90% = 324 degrees)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 2 + 0.05 * 2 * math.pi, // Start angle (skip 5%)
      0.9 * 2 * math.pi, // Sweep angle (90%)
      false,
      backgroundPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = const Color(0xFF7210FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 2 + 0.05 * 2 * math.pi,
      progress * 0.9 * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for water drop
class _WaterDropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF70BFFF), Color(0xFF007AFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.4,
        size.width * 0.1,
        size.height * 0.65,
      )
      ..cubicTo(
        size.width * 0.1,
        size.height * 0.85,
        size.width * 0.25,
        size.height,
        size.width / 2,
        size.height,
      )
      ..cubicTo(
        size.width * 0.75,
        size.height,
        size.width * 0.9,
        size.height * 0.85,
        size.width * 0.9,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.4,
        size.width / 2,
        0,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
