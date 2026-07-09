// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diaspora_app/main.dart';
import 'package:diaspora_app/core/di/injection.dart';

void main() {
  testWidgets('MyApp builds (smoke)', (WidgetTester tester) async {
    configureDependencies();
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    // avoid waiting for splash timer in unit test
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MyApp), findsOneWidget);
  });
}
