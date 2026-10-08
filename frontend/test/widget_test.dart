import 'package:flutter_test/flutter_test.dart';
import 'package:akumuslim/main.dart';

void main() {
  testWidgets('Counter initial value test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Mari awali hari dengan'), findsOneWidget);
  });
}
