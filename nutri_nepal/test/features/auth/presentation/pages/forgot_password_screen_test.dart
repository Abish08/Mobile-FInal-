import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_nepal/features/auth/presentation/pages/forgot_password_screen.dart';

void main() {
  testWidgets('ForgotPasswordScreen renders reset code form', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ForgotPasswordScreen()),
    );

    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Send reset code'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('ResetPasswordScreen renders code and password fields',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResetPasswordScreen(email: 'abish@example.com'),
      ),
    );

    expect(find.text('Reset password'), findsWidgets);
    expect(find.textContaining('abish@example.com'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
