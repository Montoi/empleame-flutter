import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:empleame/providers/providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  // Local state mirrors Firestore; initialized from currentUserStreamProvider.
  bool _loaded = false;
  bool _generalNotification = true;
  bool _sound = true;
  bool _vibrate = false;
  bool _specialOffers = true;
  bool _promoDiscount = false;
  bool _payments = true;
  bool _cashback = false;
  bool _appUpdates = true;
  bool _newService = false;
  bool _newTips = false;

  @override
  Widget build(BuildContext context) {
    // Sync local state from Firestore on first load.
    final userAsync = ref.watch(currentUserStreamProvider);
    userAsync.whenData((user) {
      if (!_loaded && user != null) {
        _loaded = true;
        // isMuted maps to the master "General Notification" toggle.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _generalNotification = !user.isMuted);
        });
      }
    });

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
          'Notificaciones',
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
          // ── Master toggle — persisted as isMuted ──────────────────────────
          _buildSettingItem(
            'Notificaciones Generales',
            _generalNotification,
            (value) {
              setState(() => _generalNotification = value);
              _persistIsMuted(!value); // isMuted is the inverse of the toggle
            },
            subtitle: 'Recibir todas las notificaciones de la app',
          ),
          _buildSettingItem('Sonido', _sound, (value) {
            setState(() => _sound = value);
          }),
          _buildSettingItem('Vibración', _vibrate, (value) {
            setState(() => _vibrate = value);
          }),
          const SizedBox(height: 16),
          const _SectionHeader(title: 'Alertas'),
          _buildSettingItem('Ofertas Especiales', _specialOffers, (value) {
            setState(() => _specialOffers = value);
          }),
          _buildSettingItem('Promos y Descuentos', _promoDiscount, (value) {
            setState(() => _promoDiscount = value);
          }),
          _buildSettingItem('Pagos', _payments, (value) {
            setState(() => _payments = value);
          }),
          _buildSettingItem('Cashback', _cashback, (value) {
            setState(() => _cashback = value);
          }),
          const SizedBox(height: 16),
          const _SectionHeader(title: 'Actualizaciones'),
          _buildSettingItem('Actualizaciones de App', _appUpdates, (value) {
            setState(() => _appUpdates = value);
          }),
          _buildSettingItem('Nuevo Servicio Disponible', _newService, (value) {
            setState(() => _newService = value);
          }),
          _buildSettingItem('Nuevos Consejos', _newTips, (value) {
            setState(() => _newTips = value);
          }),
        ],
      ),
    );
  }

  Future<void> _persistIsMuted(bool isMuted) async {
    final uid = ref.read(currentUserStreamProvider).valueOrNull?.uid;
    if (uid == null) return;
    try {
      await ref.read(userRepositoryProvider).updateUser(uid, {
        'isMuted': isMuted,
      });
    } catch (e) {
      debugPrint('NotificationSettingsScreen: failed to persist isMuted: $e');
    }
  }

  Widget _buildSettingItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    String? subtitle,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF7210FF),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
