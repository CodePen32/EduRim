import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/lesson.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/utils/url_helper.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _initializing = true;
  String? _error;
  bool _marked = false;
  bool _marking = false;

  String? _videoUrl;
  String? _localPath;
  String? _title;
  Lesson? _lesson;

  bool _argsLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      _argsLoaded = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Lesson) {
        _lesson = args;
        _title = args.title;
        _videoUrl = buildFileUrl(args.videoUrl);
      } else if (args is Map<String, dynamic>) {
        _title = args['title'] as String? ?? tr('video.title');
        final rawUrl = args['videoUrl'] as String? ?? '';
        _videoUrl = rawUrl.isNotEmpty ? buildFileUrl(rawUrl) : null;
        _localPath = args['localPath'] as String?;
      }
      debugPrint('=== VideoPlayerScreen ===');
      debugPrint('kIsWeb=$kIsWeb  videoUrl=$_videoUrl  localPath=$_localPath');
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    if (!mounted) return;
    setState(() { _initializing = true; _error = null; });

    try {
      VideoPlayerController ctrl;

      if (!kIsWeb && _localPath != null && _localPath!.isNotEmpty) {
        debugPrint('Using FILE controller: $_localPath');
        ctrl = VideoPlayerController.file(File(_localPath!));
      } else if (_videoUrl != null && _videoUrl!.isNotEmpty) {
        debugPrint('Using NETWORK controller: $_videoUrl');
        ctrl = VideoPlayerController.networkUrl(
          Uri.parse(_videoUrl!),
          httpHeaders: {'Access-Control-Allow-Origin': '*'},
        );
      } else {
        if (mounted) setState(() { _initializing = false; _error = tr('video.unavailable'); });
        return;
      }

      await ctrl.initialize();
      debugPrint('Initialized — hasError=${ctrl.value.hasError} errorDesc=${ctrl.value.errorDescription} size=${ctrl.value.size}');

      if (ctrl.value.hasError) {
        debugPrint('VideoPlayer init error: ${ctrl.value.errorDescription}');
        ctrl.dispose();
        if (mounted) setState(() { _initializing = false; _error = tr('video.playError'); });
        return;
      }

      if (!mounted) { ctrl.dispose(); return; }
      _controller = ctrl;
      ctrl.addListener(_onControllerUpdate);
      await ctrl.play();
      setState(() => _initializing = false);
    } catch (e) {
      debugPrint('VideoPlayer exception: $e');
      if (mounted) setState(() { _initializing = false; _error = tr('video.playError'); });
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    super.dispose();
  }

  Future<void> _markComplete() async {
    final lessonId = _lesson?.id ?? 0;
    if (lessonId == 0) return;
    setState(() => _marking = true);
    try {
      await progressService.saveProgress(lessonId: lessonId, watchedPercentage: 100, completed: true);
      if (mounted) setState(() { _marking = false; _marked = true; });
    } catch (_) {
      if (mounted) setState(() => _marking = false);
    }
  }

  void _togglePlayPause() {
    final ctrl = _controller;
    if (ctrl == null) return;
    if (ctrl.value.isPlaying) {
      ctrl.pause();
    } else {
      ctrl.play();
    }
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final title = _title ?? 'مشاهدة الدرس';
    final lessonId = _lesson?.id ?? 0;
    final ctrl = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Video area
          AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video or placeholder
                  if (_initializing)
                    ColoredBox(
                      color: Colors.black,
                      child: Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.white),
                          const SizedBox(height: 12),
                          Text(tr('video.loading'), style: const TextStyle(fontFamily: 'Cairo', color: Colors.white54, fontSize: 12)),
                        ],
                      )),
                    )
                  else if (_error != null)
                    ColoredBox(
                      color: Colors.black,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: const TextStyle(fontFamily: 'Cairo', color: Colors.white70, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              if (_videoUrl != null && _videoUrl!.isNotEmpty)
                                ElevatedButton.icon(
                                  onPressed: () => openExternalUrl(_videoUrl, context: context),
                                  icon: const Icon(Icons.open_in_new, size: 18),
                                  label: Text(tr('video.openBrowser'), style: const TextStyle(fontFamily: 'Cairo')),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (ctrl != null)
                    VideoPlayer(ctrl)
                  else
                    const ColoredBox(
                      color: Colors.black,
                      child: Center(child: Icon(Icons.videocam_off_outlined, color: Colors.white38, size: 64)),
                    ),

                  // Controls overlay
                  if (ctrl != null && !_initializing && _error == null)
                    _buildControls(ctrl),
                ],
              ),
            ),
          ),

          // Progress bar
          if (ctrl != null && !_initializing && _error == null)
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Text(
                    _formatDuration(ctrl.value.position),
                    style: const TextStyle(fontFamily: 'Cairo', color: Colors.white70, fontSize: 11),
                  ),
                  Expanded(
                    child: Slider(
                      value: ctrl.value.duration.inSeconds > 0
                          ? ctrl.value.position.inSeconds.toDouble().clamp(0, ctrl.value.duration.inSeconds.toDouble())
                          : 0,
                      min: 0,
                      max: ctrl.value.duration.inSeconds > 0 ? ctrl.value.duration.inSeconds.toDouble() : 1,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.white24,
                      onChanged: (v) => ctrl.seekTo(Duration(seconds: v.toInt())),
                    ),
                  ),
                  Text(
                    _formatDuration(ctrl.value.duration),
                    style: const TextStyle(fontFamily: 'Cairo', color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

          // Info panel
          Expanded(
            child: Container(
              color: const Color(0xFF111111),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
                    if (_lesson?.durationLabel.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(_lesson!.durationLabel, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white54)),
                      ]),
                    ],
                    if (_lesson?.description.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Text(_lesson!.description, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white60, height: 1.6)),
                    ],
                    if (lessonId > 0) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: _marked
                            ? Container(
                                decoration: BoxDecoration(border: Border.all(color: AppColors.success), borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                                    const SizedBox(width: 8),
                                    Text(tr('video.marked'), style: const TextStyle(fontFamily: 'Cairo', color: AppColors.success, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: !_marking ? _markComplete : null,
                                icon: _marking
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.success))
                                    : const Icon(Icons.check_circle_outline),
                                label: Text(_marking ? tr('common.saving') : tr('details.markCompleted'), style: const TextStyle(fontFamily: 'Cairo')),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.success,
                                  side: const BorderSide(color: AppColors.success),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(VideoPlayerController ctrl) {
    final isPlaying = ctrl.value.isPlaying;
    return Container(
      color: Colors.black26,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
              onPressed: () {
                final pos = ctrl.value.position - const Duration(seconds: 10);
                ctrl.seekTo(pos < Duration.zero ? Duration.zero : pos);
              },
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: Colors.white,
                size: 56,
              ),
              onPressed: _togglePlayPause,
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
              onPressed: () {
                final pos = ctrl.value.position + const Duration(seconds: 10);
                final dur = ctrl.value.duration;
                ctrl.seekTo(pos > dur ? dur : pos);
              },
            ),
          ],
        ),
      ),
    );
  }
}
