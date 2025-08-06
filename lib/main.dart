import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recommender_nk/domain/services/notification_service.dart';
import 'config/routes/routes.dart';
import 'config/theme/app_theme.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //init notifications
  // await NotificationService().initNotification();
  tz.initializeTimeZones(); // add this line to Ensure timezone initialization
  runApp(
      ProviderScope(child: const MyApp())
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.customTheme,
      routerConfig: appRouter,
    );
  }
}