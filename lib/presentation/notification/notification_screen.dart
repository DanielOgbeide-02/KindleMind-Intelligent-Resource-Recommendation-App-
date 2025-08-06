import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  final Map<String, dynamic>? notificationData;

  const NotificationsScreen({Key? key, this.notificationData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sampleNotifications = [
      {
        'title': 'Mindful Break',
        'body': 'Take a 5-minute break and try a breathing exercise.',
        'time': '8:00 AM',
      },
      {
        'title': 'Resource Reminder',
        'body': 'Check out today’s article on emotional resilience.',
        'time': '12:00 PM',
      },
      {
        'title': 'Daily Check-in',
        'body': 'Don’t forget to log your mood and journal your thoughts.',
        'time': '6:00 PM',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: Colors.white),),
        backgroundColor: AppTheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            if (notificationData != null) ...[
              Text(
                'Notification Data:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  notificationData.toString(),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: sampleNotifications.length,
                itemBuilder: (context, index) {
                  final notification = sampleNotifications[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.notifications, color: AppTheme.primary),
                      title: Text(notification['title']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification['body']!),
                          const SizedBox(height: 4),
                          Text(
                            'Sent at ${notification['time']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
