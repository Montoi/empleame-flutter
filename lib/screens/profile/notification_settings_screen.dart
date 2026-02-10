import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
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
          'Notification',
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
          _buildSettingItem('General Notification', _generalNotification, (
            value,
          ) {
            setState(() => _generalNotification = value);
          }),
          _buildSettingItem('Sound', _sound, (value) {
            setState(() => _sound = value);
          }),
          _buildSettingItem('Vibrate', _vibrate, (value) {
            setState(() => _vibrate = value);
          }),
          _buildSettingItem('Special Offers', _specialOffers, (value) {
            setState(() => _specialOffers = value);
          }),
          _buildSettingItem('Promo & Discount', _promoDiscount, (value) {
            setState(() => _promoDiscount = value);
          }),
          _buildSettingItem('Payments', _payments, (value) {
            setState(() => _payments = value);
          }),
          _buildSettingItem('Cashback', _cashback, (value) {
            setState(() => _cashback = value);
          }),
          _buildSettingItem('App Updates', _appUpdates, (value) {
            setState(() => _appUpdates = value);
          }),
          _buildSettingItem('New Service Available', _newService, (value) {
            setState(() => _newService = value);
          }),
          _buildSettingItem('New Tips Available', _newTips, (value) {
            setState(() => _newTips = value);
          }),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7210FF),
          ),
        ],
      ),
    );
  }
}
