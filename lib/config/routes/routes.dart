import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recommender_nk/config/helper/splashscreen.dart';
import 'package:recommender_nk/presentation/auth/pages/admin/admin_sign_in.dart';
import 'package:recommender_nk/presentation/auth/pages/user/forgot_password.dart';
import 'package:recommender_nk/presentation/auth/pages/user/sign_up.dart';
import 'package:recommender_nk/presentation/dashboard/pages/dashboard.dart';
import 'package:recommender_nk/presentation/home/pages/admin/admin_home.dart';
import 'package:recommender_nk/presentation/home/pages/each_content_screen.dart';
import 'package:recommender_nk/presentation/profile/pages/change_email_page.dart';
import 'package:recommender_nk/presentation/profile/pages/change_password_page.dart';
import 'package:recommender_nk/presentation/profile/pages/display_preferences.dart';
import 'package:recommender_nk/presentation/recommended_users/pages/interact_page.dart';
import 'package:recommender_nk/presentation/recommended_users/pages/users_page.dart';
import 'package:recommender_nk/presentation/saved/pages/saved_resources_page.dart';
import 'package:recommender_nk/upload%20to%20firebase.dart';
import '../../presentation/auth/pages/user/preferences_selection.dart';
import '../../presentation/auth/pages/user/sign_in.dart';
import '../../presentation/notification/notification_screen.dart';

final GoRouter appRouter = GoRouter(
    initialLocation: '/splash_screen',
    routes: [
      GoRoute(
          path: '/splash_screen',
          builder: (context, state) => const Splashscreen()
      ),
      GoRoute(
          path: '/upload_reminder',
          builder: (context, state) => UploadRemindersPage()
      ),
      GoRoute(
          path: '/sign_up',
          builder: (context, state) => SignUp()
      ),
      GoRoute(
          path: '/sign_in',
          builder: (context, state) => SignIn()
      ),
      GoRoute(
          path: '/dashboard',
          builder: (context, state) => Dashboard()
      ),
      GoRoute(
          path: '/home_screen',
          builder: (context, state) => Dashboard()
      ),
      GoRoute(
        path: '/users_page/:userId',
        builder: (context, state) => UsersPage(
          userId: state.pathParameters['userId']!,
        ),
      ),
      GoRoute(
          path: '/change_email',
          builder: (context, state) => ChangeEmailPage()
      ),
      GoRoute(
          path: '/change_password',
          builder: (context, state) => ChangePasswordPage()
      ),
      GoRoute(
          path: '/forgot_password',
          builder: (context, state) => ForgotPasswordPage()
      ),
      GoRoute(
          path: '/saved_resources',
          builder: (context, state) => SavedResourcesPage()
      ),
      GoRoute(
          path: '/admin_home',
          builder: (context, state) => AdminDashboardPage()
      ),
      GoRoute(
          path: '/admin_sign_in',
          builder: (context, state) => AdminSignInPage()
      ),
      GoRoute(
          path: '/user_preferences',
          builder: (context, state) => UserPreferencesPage()
      ),
      GoRoute(
          path: '/display_preferences',
          builder: (context, state) => PreferencesPage()
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) {
          final notificationData = state.extra as Map<String, dynamic>?;
          return MaterialPage(
            child: NotificationsScreen(notificationData: notificationData),
          );
        },
      ),
      GoRoute(
        path: '/each_content',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, String>;
          final author = data['author'] ?? 'Unknown';
          final quote = data['quote'] ?? '';
          final articleType = data['articleType'] ?? 'General';
          final title = data['title'] ?? 'Untitled';
          return MaterialPage(
            child: EachContentScreen(author: author, quote: quote, articleType: articleType, title: title),
          );
        },
      ),
      GoRoute(
        path: '/conversation_page',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final currentUserId = data['currentUserId'] ?? '';
          final otherUserId = data['otherUserId'] ?? '';
          final otherUsername = data['otherUsername'] ?? 'Unknown User';

          return MaterialPage(
            child: ConversationPage(
                currentUserId: currentUserId,
                otherUserId: otherUserId,
                otherUsername: otherUsername
            ),
          );
        },
      ),
    ]
);