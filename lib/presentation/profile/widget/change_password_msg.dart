import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class changePasswordMessage extends StatelessWidget {
  const changePasswordMessage({
    super.key,
    this.currentEmail
  });

  final String? currentEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'To complete your email change:',
          style: TextStyle(
            // fontSize: 30,
              color: Color(0xFF17203A)
          ),
        ),
        SizedBox(height: 10,),
        Text(
          'A password reset link has been sent to ${currentEmail}. Please check your email and reset your password. Use the "Logout" button below to sign out, then sign in again with your new password.',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18
          ),
        ),
        const SizedBox(height: 10,),
        const Text(
          'Note: The verification link is valid for 24 hours.',
          style: TextStyle(
            // color: Color(0xFF1A1AFF),
              color: Colors.red,
              fontSize: 18

          ),
        ),
      ],
    );
  }
}
