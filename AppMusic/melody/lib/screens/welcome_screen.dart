import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';
import 'package:melody/widgets/buttons/primary_button.dart';
import 'package:melody/widgets/buttons/secondary_button.dart';

/// Welcome/Onboarding screen
/// First screen users see when opening the app
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorMusium.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top spacing (20% of screen)
            const Spacer(flex: 2),

            // Center content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Music icon in teal circle
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColorMusium.accentTeal.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColorMusium.accentTeal,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.music_note,
                        size: 60,
                        color: AppColorMusium.accentTeal,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Welcome heading
                    Text(
                      'Welcome to Musium',
                      textAlign: TextAlign.center,
                      style: AppTypographyMusium.heading2.copyWith(
                        color: AppColorMusium.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'Your music, your way. Discover, create, and enjoy unlimited music.',
                      textAlign: TextAlign.center,
                      style: AppTypographyMusium.bodyLarge.copyWith(
                        color: AppColorMusium.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom buttons (20% of screen)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Sign In button
                    PrimaryButton(
                      label: 'Sign In',
                      onPressed: () {
                        Get.toNamed('/sign-in');
                      },
                      icon: Icons.login,
                    ),

                    const SizedBox(height: 12),

                    // Create Account button
                    SecondaryButton(
                      label: 'Create Account',
                      onPressed: () {
                        Get.toNamed('/sign-up');
                      },
                      icon: Icons.person_add,
                    ),

                    const SizedBox(height: 24),

                    // Terms & Privacy text
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTypographyMusium.bodySmall.copyWith(
                          color: AppColorMusium.textTertiary,
                        ),
                        children: [
                          const TextSpan(
                              text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms',
                            style: AppTypographyMusium.bodySmall.copyWith(
                              color: AppColorMusium.accentTeal,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: AppTypographyMusium.bodySmall.copyWith(
                              color: AppColorMusium.accentTeal,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
