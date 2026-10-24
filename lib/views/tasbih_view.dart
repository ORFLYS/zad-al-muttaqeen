// views/tasbih_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';

class TasbihView extends StatefulWidget {
  const TasbihView({super.key});

  @override
  State<TasbihView> createState() => _TasbihViewState();
}

class _TasbihViewState extends State<TasbihView> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController?.forward();
  }

  void _onTapUp(TapUpDetails details, AppProvider provider) {
    _animationController?.reverse();
    provider.incrementTasbih();
  }

  void _onTapCancel() {
    _animationController?.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // تفاصيل تسبيح الزهراء
    final isZahra = provider.isTasbihZahraMode;
    final count = provider.tasbihCount;
    final target = isZahra ? provider.currentZahraTarget : 100;
    final progress = target > 0 ? (count / target).clamp(0.0, 1.0) : 0.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            "السبحة الإلكترونية",
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
        body: Column(
          children: [
            // بطاقة التحكم العلوية الشبيهة بقائمة القبلة
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "اذكر الله يطمئن قلبك وتسبيح الصديقة الزهراء (ع)",
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // اختيار وضع التسبيح (أزرار التبديل)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => provider.setTasbihZahraMode(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isZahra
                                    ? const Color(0xFF10B981)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "تسبيح الزهراء (ع)",
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isZahra ? Colors.white : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => provider.setTasbihZahraMode(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isZahra
                                    ? const Color(0xFF10B981)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "تسبيح حر",
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: !isZahra ? Colors.white : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // لوحة العرض والضغط الدائرية الفخمة
            GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: (details) => _onTapUp(details, provider),
              onTapCancel: _onTapCancel,
              child: AnimatedBuilder(
                animation: _scaleAnimation!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation!.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // حلقة التقدم الخارجية المتوهجة
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: const Color(0xFFE2E8F0),
                            color: const Color(0xFF1E293B), // متناسق مع اللون الداكن
                          ),
                        ),

                        // الدائرة الداخلية للضغط والتسبيح
                        Container(
                          width: 230,
                          height: 230,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF334155)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: const Color(0xFFC5A880), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E293B).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isZahra) ...[
                                // اسم الذكر الحالي لتسبيح الزهراء
                                Text(
                                  provider.currentZahraPhrase,
                                  style: GoogleFonts.amiri(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFC5A880),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],

                              // العداد الكبير الرقمي
                              Text(
                                "$count",
                                style: GoogleFonts.cairo(
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // الهدف الإجمالي للورد
                              Text(
                                isZahra ? "من أصل $target" : "سبح لله",
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const Spacer(),

            // أزرار التحكم السفلي (تصفير وملاحظات)
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                label: Text("تصفير العداد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 1.5),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  provider.resetTasbih();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}





