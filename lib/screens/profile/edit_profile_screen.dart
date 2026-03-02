import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empleame/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedDob;
  File? _localImage;
  String? _currentPhotoUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  static const _primary = Color(0xFF7210FF);
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _fullNameController.text = data['displayName'] ?? '';
          _nicknameController.text = data['nickname'] ?? '';
          _emailController.text = data['email'] ?? '';
          _countryController.text = data['country'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _genderController.text = data['gender'] ?? '';
          _addressController.text = data['address'] ?? '';
          _currentPhotoUrl = data['photoUrl'];

          if (data['dateOfBirth'] != null && data['dateOfBirth'] is Timestamp) {
            _selectedDob = (data['dateOfBirth'] as Timestamp).toDate();
            _dateOfBirthController.text =
                '${_selectedDob!.month}/${_selectedDob!.day}/${_selectedDob!.year}';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() {
        _localImage = File(picked.path);
      });
    }
  }

  String _formatPhone(String input) {
    if (input.trim().isEmpty) return input;
    String digits = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (!digits.startsWith('+')) digits = '+$digits';
    return digits;
  }

  Future<void> _updateProfile() async {
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre de usuario es obligatorio.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) return;

      // 1. Update Firebase Auth displayName (syncs header)
      await user.updateDisplayName(_fullNameController.text.trim());

      // 2. Atomic Update on Firestore
      final updateData = <String, dynamic>{
        'displayName': _fullNameController.text.trim(),
        'nickname': _nicknameController.text.trim(),
        'country': _countryController.text.trim(),
        'gender': _genderController.text.trim(),
        'phone': _formatPhone(_phoneController.text.trim()),
        'address': _addressController.text.trim(),
      };

      if (_selectedDob != null) {
        updateData['dateOfBirth'] = Timestamp.fromDate(_selectedDob!);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '✅ Profile updated successfully!',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: _primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF0F172A)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Avatar Section
            _buildAvatarSection(),
            const SizedBox(height: 32),

            // Form Fields
            const _SectionLabel(label: 'Full Name'),
            const SizedBox(height: 8),
            _AppField(controller: _fullNameController, hint: 'Full Name'),
            const SizedBox(height: 20),

            const _SectionLabel(label: 'Nickname'),
            const SizedBox(height: 8),
            _AppField(controller: _nicknameController, hint: 'Nickname'),
            const SizedBox(height: 20),

            const _SectionLabel(label: 'Date of Birth'),
            const SizedBox(height: 8),
            _AppField(
              controller: _dateOfBirthController,
              hint: 'Date of Birth',
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: Color(0xFF64748B),
              ),
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDob ?? DateTime(1995, 12, 27),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDob = picked;
                    _dateOfBirthController.text =
                        '${picked.month}/${picked.day}/${picked.year}';
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            const _SectionLabel(label: 'Email'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // darker grey box
                borderRadius: BorderRadius.circular(16),
              ),
              child: _AppField(
                controller: _emailController,
                hint: 'Email',
                suffixIcon: const Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: Color(0xFF94A3B8),
                ),
                keyboardType: TextInputType.emailAddress,
                readOnly: true, // IMMUTABLE
              ),
            ),
            const SizedBox(height: 20),

            const _SectionLabel(label: 'Country'),
            const SizedBox(height: 8),
            _AppField(
              controller: _countryController,
              hint: 'Country',
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Color(0xFF64748B),
              ),
              readOnly: true,
              onTap: _showCountryPicker,
            ),
            const SizedBox(height: 20),

            const _SectionLabel(label: 'Phone Number (E.164)'),
            const SizedBox(height: 8),
            _AppField(
              controller: _phoneController,
              hint: '+1 111 467 378 399',
              suffixIcon: const Icon(
                Icons.phone_outlined,
                size: 20,
                color: Color(0xFF64748B),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            const _SectionLabel(label: 'Gender'),
            const SizedBox(height: 8),
            _AppField(
              controller: _genderController,
              hint: 'Gender',
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Color(0xFF64748B),
              ),
              readOnly: true,
              onTap: _showGenderPicker,
            ),
            const SizedBox(height: 20),

            const _SectionLabel(label: 'Address'),
            const SizedBox(height: 8),
            _AppField(
              controller: _addressController,
              hint: 'Address',
              maxLines: 3,
            ),
            const SizedBox(height: 48),

            // Save button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  elevation: 8,
                  shadowColor: _primary.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    ImageProvider avatarImage;
    if (_localImage != null) {
      avatarImage = FileImage(_localImage!);
    } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      avatarImage = NetworkImage(_currentPhotoUrl!);
    } else {
      avatarImage = const NetworkImage('https://i.pravatar.cc/300?img=33');
    }

    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                image: DecorationImage(image: avatarImage, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF7210FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker() {
    final countries = [
      'United States',
      'Canada',
      'United Kingdom',
      'Australia',
      'Germany',
      'France',
      'Spain',
      'Italy',
      'Mexico',
      'Brazil',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Country',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  return ListTile(
                    title: Text(
                      country,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    trailing: _countryController.text == country
                        ? const Icon(Icons.check, color: Color(0xFF7210FF))
                        : null,
                    onTap: () {
                      setState(() {
                        _countryController.text = country;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderPicker() {
    final genders = ['Male', 'Female', 'Other'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Gender',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: genders.length,
                itemBuilder: (context, index) {
                  final gender = genders[index];
                  return ListTile(
                    title: Text(
                      gender,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    trailing: _genderController.text == gender
                        ? const Icon(Icons.check, color: Color(0xFF7210FF))
                        : null,
                    onTap: () {
                      setState(() {
                        _genderController.text = gender;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: Color(0xFF0F172A),
    ),
  );
}

class _AppField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const _AppField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    readOnly: readOnly,
    onTap: onTap,
    style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      suffixIcon: suffixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: suffixIcon,
            )
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF7210FF), width: 2),
      ),
    ),
  );
}
