import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/helper/snackbar.dart';
import '../../../config/theme/app_theme.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/resource_model/user_notifier_provider.dart';
import '../../auth/widgets/buttons/app_btn.dart';
import '../widget/info_item.dart';
import '../widget/redirect_info_item.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController nameController = TextEditingController();
  late TextEditingController usernameController = TextEditingController();

  bool isEditing = false;
  bool isLoading = false;
  bool isPressed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController();
    usernameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Now access ref.read inside didChangeDependencies
    final user = ref.read(userNotifierProvider);

    if (user != null) {
      nameController.text = user.name;
      usernameController.text = user.username;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Icon(
                      Icons.person
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    nameController.text,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 25),
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Personal Information', style: TextStyle(fontWeight: FontWeight.w600),),
                          Row(
                            children: [
                              Icon(Icons.edit, color: AppTheme.primary,),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: ()async{
                                  // First, toggle the editing state
                                  setState(() {
                                    isEditing = !isEditing;
                                  });

                                  if (isEditing) {
                                    return; // Exit early to allow the UI to update
                                  }

                                  setState(() {
                                    isLoading = true;
                                    isPressed = true;
                                  });

                                  final authController = ref.read(authControllerProvider.notifier);
                                  final userData = ref.watch(userNotifierProvider);

                                  if (userData == null) return;

                                  //check for changes
                                  if(nameController.text.trim() == userData.name&&usernameController.text.trim() == userData.username){
                                    setState(() {
                                      isLoading = false;
                                      isPressed = false;
                                    });
                                    showTopSnackBar(
                                      context: context,
                                      title: 'message:',
                                      message: 'No changes detected',
                                    );
                                    return; // Exit the function early
                                  }
                                  final errorMessage = await authController.updateUserProfile(
                                    name: nameController.text.trim(),
                                    username: usernameController.text.trim(),
                                    email: userData.email,
                                    savedResources: userData.savedResources,
                                    likedResources: userData.likedResources,
                                    dislikedResources: userData.dislikedResources,
                                    sharedResources: userData.sharedResources,
                                    age: userData.age ?? '',
                                    gender: userData.gender ?? '',
                                    recoveryStage: userData.recoveryStage ?? '',
                                    preferredResourceTypes: userData.preferredResourceTypes ?? [],
                                  );


                                  setState(() {
                                    isLoading = false;
                                    isPressed = false;
                                    isEditing = false; // Reset editing state after saving
                                  });

                                  if (errorMessage == null) {
                                    showTopSnackBar(
                                      context: context,
                                      title: 'message: ',
                                      message: 'Profile updated successfully',
                                    );
                                  } else {
                                    showTopSnackBar(
                                      context: context,
                                      title: 'error: ',
                                      message: errorMessage,
                                    );
                                  }

                                },
                                  child: isLoading?SizedBox( width: 20, height: 20,child: CircularProgressIndicator(color: AppTheme.primary,)):Text(isEditing?'Save Changes':'Edit')
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: [
                          InfoItem(
                            icon: Icons.tag,
                            label: 'Name',
                            value: '9898712132',
                            controller: nameController,
                            isEnabled: isEditing,
                          ),
                          InfoItem(
                            icon: Icons.alternate_email,
                            label: 'User Name',
                            value: 'www.randomweb.com',
                            controller: usernameController,
                            isEnabled: isEditing,
                          ),
                          GestureDetector(
                            onTap: (){
                              context.push('/change_email');
                            },
                            child: const ProfileInfoItem(
                                icon: Icons.email_outlined,
                                label: 'Change Email',
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              context.push('/change_password');
                            },
                            child: const ProfileInfoItem(
                                icon: Icons.email_outlined,
                                label: 'Change Password',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Account Settings', style: TextStyle(fontWeight: FontWeight.w600),),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        children:  [
                          GestureDetector(
                            onTap: (){
                              context.push('/saved_resources');
                            },
                            child: ProfileInfoItem(
                              icon: Icons.bookmark ,
                              label: 'Saved Resources',
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              context.push('/display_preferences');
                            },
                            child: ProfileInfoItem(
                              icon: Icons.tune,
                              label: 'Preferences',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: basic_app_btn(
                isLogout: true,
                  onPressed: ()async{
                    final authController =
                    ref.read(authControllerProvider.notifier);

                    final result = await authController.logout();
                    if (result == 'success') {
                      context.go('/sign_up');
                    } else {
                      showTopSnackBar(
                          context: context,
                          title: 'Logout failed:',
                          message: 'An error occured while logging out. Please try again'
                      );
                    }
                  },
                  buttonText: 'Logout'
              ),
            ),
          ],
        ),
      ),
    );
  }
}
