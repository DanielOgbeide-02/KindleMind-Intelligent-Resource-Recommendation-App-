import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';

class basic_app_btn extends StatefulWidget {
  basic_app_btn({
    super.key, required this.buttonText, this.onPressed, this.isLoading = false, this.isPressed = false, this.isLogout
  });

  final String buttonText;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPressed;
  final bool? isLogout;
  @override
  State<basic_app_btn> createState() => _basic_app_btnState();
}

class _basic_app_btnState extends State<basic_app_btn> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.isLogout??false?AppTheme.primary:Colors.white,                    ),
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: (widget.isPressed)?null:widget.onPressed,
              child:
              (!widget.isLoading)?
              Text(
                widget.buttonText,
                style: TextStyle(
                  color: widget.isLogout??false?Colors.white:Colors.black,
                  fontSize: 17,
                  letterSpacing: 1,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ):
              const CircularProgressIndicator(
                color: Color(0xFF17203A),
              ),
            )
        ),
        Positioned(
          top: 15,
          right: 10,
            child: Icon(
              Icons.arrow_right,
              size: 20,
              color: Colors.black,
              weight: 10,
            )
        )
      ],
    );
  }
}
