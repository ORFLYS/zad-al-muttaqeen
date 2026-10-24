import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/shia_prayer_calculator.dart';
import 'location_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static const MethodChannel _nativeChannel = MethodChannel('com.huda.bag.hqepa/adhan_alarm');
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // يمكن التوجيه إلى شاشة معينة عند الضغط على التنبيه
      },
    );

    _isInitialized = true;
  }

  static Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  static Future<bool> requestNotificationPermission() async {
    await init();
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final bool? granted = await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
      return granted ?? true;
    }
    return true;
  }


  static Future<void> schedulePrayerNotifications({
    required ShiaCity city,
    required int minutesOffset,
    required bool notifyFajr,
    required bool notifyDhuhr,
    required bool notifyMaghrib,
    required String muezzinName, // e.g., 'shubbar'
  }) async {
    await init();
    
    // إلغاء كافة التنبيهات المجدولة السابقة لإعادة جدولتها بدقة
    await _notificationsPlugin.cancelAll();
    try {
      await _nativeChannel.invokeMethod('cancelAdhanAlarms');
    } catch (e) {
      debugPrint("Failed to cancel native adhan alarms: $e");
    }

    // إذا كانت كل التنبيهات معطلة، نكتفي بالإلغاء ونخرج
    if (!notifyFajr && !notifyDhuhr && !notifyMaghrib) return;

    // إعدادات القناة (Channel) للأندرويد التي تحدد الصوت
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'prayer_adhan_channel_v6_$muezzinName',
      'أذان الصلاة',
      channelDescription: 'تنبيهات أوقات الصلاة مع صوت الأذان',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentSound: true,
        sound: '$muezzinName.mp3', // تفعيل الصوت في iOS إذا كان الملف موجوداً
      ),
    );

    // جدولة التنبيهات للـ 30 يوماً القادمة
    DateTime now = DateTime.now();
    int notificationId = 0; // معرف متزايد لكل تنبيه
    List<int> nativeTimestamps = [];

    for (int i = 0; i < 30; i++) {
      DateTime targetDate = now.add(Duration(days: i));
      
      ShiaPrayerTimes times = ShiaPrayerCalculator.calculateTimes(
        date: targetDate,
        latitude: city.latitude,
        longitude: city.longitude,
        timezoneOffset: city.timezoneOffset,
        minutesOffset: minutesOffset,
      );

      if (notifyFajr) {
        await _scheduleAtTime(notificationId++, "صلاة الصبح", "حان الآن موعد أذان الفجر", times.fajr, platformDetails);
        if (times.fajr.isAfter(now)) {
          nativeTimestamps.add(times.fajr.millisecondsSinceEpoch);
        }
      }
      
      if (notifyDhuhr) {
        await _scheduleAtTime(notificationId++, "صلاة الظهر", "حان الآن موعد أذان الظهر", times.dhuhr, platformDetails);
        if (times.dhuhr.isAfter(now)) {
          nativeTimestamps.add(times.dhuhr.millisecondsSinceEpoch);
        }
      }
      
      if (notifyMaghrib) {
        await _scheduleAtTime(notificationId++, "صلاة المغرب", "حان الآن موعد أذان المغرب", times.maghrib, platformDetails);
        if (times.maghrib.isAfter(now)) {
          nativeTimestamps.add(times.maghrib.millisecondsSinceEpoch);
        }
      }
    }

    if (nativeTimestamps.isNotEmpty) {
      try {
        await _nativeChannel.invokeMethod('scheduleAdhanAlarms', {
          'timestamps': nativeTimestamps,
          'muezzinName': muezzinName,
        });
        debugPrint("Scheduled ${nativeTimestamps.length} native Adhan alarms successfully.");
      } catch (e) {
        debugPrint("Failed to schedule native Adhan alarms: $e");
      }
    }
  }

  static Future<void> _scheduleAtTime(
    int id,
    String title,
    String body,
    DateTime time,
    NotificationDetails details,
  ) async {
    if (time.isBefore(DateTime.now())) return; // لا نجدول تنبيهات ماضية

    try {
      // المحاولة الأولى: استخدام الجدولة الدقيقة (Exact)
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(time.toUtc(), tz.UTC),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint("Exact schedule failed for id $id ($e). Attempting inexact fallback...");
      try {
        // المحاولة الثانية (Fallback): الجدولة غير الدقيقة (Inexact) في حال حظر صلاحية exact alarm
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(time.toUtc(), tz.UTC),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        debugPrint("Inexact fallback succeeded for id: $id");
      } catch (fallbackError) {
        debugPrint("Inexact fallback also failed for id $id: $fallbackError");
      }
    }
  }
}


