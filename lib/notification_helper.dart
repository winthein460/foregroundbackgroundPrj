import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationHelper {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static initialize() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static show(int progress) async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'download_channel',
        'Download Channel',
        channelDescription: 'Shows download progress',
        importance: Importance.low,
        priority: Priority.low,
        onlyAlertOnce: true,
        showProgress: true,
        maxProgress: 100,
        progress: progress,
        ongoing: true
      ),
    );
    await flutterLocalNotificationsPlugin.show(
      11,
      "Title",
      'Downloading....$progress%',
      notificationDetails,
    );
  }
  static showMessage() async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'message_channel',
        'Message Channel',
        channelDescription: 'Mingalar pr tawthar myar',
        importance: Importance.high,
        priority: Priority.high,
        onlyAlertOnce: true,
        fullScreenIntent: true
      ),
    );
    await flutterLocalNotificationsPlugin.show(
      12,
      "Message",
      'Mingalar pr tawthar myar',
      notificationDetails,
    );
  }
}
