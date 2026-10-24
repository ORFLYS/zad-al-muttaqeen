// services/location_service.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

enum LocationResult {
  success,
  serviceDisabled,
  permissionDenied,
  error,
}

class ShiaCity {
  final String name;
  final double latitude;
  final double longitude;
  final double timezoneOffset;

  ShiaCity({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timezoneOffset,
  });
}

class ShiaCountry {
  final String name;
  final String flagEmoji;
  final List<ShiaCity> cities;

  ShiaCountry({
    required this.name,
    required this.flagEmoji,
    required this.cities,
  });
}

class LocationService {
  // موقع افتراضي متميز (كربلاء المقدسة كخيار افتراضي روحي رائع)
  static final ShiaCity defaultCity = ShiaCity(
    name: "كربلاء المقدسة، العراق",
    latitude: 32.6160,
    longitude: 44.0250,
    timezoneOffset: 3.0,
  );

  // قائمة الدول في غرب آسيا ومحافظاتها/مدنها لدعم التصفح الهرمي التفاعلي
  static final List<ShiaCountry> countries = [
    ShiaCountry(
      name: "العراق",
      flagEmoji: "🇮🇶",
      cities: [
        ShiaCity(name: "بغداد، العراق", latitude: 33.3152, longitude: 44.3661, timezoneOffset: 3.0),
        ShiaCity(name: "كربلاء المقدسة، العراق", latitude: 32.6160, longitude: 44.0250, timezoneOffset: 3.0),
        ShiaCity(name: "النجف الأشرف، العراق", latitude: 32.0250, longitude: 44.3480, timezoneOffset: 3.0),
        ShiaCity(name: "البصرة، العراق", latitude: 30.5081, longitude: 47.7835, timezoneOffset: 3.0),
        ShiaCity(name: "بابل (الحلة)، العراق", latitude: 32.4833, longitude: 44.4333, timezoneOffset: 3.0),
        ShiaCity(name: "ذي قار (الناصرية)، العراق", latitude: 31.0579, longitude: 46.2573, timezoneOffset: 3.0),
        ShiaCity(name: "ميسان (العمارة)، العراق", latitude: 31.8386, longitude: 47.1451, timezoneOffset: 3.0),
        ShiaCity(name: "القادسية (الديوانية)، العراق", latitude: 31.9904, longitude: 44.9252, timezoneOffset: 3.0),
        ShiaCity(name: "المثنى (السماوة)، العراق", latitude: 31.3314, longitude: 45.2944, timezoneOffset: 3.0),
        ShiaCity(name: "واسط (الكوت)، العراق", latitude: 32.5020, longitude: 45.8177, timezoneOffset: 3.0),
        ShiaCity(name: "ديالى (بعقوبة)، العراق", latitude: 33.7431, longitude: 44.6464, timezoneOffset: 3.0),
        ShiaCity(name: "صلاح الدين (تكريت)، العراق", latitude: 34.6074, longitude: 43.6781, timezoneOffset: 3.0),
        ShiaCity(name: "الأنبار (الرمادي)، العراق", latitude: 33.4308, longitude: 43.3012, timezoneOffset: 3.0),
        ShiaCity(name: "نينوى (الموصل)، العراق", latitude: 36.3489, longitude: 43.1577, timezoneOffset: 3.0),
        ShiaCity(name: "كركوك، العراق", latitude: 35.4681, longitude: 44.3922, timezoneOffset: 3.0),
        ShiaCity(name: "أربيل، العراق", latitude: 36.1911, longitude: 44.0092, timezoneOffset: 3.0),
        ShiaCity(name: "السليمانية، العراق", latitude: 35.5612, longitude: 45.4374, timezoneOffset: 3.0),
        ShiaCity(name: "دهوك، العراق", latitude: 36.8679, longitude: 42.9961, timezoneOffset: 3.0),
      ],
    ),
    ShiaCountry(
      name: "إيران",
      flagEmoji: "🇮🇷",
      cities: [
        ShiaCity(name: "مشهد المقدسة، إيران", latitude: 36.2972, longitude: 59.6067, timezoneOffset: 3.5),
        ShiaCity(name: "قم المقدسة، إيران", latitude: 34.6416, longitude: 50.8746, timezoneOffset: 3.5),
        ShiaCity(name: "طهران، إيران", latitude: 35.6892, longitude: 51.3890, timezoneOffset: 3.5),
        ShiaCity(name: "أصفهان، إيران", latitude: 32.6546, longitude: 51.6680, timezoneOffset: 3.5),
        ShiaCity(name: "شيراز، إيران", latitude: 29.5918, longitude: 52.5837, timezoneOffset: 3.5),
      ],
    ),
    ShiaCountry(
      name: "السعودية",
      flagEmoji: "🇸🇦",
      cities: [
        ShiaCity(name: "المدينة المنورة، الحجاز", latitude: 24.4672, longitude: 39.6111, timezoneOffset: 3.0),
        ShiaCity(name: "القطيف، السعودية", latitude: 26.5208, longitude: 49.9981, timezoneOffset: 3.0),
        ShiaCity(name: "الأحساء (الهفوف)، السعودية", latitude: 25.3644, longitude: 49.5883, timezoneOffset: 3.0),
        ShiaCity(name: "مكة المكرمة، السعودية", latitude: 21.3891, longitude: 39.8579, timezoneOffset: 3.0),
        ShiaCity(name: "الرياض، السعودية", latitude: 24.7136, longitude: 46.6753, timezoneOffset: 3.0),
        ShiaCity(name: "الدمام، السعودية", latitude: 26.4207, longitude: 50.0888, timezoneOffset: 3.0),
      ],
    ),
    ShiaCountry(
      name: "لبنان",
      flagEmoji: "🇱🇧",
      cities: [
        ShiaCity(name: "بيروت، لبنان", latitude: 33.8938, longitude: 35.5018, timezoneOffset: 3.0),
        ShiaCity(name: "صيدا، لبنان", latitude: 33.5631, longitude: 35.3689, timezoneOffset: 3.0),
        ShiaCity(name: "صور، لبنان", latitude: 33.2708, longitude: 35.1964, timezoneOffset: 3.0),
        ShiaCity(name: "بعلبك، لبنان", latitude: 34.0058, longitude: 36.2064, timezoneOffset: 3.0),
        ShiaCity(name: "النبطية، لبنان", latitude: 33.3789, longitude: 35.4839, timezoneOffset: 3.0),
      ],
    ),
    ShiaCountry(
      name: "البحرين",
      flagEmoji: "🇧🇭",
      cities: [
        ShiaCity(name: "المنامة، البحرين", latitude: 26.2285, longitude: 50.5860, timezoneOffset: 3.0),
        ShiaCity(name: "سترة، البحرين", latitude: 26.1547, longitude: 50.6053, timezoneOffset: 3.0),
        ShiaCity(name: "المحرق، البحرين", latitude: 26.2572, longitude: 50.6119, timezoneOffset: 3.0),
      ],
    ),
    ShiaCountry(
      name: "سوريا",
      flagEmoji: "🇸🇾",
      cities: [
        ShiaCity(name: "السيدة زينب (ع)، دمشق", latitude: 33.4444, longitude: 36.3408, timezoneOffset: 3.0),
        ShiaCity(name: "حلب، سوريا", latitude: 36.2021, longitude: 37.1343, timezoneOffset: 3.0),
        ShiaCity(name: "حمص، سوريا", latitude: 34.7324, longitude: 36.7137, timezoneOffset: 3.0),
        ShiaCity(name: "اللاذقية، سوريا", latitude: 35.5188, longitude: 35.7901, timezoneOffset: 3.0),
      ],
    ),
    ShiaCountry(
      name: "الكويت",
      flagEmoji: "🇰🇼",
      cities: [
        ShiaCity(name: "مدينة الكويت، الكويت", latitude: 29.3759, longitude: 47.9774, timezoneOffset: 3.0),
        ShiaCity(name: "السالمية، الكويت", latitude: 29.3315, longitude: 48.0772, timezoneOffset: 3.0),
      ],
    ),
    ShiaCountry(
      name: "الإمارات",
      flagEmoji: "🇦🇪",
      cities: [
        ShiaCity(name: "أبوظبي، الإمارات", latitude: 24.4539, longitude: 54.3773, timezoneOffset: 4.0),
        ShiaCity(name: "دبي، الإمارات", latitude: 25.2048, longitude: 55.2708, timezoneOffset: 4.0),
        ShiaCity(name: "الشارقة، الإمارات", latitude: 25.3463, longitude: 55.4209, timezoneOffset: 4.0),
      ],
    ),
    ShiaCountry(
      name: "عمان",
      flagEmoji: "🇴🇲",
      cities: [
        ShiaCity(name: "مسقط، عمان", latitude: 23.5859, longitude: 58.4059, timezoneOffset: 4.0),
        ShiaCity(name: "صلالة، عمان", latitude: 17.0151, longitude: 54.0924, timezoneOffset: 4.0),
        ShiaCity(name: "مطرح، عمان", latitude: 23.6213, longitude: 58.5658, timezoneOffset: 4.0),
      ],
    ),
    ShiaCountry(
      name: "قطر",
      flagEmoji: "🇶🇦",
      cities: [
        ShiaCity(name: "الدوحة، قطر", latitude: 25.2854, longitude: 51.5310, timezoneOffset: 3.0),
      ],
    ),
    ShiaCountry(
      name: "اليمن",
      flagEmoji: "🇾🇪",
      cities: [
        ShiaCity(name: "صنعاء، اليمن", latitude: 15.3694, longitude: 44.1910, timezoneOffset: 3.0),
        ShiaCity(name: "عدن، اليمن", latitude: 12.7855, longitude: 45.0186, timezoneOffset: 3.0),
      ],
    ),
    ShiaCountry(
      name: "الأردن",
      flagEmoji: "🇯🇴",
      cities: [
        ShiaCity(name: "عمان، الأردن", latitude: 31.9522, longitude: 35.9101, timezoneOffset: 3.0),
      ],
    ),
  ];

  // توليد قائمة مسطحة من جميع المدن تلقائياً لضمان التوافقية بنسبة 100% مع البنية القديمة
  static final List<ShiaCity> shiaCities = countries.expand((country) => country.cities).toList();

  /// دالة للحصول على إحداثيات GPS الحالية للمستخدم
  /// وإرجاع إحداثيات المدينة الافتراضية في حال رفض الأذونات
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق من تفعيل خدمة الموقع بالهاتف
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // جلب الموقع الحالي بدقة متوسطة لسرعة الاستجابة وتوفير طاقة الهاتف
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// الحصول على اسم المكان (المدينة والدولة) بالاعتماد على الإحداثيات
  static Future<String> getPlaceNameFromCoordinates(double latitude, double longitude) async {
    // 1. محاولة استخدام Geocoding الرسمي للحصول على اسم المكان بدقة باللغة العربية
    try {
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
        locale: const Locale('ar'),
      ).timeout(const Duration(seconds: 3));
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String city = place.locality?.isNotEmpty == true
            ? place.locality!
            : (place.subAdministrativeArea?.isNotEmpty == true
                ? place.subAdministrativeArea!
                : (place.administrativeArea?.isNotEmpty == true
                    ? place.administrativeArea!
                    : ''));
        String country = place.country ?? '';

        // تنظيف التسمية لتبدو طبيعية وجميلة
        city = city.replaceAll("محافظة ", "").trim();

        if (city.isNotEmpty && country.isNotEmpty) {
          return "$city، $country";
        } else if (city.isNotEmpty) {
          return city;
        } else if (country.isNotEmpty) {
          return country;
        }
      }
    } catch (_) {
      // في حال عدم وجود إنترنت أو تعذر خدمة Geocoder
    }

    // 2. البحث بدون إنترنت (Offline) عن أقرب مدينة معروفة في قاعدة بيانات التطبيق
    try {
      ShiaCity? closestCity;
      double minDistance = double.infinity;

      for (final city in shiaCities) {
        final distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          city.latitude,
          city.longitude,
        );
        if (distance < minDistance) {
          minDistance = distance;
          closestCity = city;
        }
      }

      // إذا كانت أقرب مدينة تبعد أقل من 80 كم (نطاق المحافظة/المدينة)
      if (closestCity != null && minDistance <= 80000) {
        return closestCity.name;
      }
    } catch (_) {}

    return "موقعك الحالي (GPS)";
  }

  /// نافذة منبثقة في وسط الشاشة لتنبيه المستخدم بتفعيل الـ GPS
  static void showGpsDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_off_rounded, color: Color(0xFF8A1525), size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "يرجى تفعيل الـ GPS",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "خدمة تحديد الموقع (GPS) غير مفعلة على هاتفك. يرجى تفعيلها لضبط مواقيت الصلاة والقبلة تلقائياً بحسب منطقتك.",
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                "إلغاء",
                style: GoogleFonts.cairo(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A1525),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Geolocator.openLocationSettings();
              },
              child: Text(
                "تفعيل الـ GPS",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// نافذة منبثقة لطلب إذن الموقع في حال تم رفضه
  static void showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security_rounded, color: Color(0xFF8A1525), size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "إذن الموقع مطلوب",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "يحتاج التطبيق إلى إذن الوصول للموقع ليتمكن من حساب أوقات الصلاة والقبلة تلقائياً بحسب مكان تواجدك.",
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                "إلغاء",
                style: GoogleFonts.cairo(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A1525),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Geolocator.openAppSettings();
              },
              child: Text(
                "منح الإذن",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
