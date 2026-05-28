import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

Widget buildLocalPdfViewer(
  String path,
  void Function(PdfDocumentLoadedDetails) onLoaded,
  void Function(PdfDocumentLoadFailedDetails) onFailed,
) {
  return SfPdfViewer.file(
    File(path),
    onDocumentLoaded: onLoaded,
    onDocumentLoadFailed: onFailed,
  );
}
