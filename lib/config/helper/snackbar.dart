import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

Flushbar? _currentFlushbar;

void showTopSnackBar({
  required BuildContext context,
  required String title,
  required String message,
}) {
  // Dismiss any currently visible Flushbar
  _currentFlushbar?.dismiss();

  // Create and show the new Flushbar
  _currentFlushbar = Flushbar(
    duration: Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
    title: title,
    titleColor: Colors.white,
    message: message,
    messageColor: Colors.white,
    mainButton: TextButton(
      onPressed: () {
        _currentFlushbar?.dismiss();
      },
      child: const Text(
        'Dismiss',
        style: TextStyle(color: Color(0xFF17203A)),
      ),
    ),
    margin: EdgeInsets.all(20),
    borderRadius: BorderRadius.circular(10),
    backgroundGradient: const LinearGradient(
      colors: [Color(0xFF17203A), Colors.white70],
    ),
    boxShadows:  const [
      BoxShadow(
        color: Colors.grey,
        offset: Offset(2, 2),
        blurRadius: 8,
      )
    ],
  );

  _currentFlushbar!.show(context).then((_) {
    _currentFlushbar = null; // Reset when the Flushbar is dismissed
  });
}
