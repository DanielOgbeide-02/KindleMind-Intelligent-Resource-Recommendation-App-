import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recommender_nk/provider/resource_model/resource_model.dart';
import 'package:go_router/go_router.dart';
import '../../../config/helper/snackbar.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/resource_model/user_notifier_provider.dart';
import '../../auth/widgets/auth_input_field/auth_input.dart';
import '../../auth/widgets/buttons/app_btn.dart';
import '../widget/change_email_msg.dart';

class ChangeEmailPage extends ConsumerStatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ConsumerState<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends ConsumerState<ChangeEmailPage> {

  late String currentEmail;
  late String name;
  late String username;
  late List<ResourceModel> savedResources;
  late List<ResourceModel> likedResources;
  late List<ResourceModel> dislikedResources;
  late List<ResourceModel> sharedResources;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Now access ref.read inside didChangeDependencies
    final user = ref.read(userNotifierProvider);
    if (user != null) {
      currentEmail = user.email;
      name = user.name;
      username = user.username;
      savedResources = user.savedResources;
      likedResources = user.likedResources;
      dislikedResources = user.dislikedResources;
      sharedResources = user.sharedResources;
    }
  }

  TextEditingController newEmail = TextEditingController();

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
                        'To change your email, a verification link would be sent to your current email. Complete verification and sign in with your new email.',
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
                hint: 'Enter new email',
                controller: newEmail,
              ),
              const SizedBox(
                height: 60,
              ),
              basic_app_btn(
                isLogout: true,
                onPressed: () async {
                  print(currentEmail);
                  final authController = ref.read(authControllerProvider.notifier);
                  // ✅ Check if newEmail is empty first
                  if (newEmail.text.trim().isEmpty) {
                    showTopSnackBar(
                      context: context,
                      title: 'Error:',
                      message: 'Please enter a new email address.',
                    );
                    return; // Stop execution here
                  }
                  if(newEmail.text.trim() == currentEmail) {
                    showTopSnackBar(
                        context: context,
                        title: 'message:',
                        message: 'No changes detected.'
                    );
                    return;
                  }
                  else{
                    // Show dialog or form asking the user to enter their password
                    final password = await _showPasswordDialog();
                    if(password != null){
                      final result = await authController.updateEmail(newEmail.text.trim(), password);
                      if (result == 'success') {
                        final errorMessage = await authController.updateUserProfile(
                            name: name,
                            email: newEmail.text.trim(),
                            username: username,
                            savedResources: savedResources,
                            likedResources: likedResources,
                            dislikedResources: dislikedResources,
                            sharedResources: sharedResources

                        );
                        print("Update User Profile Response: $errorMessage");
                        if (errorMessage == null) {
                          print("User profile updated successfully. Opening logout dialog...");
                          final userData = ref.read(userNotifierProvider);
                          print('current email after update: ${userData!.email}');
                          openLogoutDialog(newEmail.text.trim());
                        } else {
                          print("Failed to update user profile. Error: $errorMessage");
                          showTopSnackBar(
                            context: context,
                            title: 'error: ',
                            message: errorMessage,
                          );
                        }
                      } else {
                        showTopSnackBar(
                            context: context,
                            title: 'An error occurred:',
                            message: 'Invalid credentials might have been entered. Please try again.'
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
  Future openLogoutDialog(String updatedEmail)=>showDialog(
      context: context,
      builder: (context)=>
          AlertDialog(
            backgroundColor: Colors.grey.shade500,
            title:
            changeEmailMessage(updatedEmail: updatedEmail,),
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

  Future<String?> _showPasswordDialog() async {
    String? enteredPassword;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Password"),
          content: TextField(
            obscureText: true,
            onChanged: (value) => enteredPassword = value,
            decoration: InputDecoration(hintText: "Enter your password"),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(), // Cancel
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, enteredPassword), // Confirm
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
    return enteredPassword;
  }
}
