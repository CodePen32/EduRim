import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';

class EdurImApp extends StatelessWidget {
  const EdurImApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Concouri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar', 'MR'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const _Splash(),
      routes: AppRoutes.routes,
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
