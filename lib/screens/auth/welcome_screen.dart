import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.black,
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // Circular Image
                    Container(
                      width: 224,
                      height: 224,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.1),
                          width: 4,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipOval(
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuB_JnQktbRyxDn0amrHLi0tOYJcevJVqA69eSiM5YjayH7MMyNYpxX-yTfGDEbgg_29GHz9d0oEoH8qeyCoeSt3GEwYACzocmGLHIPc94l3QlnBM1eWjYPateTWC3hgEEnfyikUlzuLFHH9wuL0D-vAJ_eo2CEdSDodojb4TMPboTzGnK3Lu5F3VU1H_xXmNXRCIQT4eMHp6jEoLRTkkYPOMrlj0yJoccEcrfEKRENNfUijGLIFsJw-NWveGqbFpkXz7a5q0ehsglPO',
                          width: 216,
                          height: 216,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 216,
                              height: 216,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor.withValues(alpha: 0.1),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: primaryColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 216,
                              height: 216,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primaryColor.withValues(alpha: 0.15),
                                    primaryColor.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.people_alt_rounded,
                                size: 100,
                                color: primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      "Let's you in",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Social Login Buttons
                    _SocialLoginButton(
                      iconWidget: const Text(
                        'f',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1877F2),
                          fontFamily: 'Times New Roman',
                        ),
                      ),
                      text: 'Continue with Facebook',
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    _SocialLoginButton(
                      iconWidget: const Text(
                        'G',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                      text: 'Continue with Google',
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    _SocialLoginButton(
                      iconWidget: const Icon(
                        Icons.apple,
                        size: 26,
                        color: Colors.black,
                      ),
                      text: 'Continue with Apple',
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Color(0xFFE5E7EB),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: Color(0xFFE5E7EB),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sign in with password button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 6,
                          shadowColor: primaryColor.withValues(alpha: 0.4),
                        ),
                        child: const Text(
                          'Sign in with password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/sign-up'),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
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

class _SocialLoginButton extends StatelessWidget {
  final Widget iconWidget;
  final String text;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.iconWidget,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
