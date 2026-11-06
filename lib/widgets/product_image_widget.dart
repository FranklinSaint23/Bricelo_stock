import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html' as io_or_html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;
  final IconData placeholderIcon;

  const ProductImageWidget({
    super.key,
    this.imageUrl,
    this.size = 48,
    this.borderRadius = 10,
    this.placeholderIcon = Icons.inventory_2_rounded,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      final path = imageUrl!.trim();

      // 1. BASE64 DATA URL (100% universel Web, iOS, Android)
      if (path.startsWith('data:image') || path.contains(';base64,')) {
        try {
          final base64String = path.contains(',') ? path.split(',').last : path;
          final bytes = base64Decode(base64String);
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            ),
          );
        } catch (_) {
          return _buildPlaceholder();
        }
      }

      // 2. URL WEB CLASSIQUE
      if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            path,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          ),
        );
      }

      // 3. ASSET LOCAL
      if (path.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.asset(
            path,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          ),
        );
      }

      // 4. FICHIER LOCAL (Appareil physique hors-Web uniquement)
      if (!kIsWeb) {
        try {
          // ignore: avoid_slow_async_io
          final file = io_or_html.File(path);
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            ),
          );
        } catch (_) {}
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2E),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(placeholderIcon, color: AppTheme.accentGold, size: size * 0.5),
      ),
    );
  }
}

