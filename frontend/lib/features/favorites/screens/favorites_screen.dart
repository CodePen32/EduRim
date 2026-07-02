import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/favorite.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/favorite_service.dart';
import '../../../shared/widgets/app_header.dart';

class FavoritesScreen extends StatefulWidget {
  final bool standalone;
  const FavoritesScreen({super.key, this.standalone = true});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Favorite> _favorites = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await favoriteService.getFavorites();
      if (mounted) setState(() { _favorites = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = tr('fav.loadError'); _loading = false; });
    }
  }

  Future<void> _delete(Favorite fav) async {
    try {
      await favoriteService.deleteFavorite(fav.id);
      if (mounted) setState(() => _favorites.remove(fav));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('common.deleteFailed'), style: const TextStyle(fontFamily: 'Cairo')), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _openItem(Favorite fav) {
    switch (fav.itemType) {
      case 'lesson':
        // Navigate to lesson details — we pass itemId as argument since we don't have full Lesson object here
        Navigator.pushNamed(context, AppRoutes.lessonsList);
        break;
      case 'exercise':
        Navigator.pushNamed(context, AppRoutes.exercisesList);
        break;
      default:
        break;
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'lesson':   return Icons.play_lesson_outlined;
      case 'exercise': return Icons.quiz_outlined;
      default:         return Icons.star_outline;
    }
  }

  String _labelFor(String type) {
    switch (type) {
      case 'lesson':   return tr('fav.lesson');
      case 'exercise': return tr('fav.exercise');
      default:         return type;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'lesson':   return AppColors.primary;
      case 'exercise': return AppColors.warning;
      default:         return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.standalone ? AppHeader(title: tr('fav.title')) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.standalone)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(tr('fav.title'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _load,
                              child: Text(tr('common.retry'), style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary)),
                            ),
                          ],
                        ),
                      )
                    : _favorites.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_border, size: 64, color: AppColors.textLight),
                                const SizedBox(height: 12),
                                Text(tr('fav.empty'), style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, AppRoutes.lessonsList),
                                  child: Text(tr('fav.browseLessons'), style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary)),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _favorites.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final fav = _favorites[i];
                              final color = _colorFor(fav.itemType);
                              return GestureDetector(
                                onTap: () => _openItem(fav),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.cardBorder),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(_iconFor(fav.itemType), color: color),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fav.title.isNotEmpty ? fav.title : tr('common.noTitle'),
                                              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (fav.subtitle.isNotEmpty)
                                              Text(
                                                fav.subtitle,
                                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            const SizedBox(height: 2),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                              child: Text(_labelFor(fav.itemType), style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: color)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.favorite, color: AppColors.error, size: 22),
                                        tooltip: tr('fav.remove'),
                                        onPressed: () => _delete(fav),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
