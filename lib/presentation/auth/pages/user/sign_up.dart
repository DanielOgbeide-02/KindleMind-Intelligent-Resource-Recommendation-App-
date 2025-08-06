import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recommender_nk/config/theme/app_theme.dart';
import 'package:recommender_nk/presentation/auth/widgets/auth_input_field/auth_input.dart';
import 'package:recommender_nk/presentation/auth/widgets/buttons/app_btn.dart';
import 'package:go_router/go_router.dart';
import 'package:recommender_nk/provider/resource_model/resource_model.dart';

import '../../../../config/helper/snackbar.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/resource_model/user_notifier_provider.dart';


class SignUp extends ConsumerStatefulWidget {
  SignUp({super.key});
  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  bool isLoading = false;
  bool isPressed = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  List<ResourceModel> savedResources = [];
  List<ResourceModel> likedResources = [];
  List<ResourceModel> dislikedResources = [];
  List<ResourceModel> sharedResources = [];



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
                    ],
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      'Enter a name',
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
                    InputField(hint: 'e.g John Doe', controller: nameController),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Enter a username',
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
                    InputField(hint: 'e.g johnny', controller: usernameController),
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
                      height: 20,
                    ),
                    Text(
                      'Confirm password',
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
                    InputField(hint: 'min. 8 characters', controller: confirmPasswordController),
                    SizedBox(
                      height: 25,
                    ),
                    basic_app_btn(
                      isLoading: isLoading,
                      isPressed: isPressed,
                      buttonText: 'Continue',
                      onPressed: ()async{
                        setState(() {
                          isPressed = true;
                          isLoading = true;
                        });

                        //the authentication controller
                        final authController = ref.read(authControllerProvider.notifier);
                        final userNotifier = ref.read(userNotifierProvider.notifier); // ✅ Read UserNotifierProvider

                        if(
                        emailController.text.trim().isNotEmpty&&
                            passwordController.text.trim().isNotEmpty&&confirmPasswordController.text.trim().isNotEmpty
                        ) {
                          if(passwordController.text.trim() == confirmPasswordController.text.trim()){
                            final errorMessage = await authController.signUp(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                                nameController.text.trim(),
                                usernameController.text.trim(),
                                savedResources,
                                likedResources,
                                dislikedResources,
                                sharedResources
                            );
                            //authentication success or failure
                            if (errorMessage == null) {
                              final userDetails = await authController.getUserDetails();
                              if (userDetails != null) {
                                userNotifier.updateUser(userDetails);
                              }
                              // Navigate to preferences page instead of dashboard
                              context.go('/user_preferences');
                              setState(() {
                                isPressed = false;
                                isLoading = false;
                              });
                            }
                            else {
                              showTopSnackBar(
                                  context: context,
                                  title: 'error:',
                                  message: errorMessage
                              );
                              setState(() {
                                isPressed = false;
                                isLoading = false;
                              });
                            }
                          }
                          //if password doesn't match
                          else{
                            showTopSnackBar(
                                context: context,
                                title: 'error:',
                                message: 'Please ensure passwords match'
                            );
                            setState(() {
                              isPressed = false;
                              isLoading = false;
                            });
                          }
                        }
                        //if fields are empty
                        else{
                          showTopSnackBar(
                              context: context,
                              title: 'error:',
                              message: 'Please fill all fields'
                          );
                          setState(() {
                            isPressed = false;
                            isLoading = false;
                          });
                        }

                      },
                    ),
                    // basic_app_btn(
                    //     isLoading: isLoading,
                    //     isPressed: isPressed,
                    //     buttonText: 'Continue',
                    //     onPressed: ()async{
                    //       setState(() {
                    //         isPressed = true;
                    //         isLoading = true;
                    //       });
                    //
                    //       //the authentication controller
                    //       final authController = ref.read(authControllerProvider.notifier);
                    //       final userNotifier = ref.read(userNotifierProvider.notifier); // ✅ Read UserNotifierProvider
                    //
                    //       if(
                    //       emailController.text.trim().isNotEmpty&&
                    //           passwordController.text.trim().isNotEmpty&&confirmPasswordController.text.trim().isNotEmpty
                    //       ) {
                    //         if(passwordController.text.trim() == confirmPasswordController.text.trim()){
                    //           final errorMessage = await authController.signUp(
                    //             emailController.text.trim(),
                    //             passwordController.text.trim(),
                    //             nameController.text.trim(),
                    //             usernameController.text.trim(),
                    //             savedResources,
                    //             likedResources,
                    //             dislikedResources,
                    //             sharedResources
                    //           );
                    //           //authentication success or failure
                    //           if (errorMessage == null) {
                    //             final userDetails = await authController.getUserDetails();
                    //             if (userDetails != null) {
                    //               userNotifier.updateUser(userDetails);
                    //             }
                    //             context.go('/dashboard');
                    //             setState(() {
                    //               isPressed = false;
                    //               isLoading = false;
                    //             });// Navigate to home
                    //           }
                    //           else {
                    //             showTopSnackBar(
                    //                 context: context,
                    //                 title: 'error:',
                    //                 message: errorMessage
                    //             );
                    //             setState(() {
                    //               isPressed = false;
                    //               isLoading = false;
                    //             });
                    //           }
                    //         }
                    //         //if password doesn't match
                    //         else{
                    //           showTopSnackBar(
                    //               context: context,
                    //               title: 'error:',
                    //               message: 'Please ensure passwords match'
                    //           );
                    //           setState(() {
                    //             isPressed = false;
                    //             isLoading = false;
                    //           });
                    //         }
                    //       }
                    //       //if fields are empty
                    //       else{
                    //         showTopSnackBar(
                    //             context: context,
                    //             title: 'error:',
                    //             message: 'Please fill all fields'
                    //         );
                    //         setState(() {
                    //           isPressed = false;
                    //           isLoading = false;
                    //         });
                    //       }
                    //
                    //     },
                    // ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: (){
                            context.push('/sign_in');
                          },
                          child: Text(
                            'sign in',
                            style: TextStyle(
                                color: AppTheme.surface,
                              fontSize: 16,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                        ),
                        Icon(
                            Icons.arrow_right,
                          color: Colors.white,
                        )
                      ],
                    )
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


