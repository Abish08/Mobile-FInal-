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
        .physicalSize = const Size(
      430,
      1200,
    );
    TestWidgetsFlutterBinding.ensureInitialized()
            .platformDispatcher
            .views
            .first
            .devicePixelRatio =
        1;
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first
        .resetPhysicalSize();
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first
        .resetDevicePixelRatio();
  });

  testWidgets('SignupScreen renders registration form', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );
    await tester.pump();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Register'), findsWidgets);
  });

  testWidgets('SignupScreen requires terms agreement before signup', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );
    await tester.pump();

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pump();

    expect(find.text('Please agree to the Terms & Conditions'), findsOneWidget);
  });

  testWidgets('SignupScreen renders all six account fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );

    expect(find.byType(TextField), findsNWidgets(6));
    expect(find.byIcon(Icons.person_outline), findsNWidgets(2));
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
  });

  testWidgets('SignupScreen configures email and phone keyboards', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[2].keyboardType, TextInputType.emailAddress);
    expect(fields[3].keyboardType, TextInputType.phone);
  });

  testWidgets('SignupScreen obscures both password fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[4].obscureText, isTrue);
    expect(fields[5].obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));
  });

  testWidgets('SignupScreen password visibility buttons work independently', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );

    await tester.tap(find.byIcon(Icons.visibility_outlined).first);
    await tester.pump();

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[4].obscureText, isFalse);
    expect(fields[5].obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('SignupScreen terms checkbox can be selected', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );

    var checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isFalse);

    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);
  });

  testWidgets('SignupScreen Login link returns to LoginScreen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );

    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
