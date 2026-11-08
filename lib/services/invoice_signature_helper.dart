import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Service de génération algorithmique vectorielle de signatures manuscrites
/// Convertit n'importe quel nom en signature calligraphique élégante
/// Fonctionne 100% hors-ligne, sans IA distante, compatible Flutter Canvas et PDF pw.SvgImage.
class InvoiceSignatureHelper {
  InvoiceSignatureHelper._();

  // Signature Bricelo vectorielle de référence officielle
  static const String briceloSvgPath =
      'M 14 38 C 12 25, 20 8, 28 8 C 36 8, 40 18, 34 27 C 32 30, 27 33, 21 33 C 30 33, 40 33, 42 43 C 44 49, 34 49, 24 47 C 17 45, 14 39, 20 35 M 34 32 C 40 28, 46 26, 50 28 C 54 30, 51 36, 48 40 M 52 36 C 56 28, 60 28, 64 28 C 68 28, 66 40, 66 40 M 70 32 C 76 28, 82 30, 88 32 C 94 34, 92 40, 86 42 M 90 36 C 96 30, 102 32, 108 34 C 114 36, 110 42, 106 42 M 110 32 C 114 20, 118 10, 122 8 C 126 6, 124 30, 122 40 M 126 34 C 132 28, 140 30, 146 32 C 152 34, 150 42, 142 42 C 134 42, 136 34, 144 34';
  static const String briceloUnderline =
      'M 20 48 Q 80 51, 148 43 Q 158 41, 144 49 Q 88 54, 36 52';

  /// Génère le code SVG complet pour l'impression PDF (A6 ou autre)
  static String generateSvg({
    required String text,
    int styleIndex = 0,
    String colorHex = '#1E3A8A',
  }) {
    final cleanText = text.trim().isEmpty ? 'Bricelo' : text.trim();

    // Si le nom demandé est "Bricelo" avec le style par défaut (0), on restitue la signature de référence exacte
    if (cleanText.toLowerCase() == 'bricelo' && styleIndex == 0) {
      return '''
<svg viewBox="0 0 160 55" xmlns="http://www.w3.org/2000/svg">
  <path d="$briceloSvgPath" fill="none" stroke="$colorHex" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="64" cy="20" r="1.5" fill="$colorHex"/>
  <path d="$briceloUnderline" fill="$colorHex"/>
</svg>
''';
    }

    // Sinon, génération dynamique complète pour le nom personnalisé saisi
    final model = _buildSignatureModel(cleanText, styleIndex);
    final width = model.totalWidth;
    const height = 55.0;

    final buf = StringBuffer();
    buf.writeln('<svg viewBox="0 0 ${width.toInt()} $height" xmlns="http://www.w3.org/2000/svg">');
    buf.writeln('  <!-- Signature manuscrite générée dynamiquement pour "$cleanText" -->');
    buf.writeln('  <path d="${model.svgPath}" fill="none" stroke="$colorHex" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>');

    for (final dot in model.dots) {
      buf.writeln('  <circle cx="${dot.dx.toStringAsFixed(1)}" cy="${dot.dy.toStringAsFixed(1)}" r="${dot.radius.toStringAsFixed(1)}" fill="$colorHex"/>');
    }

    if (model.svgUnderline.isNotEmpty) {
      if (model.isUnderlineFilled) {
        buf.writeln('  <path d="${model.svgUnderline}" fill="$colorHex"/>');
      } else {
        buf.writeln('  <path d="${model.svgUnderline}" fill="none" stroke="$colorHex" stroke-width="2.0" stroke-linecap="round" stroke-linejoin="round"/>');
      }
    }

    buf.writeln('</svg>');
    return buf.toString();
  }

  /// Dessine la signature sur un Canvas Flutter pour les aperçus et les dialogues
  static void paint(
    Canvas canvas,
    Size size, {
    required String text,
    int styleIndex = 0,
    Color color = const Color(0xFF1E3A8A),
    double strokeWidth = 2.0,
  }) {
    final cleanText = text.trim().isEmpty ? 'Bricelo' : text.trim();

    if (cleanText.toLowerCase() == 'bricelo' && styleIndex == 0) {
      _paintBriceloDefault(canvas, size, color, strokeWidth);
      return;
    }

    final model = _buildSignatureModel(cleanText, styleIndex);
    final refW = model.totalWidth;
    const refH = 55.0;

    final scaleX = size.width / refW;
    final scaleY = size.height / refH;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Tracé des lettres
    canvas.drawPath(model.flutterPath, strokePaint);

    // Points sur les i, j ou diacritiques
    for (final dot in model.dots) {
      canvas.drawCircle(Offset(dot.dx, dot.dy), dot.radius, fillPaint);
    }

    // Paraphe de soulignement
    if (model.flutterUnderline != null) {
      if (model.isUnderlineFilled) {
        canvas.drawPath(model.flutterUnderline!, fillPaint);
      } else {
        canvas.drawPath(model.flutterUnderline!, strokePaint);
      }
    }

    canvas.restore();
  }

  static void _paintBriceloDefault(Canvas canvas, Size size, Color color, double strokeWidth) {
    final scaleX = size.width / 160.0;
    final scaleY = size.height / 55.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final p = Path()
      ..moveTo(14, 38)
      ..cubicTo(12, 25, 20, 8, 28, 8)
      ..cubicTo(36, 8, 40, 18, 34, 27)
      ..cubicTo(32, 30, 27, 33, 21, 33)
      ..cubicTo(30, 33, 40, 33, 42, 43)
      ..cubicTo(44, 49, 34, 49, 24, 47)
      ..cubicTo(17, 45, 14, 39, 20, 35)
      ..moveTo(34, 32)
      ..cubicTo(40, 28, 46, 26, 50, 28)
      ..cubicTo(54, 30, 51, 36, 48, 40)
      ..moveTo(52, 36)
      ..cubicTo(56, 28, 60, 28, 64, 28)
      ..cubicTo(68, 28, 66, 40, 66, 40)
      ..moveTo(70, 32)
      ..cubicTo(76, 28, 82, 30, 88, 32)
      ..cubicTo(94, 34, 92, 40, 86, 42)
      ..moveTo(90, 36)
      ..cubicTo(96, 30, 102, 32, 108, 34)
      ..cubicTo(114, 36, 110, 42, 106, 42)
      ..moveTo(110, 32)
      ..cubicTo(114, 20, 118, 10, 122, 8)
      ..cubicTo(126, 6, 124, 30, 122, 40)
      ..moveTo(126, 34)
      ..cubicTo(132, 28, 140, 30, 146, 32)
      ..cubicTo(152, 34, 150, 42, 142, 42)
      ..cubicTo(134, 42, 136, 34, 144, 34);

    canvas.drawPath(p, strokePaint);
    canvas.drawCircle(const Offset(64, 20), 1.6, fillPaint);

    final under = Path()
      ..moveTo(20, 48)
      ..quadraticBezierTo(80, 51, 148, 43)
      ..quadraticBezierTo(158, 41, 144, 49)
      ..quadraticBezierTo(88, 54, 36, 52)
      ..close();
    canvas.drawPath(under, fillPaint);

    canvas.restore();
  }

  // --- Modélisation algorithmique interne ---
  static _SignatureModel _buildSignatureModel(String text, int styleIndex) {
    double curX = 14.0;
    final svgBuf = StringBuffer();
    final flutterPath = Path();
    final List<_Dot> dots = [];

    final clean = _normalizeText(text);

    for (int i = 0; i < clean.length; i++) {
      final ch = clean[i];
      final isFirst = (i == 0 || clean[i - 1] == ' ');
      final letter = _getGlyph(ch, curX, isUppercase: isFirst || ch.toUpperCase() == ch && ch != ' ');

      if (letter != null) {
        if (svgBuf.isNotEmpty) svgBuf.write(' ');
        svgBuf.write(letter.svgD);

        letter.applyToFlutterPath(flutterPath);

        if (letter.dots != null) {
          dots.addAll(letter.dots!);
        }
        curX += letter.advance;
      } else {
        curX += 10.0;
      }
    }

    final totalWidth = math.max(120.0, curX + 16.0);

    // Paraphe de soulignement selon le style
    String svgUnderline = '';
    Path? flutterUnderline;
    bool isUnderlineFilled = false;

    final startX = 16.0;
    final endX = totalWidth - 12.0;
    final midX = (startX + endX) / 2;

    if (styleIndex == 0) {
      // Style 0: Paraphe classique bouclé plein
      svgUnderline = 'M $startX 48 Q $midX 52, $endX 43 Q ${endX + 8} 41, ${endX - 4} 49 Q $midX 54, ${startX + 12} 52 Z';
      isUnderlineFilled = true;
      flutterUnderline = Path()
        ..moveTo(startX, 48)
        ..quadraticBezierTo(midX, 52, endX, 43)
        ..quadraticBezierTo(endX + 8, 41, endX - 4, 49)
        ..quadraticBezierTo(midX, 54, startX + 12, 52)
        ..close();
    } else if (styleIndex == 1) {
      // Style 1: Vague moderne élancée avec retour dynamique
      svgUnderline = 'M $startX 49 Q $midX 45, $endX 46 Q ${endX + 6} 46, $endX 49 L ${startX + 20} 52';
      isUnderlineFilled = false;
      flutterUnderline = Path()
        ..moveTo(startX, 49)
        ..quadraticBezierTo(midX, 45, endX, 46)
        ..quadraticBezierTo(endX + 6, 46, endX, 49)
        ..lineTo(startX + 20, 52);
    } else {
      // Style 2: Double trait prestige
      svgUnderline = 'M $startX 47 Q $midX 50, $endX 45 M ${startX + 8} 51 Q $midX 54, ${endX - 10} 50';
      isUnderlineFilled = false;
      flutterUnderline = Path()
        ..moveTo(startX, 47)
        ..quadraticBezierTo(midX, 50, endX, 45)
        ..moveTo(startX + 8, 51)
        ..quadraticBezierTo(midX, 54, endX - 10, 50);
    }

    return _SignatureModel(
      totalWidth: totalWidth,
      svgPath: svgBuf.toString(),
      flutterPath: flutterPath,
      dots: dots,
      svgUnderline: svgUnderline,
      flutterUnderline: flutterUnderline,
      isUnderlineFilled: isUnderlineFilled,
    );
  }

  static String _normalizeText(String input) {
    // Remplacement des accents par des lettres simples pour la calligraphie
    return input
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[ÀÂÄ]'), 'A')
        .replaceAll(RegExp(r'[îï]'), 'i')
        .replaceAll(RegExp(r'[ÎÏ]'), 'I')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[ÔÖ]'), 'O')
        .replaceAll(RegExp(r'[ùûü]'), 'u')
        .replaceAll(RegExp(r'[ÙÛÜ]'), 'U')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[Ç]'), 'C');
  }

  static _Glyph? _getGlyph(String ch, double x, {required bool isUppercase}) {
    if (ch == ' ') return null;

    final lower = ch.toLowerCase();

    if (isUppercase) {
      switch (ch.toUpperCase()) {
        case 'A':
          return _Glyph(
            advance: 21,
            svgD: 'M ${x + 3} 39 C ${x + 7} 22, ${x + 11} 8, ${x + 14} 8 C ${x + 17} 8, ${x + 19} 24, ${x + 21} 40 M ${x + 8} 28 Q ${x + 14} 25, ${x + 18} 28',
            flutterBuilder: (p) {
              p.moveTo(x + 3, 39);
              p.cubicTo(x + 7, 22, x + 11, 8, x + 14, 8);
              p.cubicTo(x + 17, 8, x + 19, 24, x + 21, 40);
              p.moveTo(x + 8, 28);
              p.quadraticBezierTo(x + 14, 25, x + 18, 28);
            },
          );
        case 'B':
          return _Glyph(
            advance: 22,
            svgD: 'M ${x + 4} 39 C ${x + 2} 24, ${x + 9} 8, ${x + 15} 8 C ${x + 20} 8, ${x + 21} 18, ${x + 16} 24 C ${x + 14} 26, ${x + 10} 27, ${x + 7} 27 C ${x + 13} 27, ${x + 21} 27, ${x + 22} 35 C ${x + 23} 40, ${x + 17} 42, ${x + 9} 40',
            flutterBuilder: (p) {
              p.moveTo(x + 4, 39);
              p.cubicTo(x + 2, 24, x + 9, 8, x + 15, 8);
              p.cubicTo(x + 20, 8, x + 21, 18, x + 16, 24);
              p.cubicTo(x + 14, 26, x + 10, 27, x + 7, 27);
              p.cubicTo(x + 13, 27, x + 21, 27, x + 22, 35);
              p.cubicTo(x + 23, 40, x + 17, 42, x + 9, 40);
            },
          );
        case 'C':
          return _Glyph(
            advance: 19,
            svgD: 'M ${x + 17} 12 C ${x + 11} 7, ${x + 4} 14, ${x + 4} 26 C ${x + 4} 37, ${x + 11} 42, ${x + 18} 37',
            flutterBuilder: (p) {
              p.moveTo(x + 17, 12);
              p.cubicTo(x + 11, 7, x + 4, 14, x + 4, 26);
              p.cubicTo(x + 4, 37, x + 11, 42, x + 18, 37);
            },
          );
        case 'D':
          return _Glyph(
            advance: 21,
            svgD: 'M ${x + 6} 10 L ${x + 6} 39 C ${x + 6} 41, ${x + 3} 41, ${x + 3} 39 C ${x + 3} 37, ${x + 8} 38, ${x + 14} 38 C ${x + 21} 38, ${x + 22} 22, ${x + 16} 11 C ${x + 12} 9, ${x + 8} 9, ${x + 6} 10',
            flutterBuilder: (p) {
              p.moveTo(x + 6, 10);
              p.lineTo(x + 6, 39);
              p.cubicTo(x + 6, 41, x + 3, 41, x + 3, 39);
              p.cubicTo(x + 3, 37, x + 8, 38, x + 14, 38);
              p.cubicTo(x + 21, 38, x + 22, 22, x + 16, 11);
              p.cubicTo(x + 12, 9, x + 8, 9, x + 6, 10);
            },
          );
        case 'E':
          return _Glyph(
            advance: 18,
            svgD: 'M ${x + 15} 10 C ${x + 7} 7, ${x + 4} 15, ${x + 7} 22 C ${x + 11} 24, ${x + 14} 23, ${x + 9} 25 C ${x + 4} 28, ${x + 4} 36, ${x + 9} 40 C ${x + 14} 42, ${x + 18} 39, ${x + 19} 36',
            flutterBuilder: (p) {
              p.moveTo(x + 15, 10);
              p.cubicTo(x + 7, 7, x + 4, 15, x + 7, 22);
              p.cubicTo(x + 11, 24, x + 14, 23, x + 9, 25);
              p.cubicTo(x + 4, 28, x + 4, 36, x + 9, 40);
              p.cubicTo(x + 14, 42, x + 18, 39, x + 19, 36);
            },
          );
        case 'F':
          return _Glyph(
            advance: 19,
            svgD: 'M ${x + 3} 10 C ${x + 9} 8, ${x + 15} 8, ${x + 18} 11 M ${x + 10} 10 L ${x + 9} 39 M ${x + 6} 24 L ${x + 15} 24',
            flutterBuilder: (p) {
              p.moveTo(x + 3, 10);
              p.cubicTo(x + 9, 8, x + 15, 8, x + 18, 11);
              p.moveTo(x + 10, 10);
              p.lineTo(x + 9, 39);
              p.moveTo(x + 6, 24);
              p.lineTo(x + 15, 24);
            },
          );
        case 'G':
          return _Glyph(
            advance: 21,
            svgD: 'M ${x + 17} 11 C ${x + 9} 7, ${x + 4} 15, ${x + 4} 28 C ${x + 4} 39, ${x + 12} 41, ${x + 16} 34 L ${x + 16} 46 C ${x + 16} 52, ${x + 10} 53, ${x + 7} 48',
            flutterBuilder: (p) {
              p.moveTo(x + 17, 11);
              p.cubicTo(x + 9, 7, x + 4, 15, x + 4, 28);
              p.cubicTo(x + 4, 39, x + 12, 41, x + 16, 34);
              p.lineTo(x + 16, 46);
              p.cubicTo(x + 16, 52, x + 10, 53, x + 7, 48);
            },
          );
        case 'H':
          return _Glyph(
            advance: 21,
            svgD: 'M ${x + 5} 9 L ${x + 5} 39 M ${x + 16} 9 L ${x + 16} 39 M ${x + 4} 24 C ${x + 10} 22, ${x + 12} 26, ${x + 17} 24',
            flutterBuilder: (p) {
              p.moveTo(x + 5, 9);
              p.lineTo(x + 5, 39);
              p.moveTo(x + 16, 9);
              p.lineTo(x + 16, 39);
              p.moveTo(x + 4, 24);
              p.cubicTo(x + 10, 22, x + 12, 26, x + 17, 24);
            },
          );
        case 'I':
        case 'J':
          return _Glyph(
            advance: 16,
            svgD: 'M ${x + 3} 10 C ${x + 8} 8, ${x + 12} 8, ${x + 14} 11 M ${x + 9} 10 L ${x + 9} 38 C ${x + 9} 41, ${x + 6} 41, ${x + 3} 38',
            flutterBuilder: (p) {
              p.moveTo(x + 3, 10);
              p.cubicTo(x + 8, 8, x + 12, 8, x + 14, 11);
              p.moveTo(x + 9, 10);
              p.lineTo(x + 9, 38);
              p.cubicTo(x + 9, 41, x + 6, 41, x + 3, 38);
            },
          );
        case 'K':
          return _Glyph(
            advance: 20,
            svgD: 'M ${x + 5} 9 L ${x + 5} 39 M ${x + 17} 10 L ${x + 7} 25 L ${x + 18} 40',
            flutterBuilder: (p) {
              p.moveTo(x + 5, 9);
              p.lineTo(x + 5, 39);
              p.moveTo(x + 17, 10);
              p.lineTo(x + 7, 25);
              p.lineTo(x + 18, 40);
            },
          );
        case 'L':
          return _Glyph(
            advance: 18,
            svgD: 'M ${x + 6} 10 C ${x + 4} 24, ${x + 6} 36, ${x + 5} 39 C ${x + 5} 42, ${x + 3} 40, ${x + 4} 39 C ${x + 7} 39, ${x + 13} 39, ${x + 18} 37',
            flutterBuilder: (p) {
              p.moveTo(x + 6, 10);
              p.cubicTo(x + 4, 24, x + 6, 36, x + 5, 39);
              p.cubicTo(x + 5, 42, x + 3, 40, x + 4, 39);
              p.cubicTo(x + 7, 39, x + 13, 39, x + 18, 37);
            },
          );
        case 'M':
          return _Glyph(
            advance: 25,
            svgD: 'M ${x + 3} 39 L ${x + 6} 9 L ${x + 13} 36 L ${x + 20} 9 L ${x + 23} 39',
            flutterBuilder: (p) {
              p.moveTo(x + 3, 39);
              p.lineTo(x + 6, 9);
              p.lineTo(x + 13, 36);
              p.lineTo(x + 20, 9);
              p.lineTo(x + 23, 39);
            },
          );
        case 'N':
          return _Glyph(
            advance: 21,
            svgD: 'M ${x + 4} 39 L ${x + 6} 9 L ${x + 16} 39 L ${x + 18} 9',
            flutterBuilder: (p) {
              p.moveTo(x + 4, 39);
              p.lineTo(x + 6, 9);
              p.lineTo(x + 16, 39);
              p.lineTo(x + 18, 9);
            },
          );
        case 'O':
        case 'Q':
          return _Glyph(
            advance: 20,
            svgD: 'M ${x + 14} 10 C ${x + 7} 8, ${x + 3} 18, ${x + 3} 26 C ${x + 3} 36, ${x + 9} 41, ${x + 15} 39 C ${x + 20} 35, ${x + 20} 16, ${x + 14} 10',
            flutterBuilder: (p) {
              p.moveTo(x + 14, 10);
              p.cubicTo(x + 7, 8, x + 3, 18, x + 3, 26);
              p.cubicTo(x + 3, 36, x + 9, 41, x + 15, 39);
              p.cubicTo(x + 20, 35, x + 20, 16, x + 14, 10);
            },
          );
        case 'P':
          return _Glyph(
            advance: 19,
            svgD: 'M ${x + 5} 39 L ${x + 5} 9 C ${x + 10} 8, ${x + 18} 8, ${x + 18} 19 C ${x + 18} 27, ${x + 10} 27, ${x + 5} 27',
            flutterBuilder: (p) {
              p.moveTo(x + 5, 39);
              p.lineTo(x + 5, 9);
              p.cubicTo(x + 10, 8, x + 18, 8, x + 18, 19);
              p.cubicTo(x + 18, 27, x + 10, 27, x + 5, 27);
            },
          );
        case 'R':
          return _Glyph(
            advance: 20,
            svgD: 'M ${x + 5} 39 L ${x + 5} 9 C ${x + 10} 8, ${x + 18} 8, ${x + 18} 19 C ${x + 18} 25, ${x + 11} 26, ${x + 6} 26 M ${x + 12} 26 L ${x + 18} 40',
            flutterBuilder: (p) {
              p.moveTo(x + 5, 39);
              p.lineTo(x + 5, 9);
              p.cubicTo(x + 10, 8, x + 18, 8, x + 18, 19);
              p.cubicTo(x + 18, 25, x + 11, 26, x + 6, 26);
              p.moveTo(x + 12, 26);
              p.lineTo(x + 18, 40);
            },
          );
        case 'S':
          return _Glyph(
            advance: 18,
            svgD: 'M ${x + 15} 11 C ${x + 9} 7, ${x + 5} 15, ${x + 8} 21 C ${x + 13} 26, ${x + 17} 29, ${x + 13} 37 C ${x + 10} 41, ${x + 4} 39, ${x + 3} 36',
            flutterBuilder: (p) {
              p.moveTo(x + 15, 11);
              p.cubicTo(x + 9, 7, x + 5, 15, x + 8, 21);
              p.cubicTo(x + 13, 26, x + 17, 29, x + 13, 37);
              p.cubicTo(x + 10, 41, x + 4, 39, x + 3, 36);
            },
          );
        case 'T':
          return _Glyph(
            advance: 19,
            svgD: 'M ${x + 2} 10 C ${x + 8} 8, ${x + 14} 8, ${x + 18} 10 M ${x + 10} 10 L ${x + 10} 39',
            flutterBuilder: (p) {
              p.moveTo(x + 2, 10);
              p.cubicTo(x + 8, 8, x + 14, 8, x + 18, 10);
              p.moveTo(x + 10, 10);
              p.lineTo(x + 10, 39);
            },
          );
        case 'U':
        case 'V':
          return _Glyph(
            advance: 20,
            svgD: 'M ${x + 4} 10 L ${x + 4} 33 C ${x + 4} 40, ${x + 15} 40, ${x + 15} 33 L ${x + 15} 10',
            flutterBuilder: (p) {
              p.moveTo(x + 4, 10);
              p.lineTo(x + 4, 33);
              p.cubicTo(x + 4, 40, x + 15, 40, x + 15, 33);
              p.lineTo(x + 15, 10);
            },
          );
        case 'W':
          return _Glyph(
            advance: 24,
            svgD: 'M ${x + 3} 10 L ${x + 8} 39 L ${x + 13} 18 L ${x + 18} 39 L ${x + 23} 10',
            flutterBuilder: (p) {
              p.moveTo(x + 3, 10);
              p.lineTo(x + 8, 39);
              p.lineTo(x + 13, 18);
              p.lineTo(x + 18, 39);
              p.lineTo(x + 23, 10);
            },
          );
        case 'Y':
          return _Glyph(
            advance: 20,
            svgD: 'M ${x + 3} 10 L ${x + 10} 27 L {x + 17} 10 M ${x + 10} 27 L ${x + 10} 47 C ${x + 10} 52, ${x + 6} 53, ${x + 3} 49',
            flutterBuilder: (p) {
              p.moveTo(x + 3, 10);
              p.lineTo(x + 10, 27);
              p.lineTo(x + 17, 10);
              p.moveTo(x + 10, 27);
              p.lineTo(x + 10, 47);
              p.cubicTo(x + 10, 52, x + 6, 53, x + 3, 49);
            },
          );
        case 'Z':
          return _Glyph(
            advance: 19,
            svgD: 'M ${x + 4} 10 L ${x + 16} 10 L ${x + 5} 39 L ${x + 17} 39',
            flutterBuilder: (p) {
              p.moveTo(x + 4, 10);
              p.lineTo(x + 16, 10);
              p.lineTo(x + 5, 39);
              p.lineTo(x + 17, 39);
            },
          );
        default:
          break;
      }
    }

    // Lettres minuscules cursives
    switch (lower) {
      case 'a':
        return _Glyph(
          advance: 14,
          svgD: 'M ${x + 12} 30 C ${x + 7} 26, ${x + 1} 28, ${x + 1} 34 C ${x + 1} 40, ${x + 7} 41, ${x + 12} 37 M ${x + 12} 28 L ${x + 12} 39 C ${x + 12} 41, ${x + 13} 41, ${x + 14} 39',
          flutterBuilder: (p) {
            p.moveTo(x + 12, 30);
            p.cubicTo(x + 7, 26, x + 1, 28, x + 1, 34);
            p.cubicTo(x + 1, 40, x + 7, 41, x + 12, 37);
            p.moveTo(x + 12, 28);
            p.lineTo(x + 12, 39);
            p.cubicTo(x + 12, 41, x + 13, 41, x + 14, 39);
          },
        );
      case 'b':
        return _Glyph(
          advance: 13,
          svgD: 'M ${x + 2} 40 C ${x + 3} 24, ${x + 6} 9, ${x + 9} 9 C ${x + 11} 9, ${x + 9} 24, ${x + 7} 40 C ${x + 9} 41, ${x + 12} 39, ${x + 13} 34 C ${x + 13} 31, ${x + 11} 31, ${x + 13} 30',
          flutterBuilder: (p) {
            p.moveTo(x + 2, 40);
            p.cubicTo(x + 3, 24, x + 6, 9, x + 9, 9);
            p.cubicTo(x + 11, 9, x + 9, 24, x + 7, 40);
            p.cubicTo(x + 9, 41, x + 12, 39, x + 13, 34);
            p.cubicTo(x + 13, 31, x + 11, 31, x + 13, 30);
          },
        );
      case 'c':
        return _Glyph(
          advance: 12,
          svgD: 'M ${x + 11} 30 C ${x + 6} 26, ${x + 1} 29, ${x + 1} 35 C ${x + 1} 41, ${x + 8} 42, ${x + 12} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 11, 30);
            p.cubicTo(x + 6, 26, x + 1, 29, x + 1, 35);
            p.cubicTo(x + 1, 41, x + 8, 42, x + 12, 38);
          },
        );
      case 'd':
        return _Glyph(
          advance: 14,
          svgD: 'M ${x + 10} 30 C ${x + 6} 26, ${x + 1} 28, ${x + 1} 35 C ${x + 1} 41, ${x + 6} 41, ${x + 10} 37 M ${x + 10} 9 L ${x + 10} 39 C ${x + 10} 41, ${x + 12} 41, ${x + 14} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 10, 30);
            p.cubicTo(x + 6, 26, x + 1, 28, x + 1, 35);
            p.cubicTo(x + 1, 41, x + 6, 41, x + 10, 37);
            p.moveTo(x + 10, 9);
            p.lineTo(x + 10, 39);
            p.cubicTo(x + 10, 41, x + 12, 41, x + 14, 38);
          },
        );
      case 'e':
        return _Glyph(
          advance: 12,
          svgD: 'M ${x + 1} 37 C ${x + 5} 32, ${x + 10} 27, ${x + 10} 30 C ${x + 10} 34, ${x + 5} 37, ${x + 1} 37 C ${x + 1} 40, ${x + 6} 42, ${x + 11} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 1, 37);
            p.cubicTo(x + 5, 32, x + 10, 27, x + 10, 30);
            p.cubicTo(x + 10, 34, x + 5, 37, x + 1, 37);
            p.cubicTo(x + 1, 40, x + 6, 42, x + 11, 38);
          },
        );
      case 'f':
        return _Glyph(
          advance: 13,
          svgD: 'M ${x + 3} 40 C ${x + 4} 24, ${x + 7} 8, ${x + 9} 8 C ${x + 11} 8, ${x + 9} 26, ${x + 7} 48 C ${x + 6} 52, ${x + 9} 50, ${x + 10} 42 M ${x + 4} 33 L ${x + 12} 33',
          flutterBuilder: (p) {
            p.moveTo(x + 3, 40);
            p.cubicTo(x + 4, 24, x + 7, 8, x + 9, 8);
            p.cubicTo(x + 11, 8, x + 9, 26, x + 7, 48);
            p.cubicTo(x + 6, 52, x + 9, 50, x + 10, 42);
            p.moveTo(x + 4, 33);
            p.lineTo(x + 12, 33);
          },
        );
      case 'g':
        return _Glyph(
          advance: 14,
          svgD: 'M ${x + 11} 30 C ${x + 6} 26, ${x + 1} 28, ${x + 1} 35 C ${x + 1} 41, ${x + 6} 41, ${x + 11} 37 M ${x + 11} 28 L ${x + 11} 47 C ${x + 11} 52, ${x + 6} 53, ${x + 4} 49 C ${x + 2} 45, ${x + 7} 43, ${x + 14} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 11, 30);
            p.cubicTo(x + 6, 26, x + 1, 28, x + 1, 35);
            p.cubicTo(x + 1, 41, x + 6, 41, x + 11, 37);
            p.moveTo(x + 11, 28);
            p.lineTo(x + 11, 47);
            p.cubicTo(x + 11, 52, x + 6, 53, x + 4, 49);
            p.cubicTo(x + 2, 45, x + 7, 43, x + 14, 38);
          },
        );
      case 'h':
        return _Glyph(
          advance: 14,
          svgD: 'M ${x + 2} 40 C ${x + 3} 24, ${x + 6} 9, ${x + 8} 9 C ${x + 10} 9, ${x + 8} 25, ${x + 6} 40 M ${x + 6} 34 C ${x + 8} 28, ${x + 11} 28, ${x + 12} 32 L ${x + 12} 39 C ${x + 12} 41, ${x + 13} 41, ${x + 14} 39',
          flutterBuilder: (p) {
            p.moveTo(x + 2, 40);
            p.cubicTo(x + 3, 24, x + 6, 9, x + 8, 9);
            p.cubicTo(x + 10, 9, x + 8, 25, x + 6, 40);
            p.moveTo(x + 6, 34);
            p.cubicTo(x + 8, 28, x + 11, 28, x + 12, 32);
            p.lineTo(x + 12, 39);
            p.cubicTo(x + 12, 41, x + 13, 41, x + 14, 39);
          },
        );
      case 'i':
        return _Glyph(
          advance: 9,
          svgD: 'M ${x + 2} 34 C ${x + 4} 29, ${x + 5} 28, ${x + 6} 28 L ${x + 6} 39 C ${x + 6} 41, ${x + 8} 41, ${x + 9} 38',
          dots: [_Dot(x + 6, 20, 1.5)],
          flutterBuilder: (p) {
            p.moveTo(x + 2, 34);
            p.cubicTo(x + 4, 29, x + 5, 28, x + 6, 28);
            p.lineTo(x + 6, 39);
            p.cubicTo(x + 6, 41, x + 8, 41, x + 9, 38);
          },
        );
      case 'j':
        return _Glyph(
          advance: 10,
          svgD: 'M ${x + 2} 34 C ${x + 4} 29, ${x + 5} 28, ${x + 6} 28 L ${x + 6} 47 C ${x + 6} 52, ${x + 2} 53, ${x + 1} 49 C ${x + 0} 45, ${x + 4} 43, ${x + 10} 38',
          dots: [_Dot(x + 6, 20, 1.5)],
          flutterBuilder: (p) {
            p.moveTo(x + 2, 34);
            p.cubicTo(x + 4, 29, x + 5, 28, x + 6, 28);
            p.lineTo(x + 6, 47);
            p.cubicTo(x + 6, 52, x + 2, 53, x + 1, 49);
            p.cubicTo(x + 0, 45, x + 4, 43, x + 10, 38);
          },
        );
      case 'k':
        return _Glyph(
          advance: 13,
          svgD: 'M ${x + 2} 40 C ${x + 3} 24, ${x + 6} 9, ${x + 8} 9 C ${x + 10} 9, ${x + 8} 25, ${x + 6} 40 M ${x + 6} 33 C ${x + 10} 30, ${x + 11} 33, ${x + 8} 36 L ${x + 12} 40 C ${x + 12} 41, ${x + 13} 41, ${x + 14} 39',
          flutterBuilder: (p) {
            p.moveTo(x + 2, 40);
            p.cubicTo(x + 3, 24, x + 6, 9, x + 8, 9);
            p.cubicTo(x + 10, 9, x + 8, 25, x + 6, 40);
            p.moveTo(x + 6, 33);
            p.cubicTo(x + 10, 30, x + 11, 33, x + 8, 36);
            p.lineTo(x + 12, 40);
            p.cubicTo(x + 12, 41, x + 13, 41, x + 14, 39);
          },
        );
      case 'l':
        return _Glyph(
          advance: 10,
          svgD: 'M ${x + 2} 40 C ${x + 3} 24, ${x + 6} 9, ${x + 8} 9 C ${x + 10} 9, ${x + 8} 26, ${x + 6} 40 C ${x + 7} 41, ${x + 9} 41, ${x + 10} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 2, 40);
            p.cubicTo(x + 3, 24, x + 6, 9, x + 8, 9);
            p.cubicTo(x + 10, 9, x + 8, 26, x + 6, 40);
            p.cubicTo(x + 7, 41, x + 9, 41, x + 10, 38);
          },
        );
      case 'm':
        return _Glyph(
          advance: 19,
          svgD: 'M ${x + 1} 36 C ${x + 2} 30, ${x + 4} 28, ${x + 6} 28 L ${x + 6} 40 M ${x + 6} 33 C ${x + 8} 28, ${x + 10} 28, ${x + 12} 32 L ${x + 12} 40 M ${x + 12} 33 C ${x + 14} 28, ${x + 16} 28, ${x + 17} 32 L ${x + 17} 39 C ${x + 17} 41, ${x + 18} 41, ${x + 19} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 1, 36);
            p.cubicTo(x + 2, 30, x + 4, 28, x + 6, 28);
            p.lineTo(x + 6, 40);
            p.moveTo(x + 6, 33);
            p.cubicTo(x + 8, 28, x + 10, 28, x + 12, 32);
            p.lineTo(x + 12, 40);
            p.moveTo(x + 12, 33);
            p.cubicTo(x + 14, 28, x + 16, 28, x + 17, 32);
            p.lineTo(x + 17, 39);
            p.cubicTo(x + 17, 41, x + 18, 41, x + 19, 38);
          },
        );
      case 'n':
        return _Glyph(
          advance: 14,
          svgD: 'M ${x + 1} 36 C ${x + 2} 30, ${x + 4} 28, ${x + 6} 28 L ${x + 6} 40 M ${x + 6} 33 C ${x + 8} 28, ${x + 11} 28, ${x + 12} 32 L ${x + 12} 39 C ${x + 12} 41, ${x + 13} 41, ${x + 14} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 1, 36);
            p.cubicTo(x + 2, 30, x + 4, 28, x + 6, 28);
            p.lineTo(x + 6, 40);
            p.moveTo(x + 6, 33);
            p.cubicTo(x + 8, 28, x + 11, 28, x + 12, 32);
            p.lineTo(x + 12, 39);
            p.cubicTo(x + 12, 41, x + 13, 41, x + 14, 38);
          },
        );
      case 'o':
        return _Glyph(
          advance: 13,
          svgD: 'M ${x + 11} 31 C ${x + 6} 26, ${x + 1} 28, ${x + 1} 35 C ${x + 1} 41, ${x + 7} 42, ${x + 11} 37 C ${x + 13} 34, ${x + 13} 30, ${x + 11} 31 C ${x + 11} 31, ${x + 13} 32, ${x + 14} 32',
          flutterBuilder: (p) {
            p.moveTo(x + 11, 31);
            p.cubicTo(x + 6, 26, x + 1, 28, x + 1, 35);
            p.cubicTo(x + 1, 41, x + 7, 42, x + 11, 37);
            p.cubicTo(x + 13, 34, x + 13, 30, x + 11, 31);
            p.cubicTo(x + 11, 31, x + 13, 32, x + 14, 32);
          },
        );
      case 'p':
        return _Glyph(
          advance: 13,
          svgD: 'M ${x + 2} 35 L ${x + 5} 28 L ${x + 5} 49 M ${x + 5} 32 C ${x + 8} 27, ${x + 12} 29, ${x + 12} 35 C ${x + 12} 40, ${x + 7} 41, ${x + 5} 39 M ${x + 6} 40 C ${x + 9} 41, ${x + 12} 41, ${x + 13} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 2, 35);
            p.lineTo(x + 5, 28);
            p.lineTo(x + 5, 49);
            p.moveTo(x + 5, 32);
            p.cubicTo(x + 8, 27, x + 12, 29, x + 12, 35);
            p.cubicTo(x + 12, 40, x + 7, 41, x + 5, 39);
            p.moveTo(x + 6, 40);
            p.cubicTo(x + 9, 41, x + 12, 41, x + 13, 38);
          },
        );
      case 'q':
        return _Glyph(
          advance: 13,
          svgD: 'M ${x + 10} 30 C ${x + 6} 26, ${x + 1} 28, ${x + 1} 35 C ${x + 1} 41, ${x + 6} 41, ${x + 10} 37 M ${x + 10} 28 L ${x + 10} 49 C ${x + 10} 49, ${x + 13} 44, ${x + 13} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 10, 30);
            p.cubicTo(x + 6, 26, x + 1, 28, x + 1, 35);
            p.cubicTo(x + 1, 41, x + 6, 41, x + 10, 37);
            p.moveTo(x + 10, 28);
            p.lineTo(x + 10, 49);
            p.cubicTo(x + 10, 49, x + 13, 44, x + 13, 38);
          },
        );
      case 'r':
        return _Glyph(
          advance: 11,
          svgD: 'M ${x + 1} 36 C ${x + 3} 30, ${x + 5} 27, ${x + 7} 27 C ${x + 9} 27, ${x + 9} 31, ${x + 8} 34 L ${x + 8} 39 C ${x + 8} 41, ${x + 10} 41, ${x + 11} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 1, 36);
            p.cubicTo(x + 3, 30, x + 5, 27, x + 7, 27);
            p.cubicTo(x + 9, 27, x + 9, 31, x + 8, 34);
            p.lineTo(x + 8, 39);
            p.cubicTo(x + 8, 41, x + 10, 41, x + 11, 38);
          },
        );
      case 's':
        return _Glyph(
          advance: 10,
          svgD: 'M ${x + 1} 37 C ${x + 4} 30, ${x + 7} 27, ${x + 8} 29 C ${x + 9} 32, ${x + 3} 35, ${x + 5} 40 C ${x + 6} 41, ${x + 9} 41, ${x + 10} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 1, 37);
            p.cubicTo(x + 4, 30, x + 7, 27, x + 8, 29);
            p.cubicTo(x + 9, 32, x + 3, 35, x + 5, 40);
            p.cubicTo(x + 6, 41, x + 9, 41, x + 10, 38);
          },
        );
      case 't':
        return _Glyph(
          advance: 11,
          svgD: 'M ${x + 5} 14 L ${x + 5} 39 C ${x + 5} 41, ${x + 7} 41, ${x + 9} 38 M ${x + 1} 26 L ${x + 9} 25',
          flutterBuilder: (p) {
            p.moveTo(x + 5, 14);
            p.lineTo(x + 5, 39);
            p.cubicTo(x + 5, 41, x + 7, 41, x + 9, 38);
            p.moveTo(x + 1, 26);
            p.lineTo(x + 9, 25);
          },
        );
      case 'u':
        return _Glyph(
          advance: 13,
          svgD: 'M ${x + 1} 35 C ${x + 3} 29, ${x + 4} 28, ${x + 5} 28 L ${x + 5} 37 C ${x + 5} 41, ${x + 9} 41, ${x + 11} 36 L ${x + 11} 28 L ${x + 11} 39 C ${x + 11} 41, ${x + 12} 41, ${x + 13} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 1, 35);
            p.cubicTo(x + 3, 29, x + 4, 28, x + 5, 28);
            p.lineTo(x + 5, 37);
            p.cubicTo(x + 5, 41, x + 9, 41, x + 11, 36);
            p.lineTo(x + 11, 28);
            p.lineTo(x + 11, 39);
            p.cubicTo(x + 11, 41, x + 12, 41, x + 13, 38);
          },
        );
      case 'v':
        return _Glyph(
          advance: 12,
          svgD: 'M ${x + 1} 34 C ${x + 3} 29, ${x + 4} 28, ${x + 5} 28 L ${x + 7} 40 C ${x + 8} 41, ${x + 10} 32, ${x + 12} 31',
          flutterBuilder: (p) {
            p.moveTo(x + 1, 34);
            p.cubicTo(x + 3, 29, x + 4, 28, x + 5, 28);
            p.lineTo(x + 7, 40);
            p.cubicTo(x + 8, 41, x + 10, 32, x + 12, 31);
          },
        );
      case 'w':
        return _Glyph(
          advance: 17,
          svgD: 'M ${x + 1} 34 L ${x + 4} 28 L ${x + 5} 38 C ${x + 6} 41, ${x + 8} 39, ${x + 9} 32 L ${x + 11} 38 C ${x + 12} 41, ${x + 14} 39, ${x + 15} 31 L ${x + 17} 31',
          flutterBuilder: (p) {
            p.moveTo(x + 1, 34);
            p.lineTo(x + 4, 28);
            p.lineTo(x + 5, 38);
            p.cubicTo(x + 6, 41, x + 8, 39, x + 9, 32);
            p.lineTo(x + 11, 38);
            p.cubicTo(x + 12, 41, x + 14, 39, x + 15, 31);
            p.lineTo(x + 17, 31);
          },
        );
      case 'x':
        return _Glyph(
          advance: 12,
          svgD: 'M ${x + 2} 31 C ${x + 6} 34, ${x + 8} 38, ${x + 10} 40 M ${x + 10} 31 C ${x + 7} 35, ${x + 5} 38, ${x + 2} 40',
          flutterBuilder: (p) {
            p.moveTo(x + 2, 31);
            p.cubicTo(x + 6, 34, x + 8, 38, x + 10, 40);
            p.moveTo(x + 10, 31);
            p.cubicTo(x + 7, 35, x + 5, 38, x + 2, 40);
          },
        );
      case 'y':
        return _Glyph(
          advance: 13,
          svgD: 'M ${x + 1} 34 C ${x + 3} 29, ${x + 4} 28, ${x + 5} 28 L ${x + 5} 37 C ${x + 5} 41, ${x + 9} 41, ${x + 10} 36 L ${x + 10} 28 L ${x + 10} 47 C ${x + 10} 52, ${x + 6} 53, ${x + 4} 49 C ${x + 2} 45, ${x + 6} 43, ${x + 13} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 1, 34);
            p.cubicTo(x + 3, 29, x + 4, 28, x + 5, 28);
            p.lineTo(x + 5, 37);
            p.cubicTo(x + 5, 41, x + 9, 41, x + 10, 36);
            p.lineTo(x + 10, 28);
            p.lineTo(x + 10, 47);
            p.cubicTo(x + 10, 52, x + 6, 53, x + 4, 49);
            p.cubicTo(x + 2, 45, x + 6, 43, x + 13, 38);
          },
        );
      case 'z':
        return _Glyph(
          advance: 12,
          svgD: 'M ${x + 2} 31 C ${x + 5} 27, ${x + 9} 27, ${x + 9} 31 L ${x + 4} 40 C ${x + 7} 38, ${x + 9} 45, ${x + 8} 49 C ${x + 6} 53, ${x + 3} 51, ${x + 5} 46 C ${x + 6} 44, ${x + 9} 41, ${x + 12} 38',
          flutterBuilder: (p) {
            p.moveTo(x + 2, 31);
            p.cubicTo(x + 5, 27, x + 9, 27, x + 9, 31);
            p.lineTo(x + 4, 40);
            p.cubicTo(x + 7, 38, x + 9, 45, x + 8, 49);
            p.cubicTo(x + 6, 53, x + 3, 51, x + 5, 46);
            p.cubicTo(x + 6, 44, x + 9, 41, x + 12, 38);
          },
        );
      case '.':
        return _Glyph(
          advance: 6,
          svgD: '',
          dots: [_Dot(x + 3, 40, 1.5)],
          flutterBuilder: (_) {},
        );
      case '-':
        return _Glyph(
          advance: 8,
          svgD: 'M ${x + 1} 33 L ${x + 7} 33',
          flutterBuilder: (p) {
            p.moveTo(x + 1, 33);
            p.lineTo(x + 7, 33);
          },
        );
      case '\'':
        return _Glyph(
          advance: 6,
          svgD: 'M ${x + 3} 18 L ${x + 2} 24',
          flutterBuilder: (p) {
            p.moveTo(x + 3, 18);
            p.lineTo(x + 2, 24);
          },
        );
      default:
        // Chiffre ou caractère générique
        return _Glyph(
          advance: 10,
          svgD: 'M ${x + 2} 40 L ${x + 8} 28',
          flutterBuilder: (p) {
            p.moveTo(x + 2, 40);
            p.lineTo(x + 8, 28);
          },
        );
    }
  }
}

class _Dot {
  final double dx;
  final double dy;
  final double radius;
  const _Dot(this.dx, this.dy, this.radius);
}

class _Glyph {
  final double advance;
  final String svgD;
  final List<_Dot>? dots;
  final void Function(Path path) flutterBuilder;

  _Glyph({
    required this.advance,
    required this.svgD,
    this.dots,
    required this.flutterBuilder,
  });

  void applyToFlutterPath(Path path) {
    flutterBuilder(path);
  }
}

class _SignatureModel {
  final double totalWidth;
  final String svgPath;
  final Path flutterPath;
  final List<_Dot> dots;
  final String svgUnderline;
  final Path? flutterUnderline;
  final bool isUnderlineFilled;

  _SignatureModel({
    required this.totalWidth,
    required this.svgPath,
    required this.flutterPath,
    required this.dots,
    required this.svgUnderline,
    required this.flutterUnderline,
    required this.isUnderlineFilled,
  });
}

/// Peintre Flutter pour afficher la signature dynamique dans l'UI
class InvoiceSignaturePainter extends CustomPainter {
  final String text;
  final int styleIndex;
  final Color color;
  final double strokeWidth;

  const InvoiceSignaturePainter({
    required this.text,
    this.styleIndex = 0,
    this.color = const Color(0xFF1E3A8A),
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    InvoiceSignatureHelper.paint(
      canvas,
      size,
      text: text,
      styleIndex: styleIndex,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant InvoiceSignaturePainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.styleIndex != styleIndex ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

