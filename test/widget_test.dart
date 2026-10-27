import 'package:flutter_test/flutter_test.dart';
import 'package:stock_prime/main.dart';

void main() {
  testWidgets('StockPrimeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StockPrimeApp());
    expect(find.byType(StockPrimeApp), findsOneWidget);
  });
}
