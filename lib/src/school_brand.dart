import 'package:flutter/material.dart';

abstract final class SchoolBrand {
  static const schoolName = 'Orison International School';
  static const appName = 'Orison School';
  static const shortName = 'ORISON';
  static const campus = 'Main Campus';
  static const primary = Color(0xFFC4141B);
  static const teacherAccent = Color(0xFF3157C8);

  // Set this to a bundled school-logo asset for each white-label release.
  static const String? logoAsset = null;
}

class SchoolLogo extends StatelessWidget {
  const SchoolLogo({super.key, this.size = 54, this.dark = false});

  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    if (SchoolBrand.logoAsset != null) {
      return Image.asset(
        SchoolBrand.logoAsset!,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: .12) : SchoolBrand.primary,
        borderRadius: BorderRadius.circular(size * .29),
      ),
      child: Icon(
        Icons.school_rounded,
        color: Colors.white,
        size: size * .51,
      ),
    );
  }
}
