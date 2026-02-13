import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

double mainPaddingWidth = 20.w;
double mainPaddingHeight = 24.h;

double screenHeight(BuildContext context, {double percent = 1}) =>
    MediaQuery.of(context).size.height * percent;

double screenWidth(BuildContext context, {double percent = 1}) =>
    MediaQuery.of(context).size.width * percent;
