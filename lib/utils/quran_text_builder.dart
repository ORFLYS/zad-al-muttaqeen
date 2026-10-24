import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

/// Helper utility for rendering Quran text with Arabic verse numbers styled
/// in the UI accent color matching the font size slider control.
class QuranTextBuilder {
  static final RegExp _symbolRegExp = RegExp(
    r'(﴿[\u0660-\u0669\u06F0-\u06F9]+﴾|۝[\u0660-\u0669\u06F0-\u06F9]+|[\u06DD][\u0660-\u0669\u06F0-\u06F9]+|\([\u0660-\u0669\u06F0-\u06F9]+\))',
  );

  /// Combines all verses of a Surah into a single continuous string without redundant English numbers.
  static String buildFullSurahText(List<dynamic> verses) {
    return verses.map((v) => v.text).join(" ");
  }

  /// Builds TextSpan list for Quran text, highlighting Arabic verse numbers and their brackets
  /// in the specified active color matching the font size slider control (0xFF8A1525).
  static List<TextSpan> buildQuranSpans({
    required String text,
    required TextStyle defaultStyle,
    required bool isDark,
    Color? customSymbolColor,
  }) {
    final Color symbolColor = customSymbolColor ?? const Color(0xFF8A1525);

    final List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final match in _symbolRegExp.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: defaultStyle,
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: defaultStyle.copyWith(
          color: symbolColor,
          fontWeight: FontWeight.bold,
        ),
      ));
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: defaultStyle,
      ));
    }

    return spans;
  }

  /// Coordinates [surahNumber, verseNumber] for curated short complete inspiring daily Quran quotes.
  /// All coordinates point to 100% complete Quranic verses that fit cleanly in 1-2 lines.
  static const List<List<int>> _inspiringVerseCoords = [
    [94, 6],   // ﴿إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾ — الشرح 6
    [93, 5],   // ﴿وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ﴾ — الضحى 5
    [55, 60],  // ﴿هَلْ جَزَاءُ الْإِحْسَانِ إِلَّا الْإِحْسَانُ﴾ — الرحمن 60
    [26, 80],  // ﴿وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ﴾ — الشعراء 80
    [20, 25],  // ﴿قَالَ رَبِّ اشْرَحْ لِي صَدْرِي﴾ — طه 25
    [20, 26],  // ﴿وَيَسِّرْ لِي أَمْرِي﴾ — طه 26
    [94, 5],   // ﴿فَإِنَّ مَعَ الْعُسْرِ يُسْرًا﴾ — الشرح 5
    [93, 3],   // ﴿مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ﴾ — الضحى 3
    [93, 4],   // ﴿وَلَلْآخِرَةُ خَيْرٌ لَكَ مِنَ الْأُولَىٰ﴾ — الضحى 4
    [93, 11],  // ﴿وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ﴾ — الضحى 11
    [112, 2],  // ﴿اللَّهُ الصَّمَدُ﴾ — الإخلاص 2
    [112, 4],  // ﴿وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ﴾ — الإخلاص 4
    [108, 2],  // ﴿فَصَلِّ لِرَبِّكَ وَانْحَرْ﴾ — الكوثر 2
    [108, 3],  // ﴿إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ﴾ — الكوثر 3
    [1, 2],    // ﴿الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ﴾ — الفاتحة 2
    [1, 3],    // ﴿الرَّحْمَـٰنِ الرَّحِيمِ﴾ — الفاتحة 3
    [1, 4],    // ﴿مَالِكِ يَوْمِ الدِّينِ﴾ — الفاتحة 4
    [1, 5],    // ﴿إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ﴾ — الفاتحة 5
    [1, 6],    // ﴿اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ﴾ — الفاتحة 6
    [33, 3],   // ﴿وَتَوَكَّلْ عَلَى اللَّهِ ۚ وَكَفَىٰ بِاللَّهِ وَكِيلًا﴾ — الأحزاب 3
    [94, 7],   // ﴿فَإِذَا فَرَغْتَ فَانْصَبْ﴾ — الشرح 7
    [94, 8],   // ﴿وَإِلَىٰ رَبِّكَ فَارْغَبْ﴾ — الشرح 8
  ];

  /// Returns a deterministic Daily Quran Quote for the current day.
  static DailyQuranQuote getDailyQuote() {
    final now = DateTime.now();
    // Calculate a stable index based on day of year
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % _inspiringVerseCoords.length;

    final coord = _inspiringVerseCoords[index];
    final surahNum = coord[0];
    final verseNum = coord[1];

    final surahName = quran.getSurahNameArabic(surahNum);
    final verseText = quran.getVerse(surahNum, verseNum, verseEndSymbol: false);

    return DailyQuranQuote(
      surahName: surahName,
      verseNumber: verseNum,
      verseText: verseText,
    );
  }
}

class DailyQuranQuote {
  final String surahName;
  final int verseNumber;
  final String verseText;

  DailyQuranQuote({
    required this.surahName,
    required this.verseNumber,
    required this.verseText,
  });
}
