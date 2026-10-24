// views/home_view.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shia_hijri_calendar/shia_hijri_calendar.dart';
import '../../models/shia_data.dart';
import '../../providers/app_provider.dart';
import '../../services/location_service.dart';
import 'ziyarats_view.dart';
import 'duas_view.dart';
import 'azkar_view.dart';
import 'reader_screen.dart';
import 'qibla_view.dart';
import 'wallpapers_view.dart';
import 'acts_view.dart';
import 'quran_view.dart';
import 'prayers_view.dart';
import 'hijri_calendar_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  /// تحديد الصلاة الشرعية النشطة زمنياً بدقة تامة لإبرازها باللون الذهبي
  String _getActivePrayerName() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final times = provider.prayerTimes;
    if (times == null) return "";

    final now = DateTime.now();

    final sobh = DateTime(
      now.year,
      now.month,
      now.day,
      times.fajr.hour,
      times.fajr.minute,
    );
    final sunrise = DateTime(
      now.year,
      now.month,
      now.day,
      times.sunrise.hour,
      times.sunrise.minute,
    );
    final dhuhr = DateTime(
      now.year,
      now.month,
      now.day,
      times.dhuhr.hour,
      times.dhuhr.minute,
    );
    final sunset = DateTime(
      now.year,
      now.month,
      now.day,
      times.sunset.hour,
      times.sunset.minute,
    );
    final maghrib = DateTime(
      now.year,
      now.month,
      now.day,
      times.maghrib.hour,
      times.maghrib.minute,
    );
    final midnight = DateTime(
      now.year,
      now.month,
      now.day,
      times.midnight.hour,
      times.midnight.minute,
    );

    if (now.isAfter(sobh) && now.isBefore(sunrise)) {
      return "صلاة الصبح";
    } else if (now.isAfter(sunrise) && now.isBefore(dhuhr)) {
      return "الشروق";
    } else if (now.isAfter(dhuhr) && now.isBefore(sunset)) {
      return "صلاة الظهر";
    } else if (now.isAfter(sunset) && now.isBefore(maghrib)) {
      return "الغروب";
    } else if (now.isAfter(maghrib) && now.isBefore(midnight)) {
      return "صلاة المغرب";
    } else {
      return "منتصف الليل";
    }
  }

  /// بناء حاوية الزجاج المصقول الفائقة النعومة والرقة (Ultra-Thin Frosted Glass)
  Widget _buildThinGlassCard({
    required Widget child,
    required EdgeInsets margin,
    required EdgeInsets padding,
    double borderRadius = 20,
    double opacity = 0.85,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final times = provider.prayerTimes;

    final hijriDate =
        provider.todayHijri ??
        provider.hijriCalendar.gregorianToHijri(DateTime.now()).hijri;
    final activePrayer = _getActivePrayerName();
    final screenWidth = MediaQuery.of(context).size.width;

    // حساب عرض كل كارت من الكروت الثمانية ليناسب الشاشة بالمليمتر
    final cardWidth = (screenWidth - 32 - 36) / 4;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              provider.activeWallpaper,
            ), // الصورة النشطة ديناميكياً لتملأ الشاشة بالكامل
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Container(
          // غشاء حماية وتظليل خفيف جداً يدمج السماء بطريقة ناعمة
          color: Colors.black.withValues(alpha: 0.08),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // 1. شريط العنوان (اسم التطبيق بالوسط)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: Text(
                              "زاد المتقين",
                              style: GoogleFonts.cairo(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 2. شريط مناسبة اليوم الشفاف والفريد عائم مباشرة على السماء
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Builder(
                                builder: (context) {
                                  final todayEvents = ShiaData.getCustomOccasions(hijriDate, provider.hijriCalendar.occasionsOn(hijriDate).toList());
                                  final hasTodayEvent = todayEvents.isNotEmpty;
                                  final todayEventTitle = hasTodayEvent
                                      ? todayEvents.first.arabicName
                                      : "لا توجد مناسبة لهذا اليوم";

                                  Color indicatorColor = Colors.white;
                                  IconData todayIcon =
                                      Icons.info_outline_rounded;

                                  if (hasTodayEvent) {
                                    final ev = todayEvents.first;
                                    if (ev.type == OccasionType.martyrdom ||
                                        ev.type == OccasionType.mourning) {
                                      indicatorColor = const Color(0xFFEF4444);
                                      todayIcon = Icons.brightness_1;
                                    } else {
                                      final t = ev.arabicName;
                                      final isJoy =
                                          !(ev.type == OccasionType.martyrdom ||
                                              ev.type ==
                                                  OccasionType.mourning) &&
                                          (t.contains("مولد") ||
                                              t.contains("ولادة") ||
                                              t.contains("عيد") ||
                                              t.contains("زواج") ||
                                              t.contains("مباهلة") ||
                                              t.contains("المباهلة") ||
                                              t.contains("تنصيب") ||
                                              t.contains("بيعة") ||
                                              t.contains("خاتم") ||
                                              t.contains("مواليد"));
                                      if (isJoy) {
                                        indicatorColor = const Color(
                                          0xFF22C55E,
                                        );
                                        todayIcon = Icons.star_rounded;
                                      } else {
                                        indicatorColor = const Color(
                                          0xFFCBD5E1,
                                        );
                                        todayIcon = Icons.event_note_rounded;
                                      }
                                    }
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HijriCalendarView(provider: provider),
                                        ),
                                      );
                                    },
                                    child: Container(
                                          width:
                                              MediaQuery.of(context).size.width *
                                              0.73,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.22,
                                              ),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.08,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                todayIcon,
                                                color: hasTodayEvent
                                                    ? indicatorColor
                                                    : Colors.white70,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  todayEventTitle,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black
                                                            .withValues(alpha: 0.6),
                                                        blurRadius: 3,
                                                        offset: const Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (hasTodayEvent) ...[
                                                const SizedBox(width: 6),
                                                const Icon(
                                                  Icons.chevron_left_rounded,
                                                  color: Colors.white70,
                                                  size: 16,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 3. كارت مواقيت الصلاة العائم الأفقي الكامل (Full-Width Horizontal Prayer Times Card)
                        if (times != null)
                          _buildThinGlassCard(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.only(
                              left: 12,
                              right: 12,
                              top: 16,
                              bottom: 26,
                            ),
                            borderRadius: 20,
                            opacity:
                                0.35, // زجاجي شفاف جميل ومطابق تماماً للصورة
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // الموقع (المدينة والبلد)
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Color(0xFFE5C158),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          provider.selectedCity.name,
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(alpha: 0.6),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // التقويم الهجري والميلادي
                                Center(
                                  child: Builder(
                                    builder: (context) {
                                      final now = DateTime.now();
                                      const arabicDays = [
                                        'الاثنين',
                                        'الثلاثاء',
                                        'الأربعاء',
                                        'الخميس',
                                        'الجمعة',
                                        'السبت',
                                        'الأحد',
                                      ];
                                      const arabicMonths = [
                                        'يناير',
                                        'فبراير',
                                        'مارس',
                                        'أبريل',
                                        'مايو',
                                        'يونيو',
                                        'يوليو',
                                        'أغسطس',
                                        'سبتمبر',
                                        'أكتوبر',
                                        'نوفمبر',
                                        'ديسمبر',
                                      ];
                                      const hijriMonths = [
                                        'محرّم',
                                        'صفر',
                                        'ربيع الأول',
                                        'ربيع الثاني',
                                        'جمادى الأولى',
                                        'جمادى الآخرة',
                                        'رجب',
                                        'شعبان',
                                        'رمضان',
                                        'شوّال',
                                        'ذو القعدة',
                                        'ذو الحجّة',
                                      ];
                                      final dayName =
                                          arabicDays[now.weekday - 1];
                                      final gMonthName =
                                          arabicMonths[now.month - 1];
                                      final hMonthName =
                                          hijriMonths[hijriDate.monthNumber -
                                              1];

                                      final dateStyle = GoogleFonts.cairo(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.75,
                                            ),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      );

                                      return Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // التاريخ الهجري (يمين)
                                            Text(
                                              "${hijriDate.day} $hMonthName ${hijriDate.year} هـ",
                                              style: dateStyle,
                                            ),
                                            // فاصل ذهبي
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: Text(
                                                "•",
                                                style: GoogleFonts.cairo(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w900,
                                                  color: const Color(
                                                    0xFFE5C158,
                                                  ),
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                      blurRadius: 3,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // التاريخ الميلادي (يسار)
                                            Text(
                                              "$dayName ${now.day} $gMonthName ${now.year} م",
                                              style: dateStyle,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                const SizedBox(height: 16),
                                // الصف الأفقي للأوقات الستة بالتساوي من اليمين لليسار (RTL)
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildMinimalPrayerItem(
                                          "صلاة الصبح",
                                          times.fajr,
                                          activePrayer,
                                          Icons.wb_twilight_outlined,
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        width: 1,
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildMinimalPrayerItem(
                                          "الشروق",
                                          times.sunrise,
                                          activePrayer,
                                          Icons.wb_sunny_outlined,
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        width: 1,
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildMinimalPrayerItem(
                                          "صلاة الظهر",
                                          times.dhuhr,
                                          activePrayer,
                                          Icons.sunny,
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        width: 1,
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildMinimalPrayerItem(
                                          "الغروب",
                                          times.sunset,
                                          activePrayer,
                                          Icons.wb_twilight_outlined,
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        width: 1,
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildMinimalPrayerItem(
                                          "صلاة المغرب",
                                          times.maghrib,
                                          activePrayer,
                                          Icons.wb_twilight,
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        width: 1,
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildMinimalPrayerItem(
                                          "منتصف الليل",
                                          times.midnight,
                                          activePrayer,
                                          Icons.nightlight_outlined,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                const SizedBox(height: 12),
                                // العد التنازلي للصلاة القادمة
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Center(
                                    child: _NextPrayerCountdown(provider: provider),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),

                        // 4. شبكة الأقسام الثمانية الموحدة الفاخرة (8 كروت منفصلة تماماً ومتباعدة كما في صورتك المرجعية)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // الصف الأول (القرآن، الأدعية، الزيارات، الأذكار)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildIndividualGridCard(
                                    icon: Icons.menu_book_outlined,
                                    title: "القرآن",
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const QuranView(),
                                        ),
                                      );
                                    },
                                    cardWidth: cardWidth,
                                  ),
                                  _buildIndividualGridCard(
                                    icon: Icons.volunteer_activism_outlined,
                                    title: "الأدعية",
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const DuasView(),
                                        ),
                                      );
                                    },
                                    cardWidth: cardWidth,
                                  ),
                                  _buildIndividualGridCard(
                                    icon: Icons.mosque_outlined,
                                    title: "الزيارات",
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ZiyaratsView(),
                                        ),
                                      );
                                    },
                                    cardWidth: cardWidth,
                                  ),
                                  _buildIndividualGridCard(
                                    icon: Icons.auto_awesome_outlined,
                                    title: "الأذكار",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AzkarView(),
                                        ),
                                      );
                                    },
                                    cardWidth: cardWidth,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // الصف الثاني (المسبحة، الأعمال، التبليغات، الخدمات)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildIndividualGridCard(
                                    icon: Icons.wallpaper_outlined,
                                    title: "الخلفيات",
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const WallpapersView(),
                                        ),
                                      );
                                    },
                                    cardWidth: cardWidth,
                                  ),
                                  _buildIndividualGridCard(
                                    icon: Icons.assignment_outlined,
                                    title: "الأعمال",
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ActsView(),
                                        ),
                                      );
                                    },
                                    cardWidth: cardWidth,
                                  ),
                                  _buildIndividualGridCard(
                                    icon: Icons
                                        .calendar_month_outlined, // التقويم الهجري المحدث بصرياً
                                    title: "التقويم الهجري",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HijriCalendarView(provider: provider),
                                        ),
                                      );
                                    },
                                    cardWidth: cardWidth,
                                  ),
                                  _buildIndividualGridCard(
                                    icon: Icons.nightlight_outlined, // الصلوات
                                    title: "الصلوات",
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PrayersView(),
                                        ),
                                      );
                                    },
                                    cardWidth: cardWidth,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // الشريط المتحرك للأحاديث (الذي سيطفو فوق الناف بار)
                const _HadithTicker(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بناء كارت منفرد مخصص للشبكة الثمانية الموحدة (Frosted Glass Individual Grid Item)
  Widget _buildIndividualGridCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required double cardWidth,
  }) {
    return _buildThinGlassCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      borderRadius: 16,
      opacity: 0.32, // زجاج شفاف ممتاز ومطابق تماماً للصورة المرجعية
      child: SizedBox(
        width: cardWidth,
        height: 76,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalPrayerItem(
    String name,
    DateTime time,
    String activePrayer,
    IconData icon,
  ) {
    final format = intl.DateFormat('hh:mm').format(time);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              name,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 6),
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              format,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// منبثق سفلي يعرض أوراد الأذكار الجعفرية اليومية وتعقيبات الصلاة
  // ignore: unused_element
  void _showAzkarBottomSheet(BuildContext context) {
    // قائمة أذكار أيام الأسبوع الجعفرية
    final List<Map<String, String>> weekAzkar = [
      {
        "day": "السبت",
        "dhikr": "يَا رَبَّ الْعَالَمِين",
        "count": "100 مرة",
        "reward": "توجب استجابة الدعاء وقضاء الحوائج",
      },
      {
        "day": "الأحد",
        "dhikr": "يَا ذَا الْجَلَالِ وَالْإِكْرَام",
        "count": "100 مرة",
        "reward": "تزيد في الإيمان وتيسر الأمور",
      },
      {
        "day": "الإثنين",
        "dhikr": "يَا قَاضِيَ الْحَاجَات",
        "count": "100 مرة",
        "reward": "توجب نيل المقامات والبركة في الرزق",
      },
      {
        "day": "الثلاثاء",
        "dhikr": "يَا أَرْحَمَ الرَّاحِمِين",
        "count": "100 مرة",
        "reward": "تفتح أبواب الرحمة وتدفع البلاء",
      },
      {
        "day": "الأربعاء",
        "dhikr": "يَا حَيُّ يَا قَيُّوم",
        "count": "100 مرة",
        "reward": "تزيد في العمر وصلاح المعاش والآخرة",
      },
      {
        "day": "الخميس",
        "dhikr": "لَا إِلٰهَ إِلَّا اللهُ الْمَلِكُ الْحَقُّ الْمُبِين",
        "count": "100 مرة",
        "reward": "توجب الغنى وطرد الفقر وحفظ القبر",
      },
      {
        "day": "الجمعة",
        "dhikr":
            "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَآلِ مُحَمَّدٍ وَعَجِّلْ فَرَجَهُم",
        "count": "100 مرة",
        "reward": "تمحو السيئات وترفع الدرجات العظمى",
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      "الأذكار اليومية المستحبة لأيام الأسبوع",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A1525),
                      ),
                    ),
                    Divider(height: 20, color: const Color(0xFF334155)),

                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: weekAzkar.length,
                        itemBuilder: (context, index) {
                          final item = weekAzkar[index];
                          // معرفة اليوم الحالي لتسليط الضوء عليه
                          final weekday = DateTime.now().weekday;
                          bool isToday = false;
                          if (item["day"] == "السبت" &&
                              weekday == DateTime.saturday) {
                            isToday = true;
                          }
                          if (item["day"] == "الأحد" &&
                              weekday == DateTime.sunday) {
                            isToday = true;
                          }
                          if (item["day"] == "الإثنين" &&
                              weekday == DateTime.monday) {
                            isToday = true;
                          }
                          if (item["day"] == "الثلاثاء" &&
                              weekday == DateTime.tuesday) {
                            isToday = true;
                          }
                          if (item["day"] == "الأربعاء" &&
                              weekday == DateTime.wednesday) {
                            isToday = true;
                          }
                          if (item["day"] == "الخميس" &&
                              weekday == DateTime.thursday) {
                            isToday = true;
                          }
                          if (item["day"] == "الجمعة" &&
                              weekday == DateTime.friday) {
                            isToday = true;
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ReaderScreen(
                                    title: "أذكار يوم ${item["day"]}",
                                    text:
                                        "${item["dhikr"]}\n\n( ${item["count"]} )",
                                    benefits: item["reward"]!,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? const Color(0xFFFAF5EC)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: isToday
                                        ? const Color(
                                            0xFF8A1525,
                                          ).withValues(alpha: 0.06)
                                        : Colors.black.withValues(alpha: 0.015),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: isToday
                                      ? const Color(0xFF8A1525)
                                      : const Color(0xFF475569),
                                  width: isToday ? 1.6 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // 1. شارة اليوم الأنيقة (اليمين)
                                  Container(
                                    width: 68,
                                    height: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? const Color(0xFF8A1525)
                                          : const Color(0xFFFAF5EC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isToday
                                            ? const Color(0xFF8A1525)
                                            : const Color(
                                                0xFFC5A880,
                                              ).withValues(alpha: 0.2),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      item["day"]!,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: isToday
                                            ? Colors.white
                                            : const Color(0xFFC5A880),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // 2. خط فاصل عمودي ناعم وفخم
                                  Container(
                                    width: 1.0,
                                    height: 36,
                                    color: isToday
                                        ? const Color(
                                            0xFF8A1525,
                                          ).withValues(alpha: 0.15)
                                        : const Color(0xFF475569),
                                  ),
                                  const SizedBox(width: 14),

                                  // 3. الذكر وتفاصيله (المنتصف)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["dhikr"]!,
                                          style: GoogleFonts.amiri(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            height: 1.3,
                                            color: isToday
                                                ? const Color(0xFF8A1525)
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            // شارة العدد الصغير بلون ذهبي/ماروني ناعم
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isToday
                                                    ? const Color(
                                                        0xFF8A1525,
                                                      ).withValues(alpha: 0.08)
                                                    : const Color(0xFF334155),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item["count"]!,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: isToday
                                                      ? const Color(0xFF8A1525)
                                                      : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // وصف الأجر
                                            Expanded(
                                              child: Text(
                                                item["reward"]!,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF64748B,
                                                  ),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 4. أيقونة نجمة اليوم الفائقة الجودة (اليسار)
                                  if (isToday) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF8A1525),
                                      ),
                                      child: const Icon(
                                        Icons.star,
                                        color: Color(0xFFC5A880),
                                        size: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// منبثق سفلي فاخر لعرض قائمة الخدمات الإسلامية المتنوعة
  // ignore: unused_element
  void _showServicesBottomSheet(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    // قائمة الخدمات المتنوعة
    final List<Map<String, dynamic>> services = [
      {
        "icon": Icons.explore_outlined,
        "title": "بوصلة القبلة",
        "desc": "تحديد اتجاه القبلة بدقة عالية",
        "action": () {
          Navigator.of(context).pop();
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const QiblaView()));
        },
      },
      {
        "icon": Icons.adjust_outlined,
        "title": "المسبحة",
        "desc": "تسبيح الزهراء (ع) والأذكار",
        "action": () {
          Navigator.of(context).pop();
          provider.setActiveTab(3);
        },
      },
      {
        "icon": Icons.format_list_numbered_rtl,
        "title": "عدد الركعات",
        "desc": "ركعات الصلوات اليومية والنوافل",
        "action": () {
          Navigator.of(context).pop();
          _showRakaatBottomSheet(context);
        },
      },
      {
        "icon": Icons.calendar_month_outlined,
        "title": "التقويم الهجري",
        "desc": "مناسبات وأعياد أهل البيت (ع)",
        "action": () {
          Navigator.of(context).pop();
          final allEvents = provider.hijriCalendar.occasions;
          _showEventsBottomSheet(context, allEvents, showAll: true);
        },
      },

      {
        "icon": Icons.star_outline_rounded,
        "title": "أسماء الله الحسنى",
        "desc": "99 اسماً من أسماء الله تعالى",
        "action": () {
          Navigator.of(context).pop();
          _showAsmaaAllahBottomSheet(context);
        },
      },
      {
        "icon": Icons.share_outlined,
        "title": "مشاركة التطبيق",
        "desc": "شارك الخير مع أحبائك",
        "action": () {
          Navigator.of(context).pop();
          // يمكن إضافة منطق المشاركة لاحقاً
        },
      },
      {
        "icon": Icons.info_outline_rounded,
        "title": "عن التطبيق",
        "desc": "معلومات الإصدار والمطور",
        "action": () {
          Navigator.of(context).pop();
          _showAboutAppDialog(context);
        },
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب العلوي
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // عنوان القائمة
                Text(
                  "الخدمات",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF8A1525),
                  ),
                ),
                const SizedBox(height: 16),
                // شبكة الخدمات (4 أعمدة × 2 صفوف)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final item = services[index];
                    return GestureDetector(
                      onTap: item["action"] as VoidCallback,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF8A1525,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              item["icon"] as IconData,
                              size: 26,
                              color: const Color(0xFF8A1525),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item["title"] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item["desc"] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// منبثق عدد ركعات الصلوات اليومية والنوافل حسب المذهب الجعفري
  void _showRakaatBottomSheet(BuildContext context) {
    final List<Map<String, String>> rakaatData = [
      {"name": "صلاة الصبح", "fard": "٢", "nafila": "٢", "total": "٤"},
      {"name": "صلاة الظهر", "fard": "٤", "nafila": "٨", "total": "١٢"},
      {"name": "صلاة العصر", "fard": "٤", "nafila": "٨", "total": "١٢"},
      {"name": "صلاة المغرب", "fard": "٣", "nafila": "٤", "total": "٧"},
      {"name": "صلاة العشاء", "fard": "٤", "nafila": "٢", "total": "٦"},
      {"name": "صلاة الليل", "fard": "-", "nafila": "١١", "total": "١١"},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "عدد ركعات الصلوات اليومية",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8A1525),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "حسب المذهب الجعفري الاثنا عشري",
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const Divider(height: 20),
                // عناوين الأعمدة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "الصلاة",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF8A1525),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            "الفريضة",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            "النافلة",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            "المجموع",
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...rakaatData.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item["name"]!,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              item["fard"]!,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF8A1525),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              item["nafila"]!,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFC5A880),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              item["total"]!,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8A1525).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Color(0xFF8A1525),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "المجموع الكلي: ٥٢ ركعة يومياً (١٧ فريضة + ٣٥ نافلة)",
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8A1525),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  /// منبثق أسماء الله الحسنى
  void _showAsmaaAllahBottomSheet(BuildContext context) {
    final List<String> names = [
      "الله",
      "الرحمن",
      "الرحيم",
      "الملك",
      "القدوس",
      "السلام",
      "المؤمن",
      "المهيمن",
      "العزيز",
      "الجبار",
      "المتكبر",
      "الخالق",
      "البارئ",
      "المصور",
      "الغفار",
      "القهار",
      "الوهاب",
      "الرزاق",
      "الفتاح",
      "العليم",
      "القابض",
      "الباسط",
      "الخافض",
      "الرافع",
      "المعز",
      "المذل",
      "السميع",
      "البصير",
      "الحكم",
      "العدل",
      "اللطيف",
      "الخبير",
      "الحليم",
      "العظيم",
      "الغفور",
      "الشكور",
      "العلي",
      "الكبير",
      "الحفيظ",
      "المقيت",
      "الحسيب",
      "الجليل",
      "الكريم",
      "الرقيب",
      "المجيب",
      "الواسع",
      "الحكيم",
      "الودود",
      "المجيد",
      "الباعث",
      "الشهيد",
      "الحق",
      "الوكيل",
      "القوي",
      "المتين",
      "الولي",
      "الحميد",
      "المحصي",
      "المبدئ",
      "المعيد",
      "المحيي",
      "المميت",
      "الحي",
      "القيوم",
      "الواجد",
      "الماجد",
      "الواحد",
      "الأحد",
      "الصمد",
      "القادر",
      "المقتدر",
      "المقدم",
      "المؤخر",
      "الأول",
      "الآخر",
      "الظاهر",
      "الباطن",
      "الوالي",
      "المتعالي",
      "البر",
      "التواب",
      "المنتقم",
      "العفو",
      "الرؤوف",
      "مالك الملك",
      "ذو الجلال والإكرام",
      "المقسط",
      "الجامع",
      "الغني",
      "المغني",
      "المانع",
      "الضار",
      "النافع",
      "النور",
      "الهادي",
      "البديع",
      "الباقي",
      "الوارث",
      "الرشيد",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      "أسماء الله الحسنى",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A1525),
                      ),
                    ),
                    const Divider(height: 20),
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 2.5,
                            ),
                        itemCount: names.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFFC5A880,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                names[index],
                                style: GoogleFonts.amiri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF8A1525),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// حوار معلومات التطبيق
  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "حقيبة الحسين (ع)",
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF8A1525),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الإصدار: 1.0.0",
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "تطبيق إسلامي شيعي شامل يحتوي على القرآن الكريم والأدعية والزيارات والأذكار ومواقيت الصلاة وبوصلة القبلة والمسبحة الإلكترونية والتقويم الهجري.",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    height: 1.6,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "اللهم صل على محمد وآل محمد",
                  style: GoogleFonts.amiri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC5A880),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "حسناً",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8A1525),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// منبثق سفلي لعرض مناسبات اليوم أو كل المناسبات الهجرية
  void _showEventsBottomSheet(
    BuildContext context,
    List<IslamicOccasion> events, {
    bool showAll = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      showAll
                          ? "تقويم أحداث ومناسبات أهل البيت (ع)"
                          : "تفاصيل أعمال ومناسبات اليوم",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A1525),
                      ),
                    ),
                    Divider(height: 20, color: const Color(0xFF334155)),

                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  (event.type == OccasionType.martyrdom ||
                                      event.type == OccasionType.mourning)
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    (event.type == OccasionType.martyrdom ||
                                        event.type == OccasionType.mourning)
                                    ? Colors.red.withValues(alpha: 0.25)
                                    : const Color(
                                        0xFFC5A880,
                                      ).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          (event.type ==
                                                      OccasionType.martyrdom ||
                                                  event.type ==
                                                      OccasionType.mourning)
                                              ? Icons.brightness_1
                                              : Icons.star,
                                          color:
                                              (event.type ==
                                                      OccasionType.martyrdom ||
                                                  event.type ==
                                                      OccasionType.mourning)
                                              ? Colors.red
                                              : const Color(0xFFC5A880),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          event.arabicName,
                                          style: GoogleFonts.cairo(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                (event.type ==
                                                        OccasionType
                                                            .martyrdom ||
                                                    event.type ==
                                                        OccasionType.mourning)
                                                ? Colors.red[850]
                                                : const Color(0xFFC5A880),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (showAll)
                                      Text(
                                        "${event.day} / ${event.month}",
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }


}

class GesturefulCitySelector extends StatelessWidget {
  final AppProvider provider;

  const GesturefulCitySelector({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.edit_location, size: 14, color: Color(0xFF8A1525)),
      label: Text(
        "تغيير",
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF8A1525),
        ),
      ),
      onPressed: () {
        _showCityPickerDialog(context);
      },
    );
  }

  void _showCityPickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _ShiaLocationBottomSheet(provider: provider);
      },
    );
  }
}

// نافذة تفاعلية من مستويين تظهر من الأسفل لاختيار الدولة أولاً ثم المدينة/المحافظة المقابلة لها
class _ShiaLocationBottomSheet extends StatefulWidget {
  final AppProvider provider;

  const _ShiaLocationBottomSheet({required this.provider});

  @override
  State<_ShiaLocationBottomSheet> createState() =>
      _ShiaLocationBottomSheetState();
}

class _ShiaLocationBottomSheetState extends State<_ShiaLocationBottomSheet> {
  ShiaCountry? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    final titleText = _selectedCountry == null
        ? "اختر الدولة للحساب الشرعي"
        : "اختر المدينة في ${_selectedCountry!.name}";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // مقبض سحب علوي أنيق للتصميم العصري
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // شريط رأس المنبثق
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (_selectedCountry != null)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCountry = null;
                        });
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(left: 12),
                    ),
                  Expanded(
                    child: Text(
                      titleText,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 17, // تكبير خط العنوان للوضوح
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFF475569)),

            // محتوى القائمة
            Expanded(
              child: _selectedCountry == null
                  ? _buildCountryList()
                  : _buildCityList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsOptionCard() {
    final isGps = widget.provider.isGpsActive;
    final isLoading = widget.provider.loadingLocation;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isGps ? const Color(0xFF8A1525).withValues(alpha: 0.25) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGps ? const Color(0xFF8A1525) : const Color(0xFF334155),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isGps ? const Color(0xFF8A1525) : const Color(0xFF1E293B),
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(
                  Icons.my_location_rounded,
                  color: isGps ? Colors.white : const Color(0xFFE5C158),
                  size: 20,
                ),
        ),
        title: Text(
          "تحديد الموقع تلقائياً (GPS)",
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          isGps
              ? "الموقع المحدد: ${widget.provider.selectedCity.name}"
              : "تحديد الدولة والمحافظة ومواقيت الصلاة تلقائياً",
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        trailing: isGps
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8A1525),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "مفعّل",
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Color(0xFF64748B)),
        onTap: isLoading
            ? null
            : () async {
                final result = await widget.provider.determineUserLocation();
                if (!mounted) return;
                if (result == LocationResult.success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "تم تحديد موقعك: ${widget.provider.selectedCity.name} وضبط مواقيت الصلاة بنجاح",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: const Color(0xFF1E293B),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else if (result == LocationResult.serviceDisabled) {
                  LocationService.showGpsDisabledDialog(context);
                } else if (result == LocationResult.permissionDenied) {
                  LocationService.showPermissionDeniedDialog(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "تعذر تحديد الموقع حالياً. يرجى التأكد من تشغيل الـ GPS والمحاولة ثانية.",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.red[850],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
      ),
    );
  }

  Widget _buildCountryList() {
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildGpsOptionCard(),
        ...LocationService.countries.map((country) {
          final bool isCurrentCountry = country.cities.any(
            (c) =>
                c.name == widget.provider.selectedCity.name &&
                !widget.provider.isGpsActive,
          );

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                title: Text(
                  country.name,
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: isCurrentCountry
                        ? FontWeight.bold
                        : FontWeight.w700,
                    color: isCurrentCountry
                        ? const Color(0xFF8A1525)
                        : Colors.white,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCurrentCountry)
                      Container(
                        margin: const EdgeInsets.only(left: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "الحالية",
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8A1525),
                          ),
                        ),
                      ),
                    const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF475569),
                      size: 22,
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _selectedCountry = country;
                  });
                },
              ),
              const Divider(height: 1, color: Color(0xFF334155)),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCityList() {
    final cities = _selectedCountry!.cities;
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: cities.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: const Color(0xFF334155)),
      itemBuilder: (context, index) {
        final city = cities[index];
        final isSelected =
            widget.provider.selectedCity.name == city.name &&
            !widget.provider.isGpsActive;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ), // زيادة الهوامش للوضوح
          title: Text(
            city.name.split('،').first, // اسم المدينة فقط للاختصار الأنيق
            style: GoogleFonts.cairo(
              fontSize: 16.5, // خط كبير وواضح جداً
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.w700, // سماكة واضحة
              color: isSelected
                  ? const Color(0xFF8A1525)
                  : Colors.white, // تباين قوي
            ),
          ),
          subtitle: Text(
            "شرقاً: ${city.longitude.toStringAsFixed(2)}° | شمالاً: ${city.latitude.toStringAsFixed(2)}°",
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          trailing: isSelected
              ? const Icon(
                  Icons.check_circle,
                  color: Color(0xFF8A1525),
                  size: 24,
                )
              : null,
          onTap: () {
            // البحث عن الفهرس العام للمدينة لتخزينها بدقة ومطابقة البنية السابقة
            final globalIndex = LocationService.shiaCities.indexWhere(
              (c) => c.name == city.name,
            );
            widget.provider.selectCity(city, globalIndex);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

// ==========================================
class _HadithTicker extends StatefulWidget {
  const _HadithTicker();

  @override
  State<_HadithTicker> createState() => _HadithTickerState();
}

class _HadithTickerState extends State<_HadithTicker> {
  late Timer _timer;
  int _currentIndex = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _currentIndex = _random.nextInt(ShiaData.shortHadiths.length);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % ShiaData.shortHadiths.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ShiaData.shortHadiths.isEmpty) return const SizedBox();

    final hadith = ShiaData.shortHadiths[_currentIndex];

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 84, top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFE5C158), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 65,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: Column(
                    key: ValueKey<int>(_currentIndex),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hadith["text"]!,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "- ${hadith["author"]!} -",
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFE5C158).withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






class _NextPrayerCountdown extends StatefulWidget {
  final AppProvider provider;
  const _NextPrayerCountdown({required this.provider});

  @override
  State<_NextPrayerCountdown> createState() => _NextPrayerCountdownState();
}

class _NextPrayerCountdownState extends State<_NextPrayerCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final times = widget.provider.prayerTimes;
    if (times == null) return const SizedBox.shrink();

    final now = DateTime.now();
    DateTime makeTime(int hour, int minute) => DateTime(now.year, now.month, now.day, hour, minute);

    final sobh = makeTime(times.fajr.hour, times.fajr.minute);
    final dhuhr = makeTime(times.dhuhr.hour, times.dhuhr.minute);
    final maghrib = makeTime(times.maghrib.hour, times.maghrib.minute);

    // نضع فقط أوقات الصلوات الفعلية لكي لا يحسب للعداد للشروق أو الغروب أو منتصف الليل
    final prayers = [
      {"name": "صلاة الصبح", "time": sobh},
      {"name": "صلاة الظهر", "time": dhuhr},
      {"name": "صلاة المغرب", "time": maghrib},
    ];

    Map<String, dynamic>? nextPrayer;
    for (var p in prayers) {
      if (now.isBefore(p["time"] as DateTime)) {
        nextPrayer = p;
        break;
      }
    }

    if (nextPrayer == null) {
      final tomorrow = now.add(const Duration(days: 1));
      nextPrayer = {
        "name": "صلاة الصبح",
        "time": DateTime(tomorrow.year, tomorrow.month, tomorrow.day, times.fajr.hour, times.fajr.minute)
      };
    }

    final targetTime = nextPrayer["time"] as DateTime;
    final diff = targetTime.difference(now);

    final hours = diff.inHours.toString().padLeft(2, "0");
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, "0");
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, "0");

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time_rounded, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(
          "الصلاة القادمة بعد: ",
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          "$hours:$minutes:$seconds",
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFE5C158), // اللون الذهبي
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
