import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/features/auth/presentation/screens/login_screen.dart';
import 'package:diaspora_app/core/di/injection.dart';

void main() {
  testWidgets('LoginScreen renders', (tester) async {
    configureDependencies();
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    // basic smoke assertions
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
