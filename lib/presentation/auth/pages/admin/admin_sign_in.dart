import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/helper/snackbar.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../provider/admin_auth_provider.dart';
import '../../widgets/auth_input_field/auth_input.dart';
import '../../widgets/buttons/app_btn.dart';


class AdminSignInPage extends ConsumerStatefulWidget {
  const AdminSignInPage({super.key});

  @override
  ConsumerState<AdminSignInPage> createState() => _AdminSignInPageState();
}

class _AdminSignInPageState extends ConsumerState<AdminSignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.primary,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Column(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: AppTheme.surface,
                      size: 60,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Admin Portal',
                      style: TextStyle(
                        fontSize: 28,
                        color: AppTheme.surface,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Secure admin login',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.surface.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email address',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.surface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    InputField(
                      hint: 'admin@example.com',
                      controller: emailController,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.surface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    InputField(
                      hint: 'Enter your password',
                      controller: passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.push('/admin-forgot-password'),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    basic_app_btn(
                      buttonText: 'Sign In',
                      isLoading: isLoading,
                      isPressed: isPressed,
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                          isPressed = true;
                        });

                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          showTopSnackBar(
                            context: context,
                            title: 'Error',
                            message: 'Please fill all fields',
                          );
                        } else {
                          final result = await ref
                              .read(adminProvider.notifier)
                              .signIn(email, password);

                          if (result == 'Sign in successful') {
                            context.go('/admin_home');
                          } else {
                            showTopSnackBar(
                              context: context,
                              title: 'Login Failed',
                              message: result,
                            );
                          }
                        }

                        setState(() {
                          isLoading = false;
                          isPressed = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
