import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Owns platform notification setup and scheduling. Game rules stay in PetNotifier.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _reminderId = 101;
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    tz_data.initializeTimeZones();
    try {
      final localTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone.identifier));
    } catch (_) {
      // UTC is a safe fallback if the operating system does not expose its zone.
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    await _requestPermission();
    _initialized = true;
  }

  Future<void> _requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleCareReminder({
    required Duration delay,
    required bool hungry,
    required String petName,
  }) async {
    await initialize();
    if (kIsWeb) return;
    await cancelCareReminder();
    await _plugin.zonedSchedule(
      id: _reminderId,
      title: 'Pocket Pals',
      body: hungry ? '$petName is hungry! 🌾' : '$petName misses you!',
      scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'capy_pal_care',
          'Companion care reminders',
          channelDescription: 'Gentle reminders to check in on your companion.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelCareReminder() async {
    if (kIsWeb) return;
    await _plugin.cancel(id: _reminderId);
  }
}
