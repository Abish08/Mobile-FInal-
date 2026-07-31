import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_nepal/features/auth/presentation/pages/signup_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first
        .physicalSize = const Size(430, 1200);
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first
        .devicePixelRatio = 1;
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first
        .resetPhysicalSize();
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first
        .resetDevicePixelRatio();
  });

  testWidgets('SignupScreen renders registration form', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SignupScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Register'), findsWidgets);
  });

  testWidgets('SignupScreen requires terms agreement before signup',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SignupScreen()),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();

    expect(find.text('Please agree to the Terms & Conditions'), findsOneWidget);
  });
}
