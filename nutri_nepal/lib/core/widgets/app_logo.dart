import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  static const assetPath = 'assets/images/nutri_nepal_logo.png';

  final double size;
  final bool showText;
  final bool fullLogo;

  const AppLogo({
    super.key,
    this.size = 34,
    this.showText = true,
    this.fullLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    if (fullLogo) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.local_florist, color: Color(0xFF1B4332)),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.32),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFF2A211B),
              alignment: Alignment.center,
              child: Text(
                'N',
                style: TextStyle(
                  color: const Color(0xFFFF8A1F),
                  fontSize: size * 0.48,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.24),
          const Text(
            'NutriNepal',
            style: TextStyle(
              color: Color(0xFFFF8A1F),
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ],
    );
  }
}
