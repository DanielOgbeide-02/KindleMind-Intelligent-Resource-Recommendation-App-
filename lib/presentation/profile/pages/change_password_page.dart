import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/helper/snackbar.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/resource_model/user_notifier_provider.dart';
import '../../auth/widgets/auth_input_field/auth_input.dart';
import '../../auth/widgets/buttons/app_btn.dart';
import '../widget/change_password_msg.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  late String currentEmail;
  bool isLoading = false;
  bool isPressed = false;

  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Now access ref.read inside didChangeDependencies
    final user = ref.read(userNotifierProvider);
    if (user != null) {
      currentEmail = user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (){
                  context.pop();
                },
                child: Icon(
                    Icons.arrow_back
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 120,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text(
                          'Note:',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 17,
                            letterSpacing: 2,
                          ),
                        )
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'To change your password, a password reset link would be sent to your current email. reset password and sign in with your new password.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              InputField(
                isPassword: true,
                hint: 'Enter your current email',
                controller: emailController,
              ),
              const SizedBox(
                height: 60,
              ),
              basic_app_btn(
                isLoading: isLoading,
                isPressed: isPressed,
                isLogout: true,
                onPressed: () async {
                  setState(() {
                    isPressed = true;
                    isLoading = true;
                  });
                  final authController = ref.read(authControllerProvider.notifier);
                  // ✅ Check if newPassword is empty first
                  if (emailController.text.trim().isEmpty) {
                    setState(() {
                      isLoading = false;
                      isPressed = false;
                    });
                    showTopSnackBar(
                      context: context,
                      title: 'Error:',
                      message: 'Please enter a new password.',
                    );
                    return; // Stop execution here
                  }
                  else{
                    if(emailController.text.trim() != currentEmail) {
                      setState(() {
                        isLoading = false;
                        isPressed = false;
                      });
                      showTopSnackBar(
                          context: context,
                          title: 'message:',
                          message: 'Please enter correct email.'
                      );
                      return;
                    }
                    else{
                      // ✅ Call updatePassword method
                      final result = await authController.changePassword(currentEmail);
                      if(result == 'success'){
                        setState(() {
                          isLoading = false;
                          isPressed = false;
                        });
                        openLogoutDialog(currentEmail);
                      } else {
                        setState(() {
                          isLoading = false;
                          isPressed = false;
                        });
                        showTopSnackBar(
                          context: context,
                          title: 'Error',
                          message: result,
                        );
                      }
                    }

                  }

                },
                buttonText: 'Change',
              )
            ],
          ),
        ),
      ),
    );
  }
  Future openLogoutDialog(String currentEmail)=>showDialog(
      context: context,
      builder: (context)=>
          AlertDialog(
            backgroundColor: Colors.grey.shade500,
            title:
            changePasswordMessage(currentEmail: currentEmail,),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: (){
                    print('closed');
                    context.pop();
                  }, child: Text('Close')
              ),
              TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF1A1AFF),
                  ),
                  onPressed: ()async{
                    final authController =
                    ref.read(authControllerProvider.notifier);

                    final result = await authController.logout();
                    if (result == 'success') {
                      context.pop(); // Close dialog
                      context.go('/sign_up');
                    } else {
                      showTopSnackBar(
                          context: context,
                          title: 'Logout failed:',
                          message: 'An error occured while logging out. Please try again'
                      );
                    }
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                        color: Color(0xFF17203A)
                    ),
                  )
              )
            ],
          )
  );

}
