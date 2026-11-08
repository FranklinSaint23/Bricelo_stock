import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_prime/services/invoice_signature_helper.dart';

void main() {
  test('InvoiceSignatureHelper generates valid SVG for default Bricelo', () {
    final svg = InvoiceSignatureHelper.generateSvg(text: 'Bricelo', styleIndex: 0);
    expect(svg, contains('<svg'));
    expect(svg, contains('</svg>'));
    expect(svg, contains('path'));
  });

  test('InvoiceSignatureHelper generates valid SVG for custom seller names', () {
    for (final name in ['Franklin', 'Ousmane Zongo', 'Pascal Ouédraogo', 'Amadou', 'Jean-Pierre']) {
      for (int style = 0; style <= 2; style++) {
        final svg = InvoiceSignatureHelper.generateSvg(text: name, styleIndex: style);
        expect(svg, contains('<svg'));
        expect(svg, contains('</svg>'));
        expect(svg, contains('path'));
      }
    }
  });

  testWidgets('InvoiceSignaturePainter paints on canvas without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 140,
              height: 48,
              child: CustomPaint(
                painter: const InvoiceSignaturePainter(
                  text: 'Franklin',
                  styleIndex: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
  });
}
