import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize native android notification
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/launcher_icon');

    // Initialize native Ios Notifications
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static void showNotificationAndroid(String title, String value) async {
    /* AndroidNotificationDetails and = AndroidNotificationDetails(
      'sample_vehicle',
      'Vehicle Parking Time Remaining',
      channelDescription: 'Notify the user that vehicle\'s time of booking...',
      importance: Importance.max,
      priority: Priority.max,
      channelShowBadge: false,
      ticker: 'sample_vehicle',
      color: Colors.blue,
      onlyAlertOnce: true,
      when: whenTimer.millisecondsSinceEpoch,
      timeoutAfter: whenTimer.difference(DateTime.now()).inMilliseconds,
      usesChronometer: true,
      chronometerCountDown: true,
      visibility: NotificationVisibility.public,
      ongoing: true,
    ); */
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'timer_channel',
      'Timer',
      channelDescription: 'Channel Description',
      //styleInformation: BigTextStyleInformation(title),
      importance: Importance.max,
      priority: Priority.max,
      showProgress: true,
      onlyAlertOnce: true,
      showWhen: true,
      //sound: null,
      silent: false,
      //playSound: false,
      //enableVibration: false,
      //color: Colors.green,
      ticker: 'ticker',
      ongoing: true,
      visibility: NotificationVisibility.public,
      usesChronometer: true,
      //ongoing: true,
      //chronometerCountDown: true,
    );

    int notification_id = -1;
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        notification_id, title, value, notificationDetails,
        payload: 'Not present');
  }

  static Future<bool> checkAndroidPermissionGranted() async {
    bool granted = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;

    if (!granted) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();

      granted = grantedNotificationPermission ?? false;
    }

    return granted;
  }
}
