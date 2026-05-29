import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/announcement.dart';
import '../../../core/models/subject.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/announcement_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/subject_service.dart';
import '../../../shared/widgets/api_state_widget.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/subject_card.dart';
import '../../calculator/screens/average_calculator_screen.dart';
import '../../downloads/screens/downloads_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/announcement_carousel.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Key _homeKey = UniqueKey();

  void _refreshHome() {
    setState(() => _homeKey = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeContent(key: _homeKey, onRefreshRequested: _refreshHome),
      const FavoritesScreen(standalone: false),
      const DownloadsScreen(standalone: false),
      const AverageCalculatorScreen(standalone: false),
      ProfileScreen(standalone: false, onProfileUpdated: _refreshHome),
    ];
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final VoidCallback? onRefreshRequested;
  const _HomeContent({super.key, this.onRefreshRequested});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  late Future<List<Subject>> _subjectsFuture;
  UserModel? _user;
  List<Announcement> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _subjectsFuture = subjectService.getMySubjects();
    authService.me().then((u) {
      if (mounted) setState(() => _user = u);
    }).catchError((_) {});
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    final list = await announcementService.getMyAnnouncements();
    if (mounted) setState(() => _announcements = list);
  }

  void _reloadSubjects() => setState(() {
        _subjectsFuture = subjectService.getMySubjects();
      });

  Color _hexToColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HomeTopBar(),
      endDrawer: HomeDrawer(user: _user),
      body: CustomScrollView(
        slivers: [
          // Carousel الإعلانات
          if (_announcements.isNotEmpty)
            SliverToBoxAdapter(
              child: AnnouncementCarousel(announcements: _announcements),
            ),

          // Search + Quick actions + عنوان المواد
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: const AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'ابحث عن درس أو مادة...',
                            hintStyle: TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.textLight,
                            ),
                            prefixIcon: Icon(Icons.search, color: AppColors.textLight),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _QuickAction(
                        icon: Icons.menu_book_rounded,
                        label: 'الدروس',
                        color: AppColors.primary,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.lessonsList),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.quiz_outlined,
                        label: 'التمارين',
                        color: const Color(0xFF7C3AED),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.exercisesList),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.people_outline,
                        label: 'الأساتذة',
                        color: const Color(0xFF059669),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.teachers),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'مواد مسارك الدراسي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // قائمة المواد
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: FutureBuilder<List<Subject>>(
              future: _subjectsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: SizedBox(height: 120, child: LoadingWidget()),
                  );
                }
                if (snapshot.hasError) {
                  final err = snapshot.error;
                  final isAuth = err is ApiException &&
                      (err.statusCode == 401 || err.statusCode == 403);
                  if (isAuth) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        authService.clearToken();
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      }
                    });
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  final isConnection = err.toString().contains('SocketException') ||
                      err.toString().contains('Connection');
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 140,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              isConnection
                                  ? 'تعذر الاتصال بالخادم'
                                  : 'تعذّر تحميل المواد',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _reloadSubjects,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('إعادة المحاولة',
                                  style: TextStyle(fontFamily: 'Cairo')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                // dedup دفاعي — يمنع تكرار المواد بنفس الـ id
                final seen = <int>{};
                final subjects = (snapshot.data ?? [])
                    .where((s) => seen.add(s.id))
                    .toList();
                if (subjects.isEmpty) {
                  // BAC بدون شعبة — وجّه لاختيار الشعبة
                  if (_user != null &&
                      _user!.learningPathId == 3 &&
                      _user!.bacBranchId == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.selectBacBranch);
                      }
                    });
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  if (_user != null && _user!.learningPathId == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.selectLearningPath);
                      }
                    });
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'لا توجد مواد متاحة لهذا المستوى حاليا',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final s = subjects[i];
                      return SubjectCard(
                        name: s.nameAr,
                        color: _hexToColor(s.color),
                        coverImageUrl: s.coverImageUrl,
                        lessonsCount: s.lessonsCount,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.subjectDetails,
                          arguments: s,
                        ),
                      );
                    },
                    childCount: subjects.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
