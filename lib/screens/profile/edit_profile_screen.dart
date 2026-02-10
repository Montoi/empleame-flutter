import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullNameController = TextEditingController(text: 'Andrew Ainsley');
  final _nicknameController = TextEditingController(text: 'Andrew');
  final _dateOfBirthController = TextEditingController(text: '12/27/1995');
  final _emailController = TextEditingController(
    text: 'andrew_ainsley@yourdomain.com',
  );
  final _countryController = TextEditingController(text: 'United States');
  final _phoneController = TextEditingController(text: '+1 111 467 378 399');
  final _genderController = TextEditingController(text: 'Male');
  final _addressController = TextEditingController(
    text: '267 New Avenue Park, New York',
  );

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
          'Edit Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            child: Column(
              children: [
                // Avatar Section
                _buildAvatarSection(),
                const SizedBox(height: 32),

                // Form Fields
                _buildTextField(
                  controller: _fullNameController,
                  placeholder: 'Full Name',
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _nicknameController,
                  placeholder: 'Nickname',
                ),
                const SizedBox(height: 16),

                _buildPickerField(
                  controller: _dateOfBirthController,
                  placeholder: 'Date of Birth',
                  icon: Icons.calendar_today_outlined,
                  onTap: () {
                    // TODO: Show date picker
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  placeholder: 'Email',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildPickerField(
                  controller: _countryController,
                  placeholder: 'Country',
                  icon: Icons.keyboard_arrow_down,
                  onTap: () {
                    // TODO: Show country picker
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _phoneController,
                  placeholder: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                _buildPickerField(
                  controller: _genderController,
                  placeholder: 'Gender',
                  icon: Icons.keyboard_arrow_down,
                  onTap: () {
                    // TODO: Show gender picker
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _addressController,
                  placeholder: 'Address',
                  maxLines: 3,
                ),
              ],
            ),
          ),

          // Fixed Update Button at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Update profile
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7210FF),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF7210FF).withValues(alpha: 0.3),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/300?img=33'),
                fit: BoxFit.cover,
              ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 18,
          ),
          suffixIcon: icon != null
              ? Icon(icon, size: 20, color: const Color(0xFF64748B))
              : null,
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}
