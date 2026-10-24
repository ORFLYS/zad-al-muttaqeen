// views/search_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shia_data.dart';
import '../utils/quran_text_builder.dart';
import 'reader_screen.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<SearchIndexItem> _allIndexItems = [];
  List<SearchIndexItem> _filteredResults = [];

  // قائمة البحث الشائعة للاختيار السريع
  final List<String> _popularSuggestions = [
    "زيارة عاشوراء",
    "دعاء كميل",
    "دعاء العهد",
    "دعاء التوسل",
    "دعاء القاموس",
    "الدعاء الجامع",
  ];

  @override
  void initState() {
    super.initState();
    _buildSearchDatabase();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _filterResults();
    });
  }

  // بناء الفهرس الشامل لكل محتويات التطبيق للبحث الفوري
  void _buildSearchDatabase() {
    final List<SearchIndexItem> database = [];

    // 1. سور القرآن الكريم
    for (var surah in ShiaData.surahs) {
      database.add(
        SearchIndexItem(
          title: "سورة ${surah.name}",
          type: "سورة",
          text: QuranTextBuilder.buildFullSurahText(surah.verses),
          subtitle: "سورة ${surah.type} | عدد آياتها ${surah.verses.length}",
          surah: surah,
        ),
      );
    }

    // 2. الأدعية العامة
    for (var dua in ShiaData.duas) {
      database.add(
        SearchIndexItem(
          title: dua.title,
          type: "دعاء",
          text: dua.text,
          subtitle: dua.benefits.split('،').first,
          benefits: dua.benefits,
        ),
      );
    }

    // 3. أدعية الأيام (السبت - الجمعة)
    for (var dua in ShiaData.dailyDuas) {
      database.add(
        SearchIndexItem(
          title: dua.title,
          type: "دعاء الأيام",
          text: dua.text,
          subtitle: dua.benefits.isNotEmpty ? dua.benefits.split('،').first : "دعاء الأيام",
          benefits: dua.benefits,
        ),
      );
    }

    // 4. تعقيبات الصلاة
    for (var dua in ShiaData.prayerDuas) {
      database.add(
        SearchIndexItem(
          title: dua.title,
          type: "تعقيبات الصلاة",
          text: dua.text,
          subtitle: dua.benefits.isNotEmpty ? dua.benefits.split('،').first : "تعقيب الصلاة",
          benefits: dua.benefits,
        ),
      );
    }

    // 5. الزيارات العامة
    for (var ziyarat in ShiaData.ziyarats) {
      database.add(
        SearchIndexItem(
          title: ziyarat.title,
          type: "زيارة",
          text: ziyarat.text,
          subtitle: ziyarat.benefits.split('،').first,
          benefits: ziyarat.benefits,
        ),
      );
    }

    // 6. زيارة الأيام (أيام الأسبوع)
    for (var ziyarat in ShiaData.dailyZiyarats) {
      database.add(
        SearchIndexItem(
          title: ziyarat.title,
          type: "زيارة الأيام",
          text: ziyarat.text,
          subtitle: ziyarat.benefits.isNotEmpty ? ziyarat.benefits.split('،').first : "زيارة الأيام",
          benefits: ziyarat.benefits,
        ),
      );
    }

    _allIndexItems = database;
  }

  // تصفية النتائج بالبحث الذكي وتجاوز الفروقات البسيطة مثل (أ، ا، إ، ة، ه)
  void _filterResults() {
    if (_searchQuery.isEmpty) {
      _filteredResults = [];
      return;
    }

    final normalizedQuery = _normalizeArabic(_searchQuery);
    _filteredResults = _allIndexItems.where((item) {
      final normalizedTitle = _normalizeArabic(item.title);
      return normalizedTitle.contains(normalizedQuery);
    }).toList();
  }

  // دالة توحيد الحروف العربية لجعل عملية البحث أكثر ذكاءً ومرونة
  String _normalizeArabic(String input) {
    var output = input.toLowerCase();
    output = output.replaceAll(RegExp(r'[أإآ]'), 'ا');
    output = output.replaceAll(RegExp(r'[ة]'), 'ه');
    output = output.replaceAll(RegExp(r'[ى]'), 'ي');
    output = output.replaceAll(RegExp(r'[\u064B-\u065F]'), ''); // إزالة التشكيل تماماً
    return output;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAF9F6),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "البحث الشامل",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // 1. شريط البحث الفاخر بالأعلى
            _buildSearchInput(isDark),

            // 2. محتوى الصفحة المتغير (تلميحات أو نتائج)
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildSuggestionsView(isDark)
                  : _buildSearchResultsList(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E293B),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          autofocus: false,
          style: GoogleFonts.cairo(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: "ابحث عن دعاء، زيارة، أو سورة...",
            hintStyle: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF8A1525), size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: Color(0xFF94A3B8), size: 20),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // شاشة التلميحات السريعة
  Widget _buildSuggestionsView(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: Color(0xFF8A1525), size: 20),
              const SizedBox(width: 8),
              Text(
                "عمليات البحث الشائعة",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: _popularSuggestions.map((suggestion) {
              return ActionChip(
                label: Text(
                  suggestion,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.amber[50] : const Color(0xFF475569),
                  ),
                ),
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isDark ? Colors.transparent : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                onPressed: () {
                  _searchController.text = suggestion;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: suggestion.length),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 64,
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
                const SizedBox(height: 12),
                Text(
                  "ابحث عن أي ورد روحي بسهولة فائقة",
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // شاشة عرض نتائج البحث الفعالة
  Widget _buildSearchResultsList(bool isDark) {
    if (_filteredResults.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFF8A1525)),
              const SizedBox(height: 16),
              Text(
                "لم نجد نتائج مطابقة لـ \"$_searchQuery\"",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "تأكد من كتابة الكلمات بشكل صحيح أو حاول البحث بعبارات أخرى.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final item = _filteredResults[index];
        return _buildSearchResultCard(context, item, isDark);
      },
    );
  }

  Widget _buildSearchResultCard(BuildContext context, SearchIndexItem item, bool isDark) {
    IconData leadingIcon = Icons.spa_rounded;
    Color iconColor = const Color(0xFF8A1525);
    Color tagBgColor = const Color(0xFFFEE2E2);

    if (item.type == "سورة") {
      leadingIcon = Icons.menu_book_rounded;
      iconColor = const Color(0xFFD97706);
      tagBgColor = const Color(0xFFFEF3C7);
    } else if (item.type.startsWith("زيارة")) {
      leadingIcon = Icons.mosque_rounded;
      iconColor = const Color(0xFF16A34A);
      tagBgColor = const Color(0xFFDCFCE7);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(leadingIcon, color: iconColor, size: 22),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.subtitle ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tagBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.type,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_left_rounded, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
        onTap: () {
          if (item.surah != null) {
            // فتح صفحة قراءة السورة القرآنية مباشرة بتجربة قراءة فاخرة جداً!
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => _SurahReaderScreen(surah: item.surah!),
              ),
            );
          } else {
            // فتح صفحة قراءة الأدعية والزيارات
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReaderScreen(
                  title: item.title,
                  text: item.text,
                  benefits: item.benefits,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// نموذج عنصر الفهرس
class SearchIndexItem {
  final String title;
  final String type;
  final String text;
  final String? subtitle;
  final String? benefits;
  final Surah? surah;

  SearchIndexItem({
    required this.title,
    required this.type,
    required this.text,
    this.subtitle,
    this.benefits,
    this.surah,
  });
}

// شاشة قراءة السورة القرآنية المفتوحة من البحث بجمالية لا مثيل لها
class _SurahReaderScreen extends StatefulWidget {
  final Surah surah;

  const _SurahReaderScreen({required this.surah});

  @override
  State<_SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<_SurahReaderScreen> {
  double _fontSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String fullText = QuranTextBuilder.buildFullSurahText(widget.surah.verses);
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
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF1E293B),
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 20),
            onPressed: () {
              // مشاركة السورة الكريمة
            },
          ),
          title: Text(
            "سورة ${widget.surah.name}",
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // شريط التحكم بالخط
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
                      activeColor: const Color(0xFF8A1525),
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

            // عرض نص السورة بالكامل
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




