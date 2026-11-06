import 'dart:io';
import 'package:flutter/widgets.dart';

/// Implémentation native (Android, iOS, Desktop) utilisant dart:io.
Widget? buildPlatformFileImage({
  required String path,
  required double size,
  required double borderRadius,
  required Widget Function() placeholderBuilder,
}) {
  try {
    final file = File(path);
    if (!file.existsSync()) return null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        file,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholderBuilder(),
      ),
    );
  } catch (_) {
    return null;
  }
}
