// views/reader_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ReaderScreen extends StatefulWidget {
  final String title;
  final String text;
  final String? benefits;
  final bool? isBookmarked;
  final VoidCallback? onBookmarkToggle;
  final bool isDua;

  const ReaderScreen({
    super.key,
    required this.title,
    required this.text,
    this.benefits,
    this.isBookmarked,
    this.onBookmarkToggle,
    this.isDua = false,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  double _fontSize = 24.0;
  bool _isBookmarkedLocally = false;

  @override
  void initState() {
    super.initState();
    _isBookmarkedLocally = widget.isBookmarked ?? false;
  }

  List<TextSpan> _buildHighlightedText(String text, bool isDua) {
    final List<String> targetWords = [
      "اللهم", "الله", "اللهي", "رب", "ربي", "ربنا", "ربك", "ربكم", "ربهم", "ربه", "ربها",
      "إلهي", "الهي", "إلهنا", "الهنا", "إلهك", "الهك", "لله", "بالله", "والله", "تالله", "فالله",
      "مولاي", "مولانا"
    ];

    String buildRegexForWord(String word) {
      // Allow diacritics (\u064B-\u065F), tatweel (\u0640), and superscript alef (\u0670) between any letters
      return word.split('').map((char) {
        if (char == 'ا' || char == 'أ' || char == 'إ' || char == 'آ') {
          return r'[اأإآٱ]';
        }
        return char;
      }).join(r'[\u064B-\u065F\u0640\u0670]*') + r'[\u064B-\u065F\u0640\u0670]*';
    }

    final String wordBoundary = r'[\u0621-\u065F\u0670\u0671]';
    final String pattern = '(?<!$wordBoundary)(?:${targetWords.map(buildRegexForWord).join('|')})(?!$wordBoundary)';
    final RegExp regExp = RegExp(pattern);

    final RegExp symbolRegExp = RegExp(
      r'(﴿[\u0660-\u0669\u06F0-\u06F9]+﴾|۝[\u0660-\u0669\u06F0-\u06F9]+|[\u06DD][\u0660-\u0669\u06F0-\u06F9]+|\([\u0660-\u0669\u06F0-\u06F9]+\))',
    );

    List<TextSpan> spans = [];

    void addTextSegment(String segment) {
      if (segment.isEmpty) return;
      int idx = 0;
      for (final sMatch in symbolRegExp.allMatches(segment)) {
        if (sMatch.start > idx) {
          spans.add(TextSpan(text: segment.substring(idx, sMatch.start)));
        }
        spans.add(TextSpan(
          text: sMatch.group(0),
          style: const TextStyle(color: Color(0xFF8A1525), fontWeight: FontWeight.bold),
        ));
        idx = sMatch.end;
      }
      if (idx < segment.length) {
        spans.add(TextSpan(text: segment.substring(idx)));
      }
    }

    int currentIndex = 0;

    for (final match in regExp.allMatches(text)) {
      if (match.start > currentIndex) {
        addTextSegment(text.substring(currentIndex, match.start));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(color: Color(0xFF8A1525), fontWeight: FontWeight.w900),
      ));
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      addTextSegment(text.substring(currentIndex));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B), // خلفية كحلي/سليت غامق
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            widget.title,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
              tooltip: "نسخ النص",
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: "${widget.title}\n\n${widget.text}"));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "تم نسخ النص إلى الحافظة بنجاح",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: const Color(0xFF1E293B),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
              },
            ),
            if (widget.onBookmarkToggle != null)
              IconButton(
                icon: Icon(
                  _isBookmarkedLocally ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: _isBookmarkedLocally ? const Color(0xFFF59E0B) : Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _isBookmarkedLocally = !_isBookmarkedLocally;
                  });
                  widget.onBookmarkToggle!();
                },
              ),
          ],
        ),
        body: Column(
          children: [
            // شريط التحكم بالخط
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Text(
                    "حجم الخط:",
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 18.0,
                      max: 36.0,
                      divisions: 9,
                      activeColor: const Color(0xFF8A1525),
                      inactiveColor: Colors.grey[300],
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
                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF8A1525)),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Column(
                  children: [
                    if (widget.benefits != null && widget.benefits!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        margin: const EdgeInsets.only(bottom: 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B), // كارت كحلي فخم مثل مواقيت الصلاة والمزيد
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Text(
                          widget.benefits!,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            height: 1.6,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // لون أبيض ناصع وواضح كما طلب المستخدم
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    SelectionArea(
                      child: Text.rich(
                        TextSpan(
                          children: _buildHighlightedText(widget.text, widget.isDua),
                          style: GoogleFonts.amiri(
                            fontSize: _fontSize,
                            height: 1.9,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


