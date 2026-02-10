import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _rememberMe = true;
  bool _faceId = true;
  bool _biometricId = false;
  bool _smsAuth = true;
  bool _googleAuth = false;

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
          'Security',
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
          // Authentication Section
          _buildSectionTitle('Authentication'),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.dialpad,
              title: 'Change PIN',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 32),

          // Biometric Section
          _buildSectionTitle('Biometric'),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.fingerprint,
              title: 'Face ID',
              hasSwitch: true,
              switchValue: _faceId,
              onSwitchChanged: (value) {
                setState(() => _faceId = value);
              },
            ),
            _buildSettingItem(
              icon: Icons.scanner,
              title: 'Biometric ID',
              hasSwitch: true,
              switchValue: _biometricId,
              onSwitchChanged: (value) {
                setState(() => _biometricId = value);
              },
            ),
          ]),
          const SizedBox(height: 32),

          // Two-Factor Authentication
          _buildSectionTitle('Two-Factor Authentication'),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.chat_bubble_outline,
              title: 'SMS Authenticator',
              hasSwitch: true,
              switchValue: _smsAuth,
              onSwitchChanged: (value) {
                setState(() => _smsAuth = value);
              },
            ),
            _buildSettingItem(
              icon: Icons.g_mobiledata,
              title: 'Google Authenticator',
              hasSwitch: true,
              switchValue: _googleAuth,
              onSwitchChanged: (value) {
                setState(() => _googleAuth = value);
              },
            ),
          ]),
          const SizedBox(height: 32),

          // Other Settings
          _buildSectionTitle('Other'),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.check_box_outlined,
              title: 'Remember Me',
              hasSwitch: true,
              switchValue: _rememberMe,
              onSwitchChanged: (value) {
                setState(() => _rememberMe = value);
              },
            ),
            _buildSettingItem(
              icon: Icons.phone_android,
              title: 'Device Management',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool hasSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return InkWell(
      onTap: hasSwitch ? null : onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF7210FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF7210FF), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            if (hasSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: const Color(0xFF7210FF),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF64748B),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
