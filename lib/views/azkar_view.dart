// views/azkar_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shia_data.dart';
import 'reader_screen.dart';

class AzkarView extends StatefulWidget {
  const AzkarView({super.key});

  @override
  State<AzkarView> createState() => _AzkarViewState();
}

class _AzkarViewState extends State<AzkarView> with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A), // خلفية داكنة فخمة متطابقة مع الهوية البصرية
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "ابحث هنا...",
                    hintStyle: GoogleFonts.cairo(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                )
              : Text(
                  "الأذكار والأوراد",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchQuery = "";
                    _searchController.clear();
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFF59E0B), // مؤشر أصفر/ذهبي فاقع متطابق
            indicatorWeight: 3.5,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 13.0),
            tabs: const [
              Tab(text: "المناجاة"),
              Tab(text: "التسبيحات"),
              Tab(text: "التعويذات"),
              Tab(text: "أذكار الأيام"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDhikrList(ShiaData.munajats, Icons.bubble_chart_outlined),
            _buildDhikrList(ShiaData.tasbihat, Icons.fingerprint_rounded),
            _buildDhikrList(ShiaData.tawizat, Icons.shield_outlined),
            _buildWeekAzkarList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrList(List<Dhikr> list, IconData icon) {
    final filteredList = _searchQuery.isEmpty ? list : list.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return Consumer<AppProvider>(
          builder: (context, provider, child) {
            final isFav = provider.isZikrBookmarked(item.title);
            return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReaderScreen(
                  title: item.title,
                  text: item.text,
                  benefits: item.benefits,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    color: const Color(0xFF1E293B).withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1E293B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.benefits,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: isFav ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onPressed: () {
                    provider.toggleZikrBookmark(item.title);
                  },
                ),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF94A3B8),
                  size: 14,
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

  Widget _buildWeekAzkarList() {
    final allList = ShiaData.weekAzkar;
    final list = _searchQuery.isEmpty 
        ? allList 
        : allList.where((item) => (item['day'] ?? item['dhikr'] ?? '').toLowerCase().contains(_searchQuery)).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Consumer<AppProvider>(
          builder: (context, provider, child) {
            final isFav = provider.isZikrBookmarked("ذكر يوم ${item["day"]}");
            return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReaderScreen(
                  title: "ذكر يوم ${item["day"]}",
                  text: "${item["dhikr"]}\n\nالعدد: ${item["count"]}",
                  benefits: item["reward"],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item["day"] ?? "",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["dhikr"] ?? "",
                        style: GoogleFonts.amiri(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${item["count"]} • ${item["reward"]}",
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: isFav ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onPressed: () {
                    provider.toggleZikrBookmark("ذكر يوم ${item["day"]}");
                  },
                ),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF94A3B8),
                  size: 14,
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
}


