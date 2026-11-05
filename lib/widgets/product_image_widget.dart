import 'dart:io';
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
      if (path.startsWith('http://') || path.startsWith('https://')) {
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
      } else if (path.startsWith('assets/')) {
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
      } else {
        try {
          final file = File(path);
          if (file.existsSync()) {
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
          }
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

