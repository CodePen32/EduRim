import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/admin_scope.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/subjects_screen.dart';
import '../screens/lessons_screen.dart';
import '../screens/exercises_screen.dart';
import '../screens/past_exams_admin_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/teachers_screen.dart';
import '../screens/users_screen.dart';
import '../screens/section_select_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const AuthGate());
    case '/login':
      return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
    case '/select-section':
      return MaterialPageRoute(builder: (_) => const SectionSelectScreen());
    case '/dashboard':
      return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
    case '/subjects':
      return MaterialPageRoute(builder: (_) => const AdminSubjectsScreen());
    case '/lessons':
      return MaterialPageRoute(builder: (_) => const AdminLessonsScreen());
    case '/exercises':
      return MaterialPageRoute(builder: (_) => const AdminExercisesScreen());
    case '/past-exams':
      return MaterialPageRoute(builder: (_) => const AdminPastExamsScreen());
    case '/notifications':
      return MaterialPageRoute(builder: (_) => const AdminNotificationsScreen());
    case '/teachers':
      return MaterialPageRoute(builder: (_) => const AdminTeachersScreen());
    case '/users':
      return MaterialPageRoute(builder: (_) => const AdminUsersScreen());
    default:
      return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token');
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    // تحميل scope ثم تقرير الوجهة
    await adminScope.load();
    if (!mounted) return;
    if (!adminScope.isSelected) {
      Navigator.pushReplacementNamed(context, '/select-section');
    } else {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
