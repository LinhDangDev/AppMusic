import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../provider/auth_controller.dart';
import '../widgets/inputs/text_input_musium.dart';
import '../widgets/buttons/primary_button.dart';

class RegisterScreenMusium extends StatefulWidget {
  const RegisterScreenMusium({Key? key}) : super(key: key);

  @override
  State<RegisterScreenMusium> createState() => _RegisterScreenMusiumState();
}

class _RegisterScreenMusiumState extends State<RegisterScreenMusium> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please fill all fields',
        duration: Duration(seconds: 2),
      );
      return;
    }

    // Validate email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid email',
        duration: Duration(seconds: 2),
      );
      return;
    }

    // Validate name
    if (name.length < 2) {
      Get.snackbar(
        'Validation Error',
        'Name must be at least 2 characters',
        duration: Duration(seconds: 2),
      );
      return;
    }

    // Validate password
    if (password.length < 8) {
      Get.snackbar(
        'Validation Error',
        'Password must be at least 8 characters',
        duration: Duration(seconds: 2),
      );
      return;
    }

    // Check password strength
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    if (!hasUpperCase || !hasLowerCase || !hasNumber) {
      Get.snackbar(
        'Weak Password',
        'Password must contain uppercase, lowercase, and numbers',
        duration: Duration(seconds: 3),
      );
      return;
    }

    // Confirm password
    if (password != confirmPassword) {
      Get.snackbar(
        'Validation Error',
        'Passwords do not match',
        duration: Duration(seconds: 2),
      );
      return;
    }

    // Check terms
    if (!_agreeToTerms) {
      Get.snackbar(
        'Validation Error',
        'Please agree to Terms & Conditions',
        duration: Duration(seconds: 2),
      );
      return;
    }

    final authController = Get.find<AuthController>();
    authController.register(email: email, password: password, name: name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button & Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back, size: 24),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join AppMusic to enjoy unlimited music',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Name Input
              TextInputMusium(
                label: 'Full Name',
                controller: _nameController,
                keyboardType: TextInputType.name,
                hint: 'Enter your full name',
                prefixIcon: Icons.person_outlined,
              ),
              SizedBox(height: 16),

              // Email Input
              TextInputMusium(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hint: 'Enter your email',
                prefixIcon: Icons.email_outlined,
              ),
              SizedBox(height: 16),

              // Password Input
              TextInputMusium(
                label: 'Password',
                controller: _passwordController,
                isPassword: true,
                hint: 'At least 8 characters',
                prefixIcon: Icons.lock_outlined,
              ),
              SizedBox(height: 8),

              // Password requirements
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  '✓ Uppercase, lowercase, and numbers required',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ),
              SizedBox(height: 16),

              // Confirm Password Input
              TextInputMusium(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                isPassword: true,
                hint: 'Re-enter your password',
                prefixIcon: Icons.lock_outlined,
              ),
              SizedBox(height: 20),

              // Terms & Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'I agree to ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Register Button
              GetBuilder<AuthController>(
                builder: (controller) {
                  return PrimaryButton(
                    label: 'Sign Up',
                    onPressed: _handleRegister,
                    isLoading: controller.isLoading.value,
                    fullWidth: true,
                  );
                },
              ),
              SizedBox(height: 20),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
