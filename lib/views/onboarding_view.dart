// views/onboarding_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../services/location_service.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  ShiaCountry? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // خلفية روحية مريحة
      body: SafeArea(
        child: Column(
          children: [
            // الهيدر الروحي (Spiritual Header)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: Color(0xFF8A1525), // ماروني ملكي
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.mosque_rounded, color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    "أهلاً بك في زاد المتقين",
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedCountry == null
                        ? "يرجى اختيار بلدك لضبط إعدادات أوقات الصلاة والموقع بدقة."
                        : "اختر مدينتك في ${_selectedCountry!.name}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // زر العودة للدول إذا كان قد اختار دولة
            if (_selectedCountry != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCountry = null;
                        });
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF8A1525), size: 20),
                      label: Text(
                        "العودة لقائمة الدول",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8A1525),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        backgroundColor: const Color(0xFF8A1525).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // قائمة الدول أو المدن
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: _selectedCountry == null ? _buildCountryList(provider) : _buildCityList(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsOptionCard(AppProvider provider) {
    final isLoading = provider.loadingLocation;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8A1525),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A1525).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFF8A1525),
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(
                  Icons.my_location_rounded,
                  color: Colors.white,
                  size: 20,
                ),
        ),
        title: Text(
          "تحديد الموقع تلقائياً (GPS)",
          style: GoogleFonts.cairo(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8A1525),
          ),
        ),
        subtitle: Text(
          "ضبط تلقائي لمحافظتك ودولتك ومواقيت الصلاة بدقة",
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        trailing: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF8A1525), size: 16),
        onTap: isLoading
            ? null
            : () async {
                final result = await provider.determineUserLocation();
                if (!mounted) return;
                if (result == LocationResult.success) {
                  provider.completeOnboarding();
                } else if (result == LocationResult.serviceDisabled) {
                  LocationService.showGpsDisabledDialog(context);
                } else if (result == LocationResult.permissionDenied) {
                  LocationService.showPermissionDeniedDialog(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "تعذر تحديد الموقع حالياً. يرجى التأكد من تشغيل الـ GPS والمحاولة ثانية.",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.red[850],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
      ),
    );
  }

  Widget _buildCountryList(AppProvider provider) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: LocationService.countries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildGpsOptionCard(provider);
        }
        final country = LocationService.countries[index - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              country.name,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            trailing: const Icon(Icons.chevron_left_rounded, color: Color(0xFF94A3B8)),
            onTap: () {
              setState(() {
                _selectedCountry = country;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildCityList(AppProvider provider) {
    final cities = _selectedCountry!.cities;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: const Icon(Icons.location_city_rounded, color: Color(0xFF8A1525)),
            title: Text(
              city.name.split('،').first,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            trailing: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF94A3B8)),
            onTap: () {
              // 1. حساب الـ index الخاص بالمدينة ضمن القائمة الشاملة
              int globalIndex = LocationService.shiaCities.indexOf(city);
              
              // 2. تعيين المدينة في الـ Provider
              provider.selectCity(city, globalIndex);
              
              // 3. إنهاء مرحلة Onboarding والانتقال للشاشة الرئيسية
              provider.completeOnboarding();
            },
          ),
        );
      },
    );
  }
}
