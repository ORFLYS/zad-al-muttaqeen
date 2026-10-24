// views/qibla_view.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';

class QiblaView extends StatefulWidget {
  const QiblaView({super.key});

  @override
  State<QiblaView> createState() => _QiblaViewState();
}

class _QiblaViewState extends State<QiblaView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  // Location-related state variables
  bool _isGpsEnabled = false;
  LocationPermission _permission = LocationPermission.denied;
  Position? _currentPosition;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;

  // Compass-related state variables
  StreamSubscription<CompassEvent>? _compassSubscription;
  double? _direction;
  double _smoothDirection = 0.0;
  double _filterX = 0.0;
  double _filterY = 0.0;
  static const double _filterAlpha = 0.12; // smoothing factor (0.0 to 1.0)
  bool _compassLoading = true;
  bool _compassHasError = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _initLocation();
    _initCompass();
  }

  void _initLocation() async {
    try {
      _isGpsEnabled = await Geolocator.isLocationServiceEnabled();
      _permission = await Geolocator.checkPermission();
      
      if (_permission == LocationPermission.denied) {
        _permission = await Geolocator.requestPermission();
      }
      
      if (_isGpsEnabled && (_permission == LocationPermission.always || _permission == LocationPermission.whileInUse)) {
        _updatePosition();
      }
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error initializing location: $e");
    }

    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      bool enabled = status == ServiceStatus.enabled;
      if (enabled != _isGpsEnabled) {
        _isGpsEnabled = enabled;
        if (_isGpsEnabled) {
          _updatePosition();
        } else {
          setState(() {
            _currentPosition = null;
          });
        }
        if (mounted) setState(() {});
      }
    });
  }

  void _updatePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      debugPrint("Error getting position: $e");
    }
  }

  void _initCompass() {
    final stream = FlutterCompass.events;
    if (stream == null) {
      setState(() {
        _compassLoading = false;
        _direction = null;
      });
      return;
    }

    _compassSubscription = stream.listen(
      (CompassEvent event) {
        final heading = event.heading;
        if (heading != null) {
          double headingRad = heading * (math.pi / 180.0);
          double nextX = math.cos(headingRad);
          double nextY = math.sin(headingRad);
          
          if (_filterX == 0.0 && _filterY == 0.0) {
            _filterX = nextX;
            _filterY = nextY;
          } else {
            _filterX = _filterX + _filterAlpha * (nextX - _filterX);
            _filterY = _filterY + _filterAlpha * (nextY - _filterY);
          }
          
          double smoothHeadingRad = math.atan2(_filterY, _filterX);
          double smoothHeadingDeg = smoothHeadingRad * (180.0 / math.pi);
          
          if (mounted) {
            setState(() {
              _compassLoading = false;
              _direction = heading;
              _smoothDirection = (smoothHeadingDeg + 360.0) % 360.0;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _compassLoading = false;
              _direction = null;
            });
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _compassLoading = false;
            _compassHasError = true;
            _direction = null;
          });
        }
      },
    );

    // Timeout fallback for devices/emulators without working compass sensors
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _compassLoading) {
        setState(() {
          _compassLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _serviceStatusSubscription?.cancel();
    _compassSubscription?.cancel();
    super.dispose();
  }

  double _calculateQiblaDirection(double lat, double lng) {
    const double latKaaba = 21.4225 * math.pi / 180.0;
    const double lngKaaba = 39.8262 * math.pi / 180.0;

    double latUser = lat * math.pi / 180.0;
    double lngUser = lng * math.pi / 180.0;

    double dLng = lngKaaba - lngUser;

    double y = math.sin(dLng);
    double x = math.cos(latUser) * math.tan(latKaaba) - math.sin(latUser) * math.cos(dLng);

    double qiblaRad = math.atan2(y, x);
    double qiblaDeg = qiblaRad * 180.0 / math.pi;

    return (qiblaDeg + 360.0) % 360.0;
  }

  Widget _buildGpsBanner() {
    if (_isGpsEnabled && (_permission == LocationPermission.always || _permission == LocationPermission.whileInUse)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // خلفية داكنة تناسب التصميم
        border: Border.all(color: const Color(0xFFC5A880).withValues(alpha: 0.3)), // إطار ذهبي خفيف
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "يرجى تشغيل الموقع من اجل قراءة ادق",
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final city = provider.selectedCity;

    final double userLat = _currentPosition?.latitude ?? city.latitude;
    final double userLng = _currentPosition?.longitude ?? city.longitude;
    final bool isUsingLiveGps = _currentPosition != null;

    double qiblaAngleFromNorth = _calculateQiblaDirection(userLat, userLng);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            "بوصلة القبلة",
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF1E293B),
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            // بطاقة الموقع الحالية والإحداثيات
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUsingLiveGps ? "موقعك الدقيق (جي بي إس)" : "الموقع المحدد",
                            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11),
                          ),
                          Text(
                            isUsingLiveGps ? "موقعك الحالي" : city.name,
                            style: GoogleFonts.cairo(
                              color: const Color(0xFFC5A880),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "اتجاه القبلة",
                            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11),
                          ),
                          Text(
                            "${qiblaAngleFromNorth.toStringAsFixed(1)}° من الشمال",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.white54, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "إحداثياتك:  ${userLat.toStringAsFixed(4)}° N, ${userLng.toStringAsFixed(4)}° E",
                        style: GoogleFonts.orbitron(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // تنبيه تشغيل الـ GPS
            _buildGpsBanner(),

            const Spacer(),

            // البوصلة التفاعلية أو الفولباك
            Builder(
              builder: (context) {
                if (_compassLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8A1525)),
                  );
                }

                if (_compassHasError) {
                  return _buildManualCompassFallback(qiblaAngleFromNorth, "خطأ في تشغيل المستشعر، تم تشغيل الوضع التقديري");
                }

                double? direction = _direction;

                if (direction == null) {
                  return _buildManualCompassFallback(qiblaAngleFromNorth, "مستشعر البوصلة غير متوفر على جهازك، نعرض بوصلة تقديرية");
                }

                // حساب زوايا دوران البوصلة والقبلة (باستخدام القيم المنعمة)
                double compassRotation = -_smoothDirection * (math.pi / 180.0);
                double qiblaRotation = (qiblaAngleFromNorth - _smoothDirection) * (math.pi / 180.0);

                // التحقق من المحاذاة (+/- 6 درجات) باستخدام القيمة المنعمة
                bool isAligned = (_smoothDirection - qiblaAngleFromNorth).abs() < 6.0 ||
                    (360.0 - (_smoothDirection - qiblaAngleFromNorth).abs()) < 6.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCompassUI(compassRotation, qiblaRotation, isAligned),
                    const SizedBox(height: 40),
                    _buildGuidanceWidget(isAligned, false),
                  ],
                );
              },
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  // بناء هيكل البوصلة وتصميمها الفخم
  Widget _buildCompassUI(double compassRad, double qiblaRad, bool isAligned) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        double glowRadius = 8.0 + (_pulseController.value * 12.0);
        return Container(
          width: 290,
          height: 290,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E293B), // خلفية البوصلة الداكنة الفخمة
            border: Border.all(
              color: isAligned ? const Color(0xFF10B981) : const Color(0xFFC5A880),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (isAligned ? const Color(0xFF10B981) : const Color(0xFFC5A880))
                    .withValues(alpha: isAligned ? 0.35 : 0.15),
                blurRadius: glowRadius,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. قرص الدرجات والاتجاهات (يدور مع حركة الهاتف)
              Transform.rotate(
                angle: compassRad,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // درع البوصلة المدرج
                    _buildCompassTicks(),
                    
                    // علامات الاتجاهات الأربعة الرئيسية
                    Positioned(
                      top: 24,
                      child: Text(
                        "ش",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFEF4444), // الشمال بالأحمر
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      child: Text(
                        "ج",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 24,
                      child: Text(
                        "ق",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      child: Text(
                        "غ",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. سهم الكعبة ومؤشر القبلة الذهبي (يتجه نحو القبلة بشكل مستقل)
              Transform.rotate(
                angle: qiblaRad,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // الإبرة أو المسار المؤدي للكعبة
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        // أيقونة الكعبة المتألقة بالأعلى
                        Icon(
                          Icons.mosque,
                          color: isAligned ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          size: 36,
                        ),
                        const SizedBox(height: 2),
                        Icon(
                          Icons.keyboard_double_arrow_up,
                          color: isAligned ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          size: 28,
                        ),
                        // امتداد خط التوجيه
                        Container(
                          width: 2.5,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                isAligned ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. مركز البوصلة الذهبي أو الأخضر المضيء
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isAligned ? const Color(0xFF10B981) : const Color(0xFFC5A880),
                  border: Border.all(color: const Color(0xFF1E293B), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // رسم علامات تدريج البوصلة الدائرية (Compass Ticks) لتبدو حقيقية ومصممة بدقة
  Widget _buildCompassTicks() {
    return Stack(
      children: List.generate(12, (index) {
        final angle = index * 30.0 * (math.pi / 180.0);
        final isMajor = index % 3 == 0; // علامات رئيسية عند 0، 90، 180، 270

        return Transform.rotate(
          angle: angle,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: isMajor ? 3 : 1.5,
              height: isMajor ? 12 : 7,
              decoration: BoxDecoration(
                color: isMajor ? const Color(0xFFC5A880) : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }

  // بطاقة الإرشاد التفاعلية السفلي
  Widget _buildGuidanceWidget(bool isAligned, bool isFallback) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFallback 
              ? const Color(0xFFFEF3C7) // لونه كهرماني خفيف للتحذير
              : (isAligned ? const Color(0xFFECFDF5) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFallback
                ? const Color(0xFFFCD34D)
                : (isAligned ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isFallback
                  ? const Color(0xFFF59E0B)
                  : (isAligned ? const Color(0xFF10B981) : const Color(0xFF64748B)),
              child: Icon(
                isFallback
                    ? Icons.sensors_off_outlined
                    : (isAligned ? Icons.check : Icons.sync_problem_outlined),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFallback
                        ? "البوصلة التقديرية نشطة"
                        : (isAligned ? "تم التوجيه بنجاح" : "تعديل اتجاه الهاتف"),
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isFallback
                          ? const Color(0xFF92400E)
                          : (isAligned ? const Color(0xFF065F46) : const Color(0xFF1E293B)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isFallback
                        ? "قم بمحاذاة السهم الذهبي مع العلامة الحمراء يدوياً لمعرفة القبلة التقريبية."
                        : (isAligned
                            ? "الهاتف موجه الآن بشكل صحيح تماماً نحو الكعبة المشرفة."
                            : "قم بتدوير الهاتف يميناً أو يساراً حتى يتطابق السهم الذهبي مع الأعلى."),
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: isFallback
                          ? const Color(0xFFB45309)
                          : (isAligned ? const Color(0xFF047857) : const Color(0xFF64748B)),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // واجهة البوصلة اليدوية عند عدم توفر المستشعر (المحاكيات أو الويب)
  Widget _buildManualCompassFallback(double qiblaAngle, String message) {
    double compassRad = 0.0;
    double qiblaRad = qiblaAngle * (math.pi / 180.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCompassUI(compassRad, qiblaRad, false),
        const SizedBox(height: 30),
        _buildGuidanceWidget(false, true),
        const SizedBox(height: 16),
        // رسالة التنبيه الخاصة بنوع الجهاز
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }
}




