import 'package:flutter/material.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/theme/radioTheme.dart';
import 'package:swiftrun/common/theme/themes.dart';

class AppTheme {
  AppTheme._();
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: AppColor.primaryColor,
      secondary: AppColor.secondaryPrimary,
    ),
    useMaterial3: true,
    fontFamily: 'Lato',
    splashColor: AppColor.transparent,
    highlightColor: AppColor.transparent,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    primaryColor: AppColor.primaryColor,
    scaffoldBackgroundColor: AppColor.whiteColor,
    textTheme: AppTextTheme.lightTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: AppBottomSheetTheme.lightBottomSheetTheme,
    chipTheme: AppChipTheme.lightChipTheme,
    outlinedButtonTheme: AppOutlineButtonTheme.lightOutlineButtonTheme,
    checkboxTheme: AppCheckBoxTheme.lightCheckBoxTheme,
    inputDecorationTheme: AppTextFormFieldTheme.lightInputDecoration,
    radioTheme: AppRadioTheme.radioThemeLight,
    datePickerTheme: AppDateTheme.datePickerTheme,
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Lato',
    splashColor: AppColor.transparent,
    highlightColor: AppColor.transparent,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.dark,
    primaryColor: AppColor.primaryColor,
    scaffoldBackgroundColor: AppColor.blackColor,
    textTheme: AppTextTheme.darkTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: AppBottomSheetTheme.darkBottomSheetTheme,
    chipTheme: AppChipTheme.darkChipTheme,
    outlinedButtonTheme: AppOutlineButtonTheme.darkOutlineButtonTheme,
    checkboxTheme: AppCheckBoxTheme.darkCheckBoxTheme,
    inputDecorationTheme: AppTextFormFieldTheme.darkInputDecoration,
    radioTheme: AppRadioTheme.radioThemeLight,
    datePickerTheme: AppDateTheme.datePickerTheme,
  );
}
