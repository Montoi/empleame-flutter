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
    final isWorker = role == UserRole.worker;

    final label = isWorker ? '✦ Trabajador' : '· Cliente';
    final bgColor = isWorker
        ? const Color(0xFF7210FF)
        : const Color(0xFF475569);
    final textColor = Colors.white;

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
