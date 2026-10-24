// views/quran_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/shia_data.dart';
import '../../providers/app_provider.dart';
import '../../utils/quran_text_builder.dart';
import 'reader_screen.dart';
import 'search_view.dart';

class QuranView extends StatefulWidget {
  const QuranView({super.key});

  @override
  State<QuranView> createState() => _QuranViewState();
}

class _QuranViewState extends State<QuranView> {
  Surah? _selectedSurah;
  double _fontSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_selectedSurah != null) {
      return _buildSurahReader(_selectedSurah!, provider, isDark);
    }

    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B), // خلفية كحلي/سليت غامق فاخرة موحدة
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white), // سهم الرجوع
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  provider.setActiveTab(0);
                }
              },
            ),
            title: Text(
              "القرآن الكريم",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SearchView()),
                  );
                },
              ),
            ],
            bottom: TabBar(
              indicatorColor: const Color(0xFFF59E0B), // مؤشر أصفر/ذهبي فاقع متطابق
              indicatorWeight: 3.5,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 13.5),
              tabs: const [
                Tab(text: "سور القرآن"),
                Tab(text: "فضائل السور"),
              ],
            ),
          ),
          body: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSurahsList(isDark),
              _buildVirtuesList(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahsList(bool isDark) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: ShiaData.surahs.length,
      itemBuilder: (context, index) {
        final surah = ShiaData.surahs[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSurah = surah;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF122E28) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.teal.withValues(alpha: 0.15) : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.015),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.teal : const Color(0xFF1E293B)).withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_outlined,
                    color: isDark ? Colors.teal[300] : const Color(0xFF1E293B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "سورة ${surah.name}",
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "عدد الآيات: ${surah.verses.length} آية",
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.teal[200] : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    final isFav = provider.isSurahBookmarked(surah.name);
                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: isFav ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () {
                        provider.toggleSurahBookmark(surah.name);
                      },
                    );
                  },
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.teal[200] : const Color(0xFF94A3B8),
                  size: 14,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVirtuesList(bool isDark) {
    final List<Map<String, String>> virtues = ShiaData.quranVirtues;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: virtues.length,
      itemBuilder: (context, index) {
        final item = virtues[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReaderScreen(
                  title: "فضائل سورة ${item["name"]}",
                  text: item["benefits"]!,
                  benefits: "المصدر: ${item["hadithSource"]}",
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF122E28) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.teal.withValues(alpha: 0.15) : const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.015),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.teal : const Color(0xFF1E293B)).withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    color: isDark ? Colors.teal[300] : const Color(0xFF1E293B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "فضائل سورة ${item["name"]}",
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "المصدر: ${item["hadithSource"]}",
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.teal[200] : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.teal[200] : const Color(0xFF94A3B8),
                  size: 14,
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildSurahReader(Surah surah, AppProvider provider, bool isDark) {
    // تجميع آيات السورة الكريمة في نص واحد مستمر دون تكرار أرقام الآيات
    final String fullText = QuranTextBuilder.buildFullSurahText(surah.verses);
    final TextStyle defaultTextStyle = GoogleFonts.amiri(
      fontSize: _fontSize,
      height: 1.9,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.amber[50] : const Color(0xFF0F172A),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B), // خلفية كحلي/سليت غامق فاخرة موحدة
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedSurah = null;
              });
            },
          ),
          title: Text(
            "سورة ${surah.name}",
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white, size: 20),
              onPressed: () {
                // مشاركة السورة الكريمة كاملة
              },
            ),
            Consumer<AppProvider>(
              builder: (context, prov, _) {
                final isFav = prov.isSurahBookmarked(surah.name);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: isFav ? const Color(0xFFF59E0B) : Colors.white,
                  ),
                  onPressed: () {
                    prov.toggleSurahBookmark(surah.name);
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // شريط التحكم بالخط المتطابق تماماً مع صفحة قراءة الزيارات
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
                border: Border(bottom: BorderSide(color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Text(
                    "حجم الخط:",
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 18.0,
                      max: 36.0,
                      divisions: 9,
                      activeColor: const Color(0xFF8A1525), // اللون الماروني الشريف
                      inactiveColor: isDark ? Colors.grey[800] : Colors.grey[300],
                      label: "${_fontSize.toInt()}",
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    "${_fontSize.toInt()}",
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A1525),
                    ),
                  ),
                ],
              ),
            ),

            // عرض نص السورة بالكامل بشكل مستمر ومتصل
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: SelectionArea(
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        children: QuranTextBuilder.buildQuranSpans(
                          text: fullText,
                          defaultStyle: defaultTextStyle,
                          isDark: isDark,
                          customSymbolColor: isDark ? const Color(0xFFF59E0B) : const Color(0xFF8A1525),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
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


