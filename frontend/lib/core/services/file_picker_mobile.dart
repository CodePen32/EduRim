import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<(Uint8List, String)?> pickFileBytes() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );
  if (picked == null) return null;
  final bytes = await picked.readAsBytes();
  final name = picked.name.isNotEmpty ? picked.name : 'receipt.jpg';
  return (bytes, name);
}
