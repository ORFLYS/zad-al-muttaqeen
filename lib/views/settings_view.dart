// views/settings_view.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../services/location_service.dart';
import 'prayer_notifications_view.dart';
import 'package:share_plus/share_plus.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // خلفية هادئة وروحية
      appBar: AppBar(
        title: Text(
          "الإعدادات العامة",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // 1. قسم الحسابات والموقع الجغرافي
          _buildSectionHeader("الحساب الشرعي والموقع"),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.access_time_filled_outlined,
              title: "أوقات الصلاة اليومية",
              subtitle: "عرض التفاصيل الدقيقة وحسابات صلاة جعفرية",
              onTap: () => _showPrayerTimesBottomSheet(context, provider),
            ),
            _buildSettingsItem(
              icon: Icons.location_on_rounded,
              title: "الموقع الجغرافي الحالي",
              subtitle: "تحديد الدولة والمحافظة (الحالية: ${provider.selectedCity.name.split('،').first})",
              onTap: () => _showCityPickerBottomSheet(context, provider),
            ),
            _buildSettingsItem(
              icon: Icons.edit_calendar_rounded,
              title: "تصحيح التاريخ الهجري",
              subtitle: provider.hijriOffset == 0 
                  ? "تلقائي (الوضع الافتراضي)"
                  : (provider.hijriOffset > 0 ? "زيادة بمقدار ${provider.hijriOffset} يوم" : "إنقاص بمقدار ${provider.hijriOffset.abs()} يوم"),
              onTap: () => _showHijriOffsetDialog(context, provider),
            ),
          ]),
          const SizedBox(height: 16),

          // قسم الإشعارات
          _buildSectionHeader("التنبيهات والإشعارات"),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.notifications_active_rounded,
              title: "تنبيهات الصلاة والأذان",
              subtitle: "تفعيل أذان الصلاة واختيار المؤذن",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrayerNotificationsView()),
                );
              },
            ),
          ]),
          const SizedBox(height: 16),



          // 3. قسم لغة التطبيق
          _buildSectionHeader("إعدادات اللغة"),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.language_rounded,
              title: "لغة التطبيق",
              subtitle: "العربية (تلقائي وافتراضي)",
              onTap: () => _showLanguageDialog(context),
            ),
          ]),
          const SizedBox(height: 16),

          // 3. قسم الدعم والمشاركة
          _buildSectionHeader("الدعم والتفاعل والمشاركة"),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.share_outlined,
              title: "مشاركة التطبيق مع الأصدقاء",
              subtitle: "نشر رابط التطبيق لنيل الأجر والثواب الجاري",
              onTap: () => _shareApp(context),
            ),
            _buildSettingsItem(
              icon: Icons.star_outline_rounded,
              title: "تقييم التطبيق",
              subtitle: "دعمنا بتقييم 5 نجوم وكتابة رأيك الكريم",
              onTap: () => _openPlayStore(context),
            ),
            _buildSettingsItem(
              icon: Icons.info_outline_rounded,
              title: "عن التطبيق (زاد المتقين)",
              subtitle: "تعرف على أهداف التطبيق وإصداراته",
              onTap: () => _showAboutBottomSheet(context),
            ),
          ]),
          
          const SizedBox(height: 80), // مسافة فارغة لتفادي التداخل مع الشريط السفلي
        ],
      ),
    );
  }

  // رأس القسم
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8A1525), // اللون الماروني المتميز للرؤوس
          ),
        ),
      ),
    );
  }

  // بطاقة تجميع الإعدادات
  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: List.generate(items.length * 2 - 1, (index) {
            if (index.isOdd) {
              return const Divider(height: 1, color: Color(0xFFF1F5F9));
            }
            return items[index ~/ 2];
          }),
        ),
      ),
    );
  }

  // عنصر إعداد فردي
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0F172A), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(
          fontSize: 11.5,
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_left_rounded, color: Color(0xFF94A3B8), size: 20),
      onTap: onTap,
    );
  }

  // 1. أوقات الصلاة - منبثق سفلي
  void _showPrayerTimesBottomSheet(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Consumer<AppProvider>(
          builder: (context, currentProvider, child) {
            final times = currentProvider.prayerTimes;
            if (times == null) return const SizedBox.shrink();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                            "أوقات الصلاة اليوم",
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentProvider.selectedCity.name.split('،').first,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                    _buildPrayerTimeRow("صلاة الصبْح", "${times.fajr.hour.toString().padLeft(2, '0')}:${times.fajr.minute.toString().padLeft(2, '0')} ص"),
                    _buildPrayerTimeRow("الشروق", "${times.sunrise.hour.toString().padLeft(2, '0')}:${times.sunrise.minute.toString().padLeft(2, '0')} ص"),
                    _buildPrayerTimeRow("صلاة الظهر", "${times.dhuhr.hour.toString().padLeft(2, '0')}:${times.dhuhr.minute.toString().padLeft(2, '0')} م"),
                    _buildPrayerTimeRow("الغروب", "${times.sunset.hour.toString().padLeft(2, '0')}:${times.sunset.minute.toString().padLeft(2, '0')} م"),
                    _buildPrayerTimeRow("صلاة المغرب", "${times.maghrib.hour.toString().padLeft(2, '0')}:${times.maghrib.minute.toString().padLeft(2, '0')} م"),
                    _buildPrayerTimeRow("منتصف الليل", "${times.midnight.hour.toString().padLeft(2, '0')}:${times.midnight.minute.toString().padLeft(2, '0')} م"),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),
                    Text(
                      "تعديل أوقات الصلاة بالدقائق",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            currentProvider.setPrayerMinutesOffset(currentProvider.prayerMinutesOffset - 1);
                          },
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF8A1525)),
                          iconSize: 28,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${currentProvider.prayerMinutesOffset > 0 ? '+' : ''}${currentProvider.prayerMinutesOffset} دقيقة",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF0F172A),
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            currentProvider.setPrayerMinutesOffset(currentProvider.prayerMinutesOffset + 1);
                          },
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF8A1525)),
                          iconSize: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "يتم حساب أوقات الصلوات وفق المذهب الجعفري بدقة عالية، ويمكنك تعديل الدقائق إذا كان هناك اختلاف بسيط مع منطقتك.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A1525),
                      ),
                    ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
          },
        );
      },
    );
  }

  Widget _buildPrayerTimeRow(String label, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF8A1525),
            ),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  // 2. محدد الموقع - يستدعي محدد الموقع السفلي المحدث مباشرة!
  void _showCityPickerBottomSheet(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // نقوم بإعادة بناء نفس منبثق اختيار الموقع الذي صممناه بنجاح!
        // بما أن كلاس البوتوم شيت متاح، سنطلبه مباشرة.
        // wait! inside settings_view.dart, we need to access _ShiaLocationBottomSheet.
        // since it is a private class inside home_view.dart, wait! We can export it or make it public,
        // or just build a public launcher in home_view, or replicate the ShiaLocationBottomSheet in this file!
        // Replicating it is extremely safe, reliable, and prevents cross-file private access issues!
        // Let's implement _ShiaLocationBottomSheet here too so it is fully standalone and beautiful!
        return _ShiaLocationBottomSheet(provider: provider);
      },
    );
  }

  // 3. نافذة تصحيح التاريخ الهجري
  void _showHijriOffsetDialog(BuildContext context, AppProvider provider) {
    int currentOffset = provider.hijriOffset;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text(
                  "تصحيح التاريخ الهجري",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1E293B)),
                  textAlign: TextAlign.center,
                ),
                content: RadioGroup<int>(
                  groupValue: currentOffset,
                  onChanged: (val) {
                    if (val != null) setState(() => currentOffset = val);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      _buildRadioOption("تلقائي (الوضع الافتراضي)", 0, currentOffset, (val) => setState(() => currentOffset = val)),
                      _buildRadioOption("زيادة يوم (+1)", 1, currentOffset, (val) => setState(() => currentOffset = val)),
                      _buildRadioOption("زيادة يومين (+2)", 2, currentOffset, (val) => setState(() => currentOffset = val)),
                      _buildRadioOption("إنقاص يوم (-1)", -1, currentOffset, (val) => setState(() => currentOffset = val)),
                      _buildRadioOption("إنقاص يومين (-2)", -2, currentOffset, (val) => setState(() => currentOffset = val)),
                    ],
                  ),
                ),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("إلغاء", style: GoogleFonts.cairo(color: const Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A1525),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      provider.setHijriOffset(currentOffset);
                      Navigator.pop(context);
                    },
                    child: Text("حفظ", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildRadioOption(String title, int value, int groupValue, ValueChanged<int> onChanged) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Radio<int>(
              value: value,
              activeColor: const Color(0xFF8A1525),
            ),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: groupValue == value ? FontWeight.bold : FontWeight.w500,
                color: groupValue == value ? const Color(0xFF8A1525) : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. لغة التطبيق
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              "لغة التطبيق",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: ListTile(
              leading: const Icon(Icons.check, color: Color(0xFF8A1525)),
              title: Text(
                "اللغة العربية (الافتراضية)",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              subtitle: Text(
                "يتم تفعيل اللغة العربية كخيار تلقائي وافتراضي للأوراد والأدعية المباركة.",
                style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "إغلاق",
                  style: GoogleFonts.cairo(color: Colors.grey[700], fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // 5. مشاركة التطبيق
  void _shareApp(BuildContext context) {
    const appLink = "https://play.google.com/store/apps/details?id=com.huda.bag.hqepa";
    const shareText = "تطبيق زاد المتقين - دليلك الشامل للأعمال والصلوات والزيارات الدينية.\nحمّله الآن:\n$appLink";
    Share.share(shareText); // ignore: deprecated_member_use
  }

  // 6. تقييم التطبيق تفاعلي بالكامل
  void _openPlayStore(BuildContext context) async {
    const playStoreUrl = "https://play.google.com/store/apps/details?id=com.huda.bag.hqepa"; // يمكن تغيير الرابط لاحقاً
    final uri = Uri.parse(playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("لا يمكن فتح الرابط حالياً. تأكد من اتصالك بالإنترنت.", style: GoogleFonts.cairo()),
            backgroundColor: const Color(0xFF8A1525),
          ),
        );
      }
    }
  }

  // 7. عن التطبيق
  void _showAboutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                // أيقونة التطبيق الكبيرة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF9F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.mosque_rounded, color: Color(0xFF8A1525), size: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  "زاد المتقين",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  "الإصدار 1.0.0 (Spiritual Edition)",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "زاد المتقين هو تطبيق إسلامي روحي متكامل مصمم ليكون رفيقك الدائم في رحلتك الإيمانية. يحتوي التطبيق على القرآن الكريم كاملاً، الأدعية والزيارات الشريفة اليومية، الأذكار وتعقيبات الصلاة، السبحة الإلكترونية التفاعلية، ومعرض الخلفيات الروحية. نسألكم الدعاء لتعجيل فرج مولانا صاحب الامر الحجة ابن الحسن ارواحنا لتراب مقدمة الفداء.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    color: const Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "جميع الحقوق محفوظة © زاد المتقين 2026",
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

// محدد موقع هرمي تفاعلي standalone داخل الإعدادات لضمان أداء مستقر وعالي الوضوح
class _ShiaLocationBottomSheet extends StatefulWidget {
  final AppProvider provider;

  const _ShiaLocationBottomSheet({required this.provider});

  @override
  State<_ShiaLocationBottomSheet> createState() => _ShiaLocationBottomSheetState();
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
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
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
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      if (_selectedCountry != null)
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: _selectedCountry == null ? TextAlign.center : TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedCountry == null ? _buildCountryList() : _buildCityList(),
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
        color: isGps ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGps ? const Color(0xFF8A1525) : const Color(0xFFE2E8F0),
          width: 1.5,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isGps ? const Color(0xFF8A1525) : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8A1525)),
                )
              : Icon(
                  Icons.my_location_rounded,
                  color: isGps ? Colors.white : const Color(0xFF8A1525),
                  size: 20,
                ),
        ),
        title: Text(
          "تحديد الموقع تلقائياً (GPS)",
          style: GoogleFonts.cairo(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: isGps ? const Color(0xFF8A1525) : const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          isGps
              ? "الموقع المحدد: ${widget.provider.selectedCity.name}"
              : "تحديد الدولة والمحافظة ومواقيت الصلاة تلقائياً",
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
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
            : const Icon(Icons.chevron_left, color: Color(0xFF94A3B8), size: 22),
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: LocationService.countries.length + 1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildGpsOptionCard();
        }
        final country = LocationService.countries[index - 1];
        final bool isCurrentCountry = country.cities.any(
          (c) => c.name == widget.provider.selectedCity.name && !widget.provider.isGpsActive
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentCountry ? const Color(0xFF8A1525).withValues(alpha: 0.3) : const Color(0xFFF1F5F9), 
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              country.name,
              style: GoogleFonts.cairo(
                fontSize: 16.5,
                fontWeight: isCurrentCountry ? FontWeight.bold : FontWeight.w700,
                color: isCurrentCountry ? const Color(0xFF8A1525) : const Color(0xFF0F172A),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCurrentCountry)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                const Icon(Icons.chevron_left, color: Color(0xFF94A3B8), size: 22),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedCountry = country;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildCityList() {
    final cities = _selectedCountry!.cities;
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: cities.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final city = cities[index];
        final isSelected = widget.provider.selectedCity.name == city.name && !widget.provider.isGpsActive;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF8A1525).withValues(alpha: 0.3) : const Color(0xFFF1F5F9), 
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              city.name.split('،').first,
              style: GoogleFonts.cairo(
                fontSize: 16.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
                color: isSelected ? const Color(0xFF8A1525) : const Color(0xFF0F172A),
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
                ? const Icon(Icons.check_circle, color: Color(0xFF8A1525), size: 24) 
                : null,
            onTap: () {
              final globalIndex = LocationService.shiaCities.indexWhere(
                (c) => c.name == city.name
              );
              widget.provider.selectCity(city, globalIndex);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}


