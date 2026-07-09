import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/core/di/injection.dart';
import 'package:diaspora_app/features/services/presentation/screens/services_home_screen.dart';

void main() {
  testWidgets('ServicesHomeScreen renders list', (tester) async {
    configureDependencies();
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ServicesHomeScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ServicesHomeScreen), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });
}
