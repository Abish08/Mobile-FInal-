import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_nepal/features/auth/presentation/pages/forgot_password_screen.dart';

void main() {
  testWidgets('ForgotPasswordScreen renders reset code form', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Send reset code'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('ResetPasswordScreen renders code and password fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ResetPasswordScreen(email: 'abish@example.com')),
    );

    expect(find.text('Reset password'), findsWidgets);
    expect(find.textContaining('abish@example.com'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('ForgotPasswordScreen configures an email input', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

    final emailField = tester.widget<TextField>(find.byType(TextField));
    expect(emailField.keyboardType, TextInputType.emailAddress);
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
  });

  testWidgets('ForgotPasswordScreen ignores an empty submission', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Send reset code'));
    await tester.pump();

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('ResetPasswordScreen limits code input to six digits', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ResetPasswordScreen(email: 'abish@example.com')),
    );

    final codeField = tester.widget<TextField>(find.byType(TextField).first);
    expect(codeField.keyboardType, TextInputType.number);
    expect(codeField.maxLength, 6);
    expect(find.byIcon(Icons.pin_outlined), findsOneWidget);
  });

  testWidgets('ResetPasswordScreen obscures the new password', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ResetPasswordScreen(email: 'abish@example.com')),
    );

    final passwordField = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );
    expect(passwordField.obscureText, isTrue);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });
}
