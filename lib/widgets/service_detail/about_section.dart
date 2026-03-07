import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutSection extends StatefulWidget {
  final String text;

  const AboutSection({super.key, required this.text});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final preview = widget.text.length > 120
        ? '${widget.text.substring(0, 120)}...'
        : widget.text;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('serviceDetail.aboutMe'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _expanded ? widget.text : preview,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded
                  ? tr('serviceDetail.seeLess')
                  : tr('serviceDetail.readMore'),
              style: const TextStyle(
                color: Color(0xFF7210FF),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
