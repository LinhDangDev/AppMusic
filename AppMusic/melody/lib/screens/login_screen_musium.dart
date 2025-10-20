import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../provider/auth_controller.dart';
import '../widgets/inputs/text_input_musium.dart';
import '../widgets/buttons/primary_button.dart';

class LoginScreenMusium extends StatefulWidget {
  const LoginScreenMusium({Key? key}) : super(key: key);

  @override
  State<LoginScreenMusium> createState() => _LoginScreenMusiumState();
}

class _LoginScreenMusiumState extends State<LoginScreenMusium> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

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

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
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

    final authController = Get.find<AuthController>();
    authController.login(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Login to your account to continue enjoying music',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              SizedBox(height: 40),

              // Email Input
              TextInputMusium(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hint: 'Enter your email',
                prefixIcon: Icons.email_outlined,
              ),
              SizedBox(height: 20),

              // Password Input
              TextInputMusium(
                label: 'Password',
                controller: _passwordController,
                isPassword: true,
                hint: 'Enter your password',
                prefixIcon: Icons.lock_outlined,
              ),
              SizedBox(height: 12),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/forgot-password');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Login Button
              GetBuilder<AuthController>(
                builder: (controller) {
                  return PrimaryButton(
                    label: 'Login',
                    onPressed: _handleLogin,
                    isLoading: controller.isLoading.value,
                    fullWidth: true,
                  );
                },
              ),
              SizedBox(height: 20),

              // Divider with text
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey[300],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/register');
                    },
                    child: Text(
                      'Sign up',
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
