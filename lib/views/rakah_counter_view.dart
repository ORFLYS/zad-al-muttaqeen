import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'dart:async';

class RakahCounterView extends StatefulWidget {
  const RakahCounterView({super.key});

  @override
  State<RakahCounterView> createState() => _RakahCounterViewState();
}

class _RakahCounterViewState extends State<RakahCounterView> {
  final List<Map<String, dynamic>> prayerTypes = [
    {"name": "الصبح", "rakahs": 2},
    {"name": "الظهر", "rakahs": 4},
    {"name": "العصر", "rakahs": 4},
    {"name": "المغرب", "rakahs": 3},
    {"name": "العشاء", "rakahs": 4},
    {"name": "صلاة نافلة", "rakahs": 2},
    {"name": "مفتوح (حُر)", "rakahs": 99},
  ];

  int selectedPrayerIndex = 0;
  int currentRakah = 1;
  int currentSajdah = 0; // 0 = لم يسجد بعد، 1 = السجدة الأولى، 2 = السجدة الثانية
  bool isCompleted = false;
  bool _showTapFlash = false; 

  late StreamSubscription<int> _proximitySubscription;
  bool _isNear = false;

  @override
  void initState() {
    super.initState();
    _listenSensor();
  }

  void _listenSensor() {
    _proximitySubscription = ProximitySensor.events.listen((int event) {
      final bool isNear = (event > 0);
      if (isNear && !_isNear) {
        _handleSajdahTap();
      }
      _isNear = isNear;
    });
  }

  @override
  void dispose() {
    _proximitySubscription.cancel();
    super.dispose();
  }

  void _handleSajdahTap() {
    if (isCompleted) return;

    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);

    setState(() {
      _showTapFlash = true;
      if (currentSajdah == 0) {
        currentSajdah = 1;
      } else if (currentSajdah == 1) {
        currentSajdah = 2;
        final maxRakahs = prayerTypes[selectedPrayerIndex]["rakahs"] as int;
        if (currentRakah >= maxRakahs) {
          isCompleted = true;
        }
      } else {
        currentRakah++;
        currentSajdah = 1;
      }
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _showTapFlash = false;
        });
      }
    });
  }

  void _resetCounter() {
    setState(() {
      currentRakah = 1;
      currentSajdah = 0;
      isCompleted = false;
      _showTapFlash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activePrayer = prayerTypes[selectedPrayerIndex];
    final maxRakahs = activePrayer["rakahs"] as int;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _showTapFlash ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "عداد الركعات والسجدات",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
        body: SafeArea(
          child: Column(
            children: [
              // 1. شريط الصلوات
              Container(
                height: 65,
                color: const Color(0xFF1E293B),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: prayerTypes.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedPrayerIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPrayerIndex = index;
                          _resetCounter();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF8A1525) : const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: const Color(0xFF8A1525).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ] : null,
                        ),
                        child: Center(
                          child: Text(
                            prayerTypes[index]["name"],
                            style: GoogleFonts.cairo(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. باقي شاشة العداد
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // الإرشادات (بطاقة واضحة وكتابة ناصعة)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF334155), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.info_outline, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "ضع الهاتف على موضع السجود، وسيقوم الحساس بحساب الركعات والسجدات تلقائياً عند اقترابك.",
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.6,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // العداد الرئيسي المربع 
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: isCompleted
                                ? const Color(0xFF10B981) // أخضر اكتمال
                                : (currentSajdah == 0
                                    ? const Color(0xFF334155)
                                    : const Color(0xFF8A1525)),
                            width: 4, 
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: (isCompleted
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF8A1525))
                                  .withValues(alpha: _showTapFlash ? 0.3 : 0.05),
                              blurRadius: 40,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isCompleted) ...[
                              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 80),
                              const SizedBox(height: 16),
                              Text(
                                "اكتملت الصلاة",
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "بتقبل الله طاعاتكم",
                                style: GoogleFonts.cairo(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ] else ...[
                              Text(
                                "الركعة الحالية",
                                style: GoogleFonts.cairo(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$currentRakah",
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 90,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                              if (maxRakahs != 99) ...[
                                const SizedBox(height: 8),
                                Text(
                                  "من أصل $maxRakahs ركعات",
                                  style: GoogleFonts.cairo(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              // حالة السجدة الحالية (داخل المربع)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: currentSajdah == 0
                                      ? const Color(0xFF334155)
                                      : (currentSajdah == 1
                                          ? const Color(0xFF8A1525)
                                          : const Color(0xFFD97706)),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: currentSajdah != 0 ? [
                                    BoxShadow(
                                      color: (currentSajdah == 1 ? const Color(0xFF8A1525) : const Color(0xFFD97706)).withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ] : null,
                                ),
                                child: Text(
                                  currentSajdah == 0
                                      ? "بانتظار السجدة الأولى"
                                      : (currentSajdah == 1 ? "السجدة الأولى" : "السجدة الثانية"),
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // شريط الحساس قيد العمل
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sensors, color: Color(0xFF10B981), size: 24),
                            const SizedBox(width: 12),
                            Text(
                              "الحساس قيد العمل تلقائياً...",
                              style: GoogleFonts.cairo(
                                color: const Color(0xFF10B981),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // أزرار التحكم السفلية (إعادة التصفير)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF334155),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _resetCounter,
                          icon: const Icon(Icons.refresh, size: 22),
                          label: Text(
                            "إعادة البدء والتصفير",
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


