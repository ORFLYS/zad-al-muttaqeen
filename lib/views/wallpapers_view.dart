// views/wallpapers_view.dart
// معرض الخلفيات الإسلامية - تصفح وعرض وتعيين كواجهة للتطبيق

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gal/gal.dart';
import '../../providers/app_provider.dart';

class WallpapersView extends StatefulWidget {
  const WallpapersView({super.key});

  @override
  State<WallpapersView> createState() => _WallpapersViewState();
}

class _WallpapersViewState extends State<WallpapersView> {
  // القسم المحدد حالياً - null يعني عرض جميع الخلفيات
  String? _selectedCategory;

  // خريطة توزيع الخلفيات حسب الأقسام الثلاثة
  static final Map<String, List<String>> _categoryWallpapers = {
    'منوعات': [
      'assets/aa.jpg', // خلفية رقم 4
    ],
    'مساجد ومراقد': [
      'assets/d1.jpg',
      'assets/d2.jpg',
      'assets/d3.jpg',
      'assets/d4.jpg',
      'assets/d5.jpg',
      'assets/d6.jpg',
      'assets/22.jpg', // خلفية رقم 1
      'assets/1.jpg',  // خلفية رقم 5
      'assets/2.jpg',  // خلفية رقم 6
      'assets/3.jpg',  // خلفية رقم 7
      'assets/4.jpg',  // خلفية رقم 8
      'assets/5.jpg',  // خلفية رقم 9
      'assets/66.jpg', // خلفية رقم 10
      'assets/77.jpg', // خلفية رقم 11
      'assets/GG.jpg', // خلفية رقم 12
    ],
    'مناسبات': [
      'assets/23.jpg', // خلفية رقم 2
      'assets/24.jpg', // خلفية رقم 3
    ],
  };

  Widget _buildCategoryTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8A1525) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFFE5C158) : Colors.grey.shade200,
              width: isSelected ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF8A1525).withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFFE5C158) : const Color(0xFF8A1525),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allWallpapers = provider.wallpapers;

    // تحديد الخلفيات المعروضة: إن لم يُختر قسم، تُعرض جميع الخلفيات
    final displayedWallpapers = _selectedCategory == null
        ? allWallpapers
        : (_categoryWallpapers[_selectedCategory] ?? []);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "معرض الخلفيات",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF8A1525),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF8A1525), size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            // شريط الأقسام الثلاثة في الأعلى (منوعات - مساجد ومراقد - مناسبات)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                children: [
                  // 1. منوعات
                  Expanded(
                    child: _buildCategoryTab(
                      title: "منوعات",
                      icon: Icons.auto_awesome_rounded,
                      isSelected: _selectedCategory == "منوعات",
                      onTap: () {
                        setState(() {
                          _selectedCategory = _selectedCategory == "منوعات" ? null : "منوعات";
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 2. مساجد ومراقد
                  Expanded(
                    child: _buildCategoryTab(
                      title: "مساجد ومراقد",
                      icon: Icons.mosque_rounded,
                      isSelected: _selectedCategory == "مساجد ومراقد",
                      onTap: () {
                        setState(() {
                          _selectedCategory = _selectedCategory == "مساجد ومراقد" ? null : "مساجد ومراقد";
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 3. مناسبات
                  Expanded(
                    child: _buildCategoryTab(
                      title: "مناسبات",
                      icon: Icons.event_note_rounded,
                      isSelected: _selectedCategory == "مناسبات",
                      onTap: () {
                        setState(() {
                          _selectedCategory = _selectedCategory == "مناسبات" ? null : "مناسبات";
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // شريط توضيحي في حال تفعيل أحد الأقسام مع خيار عرض الكل
            if (_selectedCategory != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8A1525),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "عرض: $_selectedCategory (${displayedWallpapers.length} خلفيات)",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF8A1525),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close_rounded, size: 12, color: Colors.grey.shade700),
                            const SizedBox(width: 3),
                            Text(
                              "عرض الكل",
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // شبكة عرض الخلفيات
            Expanded(
              child: displayedWallpapers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "لا توجد خلفيات في هذا القسم حالياً",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: displayedWallpapers.length,
                        itemBuilder: (context, index) {
                          final wallpaper = displayedWallpapers[index];
                          final isActive = provider.activeWallpaper == wallpaper;
                          final originalIndex = allWallpapers.indexOf(wallpaper);
                          final displayNum = originalIndex != -1 ? (originalIndex + 1) : (index + 1);

                          return GestureDetector(
                            onTap: () {
                              // فتح الصورة بالحجم الكامل
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => _WallpaperFullScreen(
                                    wallpaperPath: wallpaper,
                                    wallpaperIndex: displayNum,
                                    totalCount: allWallpapers.length,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: isActive
                                    ? Border.all(color: const Color(0xFFE5C158), width: 3)
                                    : Border.all(color: Colors.grey.shade200, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(isActive ? 13 : 15),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // الصورة
                                    Image.asset(
                                      wallpaper,
                                      fit: BoxFit.cover,
                                    ),
                                    // شارة "الحالية" إذا كانت الخلفية النشطة
                                    if (isActive)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE5C158),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.3),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            "الحالية",
                                            style: GoogleFonts.cairo(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    // تدرج سفلي خفيف
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withValues(alpha: 0.4),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "خلفية $displayNum",
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شاشة عرض الخلفية بالحجم الكامل مع خيارات الحفظ والتعيين
class _WallpaperFullScreen extends StatelessWidget {
  final String wallpaperPath;
  final int wallpaperIndex;
  final int totalCount;

  const _WallpaperFullScreen({
    required this.wallpaperPath,
    required this.wallpaperIndex,
    required this.totalCount,
  });

  Future<void> _saveWallpaperToDevice(BuildContext context, String assetPath) async {
    try {
      // 1. تحميل الصورة من الأصول (Assets) كبايتات
      final byteData = await rootBundle.load(assetPath);
      Uint8List bytes = byteData.buffer.asUint8List();

      // إضافة حقوق التطبيق المائية (صورة 88 الشفافة)
      try {
        final ui.Codec bgCodec = await ui.instantiateImageCodec(bytes);
        final ui.Image bgImage = (await bgCodec.getNextFrame()).image;

        final ByteData logoData = await rootBundle.load('assets/88.jpg');
        final ui.Codec logoCodec = await ui.instantiateImageCodec(logoData.buffer.asUint8List());
        final ui.Image logoImage = (await logoCodec.getNextFrame()).image;

        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final ui.Canvas canvas = ui.Canvas(recorder);

        // رسم الخلفية الأصلية
        canvas.drawImage(bgImage, Offset.zero, ui.Paint());

        // حساب الحجم (صغير نسبياً - 15% من عرض الشاشة ليكون أنيقاً)
        double logoWidth = bgImage.width * 0.15;
        double scale = logoWidth / logoImage.width;
        double logoHeight = logoImage.height * scale;

        // رسم في الأسفل بالمنتصف
        double x = (bgImage.width - logoWidth) / 2;
        double y = bgImage.height - logoHeight - (bgImage.height * 0.05); // ارتفاع من الأسفل 5%

        canvas.save();
        canvas.translate(x, y);
        canvas.scale(scale, scale);
        
        // رسم الشعار بشفافية مع إزالة الخلفية السوداء
        final paint = ui.Paint()
          ..blendMode = ui.BlendMode.screen
          ..colorFilter = const ui.ColorFilter.mode(
            Color.fromRGBO(255, 255, 255, 0.7), // شفافية النص
            ui.BlendMode.modulate,
          );
        canvas.drawImage(logoImage, Offset.zero, paint);
        canvas.restore();

        final ui.Picture picture = recorder.endRecording();
        final ui.Image finalImage = await picture.toImage(bgImage.width, bgImage.height);
        final ByteData? finalByteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
        
        if (finalByteData != null) {
          bytes = finalByteData.buffer.asUint8List();
        }
      } catch (e) {
        debugPrint("Watermark error: $e");
      }

      // 2. تحديد اسم الحفظ وطريق التخزين
      // نستبدل الامتداد بـ png لأن الصورة المدمجة تم تصديرها كـ png
      String fileName = assetPath.split('/').last.replaceAll(RegExp(r'\.jpg|\.jpeg'), '.png');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final saveName = "hqepa_${timestamp}_$fileName";

      if (Platform.isAndroid || Platform.isIOS) {
        // حفظ الصورة مباشرة في المعرض الخاص بالمستخدم باستخدام حزمة gal
        await Gal.putImageBytes(bytes, album: "زاد المتقين");
        if (!context.mounted) return;
        _showSnackBar(context, "تم حفظ الصورة في معرض الصور (الاستوديو) بنجاح!", isSuccess: true);
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // دعم أنظمة سطح المكتب
        final file = File(saveName);
        await file.writeAsBytes(bytes);
        if (!context.mounted) return;
        _showSnackBar(context, "تم حفظ الصورة في مجلد التطبيق بنجاح!", isSuccess: true);
      } else {
        throw Exception("المنصة الحالية غير مدعومة للحفظ المباشر");
      }
    } catch (e) {
      debugPrint("Save Image Error: $e");
      if (!context.mounted) return;
      _showSnackBar(context, "لم نتمكن من حفظ الصورة تلقائياً. تأكد من منح صلاحية التخزين للتطبيق.", isSuccess: false);
    }
  }

  void _showSnackBar(BuildContext context, String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isSuccess ? const Color(0xFF8A1525) : Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isActive = provider.activeWallpaper == wallpaperPath;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // الصورة بالحجم الكامل مع إمكانية التكبير
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.asset(
                wallpaperPath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // شريط علوي شفاف مع زر الرجوع
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر الرجوع
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                        // عنوان الصورة
                        Text(
                          "خلفية $wallpaperIndex من $totalCount",
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
                            ],
                          ),
                        ),
                        // مساحة فارغة للتوازن
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // شريط الأزرار السفلي
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Row(
                      children: [
                        // 1. زر حفظ الصورة للرأس/الألبوم
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _saveWallpaperToDevice(context, wallpaperPath),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.download_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "حفظ الصورة",
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // 2. زر تعيين كواجهة للتطبيق
                        Expanded(
                          child: GestureDetector(
                            onTap: isActive
                                ? null
                                : () {
                                    provider.setWallpaper(wallpaperPath);
                                    _showSnackBar(context, "تم تعيين الخلفية كواجهة للتطبيق بنجاح!", isSuccess: true);
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : const Color(0xFFE5C158),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isActive
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: const Color(0xFFE5C158).withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isActive ? Icons.check_circle_rounded : Icons.wallpaper_rounded,
                                    color: isActive ? Colors.white70 : Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isActive ? "الخلفية النشطة" : "تعيين كواجهة",
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: isActive ? Colors.white70 : Colors.white,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


