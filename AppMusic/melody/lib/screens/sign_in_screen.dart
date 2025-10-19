import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';
import 'package:melody/widgets/buttons/primary_button.dart';
import 'package:melody/widgets/inputs/text_input_musium.dart';

/// Sign In screen
class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    setState(() => _isLoading = true);
    // TODO: Implement sign in logic
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      Get.toNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorMusium.darkBg,
      appBar: AppBar(
        backgroundColor: AppColorMusium.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
          color: AppColorMusium.textPrimary,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Welcome Back',
                style: AppTypographyMusium.heading2.copyWith(
                  color: AppColorMusium.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Sign in to your account to continue',
                style: AppTypographyMusium.bodyLarge.copyWith(
                  color: AppColorMusium.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              // Email input
              TextInputMusium(
                label: 'Email Address',
                hint: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
              ),

              const SizedBox(height: 20),

              // Password input
              TextInputMusium(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 12),

              // Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.toNamed('/forgot-password'),
                  child: Text(
                    'Forgot Password?',
                    style: AppTypographyMusium.labelMedium.copyWith(
                      color: AppColorMusium.accentTeal,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Sign in button
              PrimaryButton(
                label: 'Sign In',
                onPressed: _handleSignIn,
                isLoading: _isLoading,
                icon: Icons.login,
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColorMusium.textTertiary.withValues(alpha: 0.3),
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or continue with',
                      style: AppTypographyMusium.bodySmall.copyWith(
                        color: AppColorMusium.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColorMusium.textTertiary.withValues(alpha: 0.3),
                      height: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Social login buttons
              Row(
                children: [
                  // Google button
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColorMusium.textTertiary
                              .withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.g_mobiledata,
                          color: AppColorMusium.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Apple button
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColorMusium.textTertiary
                              .withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.apple,
                          color: AppColorMusium.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sign up link
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTypographyMusium.bodyMedium.copyWith(
                      color: AppColorMusium.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: "Don't have an account? "),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Get.toNamed('/sign-up'),
                          child: Text(
                            'Sign Up',
                            style: AppTypographyMusium.labelMedium.copyWith(
                              color: AppColorMusium.accentTeal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
