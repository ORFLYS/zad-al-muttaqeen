import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KheeraView extends StatelessWidget {
  const KheeraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            "خيرة الإمام الصادق (ع) بالقرآن",
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // المقدمة
              Text(
                "أشهر استخارة مروية عن أهل البيت (عليهم السلام) تؤخذ بالقرآن الكريم هي خيرة الإمام جعفر الصادق (عليه السلام)، وقد نقلها العديد من العلماء كالسيد ابن طاووس في كتاب (فتح الأبواب).",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  height: 1.8,
                  color: const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),

              // بطاقة الخطوات
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book, color: Color(0xFFC5A880), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          "خطوات الاستخارة",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildStepItem(
                      number: "١",
                      title: "الاستعداد والطهارة",
                      content: "أن تكون على وضوء وتستقبل القبلة.",
                    ),
                    _buildStepItem(
                      number: "٢",
                      title: "قراءة السور",
                      content: "تقرأ سورة (الإخلاص) 3 مرات، ثم تصلي على النبي وآله 3 مرات.",
                    ),
                    _buildStepItem(
                      number: "٣",
                      title: "الدعاء",
                      content: "تقول هذا الدعاء:\n(اللَّهُمَّ إِنِّي تَفَأَّلْتُ بِكِتَابِكَ، وَآمَنْتُ بِكَ، وَتَوَكَّلْتُ عَلَيْكَ، فَأَرِنِي فِي كِتَابِكَ الْمَكْنُونِ مَا هُوَ مَكْتُوبٌ مِنْ سِرِّكَ الْمَكْتُومِ فِي غَيْبِكَ، يَا ذَا الْجَلالِ وَالإِكْرَامِ).",
                      isDua: true,
                    ),
                    _buildStepItem(
                      number: "٤",
                      title: "فتح المصحف",
                      content: "تفتح القرآن الكريم وتأخذ أول آية في الصفحة اليمنى.",
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // بطاقة تفسير النتيجة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          "تفسير النتيجة",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildResultItem(
                      title: "الخيرة حسنة (افعل):",
                      desc: "الآية التي فيها أمر أو وعد بالخير.",
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF10B981),
                    ),
                    _buildResultItem(
                      title: "الخيرة سيئة (لا تفعل):",
                      desc: "الآية التي فيها نهي، تحذير، أو وعيد.",
                      icon: Icons.cancel_outlined,
                      color: const Color(0xFFEF4444),
                    ),
                    _buildResultItem(
                      title: "الخيرة متوسطة (توقف عن الأمر):",
                      desc: "الآية المختلطة (التي فيها أمر ونهي معاً).",
                      icon: Icons.remove_circle_outline_rounded,
                      color: const Color(0xFFF59E0B),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required String number,
    required String title,
    required String content,
    bool isLast = false,
    bool isDua = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFC5A880),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.cairo(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    height: 1.6,
                    color: isDua ? const Color(0xFFC5A880) : Colors.white.withValues(alpha: 0.8),
                    fontWeight: isDua ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: const Color(0xFF334155),
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: "$title ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
