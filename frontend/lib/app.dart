import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/i18n/locale_controller.dart';
import 'core/routes/app_routes.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class EdurImApp extends StatelessWidget {
  const EdurImApp({super.key});

  @override
  Widget build(BuildContext context) {
    // يعيد بناء MaterialApp عند تغيير اللغة، مع ضبط الاتجاه ديناميكياً.
    // يعيد البناء عند تغيير اللغة أو السمة.
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController.locale,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeController.mode,
          builder: (context, themeMode, _) {
            final isArabic = locale.languageCode == 'ar';
            return MaterialApp(
              title: 'Concouri',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: const [Locale('ar'), Locale('fr')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                // ar = RTL، fr = LTR.
                return Directionality(
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: child!,
                );
              },
              home: const _Splash(),
              routes: AppRoutes.routes,
            );
          },
        );
      },
    );
  }
}

/// شاشة انتقالية تتحقق من token وتوجّه المستخدم
class _Splash extends StatefulWidget {
  const _Splash();

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await authService.loadSavedToken();
    final hasToken = await authService.isLoggedIn();
    if (!hasToken) {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
    // Verify token is still valid with server
    try {
      final user = await authService.me();
      if (!mounted) return;
      // If user has no learning path, send to selection
      if (user.learningPathId == null) {
        Navigator.pushReplacementNamed(context, AppRoutes.selectLearningPath);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (_) {
      // Token invalid or server error — clear and go to login
      await authService.clearToken();
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
