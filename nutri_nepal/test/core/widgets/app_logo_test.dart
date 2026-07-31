import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_nepal/core/widgets/app_logo.dart';

void main() {
  Future<void> pumpLogo(
    WidgetTester tester, {
    double size = 34,
    bool showText = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppLogo(size: size, showText: showText),
          ),
        ),
      ),
    );
  }

  testWidgets('AppLogo shows the NutriNepal wordmark by default', (
    tester,
  ) async {
    await pumpLogo(tester);

    expect(find.text('NutriNepal'), findsOneWidget);
  });

  testWidgets('AppLogo can hide the wordmark', (tester) async {
    await pumpLogo(tester, showText: false);

    expect(find.text('NutriNepal'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('AppLogo applies its configured image size', (tester) async {
    await pumpLogo(tester, size: 64);

    final logoContainer = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AppLogo),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(logoContainer.constraints?.maxWidth, 64);
    expect(logoContainer.constraints?.maxHeight, 64);
  });

  testWidgets('AppLogo loads the shared logo asset with cover fit', (
    tester,
  ) async {
    await pumpLogo(tester);

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as AssetImage;
    expect(provider.assetName, AppLogo.assetPath);
    expect(image.fit, BoxFit.cover);
  });
}
