import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:nutri_nepal/features/onboarding/presentation/pages/onboarding_screen.dart';

void main() {
  Future<void> pumpOnboarding(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingView())),
    );
    await tester.pump();
  }

  Future<void> goToPage(WidgetTester tester, int page) async {
    for (var index = 0; index < page; index++) {
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('OnboardingView starts with nutrition guidance', (tester) async {
    await pumpOnboarding(tester);

    expect(find.text('Track your Nutrition'), findsOneWidget);
    expect(
      find.text(
        'Log meals,track macros, and stay on top of your daily calories.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('OnboardingView displays the nutrition icon first', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    expect(find.byIcon(Icons.restaurant), findsOneWidget);
  });

  testWidgets('OnboardingView renders one indicator per page', (tester) async {
    await pumpOnboarding(tester);

    expect(find.byType(AnimatedContainer), findsNWidgets(3));
  });

  testWidgets('OnboardingView highlights the first indicator initially', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    final indicatorFinder = find.byType(AnimatedContainer);
    final widths = List.generate(
      3,
      (index) => tester.getSize(indicatorFinder.at(index)).width,
    );
    expect(widths[0], greaterThan(widths[1]));
    expect(widths[1], widths[2]);
  });

  testWidgets('Next advances to personalized workouts', (tester) async {
    await pumpOnboarding(tester);

    await goToPage(tester, 1);

    expect(find.text('Personalized Workouts'), findsOneWidget);
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
  });

  testWidgets('second page highlights the middle indicator', (tester) async {
    await pumpOnboarding(tester);

    await goToPage(tester, 1);

    final indicatorFinder = find.byType(AnimatedContainer);
    final widths = List.generate(
      3,
      (index) => tester.getSize(indicatorFinder.at(index)).width,
    );
    expect(widths[1], greaterThan(widths[0]));
    expect(widths[0], widths[2]);
  });

  testWidgets('Next reaches progress monitoring guidance', (tester) async {
    await pumpOnboarding(tester);

    await goToPage(tester, 2);

    expect(find.text('Monitor Your Progress'), findsOneWidget);
    expect(find.byIcon(Icons.show_chart), findsOneWidget);
    expect(
      find.text(
        'Track weight, view charts, and celebrate your health milestones',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Next on the final page opens LoginScreen', (tester) async {
    await pumpOnboarding(tester);

    await goToPage(tester, 2);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingView), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
