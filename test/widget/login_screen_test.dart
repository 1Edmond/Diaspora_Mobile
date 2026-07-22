import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:diaspora_app/features/auth/presentation/screens/login_screen.dart';
import 'package:diaspora_app/core/di/injection.dart';

void main() {
  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync('hive_login_test').path);
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.close();
  });

  testWidgets('LoginScreen renders', (tester) async {
    configureDependencies();
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
