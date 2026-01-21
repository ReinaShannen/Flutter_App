import 'dart:convert';
import 'dart:typed_data';

class ImageUtils {
  static Uint8List decodeBase64(String base64String) {
    final cleaned = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(cleaned);
  }
}
