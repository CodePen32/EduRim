import 'package:flutter_test/flutter_test.dart';
import 'package:edurim/app.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const EdurImApp());
    expect(find.byType(EdurImApp), findsOneWidget);
  });
}
