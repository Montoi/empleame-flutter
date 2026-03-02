import 'package:flutter/material.dart';
import 'package:empleame/models/user_model.dart';

/// Reusable role badge. Shows "Trabajador" (purple) for [UserRole.worker]
/// and "Cliente" (blue-grey) for [UserRole.client].
/// Drop it anywhere — const-safe when [role] is known at compile time.
class UserRoleTag extends StatelessWidget {
  final UserRole role;

  const UserRoleTag({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color bgColor;

    switch (role) {
      case UserRole.admin:
        label = '★ Admin';
        bgColor = const Color(0xFFEF4444); // Red
        break;
      case UserRole.worker:
        label = '✦ Trabajador';
        bgColor = const Color(0xFF7210FF); // Purple
        break;
      case UserRole.client:
        label = '· Cliente';
        bgColor = const Color(0xFF475569); // Slate
        break;
    }

    const textColor = Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
