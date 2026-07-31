import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_nepal/features/auth/presentation/pages/login_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first
        .physicalSize = const Size(
      430,
      932,
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

  testWidgets('LoginScreen renders primary login controls', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pump();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets('LoginScreen shows validation message for empty fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pump();

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Please fill all fields'), findsOneWidget);
  });

  testWidgets('LoginScreen accepts email and password input', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'asha@example.com');
    await tester.enterText(fields.at(1), 'secret123');

    expect(find.text('asha@example.com'), findsOneWidget);
    expect(find.text('secret123'), findsOneWidget);
  });

  testWidgets('LoginScreen configures email keyboard', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    final emailField = tester.widget<TextField>(find.byType(TextField).first);
    expect(emailField.keyboardType, TextInputType.emailAddress);
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
  });

  testWidgets('LoginScreen obscures password initially', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    final passwordField = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );
    expect(passwordField.obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });

  testWidgets('LoginScreen visibility button reveals password', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    final passwordField = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );
    expect(passwordField.obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('LoginScreen Register link opens SignupScreen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('LoginScreen exposes an enabled Google sign-in action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(button.onPressed, isNotNull);
    expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
  });
}
