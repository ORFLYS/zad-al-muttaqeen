// views/library_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shia_data.dart';
import '../providers/app_provider.dart';
import '../utils/quran_text_builder.dart';
import 'reader_screen.dart';

class FavoriteItem {
  final String type; // 'surah', 'dua', 'ziyarat'
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final dynamic data;

  FavoriteItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.data,
  });
}

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // تجميع كافة المفضلات في قائمة واحدة موحدة
    final List<FavoriteItem> favoriteItems = [];

    // 1. إضافة السور الكريمة المفضلة
    for (var name in provider.bookmarkedSurahs) {
      try {
        final surah = ShiaData.surahs.firstWhere((s) => s.name == name);
        favoriteItems.add(FavoriteItem(
          type: 'surah',
          title: "سورة ${surah.name}",
          subtitle: "سورة قرآنية • عدد الآيات: ${surah.verses.length} آية",
          icon: Icons.menu_book_outlined,
          iconBgColor: const Color(0xFFE6F4EA), // أخضر خفيف مريح للقرآن
          iconColor: const Color(0xFF137333),
          data: surah,
        ));
      } catch (_) {}
    }

    // 2. إضافة الأدعية المفضلة
    for (var title in provider.bookmarkedDuas) {
      try {
        Dua? dua;
        try {
          dua = ShiaData.duas.firstWhere((d) => d.title == title);
        } catch (_) {}
        if (dua == null) {
          try {
            dua = ShiaData.dailyDuas.firstWhere((d) => d.title == title);
          } catch (_) {}
        }
        if (dua == null) {
          try {
            dua = ShiaData.prayerDuas.firstWhere((d) => d.title == title);
          } catch (_) {}
        }
        if (dua != null) {
          favoriteItems.add(FavoriteItem(
            type: 'dua',
            title: dua.title,
            subtitle: "دعاء مبارك • ${dua.benefits}",
            icon: Icons.volunteer_activism_outlined,
            iconBgColor: const Color(0xFFFCE8E6), // أحمر/وردي خفيف للأدعية
            iconColor: const Color(0xFFC5221F),
            data: dua,
          ));
        }
      } catch (_) {}
    }

    // 3. إضافة الزيارات المفضلة
    for (var title in provider.bookmarkedZiyarats) {
      try {
        Ziyarat? ziyarat;
        try {
          ziyarat = ShiaData.ziyarats.firstWhere((z) => z.title == title);
        } catch (_) {}
        if (ziyarat == null) {
          try {
            ziyarat = ShiaData.dailyZiyarats.firstWhere((z) => z.title == title);
          } catch (_) {}
        }
        if (ziyarat != null) {
          favoriteItems.add(FavoriteItem(
            type: 'ziyarat',
            title: ziyarat.title,
            subtitle: "زيارة شريفة • ${ziyarat.benefits}",
            icon: Icons.mosque_outlined,
            iconBgColor: const Color(0xFFFEF7E0), // ذهبي/أصفر خفيف للزيارات
            iconColor: const Color(0xFFB06000),
            data: ziyarat,
          ));
        }
      } catch (_) {}
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6), // خلفية داكنة فخمة متطابقة مع الهوية البصرية
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF9F6),
          elevation: 0,
          title: Text(
            "المفضلة",
            style: GoogleFonts.cairo(
              color: const Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: favoriteItems.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                itemCount: favoriteItems.length,
                itemBuilder: (context, index) {
                  final item = favoriteItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF475569)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.015),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color: item.iconColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        item.subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.bookmark_rounded,
                              color: Color(0xFFF59E0B),
                              size: 20,
                            ),
                            onPressed: () {
                              _toggleBookmark(provider, item);
                            },
                          ),
                          const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF94A3B8),
                            size: 14,
                          ),
                        ],
                      ),
                      onTap: () {
                        _navigateToReader(context, item);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF475569).withValues(alpha: 0.1)),
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                color: Color(0xFF94A3B8),
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "المفضلة فارغة حالياً",
              style: GoogleFonts.cairo(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "قم بإضافة السور، الأدعية، أو الزيارات لكي تجدها هنا مجتمعة",
              style: GoogleFonts.cairo(
                color: const Color(0xFF94A3B8),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBookmark(AppProvider provider, FavoriteItem item) {
    if (item.type == 'surah') {
      provider.toggleSurahBookmark(item.data.name);
    } else if (item.type == 'dua') {
      provider.toggleDuaBookmark(item.data.title);
    } else if (item.type == 'ziyarat') {
      provider.toggleZiyaratBookmark(item.data.title);
    }
  }

  void _navigateToReader(BuildContext context, FavoriteItem item) {
    if (item.type == 'surah') {
      final String fullText = QuranTextBuilder.buildFullSurahText(item.data.verses);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Consumer<AppProvider>(
            builder: (context, prov, _) => ReaderScreen(
              title: "سورة ${item.data.name}",
              text: fullText,
              benefits: "عدد الآيات: ${item.data.verses.length} آية",
              isBookmarked: prov.isSurahBookmarked(item.data.name),
              onBookmarkToggle: () => prov.toggleSurahBookmark(item.data.name),
            ),
          ),
        ),
      );
    } else if (item.type == 'dua') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Consumer<AppProvider>(
            builder: (context, prov, _) => ReaderScreen(
              title: item.data.title,
              text: item.data.text,
              benefits: item.data.benefits,
              isBookmarked: prov.isDuaBookmarked(item.data.title),
              onBookmarkToggle: () => prov.toggleDuaBookmark(item.data.title),
            ),
          ),
        ),
      );
    } else if (item.type == 'ziyarat') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Consumer<AppProvider>(
            builder: (context, prov, _) => ReaderScreen(
              title: item.data.title,
              text: item.data.text,
              benefits: item.data.benefits,
              isBookmarked: prov.isZiyaratBookmarked(item.data.title),
              onBookmarkToggle: () => prov.toggleZiyaratBookmark(item.data.title),
            ),
          ),
        ),
      );
    }
  }
}




