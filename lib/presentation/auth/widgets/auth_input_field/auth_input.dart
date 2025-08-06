import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';

class InputField extends StatefulWidget {
  InputField({
    super.key,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.defaultValue = '', // Default value added
  });

  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final String defaultValue; // Default value field

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool obscureText; // Move obscureText to state

  @override
  void initState() {
    super.initState();
    obscureText = widget.isPassword;
    widget.controller.text = widget.defaultValue; // Set default value
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        hintText: widget.hint,
        suffixIcon: widget.isPassword
            ? IconButton(
          onPressed: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: Colors.grey,
        width: 2,
      ),
    ),
      )
    );
  }
}
