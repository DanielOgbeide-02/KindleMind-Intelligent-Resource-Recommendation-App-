import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class changeEmailMessage extends StatelessWidget {
  const changeEmailMessage({
    super.key,
    this.updatedEmail
  });

  final String? updatedEmail;

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
          'A verification email has been sent to ${updatedEmail}. Please check your email and verify the address. After verification, use the "Logout" button below to sign out, then sign in again with your new email.',
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
