import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:diaspora_app/core/di/injection.dart';
import 'package:diaspora_app/features/services/presentation/screens/services_home_screen.dart';

void main() {
  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync('hive_svc_test').path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.close();
  });

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
