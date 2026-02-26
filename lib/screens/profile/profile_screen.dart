import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:empleame/providers/providers.dart';
import 'package:empleame/screens/profile/edit_profile_screen.dart';
import 'package:empleame/screens/profile/notification_settings_screen.dart';
import 'package:empleame/screens/profile/security_screen.dart';
import 'package:empleame/screens/profile/language_screen.dart';
import 'package:empleame/screens/profile/payment_methods_screen.dart';
import 'package:empleame/screens/profile/privacy_policy_screen.dart';
import 'package:empleame/screens/profile/help_center_screen.dart';
import 'package:empleame/services/auth_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final AuthService? authService;

  const ProfileScreen({super.key, this.authService});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Profile Section — reactive to Firestore
                    userAsync.when(
                      data: (user) => _buildProfileSection(
                        displayName: user?.displayName ?? '',
                        email: user?.email ?? '',
                        photoUrl: user?.photoUrl ?? '',
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              e.toString().contains('permission')
                                  ? 'No tienes permiso para ver este perfil.'
                                  : 'Error al cargar el perfil.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notification',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payment',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentMethodsScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.shield_outlined,
                      title: 'Security',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SecurityScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.language,
                      title: 'Language',
                      value: 'English (US)',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LanguageScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.remove_red_eye_outlined,
                      title: 'Dark Mode',
                      hasSwitch: true,
                      switchValue: _isDarkMode,
                      onSwitchChanged: (value) =>
                          setState(() => _isDarkMode = value),
                    ),
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Privacy Policy',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpCenterScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.people_outline,
                      title: 'Invite Friends',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      isDestructive: true,
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFEF4444),
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        if (shouldLogout == true &&
                            widget.authService != null) {
                          await widget.authService!.signOut();
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF7210FF),
              borderRadius: BorderRadius.circular(10),
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
          const Expanded(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Container(
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
    );
  }

  Widget _buildProfileSection({
    required String displayName,
    required String email,
    required String photoUrl,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: ClipOval(
                child: photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (ctx, url, err) => const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF94A3B8),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF94A3B8),
                      ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF7210FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          displayName.isNotEmpty ? displayName : 'Sin nombre',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFE2E8F0),
      margin: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? value,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool hasSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    final color = isDestructive
        ? const Color(0xFFEF4444)
        : const Color(0xFF0F172A);

    return InkWell(
      onTap: hasSwitch ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            if (value != null) ...[
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (hasSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeTrackColor: const Color(0xFF7210FF),
              )
            else
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFF64748B),
              ),
          ],
        ),
      ),
    );
  }
}
