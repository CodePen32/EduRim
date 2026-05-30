import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<(Uint8List, String, String)?> pickFileBytes() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );
  if (picked == null) return null;
  final bytes = await picked.readAsBytes();

  // Ensure filename always has a valid extension
  String name = picked.name;
  final lower = name.toLowerCase();
  if (!lower.endsWith('.jpg') &&
      !lower.endsWith('.jpeg') &&
      !lower.endsWith('.png') &&
      !lower.endsWith('.webp')) {
    name = 'receipt.jpg';
  }

  // Derive MIME from extension
  final mime = name.toLowerCase().endsWith('.png')
      ? 'image/png'
      : name.toLowerCase().endsWith('.webp')
          ? 'image/webp'
          : 'image/jpeg';

  return (bytes, name, mime);
}
