import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:recommender_nk/config/theme/app_theme.dart';
import 'package:recommender_nk/presentation/auth/widgets/auth_input_field/auth_input.dart';
import 'package:recommender_nk/presentation/auth/widgets/buttons/app_btn.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/helper/snackbar.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/resource_model/user_notifier_provider.dart';



class SignIn extends ConsumerStatefulWidget {
  SignIn({super.key});
  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  bool isLoading = false;
  bool isPressed = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: AppTheme.primary,
          body: Padding(
            padding: const EdgeInsets.only(left: 30,right: 30, top: 100, bottom: 50),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Column(
                      //sign up page header
                      children: [
                        Text(
                          'KindleMind',
                          style: TextStyle(
                              fontSize: 30,
                              color: AppTheme.surface,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700
                          ),
                        ),
                        Text(
                          ' Connect, Uplift, Thrive',
                          style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.surface,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            context.push('/admin_sign_in');
                          },
                          child: Text(
                            'sign in as admin',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                            'Sign in to your KindleMind',
                          style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.surface,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'your email address',
                        style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.surface,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      InputField(hint: 'johndoe@gmail.com', controller: emailController),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Choose a password',
                        style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.surface,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      InputField(hint: 'min. 8 characters', controller: passwordController),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: (){
                          context.push('/forgot_password');
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      basic_app_btn(buttonText: 'Sign In',
                        isLoading: isLoading,
                        isPressed: isPressed,
                        onPressed: () async {
                          setState(() {
                            isPressed = true;
                            isLoading = true;
                          });
              
                          // Access the authentication and user notifier
                          final authController = ref.read(authControllerProvider.notifier);
                          final userNotifier = ref.read(userNotifierProvider.notifier); // ✅ Read UserNotifierProvider
              
                          // Check if email and password fields are not empty
                          if (emailController.text.trim().isNotEmpty &&
                              passwordController.text.trim().isNotEmpty) {
              
                            final errorMessage = await authController.signIn(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                              print('Error message is: $errorMessage');
                            // Check if sign-in was successful
                            if (errorMessage == null || errorMessage == 'success') {
                              final userDetails = await authController.getUserDetails();
                              if (userDetails != null) {
                                print('User details is: $userDetails');
                                userNotifier.updateUser(userDetails);
                              }
                              context.go('/dashboard');
                            } else {
                              print('unable to get user details');
                              showTopSnackBar(
                                context: context,
                                title: 'error:',
                                message: errorMessage,
                              );
                            }
                          } else {
                            showTopSnackBar(
                              context: context,
                              title: 'error:',
                              message: 'Please fill all fields',
                            );
                          }
              
                          setState(() {
                            isPressed = false;
                            isLoading = false;
                          });
                        },
              
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
      ),
    );
  }
}
