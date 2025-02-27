import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // AMOLED theme with lavender/purple accents
  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFEFEFE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color.fromRGBO(10, 10, 10, 1);
  static const Color nearlyBlack2 = Color.fromRGBO(16, 16, 15, 1);
  static const Color grey = Color(0xFF2A2A2A);
  // ignore: constant_identifier_names
  static const Color dark_grey = Color(0xFF1A1A1A);

  // Accent colors
  static const Color klooigeldRoze = Color(0xFFF787D9); // New: Accent style 1 / Card style 1
  static const Color klooigeldRozeAlt = Color(0xFFD866B9);
  static const Color klooigeldGroen = Color(0xFFB2DF1F); // New: Background 1 / Accent style 2 / Card style 2
  static const Color klooigeldDarkGroen = Color(0xFF7D9D16);
  static const Color klooigeldPaars = Color(0xFFC8BBF3); // New: Accent style 2 / Card style 3
  static const Color klooigeldBlauw = Color(0xFF1D1999); // New: Button & pop-up background / Button text
  static const Color black = Color(0xFF000000); // New: Main text color

  static const Color darkText = Color(0xFFB0BEC5);
  static const Color darkerText = Color(0xFFECEFF1);
  static const Color lightText = Color(0xFFB3B3B3);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF37474F);
  static const Color chipBackground = Color(0xFF263238);
  static const Color spacer = Color(0xFF212121);

  // Updated font families
  static const String fontName = 'Poppins';
  static const String logoFont1 = 'PurpleMagic'; // Logo font 1
  static const String logoFont2 = 'PurpleMagicSVG'; // Logo font 2
  static const String titleFont = 'NeighborBlack'; // Title font
  static const String neighbor = 'Neighbor'; // Title font

  static const TextTheme textTheme = TextTheme(
    headlineMedium: display1,
    headlineSmall: headline,
    titleLarge: title,
    titleSmall: subtitle,
    bodyMedium: body2,
    bodyLarge: body1,
    bodySmall: caption,
  );

  static const TextStyle display1 = TextStyle( // h4 -> display1
    fontFamily: logoFont1,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle( // h5 -> headline
    fontFamily: titleFont,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle( // h6 -> title
    fontFamily: titleFont,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle( // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle( // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle( // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle( // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // Light text color
  );
}
