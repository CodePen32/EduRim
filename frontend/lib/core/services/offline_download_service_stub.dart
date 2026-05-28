// Stub for Web — all native operations are no-ops

Future<Map<String, dynamic>?> nativeDownloadLesson({
  required int lessonId,
  required String videoUrl,
  required String summaryUrl,
  required String coverUrl,
  void Function(double progress, String label)? onProgress,
}) async {
  return null;
}

Future<void> nativeDeleteLesson(int lessonId) async {}
