// main.dart

import 'dart:ui'; // مطلوب لتأثير الزجاج المصقول BackdropFilter
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'providers/app_provider.dart';
import 'views/home_view.dart';
import 'views/library_view.dart';
import 'views/tasbih_view.dart';
import 'views/settings_view.dart';
import 'views/search_view.dart';
import 'views/qibla_view.dart';

import 'views/names_of_allah_view.dart';
import 'views/rakah_counter_view.dart';
import 'views/kheera_view.dart';
import 'views/onboarding_view.dart';

void main() async {
  // 1. ضمان تهيئة خدمات فلاتر الأساسية قبل البدء
  WidgetsFlutterBinding.ensureInitialized();

  // تفعيل معدل التحديث الأعلى (120 هرتز) تلقائياً على أجهزة الأندرويد المدعومة لضمان سلاسة حركات فائقة
  if (!kIsWeb && Platform.isAndroid) {
    try {
      FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      // تجاهل في حالة عدم الدعم البرمجي أو الأجهزة القديمة
    }
  }

  // 2. تهيئة التنسيقات المحلية للغة العربية (للتواريخ والأوقات)
  await initializeDateFormatting('ar', null);

  // 3. تهيئة قاعدة البيانات المحلية Hive
  await Hive.initFlutter();
  await Hive.openBox('huda_settings');

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const HudaApp(),
    ),
  );
}

class HudaApp extends StatelessWidget {
  const HudaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    final spiritualTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF8A1525), // ماروني شريف
      scaffoldBackgroundColor: const Color(0xFFFAF9F6),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF8A1525),
        secondary: Color(0xFFC5A880),
        surface: Colors.white,
        onSurface: Color(0xFF0F172A),
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: GoogleFonts.cairo(color: const Color(0xFF0F172A)),
        bodyMedium: GoogleFonts.cairo(color: const Color(0xFF334155)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAF9F6),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      ),
    );

    return MaterialApp(
      title: 'زاد المتقين',
      debugShowCheckedModeBanner: false,
      theme: spiritualTheme,
      home: provider.isFirstLaunch ? const OnboardingView() : const AppShell(),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    // قائمة الشاشات الفرعية المقترنة بالتبويبات الخمسة
    final List<Widget> screens = [
      const HomeView(),
      const SearchView(),
      const LibraryView(),
      const TasbihView(),
      const SettingsView(),
    ];

    final activeIndex = provider.activeTabIndex;

    return Scaffold(
      body: Stack(
        children: [
          // 1. الشاشة النشطة مع تركها تنساب خلف شريط القائمة السفلي لتأثير جمالي حديث
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: screens[activeIndex],
            ),
          ),
          
          // 2. شريط التنقل السفلي الاحترافي المطابق للمرجع (World-Class Translucent Floating Bottom Nav Bar)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 72,
                    padding: const EdgeInsets.only(bottom: 6, top: 4),
                    decoration: BoxDecoration(
                      // لون زجاجي ناصع مدمج مع الخلفية
                      color: Colors.white.withValues(alpha: 0.90),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // تبويب المزيد (Index 3 - Tasbih)
                        _buildNavItem(context, provider, 3, "المزيد", Icons.grid_view_outlined),
                        
                        // تبويب المفضلة (Index 2 - Library)
                        _buildNavItem(context, provider, 2, "المفضلة", Icons.favorite_border_outlined),
                        
                        // تبويب الرئيسية الماروني الفخم المرتفع بالمنتصف (Index 0 - Home)
                        _buildCenterHomeItem(context, provider),
                        
                        // تبويب بحث (Index 1 - Quran)
                        _buildNavItem(context, provider, 1, "بحث", Icons.search_outlined),
                        
                        // تبويب الاعدادات (Index 4 - Qibla)
                        _buildNavItem(context, provider, 4, "الاعدادات", Icons.settings_outlined),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء مفتاح الرئيسية الماروني الفاخر المرتفع بالمنتصف (Center Majestic Home Key)
  Widget _buildCenterHomeItem(BuildContext context, AppProvider provider) {
    return GestureDetector(
      onTap: () => provider.setActiveTab(0),
      child: Container(
        width: 52,
        height: 52,
        margin: const EdgeInsets.only(bottom: 12), // مرفوع للأعلى تماماً كالتصميم العالمي
        decoration: BoxDecoration(
          color: const Color(0xFF8A1525), // ماروني ملكي صلب
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A1525).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: const Icon(
          Icons.mosque_outlined, // أيقونة المسجد الشريفة البيضاء بالمنتصف
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  /// بناء عنصر قائمة سفلي اعتيادي
  Widget _buildNavItem(
    BuildContext context,
    AppProvider provider,
    int index,
    String title,
    IconData icon,
  ) {
    bool isActive = (provider.activeTabIndex == index);
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          _showMoreBottomSheet(context);
        } else {
          provider.setActiveTab(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF8A1525) : const Color(0xFF64748B),
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                color: isActive ? const Color(0xFF8A1525) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// منبثق سفلي يعرض قائمة الخدمات الإضافية الفخمة
  void _showMoreBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAF9F6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // رأس القائمة الملون (Header)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12, bottom: 20, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      // مقبض السحب
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        "المزيد من الخدمات",
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "اختر الخدمة أو الأداة التي ترغب في استخدامها",
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // خيارات القائمة
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                  child: Column(
                    children: [
                      _buildModernListItem(
                        context,
                        icon: Icons.filter_vintage_rounded,
                        title: "المسبحة الإلكترونية",
                        subtitle: "تسبيح تفاعلي لحساب الأذكار والتعقيبات اليومية",
                        color: const Color(0xFF10B981),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TasbihView()),
                          );
                        },
                      ),
                      _buildModernListItem(
                        context,
                        icon: Icons.explore_rounded,
                        title: "بوصلة اتجاه القبلة",
                        subtitle: "تحديد دقيق لاتجاه القبلة الجغرافية عبر المستشعرات",
                        color: const Color(0xFF3B82F6),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const QiblaView()),
                          );
                        },
                      ),
                      _buildModernListItem(
                        context,
                        icon: Icons.auto_awesome_rounded,
                        title: "أسماء الله الحسنى",
                        subtitle: "شرح الـ 99 اسماً الشريفة مع فضل الورد وعداد خاص",
                        color: const Color(0xFF6366F1),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NamesOfAllahView()),
                          );
                        },
                      ),
                      _buildModernListItem(
                        context,
                        icon: Icons.touch_app_rounded,
                        title: "عداد حساب الركعات والسجدات",
                        subtitle: "مساعدك لحساب السجدات والركعات تلقائياً أثناء الصلاة",
                        color: const Color(0xFF8A1525),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RakahCounterView()),
                          );
                        },
                      ),
                      _buildModernListItem(
                        context,
                        icon: Icons.menu_book_rounded,
                        title: "خيرة الإمام الصادق (ع) بالقرآن",
                        subtitle: "الاستخارة المروية عن الإمام الصادق (ع) بفتح المصحف الشريف",
                        color: const Color(0xFFF59E0B),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const KheeraView()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFF1F5F9), 
          width: 1.5
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_left_rounded, size: 20, color: Color(0xFF94A3B8)),
        onTap: onTap,
      ),
    );
  }
}
