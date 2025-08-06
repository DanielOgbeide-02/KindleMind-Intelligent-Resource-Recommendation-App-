import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:recommender_nk/config/theme/app_theme.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  bool _animationDone = false;

  @override
  Widget build(BuildContext context) {
    final splashTextStyle = GoogleFonts.bebasNeue(
      fontSize: 45,
      color: AppTheme.surface,
      letterSpacing: 1.5,
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary,
              AppTheme.backgroundLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: DefaultTextStyle(
            style: splashTextStyle,
            child: _animationDone
            // once done, show static text briefly
                ? Text('KindleMind')
                : AnimatedTextKit(
              animatedTexts: [
                ScaleAnimatedText(
                  'KindleMind',
                  duration: const Duration(milliseconds: 2000),
                ),
              ],
              totalRepeatCount: 1,
              isRepeatingAnimation: false,
              onFinished: () {
                // first flip to static text
                setState(() => _animationDone = true);
                // then navigate after a short pause
                Future.delayed(const Duration(seconds: 1), () {
                  // replace '/signup' with your actual route name
                  context.go('/sign_up');
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
