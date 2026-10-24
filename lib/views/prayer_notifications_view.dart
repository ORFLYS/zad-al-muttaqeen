import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/app_provider.dart';
import '../services/notification_service.dart';

class PrayerNotificationsView extends StatefulWidget {
  const PrayerNotificationsView({super.key});

  @override
  State<PrayerNotificationsView> createState() => _PrayerNotificationsViewState();
}

class _PrayerNotificationsViewState extends State<PrayerNotificationsView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingMuezzinId;

  final List<Map<String, String>> _availableMuezzins = [
    {
      'id': 'osama',
      'name': 'الشيخ أسامة الكربلائي',
      'asset': 'assets/osama.mp3',
    },
    {
      'id': 'hani',
      'name': 'السيد هاني الموسوي',
      'asset': 'assets/hani.mp3',
    },
    {
      'id': 'shubbar',
      'name': 'الشيخ شبر معلة (العتبة العلوية)',
      'asset': 'assets/shubbar.mp3',
    },
    // يمكن إضافة المزيد مستقبلاً هنا
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.requestPermissions();
    
    // مراقبة حالة المشغل لتغيير الأيقونة عند انتهاء الصوت
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            _playingMuezzinId = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(String id, String assetPath) async {
    if (_playingMuezzinId == id && _audioPlayer.playing) {
      await _audioPlayer.pause();
      setState(() {
        _playingMuezzinId = null;
      });
    } else {
      setState(() {
        _playingMuezzinId = id;
      });
      try {
        await _audioPlayer.setAsset(assetPath);
        await _audioPlayer.play();
      } catch (e) {
        // Handle error quietly
        debugPrint("Error playing audio: $e");
        setState(() {
          _playingMuezzinId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تنبيهات الصلاة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildPrayerToggle(
            title: 'صلاة الفجر',
            subtitle: 'تنبيه بصوت الأذان عند دخول وقت صلاة الفجر',
            value: provider.notifyFajr,
            onChanged: (val) => provider.setNotifyFajr(val),
          ),
          const SizedBox(height: 12),
          _buildPrayerToggle(
            title: 'صلاة الظهرين',
            subtitle: 'تنبيه بصوت الأذان عند دخول وقت صلاة الظهر',
            value: provider.notifyDhuhr,
            onChanged: (val) => provider.setNotifyDhuhr(val),
          ),
          const SizedBox(height: 12),
          _buildPrayerToggle(
            title: 'صلاة العشاءين',
            subtitle: 'تنبيه بصوت الأذان عند دخول وقت صلاة المغرب',
            value: provider.notifyMaghrib,
            onChanged: (val) => provider.setNotifyMaghrib(val),
          ),
          const SizedBox(height: 32),
          _buildMuezzinSelector(provider),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8A1525).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8A1525).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded, color: Color(0xFF8A1525), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'سيتم تنبيهك بصوت الأذان في أوقات الصلاة المحددة بناءً على منطقتك الجغرافية الحالية.',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF8A1525),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        value: value,
        activeColor: const Color(0xFF8A1525),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMuezzinSelector(AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'صوت الأذان',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: _availableMuezzins.map((muezzin) {
              final id = muezzin['id']!;
              final name = muezzin['name']!;
              final asset = muezzin['asset']!;
              final isSelected = provider.selectedMuezzin == id;
              final isPlaying = _playingMuezzinId == id;

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Radio<String>(
                      value: id,
                      groupValue: provider.selectedMuezzin,
                      activeColor: const Color(0xFF8A1525),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          provider.setSelectedMuezzin(newValue);
                        }
                      },
                    ),
                    title: Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? const Color(0xFF8A1525) : const Color(0xFF0F172A),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                        color: isPlaying ? const Color(0xFF8A1525) : const Color(0xFF94A3B8),
                        size: 36,
                      ),
                      onPressed: () => _togglePlay(id, asset),
                    ),
                    onTap: () {
                      provider.setSelectedMuezzin(id);
                    },
                  ),
                  if (muezzin != _availableMuezzins.last)
                    const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xFFE2E8F0)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
