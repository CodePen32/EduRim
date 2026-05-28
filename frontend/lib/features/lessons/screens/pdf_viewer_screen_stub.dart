import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

Widget buildLocalPdfViewer(
  String path,
  void Function(PdfDocumentLoadedDetails) onLoaded,
  void Function(PdfDocumentLoadFailedDetails) onFailed,
) {
  // On Web there are no local files — show network viewer or empty
  return const SizedBox.shrink();
}
