// views/duas_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/shia_data.dart';
import '../providers/app_provider.dart';
import 'reader_screen.dart';

class DuasView extends StatefulWidget {
  const DuasView({super.key});

  @override
  State<DuasView> createState() => _DuasViewState();
}

class _DuasViewState extends State<DuasView> with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                    hintText: "بحث في القسم...",
                    hintStyle: GoogleFonts.cairo(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                )
              : Text(
                  "الأدعية والتعقيبات",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFF59E0B), // مؤشر أصفر/ذهبي فاقع متطابق
            indicatorWeight: 3.5,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 13.0),
            tabs: const [
              Tab(text: "أدعية الأيام"),
              Tab(text: "تعقيبات الصلاة"),
              Tab(text: "الأدعية العامة"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDailyDuasList(),
            _buildPrayerDuasList(),
            _buildGeneralDuasList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyDuasList() {
    final allList = ShiaData.dailyDuas;
    final list = _searchQuery.isEmpty 
        ? allList 
        : allList.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Consumer<AppProvider>(
          builder: (context, provider, child) {
            final isFav = provider.isDuaBookmarked(item.title);
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Consumer<AppProvider>(
                      builder: (context, prov, _) => ReaderScreen(
                        title: item.title,
                        text: item.text,
                        benefits: item.benefits,
                        isBookmarked: prov.isDuaBookmarked(item.title),
                        onBookmarkToggle: () => prov.toggleDuaBookmark(item.title),
                        isDua: true,
                      ),
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
                      child: const Icon(
                        Icons.volunteer_activism_outlined,
                        color: Color(0xFF1E293B),
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
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: isFav ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () {
                        provider.toggleDuaBookmark(item.title);
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

  Widget _buildPrayerDuasList() {
    final allList = ShiaData.prayerDuas;
    final list = _searchQuery.isEmpty 
        ? allList 
        : allList.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Consumer<AppProvider>(
          builder: (context, provider, child) {
            final isFav = provider.isDuaBookmarked(item.title);
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Consumer<AppProvider>(
                      builder: (context, prov, _) => ReaderScreen(
                        title: item.title,
                        text: item.text,
                        benefits: item.benefits,
                        isBookmarked: prov.isDuaBookmarked(item.title),
                        onBookmarkToggle: () => prov.toggleDuaBookmark(item.title),
                        isDua: true,
                      ),
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
                      child: const Icon(
                        Icons.volunteer_activism_outlined,
                        color: Color(0xFF1E293B),
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
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: isFav ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () {
                        provider.toggleDuaBookmark(item.title);
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

  Widget _buildGeneralDuasList() {
    final allList = ShiaData.duas;
    final list = _searchQuery.isEmpty 
        ? allList 
        : allList.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Consumer<AppProvider>(
          builder: (context, provider, child) {
            final isFav = provider.isDuaBookmarked(item.title);
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Consumer<AppProvider>(
                      builder: (context, prov, _) => ReaderScreen(
                        title: item.title,
                        text: item.text,
                        benefits: item.benefits,
                        isBookmarked: prov.isDuaBookmarked(item.title),
                        onBookmarkToggle: () => prov.toggleDuaBookmark(item.title),
                        isDua: true,
                      ),
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
                      child: const Icon(
                        Icons.volunteer_activism_outlined,
                        color: Color(0xFF1E293B),
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
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: isFav ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () {
                        provider.toggleDuaBookmark(item.title);
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


