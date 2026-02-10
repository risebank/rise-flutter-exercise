import 'package:flutter/material.dart';

abstract class RiseAppColors {
  Color get primary;
  Color get onPrimary;
  Color get primaryContainer;
  Color get onPrimaryContainer;

  Color get secondary;
  Color get onSecondary;
  Color get secondaryContainer;
  Color get onSecondaryContainer;

  Color get tertiary;
  Color get onTertiary;
  Color get tertiaryContainer;
  Color get onTertiaryContainer;

  Color get background;
  Color get onBackground;

  Color get surface;
  Color get onSurface;
  Color get surfaceVariant;
  Color get onSurfaceVariant;
  Color get surfaceDim;
  Color get surfaceBright;
  Color get surfaceContainerLowest;
  Color get surfaceContainerLow;
  Color get surfaceContainer;
  Color get surfaceContainerHigh;
  Color get surfaceContainerHighest;

  Color get inversePrimary;
  Color get inverseSurface;
  Color get inverseOnSurface;

  Color get error;
  Color get onError;
  Color get errorContainer;
  Color get onErrorContainer;

  Color get outline;
  Color get outlineVariant;
  Color get shadow;
  Color get scrim;

  // Custom
  Color get redVelvet;
  Color get redVelvetContainer;
  Color get onRedVelvet;
  Color get onRedVelvetContainer;
  Color get surfaceGradientRedVelvet1;
  Color get gold;
  Color get goldContainer;
  Color get onGold;
  Color get onGoldContainer;
  Color get surfaceGradientGold1;
  Color get violet;
  Color get violetContainer;
  Color get onViolet;
  Color get onVioletContainer;
  Color get success;
  Color get onSuccess;
  Color get successContainer;
  Color get onSuccessContainer;
  Color get onGreen;

  Color get primaryFixed;
  Color get onPrimaryFixed;
  Color get primaryFixedDim;
  Color get onPrimaryFixedVariant;

  Color get secondaryFixed;
  Color get onSecondaryFixed;
  Color get secondaryFixedDim;
  Color get onSecondaryFixedVariant;

  Color get tertiaryFixed;
  Color get onTertiaryFixed;
  Color get tertiaryFixedDim;
  Color get onTertiaryFixedVariant;

  static RiseAppColors light() => LightAppColors();
  static RiseAppColors dark() => DarkAppColors();
}

class DarkAppColors implements RiseAppColors {
  @override
  final primary = Color(0xffF1F1F1);
  @override
  final onPrimary = Color(0xff1B1B1B);
  @override
  final primaryContainer = Color(0xff000000);
  @override
  final onPrimaryContainer = Color(0xff757575);

  @override
  final secondary = Color(0xffC6C6C6);
  @override
  final onSecondary = Color(0xff303030);
  @override
  final secondaryContainer = Color(0xff474747);
  @override
  final onSecondaryContainer = Color(0xffB5B5B5);

  @override
  final tertiary = Color(0xffC6C6C6);
  @override
  final onTertiary = Color(0xff303030);
  @override
  final tertiaryContainer = Color(0xff000000);
  @override
  final onTertiaryContainer = Color(0xff757575);

  @override
  final background = Color(0xff131313);
  @override
  final onBackground = Color(0xffE2E2E2);

  @override
  final surface = Color(0xff131313);
  @override
  final onSurface = Color(0xffE2E2E2);
  @override
  final surfaceVariant = Color(0xff4C4546);
  @override
  final onSurfaceVariant = Color(0xffCFC4C5);
  @override
  final surfaceDim = Color(0xff131313);
  @override
  final surfaceBright = Color(0xff393939);
  @override
  final surfaceContainerLowest = Color(0xff0E0E0E);
  @override
  final surfaceContainerLow = Color(0xff1B1B1B);
  @override
  final surfaceContainer = Color(0xff1F1F1F);
  @override
  final surfaceContainerHigh = Color(0xff2A2A2A);
  @override
  final surfaceContainerHighest = Color(0xff353535);
  @override
  final inverseSurface = Color(0xffE2E2E2);
  @override
  final inverseOnSurface = Color(0xff303030);
  @override
  final inversePrimary = Color(0xff5E5E5E);

  @override
  final error = Color(0xffFFB4AB);
  @override
  final onError = Color(0xff690005);
  @override
  final errorContainer = Color(0xff93000A);
  @override
  final onErrorContainer = Color(0xffFFDAD6);

  @override
  final outline = Color(0xff988E90);
  @override
  final outlineVariant = Color(0xff4C4546);
  @override
  final shadow = Color(0xff000000);
  @override
  final scrim = Color(0xff000000);

  @override
  final redVelvet = Color(0xff893741);
  @override
  final redVelvetContainer = Color(0xffFADCDB);
  @override
  final onRedVelvet = Color(0xffFFFFFF);
  @override
  final onRedVelvetContainer = Color(0xff792C36);
  @override
  final surfaceGradientRedVelvet1 = Color(0xFFAF6F72);
  @override
  final gold = Color(0xff8F7403);
  @override
  final goldContainer = Color(0xffFAE195);
  @override
  final surfaceGradientGold1 = Color.fromARGB(255, 151, 138, 100);
  @override
  final onGold = Color(0xffFCF0D0);
  @override
  final onGoldContainer = Color(0xff483A01);
  @override
  final violet = Color(0xff832BD1);
  @override
  final violetContainer = Color(0xffEFDBFF);
  @override
  final onViolet = Color(0xffFFFFFF);
  @override
  final onVioletContainer = Color(0xff670BAD);
  @override
  final success = Color(0xff00BE90);
  @override
  final onSuccess = Color(0xffFFFFFF);
  @override
  final successContainer = Color(0xffD1F9E8);
  @override
  final onSuccessContainer = Color(0xff00785A);
  @override
  final onGreen = Color(0xff163816);

  @override
  final primaryFixed = Color(0xffE2E2E2);
  @override
  final onPrimaryFixed = Color(0xff1B1B1B);
  @override
  final primaryFixedDim = Color(0xffC6C6C6);
  @override
  final onPrimaryFixedVariant = Color(0xff474747);

  @override
  final secondaryFixed = Color(0xffE2E2E2);
  @override
  final onSecondaryFixed = Color(0xff1B1B1B);
  @override
  final secondaryFixedDim = Color(0xffC6C6C6);
  @override
  final onSecondaryFixedVariant = Color(0xff474747);

  @override
  final tertiaryFixed = Color(0xffE2E2E2);
  @override
  final onTertiaryFixed = Color(0xff1B1B1B);
  @override
  final tertiaryFixedDim = Color(0xffC6C6C6);
  @override
  final onTertiaryFixedVariant = Color(0xff474747);
}

class LightAppColors implements RiseAppColors {
  @override
  final primary = Color(0xff8C4A60);
  @override
  final onPrimary = Color(0xffFFFFFF);
  @override
  final primaryContainer = Color(0xff1B1B1B);
  @override
  final onPrimaryContainer = Color(0xff848484);

  @override
  final secondary = Color(0xff5E5E5E);
  @override
  final onSecondary = Color(0xffFFFFFF);
  @override
  final secondaryContainer = Color(0xffE2E2E2);
  @override
  final onSecondaryContainer = Color(0xff646464);

  @override
  final tertiary = Color(0xff000000);
  @override
  final onTertiary = Color(0xffFFFFFF);
  @override
  final tertiaryContainer = Color(0xff1B1B1B);
  @override
  final onTertiaryContainer = Color(0xff848484);

  @override
  final background = Color(0xffF9F9F9);
  @override
  final onBackground = Color(0xff1B1B1B);

  @override
  final surface = Color(0xffF9F9F9);
  @override
  final onSurface = Color(0xff1B1B1B);
  @override
  final surfaceVariant = Color(0xffEBE0E1);
  @override
  final onSurfaceVariant = Color(0xff4C4546);
  @override
  final surfaceDim = Color(0xffDADADA);
  @override
  final surfaceBright = Color(0xffF9F9F9);
  @override
  final surfaceContainerLowest = Color(0xffFFFFFF);
  @override
  final surfaceContainerLow = Color(0xffF3F3F3);
  @override
  final surfaceContainer = Color(0xffEEEEEE);
  @override
  final surfaceContainerHigh = Color(0xffE8E8E8);
  @override
  final surfaceContainerHighest = Color(0xffE2E2E2);
  @override
  final inverseSurface = Color(0xff303030);
  @override
  final inverseOnSurface = Color(0xffF1F1F1);
  @override
  final inversePrimary = Color(0xffC6C6C6);

  @override
  final error = Color(0xffBA1A1A);
  @override
  final onError = Color(0xffFFFFFF);
  @override
  final errorContainer = Color(0xffFFDAD6);
  @override
  final onErrorContainer = Color(0xff93000A);

  @override
  final outline = Color(0xff7E7576);
  @override
  final outlineVariant = Color(0xffCFC4C5);
  @override
  final shadow = Color(0xff000000);
  @override
  final scrim = Color(0xff000000);

  @override
  final redVelvet = Color(0xff8F4A51);
  @override
  final redVelvetContainer = Color(0xffFFDADB);
  @override
  final onRedVelvet = Color(0xffFFFFFF);
  @override
  final onRedVelvetContainer = Color(0xff72333A);
  @override
  final surfaceGradientRedVelvet1 = Color(0xFFAF6F72);
  @override
  final gold = Color(0xff755B0B);
  @override
  final goldContainer = Color(0xffFFDF95);
  @override
  final onGold = Color(0xffFFFFFF);
  @override
  final onGoldContainer = Color(0xff594400);
  @override
  final surfaceGradientGold1 = Color(0xFFFAE195);
  @override
  final violet = Color(0xff832BD1);
  @override
  final violetContainer = Color(0xffF2DAFF);
  @override
  final onViolet = Color(0xffFFFFFF);
  @override
  final onVioletContainer = Color(0xff670BAD);
  @override
  final success = Color(0xff00BE90);
  @override
  final onSuccess = Color(0xffFFFFFF);
  @override
  final successContainer = Color(0xffD1F9E8);
  @override
  final onSuccessContainer = Color(0xff00785A);
  @override
  final onGreen = Color(0xff163816);

  @override
  final primaryFixed = Color(0xffE2E2E2);
  @override
  final onPrimaryFixed = Color(0xff1B1B1B);
  @override
  final primaryFixedDim = Color(0xffC6C6C6);
  @override
  final onPrimaryFixedVariant = Color(0xff474747);

  @override
  final secondaryFixed = Color(0xffE2E2E2);
  @override
  final onSecondaryFixed = Color(0xff1B1B1B);
  @override
  final secondaryFixedDim = Color(0xffC6C6C6);
  @override
  final onSecondaryFixedVariant = Color(0xff474747);

  @override
  final tertiaryFixed = Color(0xffE2E2E2);
  @override
  final onTertiaryFixed = Color(0xff1B1B1B);
  @override
  final tertiaryFixedDim = Color(0xffC6C6C6);
  @override
  final onTertiaryFixedVariant = Color(0xff474747);
}
