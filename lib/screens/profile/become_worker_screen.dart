import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:empleame/providers/worker_conversion_provider.dart';
import 'package:empleame/services/user_repository.dart';

class BecomeWorkerScreen extends ConsumerStatefulWidget {
  const BecomeWorkerScreen({super.key});

  @override
  ConsumerState<BecomeWorkerScreen> createState() => _BecomeWorkerScreenState();
}

class _BecomeWorkerScreenState extends ConsumerState<BecomeWorkerScreen> {
  final _codeController = TextEditingController();
  Timer? _debounce;

  static const _primary = Color(0xFF7210FF);
  static const _debounceMs = 400;

  @override
  void dispose() {
    _debounce?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      ref.read(workerConversionProvider.notifier).reset();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: _debounceMs), () {
      ref.read(workerConversionProvider.notifier).validateCode(value);
    });
  }

  Future<void> _confirm() async {
    await ref
        .read(workerConversionProvider.notifier)
        .confirm(_codeController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workerConversionProvider);

    // Navigate back when conversion succeeds
    ref.listen(workerConversionProvider, (_, next) {
      if (next.status == WorkerConversionStatus.success) {
        if (context.mounted) {
          _showSuccessAndPop(context);
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Convertirse en Trabajador',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        leading: const BackButton(color: Color(0xFF0F172A)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero ────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7210FF), Color(0xFF9B5CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.work_outline_rounded,
                      size: 52,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '¡Únete como Trabajador!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ingresa el código de invitación que recibiste '
                      'para activar tu perfil de trabajador.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Code input ──────────────────────────────────────────
              const Text(
                'Código de Invitación',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              _CodeField(
                controller: _codeController,
                state: state,
                onChanged: _onCodeChanged,
              ),

              // ── Inline status message ───────────────────────────────
              const SizedBox(height: 8),
              _StatusMessage(state: state),

              // ── Inviter preview card ─────────────────────────────────
              if (state.status == WorkerConversionStatus.valid &&
                  state.inviter != null) ...[
                const SizedBox(height: 24),
                _InviterCard(inviter: state.inviter!),
              ],

              const SizedBox(height: 40),

              // ── Confirm button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (state.canConfirm && !state.isLoading)
                      ? _confirm
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    elevation: state.canConfirm ? 8 : 0,
                    shadowColor: _primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: state.status == WorkerConversionStatus.converting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Confirmar activación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),
              const _Disclaimer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessAndPop(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: Color(0xFF10B981),
            ),
            SizedBox(height: 16),
            Text(
              '¡Ya eres Trabajador!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tu perfil ha sido activado.\n'
              'Completa tu perfil de trabajador para empezar a recibir solicitudes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // back to profile
            },
            child: const Text(
              'Ir a mi perfil',
              style: TextStyle(
                color: Color(0xFF7210FF),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Code field ────────────────────────────────────────────────────────────────

class _CodeField extends StatelessWidget {
  final TextEditingController controller;
  final WorkerConversionState state;
  final ValueChanged<String> onChanged;

  const _CodeField({
    required this.controller,
    required this.state,
    required this.onChanged,
  });

  Color get _borderColor {
    return switch (state.status) {
      WorkerConversionStatus.valid => const Color(0xFF10B981),
      WorkerConversionStatus.invalidCode ||
      WorkerConversionStatus.noSlots ||
      WorkerConversionStatus.error => const Color(0xFFEF4444),
      _ => const Color(0xFFE2E8F0),
    };
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: 'Ej: abc123xyz',
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          letterSpacing: 0,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _borderColor, width: 2),
        ),
        suffixIcon: state.status == WorkerConversionStatus.validating
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : state.status == WorkerConversionStatus.valid
            ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 22)
            : null,
      ),
    );
  }
}

// ── Status message ────────────────────────────────────────────────────────────

class _StatusMessage extends StatelessWidget {
  final WorkerConversionState state;
  const _StatusMessage({required this.state});

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (state.status) {
      WorkerConversionStatus.invalidCode => (
        '❌ Código no encontrado. Verifica e intenta de nuevo.',
        const Color(0xFFEF4444),
      ),
      WorkerConversionStatus.noSlots => (
        '⚠️ El invitador no tiene cupos disponibles.',
        const Color(0xFFF59E0B),
      ),
      WorkerConversionStatus.valid => (
        '✅ Código válido.',
        const Color(0xFF10B981),
      ),
      WorkerConversionStatus.error => (
        '❌ Error inesperado. Intenta de nuevo.',
        const Color(0xFFEF4444),
      ),
      _ => ('', Colors.transparent),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: text.isEmpty
          ? const SizedBox.shrink(key: ValueKey('empty'))
          : Text(
              text,
              key: ValueKey(state.status),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
    );
  }
}

// ── Inviter card ──────────────────────────────────────────────────────────────

class _InviterCard extends StatelessWidget {
  final InviterInfo inviter;
  const _InviterCard({required this.inviter});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3ECFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF7210FF).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: inviter.photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: inviter.photoUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[200],
                      ),
                      errorWidget: (_, _, _) =>
                          _AvatarFallback(name: inviter.displayName),
                    )
                  : _AvatarFallback(name: inviter.displayName),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Al convertirte en trabajador, serás parte de la red de',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    inviter.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7210FF),
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
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 24,
    backgroundColor: const Color(0xFF7210FF),
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
    ),
  );
}

// ── Disclaimer ────────────────────────────────────────────────────────────────

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) => const Text(
    'Al confirmar, tu cuenta cambiará de Cliente a Trabajador. '
    'Esta acción requiere un código válido y consume '
    'un cupo del invitador.',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.5),
  );
}
