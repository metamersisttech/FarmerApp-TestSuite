import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Compresses an image file to reduce upload size.
///
/// - Max dimension: 1024px (maintains aspect ratio)
/// - Quality: 80% JPEG
/// - Falls back to the original file if compression fails.
Future<File> compressImage(File file) async {
  try {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 1024,
      minHeight: 1024,
      quality: 80,
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      final compressed = File(result.path);
      final originalSize = await file.length();
      final compressedSize = await compressed.length();
      debugPrint(
        'Image compressed: ${(originalSize / 1024).toStringAsFixed(0)}KB '
        '-> ${(compressedSize / 1024).toStringAsFixed(0)}KB '
        '(${(100 - compressedSize * 100 / originalSize).toStringAsFixed(0)}% reduction)',
      );
      return compressed;
    }

    debugPrint('Image compression returned null, using original file');
    return file;
  } catch (e) {
    debugPrint('Image compression failed, using original: $e');
    return file;
  }
}

/// Compresses a list of image files.
/// Each file is compressed independently; failures fall back to originals.
Future<List<File>> compressImages(List<File> files) async {
  return Future.wait(files.map(compressImage));
}
