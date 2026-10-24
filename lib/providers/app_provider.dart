// providers/app_provider.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:shia_hijri_calendar/shia_hijri_calendar.dart';
import '../services/location_service.dart';
import '../utils/shia_prayer_calculator.dart';
import '../services/notification_service.dart';

class HiveAnchorStore extends StringAnchorStore {
  final Box box;
  HiveAnchorStore(this.box);

  @override
  Future<String?> readString() async => box.get('shia_hijri');

  @override
  Future<void> writeString(String value) async => box.put('shia_hijri', value);
}

class AppProvider with ChangeNotifier {
  // 1. الملاحة الأساسية
  bool _isFirstLaunch = true;
  bool get isFirstLaunch => _isFirstLaunch;

  int _activeTabIndex = 0;
  int get activeTabIndex => _activeTabIndex;

  void setActiveTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  // 2. الموقع والمدن والحسابات الشرعية
  ShiaCity _selectedCity = LocationService.defaultCity;
  ShiaCity get selectedCity => _selectedCity;
  
  bool _isGpsActive = false;
  bool get isGpsActive => _isGpsActive;

  ShiaPrayerTimes? _prayerTimes;
  ShiaPrayerTimes? get prayerTimes => _prayerTimes;

  bool _loadingLocation = false;
  bool get loadingLocation => _loadingLocation;

  // إعدادات تنبيهات الصلاة
  bool _notifyFajr = false;
  bool get notifyFajr => _notifyFajr;

  bool _notifyDhuhr = false;
  bool get notifyDhuhr => _notifyDhuhr;

  bool _notifyMaghrib = false;
  bool get notifyMaghrib => _notifyMaghrib;

  String _selectedMuezzin = 'osama';
  String get selectedMuezzin => _selectedMuezzin;

  // 3. قاعدة البيانات المحلية والمفضلة وحالة التطبيق
  Box? _settingsBox;

  late ShiaHijriCalendar _hijriCalendar;
  ShiaHijriCalendar get hijriCalendar => _hijriCalendar;

  HijriDate? _todayHijri;
  HijriDate? get todayHijri => _todayHijri;

  bool _loadingHijri = false;
  bool get loadingHijri => _loadingHijri;

  Future<void> _fetchTodayHijri({bool forceRefresh = false}) async {
    _loadingHijri = true;
    notifyListeners();
    try {
      _todayHijri = await _hijriCalendar.today(forceRefresh: forceRefresh);
    } catch (e) {
      debugPrint("Hijri fetch error: $e");
      _todayHijri = _hijriCalendar.gregorianToHijri(DateTime.now()).hijri;
    } finally {
      _loadingHijri = false;
      notifyListeners();
    }
  }

  Future<void> refreshHijriCalendar() async {
    await _fetchTodayHijri(forceRefresh: true);
  }

  int _prayerMinutesOffset = 0;
  int get prayerMinutesOffset => _prayerMinutesOffset;

  void setPrayerMinutesOffset(int offset) {
    _prayerMinutesOffset = offset;
    _settingsBox?.put('prayerMinutesOffset', offset);
    calculatePrayerTimes(); // إعادة الحساب عند تغيير التعديل
    notifyListeners();
  }

  int _hijriOffset = 0;
  int get hijriOffset => _hijriOffset;

  void setHijriOffset(int offset) {
    _hijriOffset = offset;
    _settingsBox?.put('hijriOffset', offset);
    _hijriCalendar = ShiaHijriCalendar(
      store: _settingsBox != null ? HiveAnchorStore(_settingsBox!) : null,
      clock: () => DateTime.now().add(Duration(days: _hijriOffset)),
    );
    _fetchTodayHijri();
  }

  List<String> _bookmarkedVerses = [];
  List<String> get bookmarkedVerses => _bookmarkedVerses;

  List<String> _bookmarkedSurahs = [];
  List<String> get bookmarkedSurahs => _bookmarkedSurahs;

  List<String> _bookmarkedDuas = [];
  List<String> get bookmarkedDuas => _bookmarkedDuas;

  List<String> _bookmarkedZiyarats = [];
  List<String> get bookmarkedZiyarats => _bookmarkedZiyarats;

  List<String> _bookmarkedPrayers = [];
  List<String> get bookmarkedPrayers => _bookmarkedPrayers;

  List<String> _bookmarkedActs = [];
  List<String> get bookmarkedActs => _bookmarkedActs;

  List<String> _bookmarkedAzkar = [];
  List<String> get bookmarkedAzkar => _bookmarkedAzkar;

  // 4. السبحة الإلكترونية
  int _tasbihCount = 0;
  int get tasbihCount => _tasbihCount;

  bool _isTasbihZahraMode = true; // تفعيل وضع تسبيح الزهراء عليها السلام افتراضياً
  bool get isTasbihZahraMode => _isTasbihZahraMode;

  // مراحل تسبيح الزهراء (34 الله أكبر -> 33 الحمد لله -> 33 سبحان الله)
  int _zahraStep = 0; // 0: التكبير، 1: التحميد، 2: التسبيح
  int get zahraStep => _zahraStep;

  String get currentZahraPhrase {
    if (_zahraStep == 0) return "اللهُ أَكْبَر";
    if (_zahraStep == 1) return "الْحَمْدُ لِلَّه";
    return "سُبْحَانَ اللَّه";
  }

  int get currentZahraTarget {
    if (_zahraStep == 0) return 34;
    return 33;
  }

  // 5. مشغل الصوتيات للأدعية والقرآن
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;

  String _activeAudioTitle = "";
  String get activeAudioTitle => _activeAudioTitle;

  bool _isPlayingAudio = false;
  bool get isPlayingAudio => _isPlayingAudio;

  Duration _audioPosition = Duration.zero;
  Duration get audioPosition => _audioPosition;

  Duration _audioDuration = Duration.zero;
  Duration get audioDuration => _audioDuration;

  AppProvider() {
    _initHiveAndLoadSettings();
    _initAudioStreams();
  }

  /// تهيئة Hive وتحميل إعدادات المستخدم المحفوظة
  void _initHiveAndLoadSettings() {
    try {
      if (Hive.isBoxOpen('huda_settings')) {
        _settingsBox = Hive.box('huda_settings');
      }
      if (_settingsBox != null) {
        _isFirstLaunch = _settingsBox!.get('isFirstLaunch', defaultValue: true);
        _isTasbihZahraMode = _settingsBox!.get('isTasbihZahraMode', defaultValue: true);
        _tasbihCount = _settingsBox!.get('tasbihCount', defaultValue: 0);
        _zahraStep = _settingsBox!.get('zahraStep', defaultValue: 0);
        _bookmarkedVerses = List<String>.from(_settingsBox!.get('bookmarks', defaultValue: []));
        _bookmarkedSurahs = List<String>.from(_settingsBox!.get('bookmarkedSurahs', defaultValue: []));
        _bookmarkedDuas = List<String>.from(_settingsBox!.get('bookmarkedDuas', defaultValue: []));
        _bookmarkedZiyarats = List<String>.from(_settingsBox!.get('bookmarkedZiyarats', defaultValue: []));
        _bookmarkedPrayers = List<String>.from(_settingsBox!.get('bookmarkedPrayers', defaultValue: []));
        _bookmarkedActs = List<String>.from(_settingsBox!.get('bookmarkedActs', defaultValue: []));
        _bookmarkedAzkar = List<String>.from(_settingsBox!.get('bookmarkedAzkar', defaultValue: []));
        _activeWallpaper = _settingsBox!.get('activeWallpaper', defaultValue: "assets/66.jpg");
        _prayerMinutesOffset = _settingsBox!.get('prayerMinutesOffset', defaultValue: 0);
        _hijriOffset = _settingsBox!.get('hijriOffset', defaultValue: 0);
        
        _notifyFajr = _settingsBox!.get('notifyFajr', defaultValue: false);
        _notifyDhuhr = _settingsBox!.get('notifyDhuhr', defaultValue: false);
        _notifyMaghrib = _settingsBox!.get('notifyMaghrib', defaultValue: false);
        _selectedMuezzin = _settingsBox!.get('selectedMuezzin', defaultValue: 'osama');

        // تحميل المدينة المحددة سابقاً
        bool isGps = _settingsBox!.get('isGpsActive', defaultValue: false);
        if (isGps) {
          double? lat = _settingsBox!.get('gpsLat');
          double? long = _settingsBox!.get('gpsLong');
          double? tz = _settingsBox!.get('gpsTz');
          String name = _settingsBox!.get('gpsCityName', defaultValue: "موقعك الحالي (GPS)");
          if (lat != null && long != null) {
            _selectedCity = ShiaCity(
              name: name,
              latitude: lat,
              longitude: long,
              timezoneOffset: tz ?? (DateTime.now().timeZoneOffset.inMinutes / 60.0),
            );
            _isGpsActive = true;
          }
        } else {
          int savedCityIndex = _settingsBox!.get('selectedCityIndex', defaultValue: -1);
          if (savedCityIndex >= 0 && savedCityIndex < LocationService.shiaCities.length) {
            _selectedCity = LocationService.shiaCities[savedCityIndex];
          }
        }
      }
    } catch (e) {
      debugPrint("Hive Load Error: $e");
    }
    
    _hijriCalendar = ShiaHijriCalendar(
      store: _settingsBox != null ? HiveAnchorStore(_settingsBox!) : null,
      clock: () => DateTime.now().add(Duration(days: _hijriOffset)),
    );
    _fetchTodayHijri();

    // حساب الأوقات للمرة الأولى
    calculatePrayerTimes();
  }

  Future<void> completeOnboarding() async {
    _isFirstLaunch = false;
    if (_settingsBox != null) {
      await _settingsBox!.put('isFirstLaunch', false);
    }
    notifyListeners();
  }



  /// حساب أوقات الصلاة بناءً على الإحداثيات الحالية للمدينة المحددة
  void calculatePrayerTimes() {
    _prayerTimes = ShiaPrayerCalculator.calculateTimes(
      date: DateTime.now(),
      latitude: _selectedCity.latitude,
      longitude: _selectedCity.longitude,
      timezoneOffset: _selectedCity.timezoneOffset,
      minutesOffset: _prayerMinutesOffset,
    );
    
    // جدولة التنبيهات مع كل تغيير في الوقت أو الموقع أو الإعدادات
    NotificationService.schedulePrayerNotifications(
      city: _selectedCity,
      minutesOffset: _prayerMinutesOffset,
      notifyFajr: _notifyFajr,
      notifyDhuhr: _notifyDhuhr,
      notifyMaghrib: _notifyMaghrib,
      muezzinName: _selectedMuezzin,
    );
    
    notifyListeners();
  }

  Future<void> setNotifyFajr(bool value) async {
    if (value) {
      bool granted = await NotificationService.requestNotificationPermission();
      if (!granted) {
        _notifyFajr = false;
        _settingsBox?.put('notifyFajr', false);
        notifyListeners();
        return;
      }
    }
    _notifyFajr = value;
    _settingsBox?.put('notifyFajr', value);
    calculatePrayerTimes();
  }

  Future<void> setNotifyDhuhr(bool value) async {
    if (value) {
      bool granted = await NotificationService.requestNotificationPermission();
      if (!granted) {
        _notifyDhuhr = false;
        _settingsBox?.put('notifyDhuhr', false);
        notifyListeners();
        return;
      }
    }
    _notifyDhuhr = value;
    _settingsBox?.put('notifyDhuhr', value);
    calculatePrayerTimes();
  }

  Future<void> setNotifyMaghrib(bool value) async {
    if (value) {
      bool granted = await NotificationService.requestNotificationPermission();
      if (!granted) {
        _notifyMaghrib = false;
        _settingsBox?.put('notifyMaghrib', false);
        notifyListeners();
        return;
      }
    }
    _notifyMaghrib = value;
    _settingsBox?.put('notifyMaghrib', value);
    calculatePrayerTimes();
  }


  void setSelectedMuezzin(String muezzin) {
    _selectedMuezzin = muezzin;
    _settingsBox?.put('selectedMuezzin', muezzin);
    calculatePrayerTimes();
  }

  /// تحديد الموقع الجغرافي تلقائياً عبر الـ GPS
  Future<LocationResult> determineUserLocation() async {
    _loadingLocation = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.permissionDenied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.permissionDenied;
      }

      Position? position = await LocationService.getCurrentPosition();
      if (position != null) {
        String locationName = await LocationService.getPlaceNameFromCoordinates(
          position.latitude,
          position.longitude,
        );

        _selectedCity = ShiaCity(
          name: locationName,
          latitude: position.latitude,
          longitude: position.longitude,
          timezoneOffset: DateTime.now().timeZoneOffset.inMinutes / 60.0,
        );
        _isGpsActive = true;
        _settingsBox?.put('isGpsActive', true);
        _settingsBox?.put('gpsCityName', _selectedCity.name);
        _settingsBox?.put('gpsLat', position.latitude);
        _settingsBox?.put('gpsLong', position.longitude);
        _settingsBox?.put('gpsTz', _selectedCity.timezoneOffset);
        calculatePrayerTimes();
        return LocationResult.success;
      }
      return LocationResult.error;
    } catch (e) {
      debugPrint("GPS Location Error: \$e");
      return LocationResult.error;
    } finally {
      _loadingLocation = false;
      notifyListeners();
    }
  }

  /// تغيير المدينة يدوياً
  void selectCity(ShiaCity city, int index) {
    _selectedCity = city;
    _isGpsActive = false;
    _settingsBox?.put('isGpsActive', false);
    _settingsBox?.put('selectedCityIndex', index);
    calculatePrayerTimes();
  }

  // ================== نظام السبحة الإلكترونية ==================

  /// تفعيل/إلغاء وضع تسبيح الزهراء (ع)
  void setTasbihZahraMode(bool active) {
    _isTasbihZahraMode = active;
    _tasbihCount = 0;
    _zahraStep = 0;
    _settingsBox?.put('isTasbihZahraMode', active);
    _settingsBox?.put('tasbihCount', 0);
    _settingsBox?.put('zahraStep', 0);
    notifyListeners();
  }

  /// زيادة العداد وإعطاء اهتزازات خفيفة تفاعلية للمستخدم
  void incrementTasbih() {
    // محاكاة اهتزاز خفيف بالهاتف (Haptic Feedback)
    HapticFeedback.selectionClick();

    if (_isTasbihZahraMode) {
      _tasbihCount++;
      
      int target = currentZahraTarget;
      if (_tasbihCount >= target) {
        // الانتقال للمرحلة التالية من التسبيح
        HapticFeedback.heavyImpact(); // اهتزاز أقوى عند إكمال الورد
        if (_zahraStep < 2) {
          _zahraStep++;
          _tasbihCount = 0;
        } else {
          // اكتمل تسبيح الزهراء بالكامل، نعيد التشغيل
          _zahraStep = 0;
          _tasbihCount = 0;
        }
        _settingsBox?.put('zahraStep', _zahraStep);
      }
    } else {
      _tasbihCount++;
    }
    
    _settingsBox?.put('tasbihCount', _tasbihCount);
    notifyListeners();
  }

  /// تصفير العداد
  void resetTasbih() {
    _tasbihCount = 0;
    _zahraStep = 0;
    _settingsBox?.put('tasbihCount', 0);
    _settingsBox?.put('zahraStep', 0);
    notifyListeners();
  }

  // ================== نظام المفضلات (القرآن والسور والأدعية والزيارات) ==================

  bool isVerseBookmarked(String ref) => _bookmarkedVerses.contains(ref);

  void toggleBookmark(String ref) {
    if (_bookmarkedVerses.contains(ref)) {
      _bookmarkedVerses.remove(ref);
    } else {
      _bookmarkedVerses.add(ref);
    }
    _settingsBox?.put('bookmarks', _bookmarkedVerses);
    notifyListeners();
  }

  bool isSurahBookmarked(String surahName) => _bookmarkedSurahs.contains(surahName);

  void toggleSurahBookmark(String surahName) {
    if (_bookmarkedSurahs.contains(surahName)) {
      _bookmarkedSurahs.remove(surahName);
    } else {
      _bookmarkedSurahs.add(surahName);
    }
    _settingsBox?.put('bookmarkedSurahs', _bookmarkedSurahs);
    notifyListeners();
  }

  bool isDuaBookmarked(String duaTitle) => _bookmarkedDuas.contains(duaTitle);

  void toggleDuaBookmark(String duaTitle) {
    if (_bookmarkedDuas.contains(duaTitle)) {
      _bookmarkedDuas.remove(duaTitle);
    } else {
      _bookmarkedDuas.add(duaTitle);
    }
    _settingsBox?.put('bookmarkedDuas', _bookmarkedDuas);
    notifyListeners();
  }

  bool isZiyaratBookmarked(String title) => _bookmarkedZiyarats.contains(title);

  void toggleZiyaratBookmark(String title) {
    if (_bookmarkedZiyarats.contains(title)) {
      _bookmarkedZiyarats.remove(title);
    } else {
      _bookmarkedZiyarats.add(title);
    }
    _settingsBox?.put('bookmarkedZiyarats', _bookmarkedZiyarats);
    notifyListeners();
  }

  bool isPrayerBookmarked(String title) => _bookmarkedPrayers.contains(title);

  void togglePrayerBookmark(String title) {
    if (_bookmarkedPrayers.contains(title)) {
      _bookmarkedPrayers.remove(title);
    } else {
      _bookmarkedPrayers.add(title);
    }
    _settingsBox?.put('bookmarkedPrayers', _bookmarkedPrayers);
    notifyListeners();
  }

  bool isActBookmarked(String title) => _bookmarkedActs.contains(title);

  void toggleActBookmark(String title) {
    if (_bookmarkedActs.contains(title)) {
      _bookmarkedActs.remove(title);
    } else {
      _bookmarkedActs.add(title);
    }
    _settingsBox?.put('bookmarkedActs', _bookmarkedActs);
    notifyListeners();
  }

  bool isZikrBookmarked(String title) => _bookmarkedAzkar.contains(title);

  void toggleZikrBookmark(String title) {
    if (_bookmarkedAzkar.contains(title)) {
      _bookmarkedAzkar.remove(title);
    } else {
      _bookmarkedAzkar.add(title);
    }
    _settingsBox?.put('bookmarkedAzkar', _bookmarkedAzkar);
    notifyListeners();
  }

  // ================== مشغل الصوتيات ==================

  /// تهيئة تدفقات قراءة الصوت لتحديث الواجهات بشكل فوري وتفاعلي
  void _initAudioStreams() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlayingAudio = state.playing;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((pos) {
      _audioPosition = pos;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        _audioDuration = dur;
        notifyListeners();
      }
    });
  }

  /// تشغيل دعاء أو زيارة صوتياً عبر الرابط المباشر
  Future<void> playAudio(String title, String url) async {
    if (_activeAudioTitle == title && _isPlayingAudio) {
      await pauseAudio();
      return;
    }

    try {
      _activeAudioTitle = title;
      notifyListeners();
      
      // تهيئة الصوت والتشغيل
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Audio Play Error: \$e");
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.play();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _activeAudioTitle = "";
    _isPlayingAudio = false;
    _audioPosition = Duration.zero;
    _audioDuration = Duration.zero;
    notifyListeners();
  }

  Future<void> seekAudio(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // ================== نظام الخلفيات الروحية المخصصة ==================
  String _activeWallpaper = "assets/66.jpg";
  String get activeWallpaper => _activeWallpaper;

  final List<String> wallpapers = [
    "assets/d1.jpg",
    "assets/d2.jpg",
    "assets/d3.jpg",
    "assets/d4.jpg",
    "assets/d5.jpg",
    "assets/d6.jpg",
    "assets/22.jpg",
    "assets/23.jpg",
    "assets/24.jpg",
    "assets/aa.jpg",
    "assets/1.jpg",
    "assets/2.jpg",
    "assets/3.jpg",
    "assets/4.jpg",
    "assets/5.jpg",
    "assets/66.jpg",
    "assets/77.jpg",
    "assets/GG.jpg",
  ];

  void setWallpaper(String path) {
    _activeWallpaper = path;
    _settingsBox?.put('activeWallpaper', path);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void triggerUIRefresh() => notifyListeners();
}
