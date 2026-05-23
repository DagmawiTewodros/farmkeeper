import 'package:flutter_test/flutter_test.dart';

import 'package:farmkeeper/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FarmKeeperApp());

    expect(find.text('FarmKeeper'), findsOneWidget);
    expect(find.text('INITIALIZING FIELD SENSORS'), findsOneWidget);
  });
}
