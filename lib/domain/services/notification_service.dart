//
// class NotificationService{
//   final notificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   bool _isInitialized = false;
//   bool get isInitialized => _isInitialized;
//
//   //INITIALIZE
//   Future<void> initNotification() async{
//     if (_isInitialized) return;
//
//     //init time zone handling
//     tz.initializeTimeZones();
//     final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
//     tz.setLocalLocation(tz.getLocation(currentTimeZone));
//
//
//     //prepare android init settings
//     const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     //init settings
//     const initSettings = InitializationSettings(
//       android: initSettingsAndroid
//     );
//
//     //finally, initialize the plugin
//     await notificationsPlugin.initialize(initSettings);
//   }
//
//   //NOTIFICATION DETAILS SETUP
//   NotificationDetails notificationDetails(){
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//           'channelId',
//           'channelName',
//           channelDescription: 'Notification',
//           importance: Importance.max,
//           priority: Priority.high
//       )
//     );
//   }
//
//   //SHOW NOTIFICATION
//   Future<void> showNotification({
//     int id = 0,
//     String? title,
//     String? body,
//   }) async{
//     print('Notification shown');
//     return notificationsPlugin.show(id, title, body, notificationDetails());
// }
//
//   //scheduling a notification at a specified time
//   //hour(0-23)
//   //minute(0-59)
//
//   Future<void> scheduleNotification({
//     int id = 1,
//     required String title,
//     required String body,
//     required int hour,
//     required int minute
// }) async{
//     //get the current date time in the device's local timezone
//     final now = tz.TZDateTime.now(tz.local);
//
//     //create a date/time for today at the specified hour/min
//     var scheduledDate = tz.TZDateTime(
//         tz.local,
//         now.year,
//         now.month,
//         now.day,
//         hour,
//         minute
//     );
//
//     // If scheduled time has already passed for today, schedule it for tomorrow
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(Duration(days: 1));
//     }
//
//     //schedule the notification
//     await notificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         scheduledDate,
//         notificationDetails(),
//         //android specific, allow notification while it is in low power mode
//         androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       //make notification repeat at the same time daily
//         matchDateTimeComponents: DateTimeComponents.time,
//     );
//     print('Notification set');
//   }
//
//   //cancel all notifications
//   Future<void> cancelAllNotifications() async{
//     await notificationsPlugin.cancelAll();
//   }
//
//
// }



import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

// class NotificationService {
//   final notificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   bool _isInitialized = false;
//   bool get isInitialized => _isInitialized;
//
//   // Initialize notifications
//   Future<void> initNotification() async {
//     if (_isInitialized) return;
//
//     // Initialize time zone handling
//     tz.initializeTimeZones();
//     final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
//     tz.setLocalLocation(tz.getLocation(currentTimeZone));
//
//     // Prepare Android initialization settings
//     const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: initSettingsAndroid);
//
//     // Initialize the plugin
//     try {
//       await notificationsPlugin.initialize(initSettings);
//       _isInitialized = true;
//       print('Notification plugin initialized');
//     } catch (e) {
//       print('Error initializing notifications: $e');
//     }
//   }
//
//   // Check and request exact alarm permission (Android 12+)
//   Future<bool> requestExactAlarmPermission() async {
//     if (Platform.isAndroid) {
//       // Check if SCHEDULE_EXACT_ALARM permission is needed (Android 12+)
//       final status = await Permission.scheduleExactAlarm.status;
//       if (status.isDenied || status.isPermanentlyDenied) {
//         try {
//           // Open system settings to allow exact alarms
//           final intent = AndroidIntent(
//             action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
//             flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
//           );
//           await intent.launch();
//           // Re-check permission status after prompting
//           return await Permission.scheduleExactAlarm.isGranted;
//         } catch (e) {
//           print('Error requesting exact alarm permission: $e');
//           return false;
//         }
//       }
//       return status.isGranted;
//     }
//     return true; // Permission not needed for non-Android platforms
//   }
//
//   // Check and request battery optimization exemption
//   Future<bool> requestBatteryOptimizationExemption() async {
//     if (Platform.isAndroid) {
//       try {
//         final intent = AndroidIntent(
//           action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
//           data: 'package:com.example.recommender_nk', // Replace with your package name
//           flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
//         );
//         await intent.launch();
//         return true;
//       } catch (e) {
//         print('Error requesting battery optimization exemption: $e');
//         return false;
//       }
//     }
//     return true; // Not needed for non-Android platforms
//   }
//
//   // Notification details setup
//   NotificationDetails notificationDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'channelId',
//         'channelName',
//         channelDescription: 'Notification',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//     );
//   }
//
//   // Show immediate notification
//   Future<void> showNotification({
//     int id = 0,
//     String? title,
//     String? body,
//   }) async {
//     try {
//       print('Showing notification: $title');
//       await notificationsPlugin.show(id, title, body, notificationDetails());
//     } catch (e) {
//       print('Error showing notification: $e');
//     }
//   }
//
//   // Schedule notification
//   Future<void> scheduleNotification({
//     int id = 1,
//     required String title,
//     required String body,
//     required int hour,
//     required int minute,
//   }) async {
//     // Ensure notifications are initialized
//     await initNotification();
//
//     // Request exact alarm permission
//     if (!await requestExactAlarmPermission()) {
//       print('Exact alarm permission not granted');
//       return;
//     }
//
//     // Request battery optimization exemption
//     if (!await requestBatteryOptimizationExemption()) {
//       print('Battery optimization exemption not granted');
//     }
//
//     try {
//       final now = tz.TZDateTime.now(tz.local);
//       var scheduledDate = tz.TZDateTime(
//         tz.local,
//         now.year,
//         now.month,
//         now.day,
//         hour,
//         minute,
//       );
//
//       // If scheduled time has passed, schedule for tomorrow
//       if (scheduledDate.isBefore(now)) {
//         scheduledDate = scheduledDate.add(const Duration(days: 1));
//       }
//
//       await notificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         scheduledDate,
//         notificationDetails(),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         matchDateTimeComponents: DateTimeComponents.time,
//       );
//       print('Notification scheduled for $scheduledDate');
//     } catch (e) {
//       print('Error scheduling notification: $e');
//     }
//   }
//
//   // Cancel all notifications
//   Future<void> cancelAllNotifications() async {
//     try {
//       await notificationsPlugin.cancelAll();
//       print('All notifications cancelled');
//     } catch (e) {
//       print('Error cancelling notifications: $e');
//     }
//   }
// }

class ShowLocalNotification {
  ShowLocalNotification(){
    tz.initializeTimeZones();
  }
  //initialization
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void shownotificaton(String title, String body) async {
    var android = AndroidNotificationDetails('channel id', 'channel NAME',
        priority: Priority.high, importance: Importance.max);
    var platform = NotificationDetails(
      android: android,
    );
    await flutterLocalNotificationsPlugin.show(0, title, body, platform,
        payload: 'Welcome to the Local Notification demo ');
  }

  void scheduleNotification(String title, String body, int time) async {
    print("start");
    var android = AndroidNotificationDetails('channel id', 'channel NAME',
        priority: Priority.high, importance: Importance.max);
    var platform = NotificationDetails(
      android: android,
    );
    await ShowLocalNotification().flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: time)),
        platform,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
    );
    print("22222");
  }

}