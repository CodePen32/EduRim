import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<(Uint8List, String, String)?> pickFileBytes() async {
  final completer = Completer<(Uint8List, String, String)?>();

  final input = web.document.createElement('input') as web.HTMLInputElement;
  input.type = 'file';
  input.accept = 'image/jpeg,image/png,image/webp';

  input.onchange = ((web.Event _) {
    final files = input.files;
    if (files == null || files.length == 0) {
      completer.complete(null);
      return;
    }
    final file = files.item(0)!;
    final filename = file.name.isNotEmpty ? file.name : 'receipt.jpg';
    final mime = file.type.isNotEmpty ? file.type : 'image/jpeg';

    final reader = web.FileReader();

    reader.onloadend = ((web.Event _) {
      final result = reader.result;
      if (result == null) {
        completer.completeError(Exception('تعذر قراءة الملف'));
        return;
      }
      final jsBuffer = result as JSArrayBuffer;
      final uint8 = jsBuffer.toDart.asUint8List();
      completer.complete((uint8, filename, mime));
    }).toJS;

    reader.onerror = ((web.Event _) {
      completer.completeError(Exception('خطأ في قراءة الملف'));
    }).toJS;

    reader.readAsArrayBuffer(file);
  }).toJS;

  input.click();
  return completer.future;
}
