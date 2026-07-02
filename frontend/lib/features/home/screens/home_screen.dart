import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
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

  // Keep pages alive across tab switches — avoid rebuilding on every tap
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeContent(onRefreshRequested: _refreshHome),
      const FavoritesScreen(standalone: false),
      const DownloadsScreen(standalone: false),
      const AverageCalculatorScreen(standalone: false),
      ProfileScreen(standalone: false, onProfileUpdated: _refreshHome),
    ];
  }

  void _refreshHome() {
    // Invalidate subject cache so next home visit fetches fresh data
    subjectService.invalidate();
    setState(() {
      _pages[0] = _HomeContent(key: UniqueKey(), onRefreshRequested: _refreshHome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: tr('home.searchHint'),
                            hintStyle: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.textLight,
                            ),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
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
                        icon: Icons.play_circle_outline_rounded,
                        label: tr('home.lessons'),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.lessonsList),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.assignment_outlined,
                        label: tr('home.exercises'),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.exercisesList),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.groups_2_outlined,
                        label: tr('home.teachers'),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.teachers),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    tr('home.mySubjects'),
                    style: const TextStyle(
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
                                  ? tr('home.connError')
                                  : tr('home.loadError'),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _reloadSubjects,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: Text(tr('common.retry'),
                                  style: const TextStyle(fontFamily: 'Cairo')),
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
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          tr('home.noSubjects'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
                        nameFr: s.nameFr,
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
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Unified, calm style harmonized with the primary blue: white card with a
    // soft shadow and a circular light-blue icon badge — consistent across all
    // three quick actions for a clean, professional look.
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
