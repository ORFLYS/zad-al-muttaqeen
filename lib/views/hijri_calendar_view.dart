
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shia_hijri_calendar/shia_hijri_calendar.dart';
import '../models/shia_data.dart';
import '../providers/app_provider.dart';

// التقويم الهجري - النسخة الفخمة الجديدة
class HijriCalendarView extends StatefulWidget {
  final AppProvider provider;
  const HijriCalendarView({super.key, required this.provider});

  @override
  State<HijriCalendarView> createState() => _HijriCalendarViewState();
}

class _HijriCalendarViewState extends State<HijriCalendarView> {
  late int currentYear;
  late int currentMonth;
  late int selectedDay;
  late HijriDate todayHijri;

  @override
  void initState() {
    super.initState();
    todayHijri = widget.provider.todayHijri ?? widget.provider.hijriCalendar.gregorianToHijri(DateTime.now()).hijri;
    currentYear = todayHijri.year;
    currentMonth = todayHijri.monthNumber;
    selectedDay = todayHijri.day;
  }

  void _changeMonth(int direction) {
    setState(() {
      currentMonth += direction;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      } else if (currentMonth < 1) {
        currentMonth = 12;
        currentYear--;
      }
      selectedDay = 1;
    });
  }

  int _getWeekdayOffset(int weekday) {
    switch (weekday) {
      case DateTime.saturday: return 0;
      case DateTime.sunday: return 1;
      case DateTime.monday: return 2;
      case DateTime.tuesday: return 3;
      case DateTime.wednesday: return 4;
      case DateTime.thursday: return 5;
      case DateTime.friday: return 6;
      default: return 0;
    }
  }

  bool _isJoyEvent(IslamicOccasion event) {
    if (event.type == OccasionType.martyrdom || event.type == OccasionType.mourning) return false;
    final t = event.arabicName;
    return t.contains("مولد") || t.contains("ولادة") || t.contains("عيد") || t.contains("زواج") || t.contains("مباهلة") || t.contains("المباهلة") || t.contains("تنصيب") || t.contains("بيعة") || t.contains("خاتم") || t.contains("مواليد");
  }

  @override
  Widget build(BuildContext context) {
    const hijriMonths = ['محرّم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوّال', 'ذو القعدة', 'ذو الحجّة'];
    final tempCal = widget.provider.hijriCalendar;
    final totalDays = 30;
    DateTime firstDayG;
    try {
      firstDayG = tempCal.hijriToGregorian(HijriDate(currentYear, currentMonth, 1)).gregorian.subtract(Duration(days: widget.provider.hijriOffset));
    } catch (e) {
      firstDayG = DateTime.now();
    }
    final startOffset = _getWeekdayOffset(firstDayG.weekday);
    final totalGridCells = startOffset + totalDays;

    final selectedDayEvents = ShiaData.getCustomOccasions(HijriDate(currentYear, currentMonth, selectedDay), widget.provider.hijriCalendar.occasionsOn(HijriDate(currentYear, currentMonth, selectedDay)).toList());

    int nextEventDay = -1;
    int nextEventMonth = -1;
    int nextEventYear = currentYear;
    List<IslamicOccasion> nextEvents = [];

    for (int d = selectedDay + 1; d <= 30; d++) {
      final dayEvs = ShiaData.getCustomOccasions(HijriDate(currentYear, currentMonth, d), widget.provider.hijriCalendar.occasionsOn(HijriDate(currentYear, currentMonth, d)).toList());
      if (dayEvs.isNotEmpty) {
        nextEventDay = d; nextEventMonth = currentMonth; nextEventYear = currentYear; nextEvents = dayEvs; break;
      }
    }
    if (nextEvents.isEmpty) {
      for (int mOffset = 1; mOffset <= 12; mOffset++) {
        final searchMonth = (currentMonth + mOffset - 1) % 12 + 1;
        final searchYear = searchMonth < currentMonth ? currentYear + 1 : currentYear;
        for (int d = 1; d <= 30; d++) {
          final dayEvs = ShiaData.getCustomOccasions(HijriDate(searchYear, searchMonth, d), widget.provider.hijriCalendar.occasionsOn(HijriDate(searchYear, searchMonth, d)).toList());
          if (dayEvs.isNotEmpty) {
            nextEventDay = d; nextEventMonth = searchMonth; nextEventYear = searchYear; nextEvents = dayEvs; break;
          }
        }
        if (nextEvents.isNotEmpty) break;
      }
    }

    final gregorianMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final tempHijriToday = widget.provider.hijriCalendar;
    final gDateToday = tempHijriToday.hijriToGregorian(HijriDate(currentYear, currentMonth, selectedDay));
    final actualGDateToday = gDateToday.gregorian.subtract(Duration(days: widget.provider.hijriOffset));
    final currentGregorianYear = actualGDateToday.year;
    final currentGregorianMonthStr = gregorianMonths[actualGDateToday.month - 1];

    String nextEventGStr = "";
    if (nextEvents.isNotEmpty) {
      final gDateNext = tempHijriToday.hijriToGregorian(HijriDate(nextEventYear, nextEventMonth, nextEventDay));
      final actualGDateNext = gDateNext.gregorian.subtract(Duration(days: widget.provider.hijriOffset));
      nextEventGStr = " - ${actualGDateNext.day} ${gregorianMonths[actualGDateNext.month - 1]}";
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: Text("التقويم الهجري", style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomPaint(
                painter: CalendarCardPainter(
                  color: const Color(0xFF1E293B),
                  borderColor: const Color(0xFFE2E8F0).withOpacity(0.1),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 12, left: 12, right: 12),
                      child: Column(
                        children: [
                          // Header (المحراب)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildNavButton(Icons.arrow_back_ios_rounded, () => _changeMonth(-1)),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.spa, color: Color(0xFFC5A880), size: 14),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text("${hijriMonths[currentMonth - 1]} $currentYear هـ", 
                                              style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFC5A880)),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.spa, color: Color(0xFFC5A880), size: 14),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text("$currentGregorianMonthStr $currentGregorianYear م", style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                                    ],
                                  ),
                                ),
                                _buildNavButton(Icons.arrow_forward_ios_rounded, () => _changeMonth(1)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // أيام الأسبوع
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              _WeekdayHeaderCell(title: "السبت"),
                              _WeekdayHeaderCell(title: "الأحد"),
                              _WeekdayHeaderCell(title: "الإثنين"),
                              _WeekdayHeaderCell(title: "الثلاثاء"),
                              _WeekdayHeaderCell(title: "الأربعاء"),
                              _WeekdayHeaderCell(title: "الخميس"),
                              _WeekdayHeaderCell(title: "الجمعة"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // شبكة الأيام
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1.1,
                            ),
                            itemCount: totalGridCells,
                            itemBuilder: (context, index) {
                              if (index < startOffset) return const SizedBox();
                              final dayNum = index - startOffset + 1;
                              final isToday = dayNum == todayHijri.day && currentMonth == todayHijri.monthNumber && currentYear == todayHijri.year;
                              final isSelected = dayNum == selectedDay;
                              
                              final dayEvents = ShiaData.getCustomOccasions(HijriDate(currentYear, currentMonth, dayNum), widget.provider.hijriCalendar.occasionsOn(HijriDate(currentYear, currentMonth, dayNum)).toList());
                              final hasEvents = dayEvents.isNotEmpty;
                              final hasMartyrdom = dayEvents.any((e) => e.type == OccasionType.martyrdom || e.type == OccasionType.mourning);
                              final hasJoy = dayEvents.any((e) => _isJoyEvent(e));
                              Color dotColor = const Color(0xFF94A3B8);
                              if (hasMartyrdom) dotColor = const Color(0xFFFCA5A5);
                              else if (hasJoy) dotColor = const Color(0xFF86EFAC);

                              final gDate = widget.provider.hijriCalendar.hijriToGregorian(HijriDate(currentYear, currentMonth, dayNum)).gregorian.subtract(Duration(days: widget.provider.hijriOffset));
                              final gDay = gDate.day;

                              return GestureDetector(
                                onTap: () => setState(() => selectedDay = dayNum),
                                child: isSelected ? _buildSelectedBadge(dayNum, gDay) : _buildNormalCell(dayNum, gDay, isToday, hasEvents, dotColor),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildEventsList(hijriMonths, selectedDayEvents, nextEvents, nextEventDay, nextEventMonth, currentGregorianMonthStr, actualGDateToday.day, nextEventGStr),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFC5A880).withOpacity(0.3), width: 1),
          color: const Color(0xFFC5A880).withOpacity(0.05),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFFC5A880)),
      ),
    );
  }

  Widget _buildSelectedBadge(int dayNum, int gDay) {
    return CustomPaint(
      painter: IslamicBadgePainter(color: const Color(0xFFC5A880).withOpacity(0.15), borderColor: const Color(0xFFC5A880)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dayNum.toString(), style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFE5C158), height: 1.1)),
            Text(gDay.toString(), style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white, height: 1.1)),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalCell(int dayNum, int gDay, bool isToday, bool hasEvents, Color dotColor) {
    return Container(
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFFC5A880).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isToday ? const Color(0xFFC5A880).withOpacity(0.5) : const Color(0xFFC5A880).withOpacity(0.08), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dayNum.toString(), style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
            Text(gDay.toString(), style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8), height: 1.1)),
            if (hasEvents) Container(margin: const EdgeInsets.only(top: 2), width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<String> hijriMonths, List<IslamicOccasion> selectedDayEvents, List<IslamicOccasion> nextEvents, int nextEventDay, int nextEventMonth, String currentGMonth, int currentGDay, String nextEventGStr) {
    return Column(
      children: [
        _buildEventSectionTitle("مناسبات اليوم ($selectedDay ${hijriMonths[currentMonth - 1]} - $currentGDay $currentGMonth)", Icons.bookmark_rounded),
        const SizedBox(height: 12),
        if (selectedDayEvents.isEmpty) _buildEmptyEventCard()
        else ...selectedDayEvents.map((e) => _buildEventCard(e)),
        
        if (nextEvents.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildEventSectionTitle("الحدث القادم ($nextEventDay ${hijriMonths[nextEventMonth - 1]}$nextEventGStr)", Icons.event_note_rounded),
          const SizedBox(height: 12),
          ...nextEvents.map((e) => _buildEventCard(e)),
        ]
      ],
    );
  }

  Widget _buildEventSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFF59E0B)),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildEmptyEventCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text("لا توجد مناسبة لهذا اليوم.", style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569)))),
        ],
      ),
    );
  }

  Widget _buildEventCard(IslamicOccasion event) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Text(event.arabicName, style: GoogleFonts.cairo(fontSize: 15.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
    );
  }
}

class _WeekdayHeaderCell extends StatelessWidget {
  final String title;
  const _WeekdayHeaderCell({required this.title});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(title, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

class IslamicBadgePainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  IslamicBadgePainter({required this.color, required this.borderColor});
  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    final path = Path();
    double br = w * 0.15;
    double bumpW = w * 0.15;
    double bumpH = h * 0.08;

    path.moveTo(br, 0);
    path.lineTo(w/2 - bumpW, 0);
    path.quadraticBezierTo(w/2, -bumpH*2, w/2 + bumpW, 0);
    path.lineTo(w - br, 0);
    path.quadraticBezierTo(w, 0, w, br);
    path.lineTo(w, h/2 - bumpW);
    path.quadraticBezierTo(w + bumpH*2, h/2, w, h/2 + bumpW);
    path.lineTo(w, h - br);
    path.quadraticBezierTo(w, h, w - br, h);
    path.lineTo(w/2 + bumpW, h);
    path.quadraticBezierTo(w/2, h + bumpH*2, w/2 - bumpW, h);
    path.lineTo(br, h);
    path.quadraticBezierTo(0, h, 0, h - br);
    path.lineTo(0, h/2 + bumpW);
    path.quadraticBezierTo(-bumpH*2, h/2, 0, h/2 - bumpW);
    path.lineTo(0, br);
    path.quadraticBezierTo(0, 0, br, 0);
    path.close();

    canvas.drawShadow(path, Colors.black, 4.0, true);
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CalendarCardPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  CalendarCardPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    double br = 24.0;
    
    // The flat top edge y-coordinate
    double topY = 25.0; 
    
    final path = Path();
    path.moveTo(br, topY);
    path.lineTo(w * 0.15, topY); // Flat line
    
    // The Arch (Mihrab)
    path.quadraticBezierTo(w * 0.25, topY, w * 0.3, topY * 0.5);
    path.quadraticBezierTo(w * 0.5, -topY * 0.3, w * 0.7, topY * 0.5);
    path.quadraticBezierTo(w * 0.75, topY, w * 0.85, topY);
    
    path.lineTo(w - br, topY);
    path.quadraticBezierTo(w, topY, w, topY + br);
    path.lineTo(w, h - br);
    path.quadraticBezierTo(w, h, w - br, h);
    path.lineTo(br, h);
    path.quadraticBezierTo(0, h, 0, h - br);
    path.lineTo(0, topY + br);
    path.quadraticBezierTo(0, topY, br, topY);
    
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 15.0, true);
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 1.2);
    
    final ornamentPaint = Paint()..color = borderColor..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.15, topY), 2.0, ornamentPaint);
    canvas.drawCircle(Offset(w * 0.85, topY), 2.0, ornamentPaint);
    canvas.drawCircle(Offset(w * 0.5, -topY * 0.1), 2.0, ornamentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
