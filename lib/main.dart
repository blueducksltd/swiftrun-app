
import 'package:country_picker/country_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:swiftrun/common/routes/route.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/theme/themes.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/firebase_options.dart';
import 'package:swiftrun/global/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation to avoid layout issues in landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Add error handler for lifecycle assertion errors
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('Invalid state transition')) {
      print('Lifecycle assertion error handled: ${details.exception}');
      return;
    }
    FlutterError.presentError(details);
  };

  // Initialize Firebase first, before anything else
  try {
    Firebase.app();
  } catch (_) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  // Initialize Global (essential services only)
  await Global.init();
  
  // Defer App Check activation to after UI shows (non-blocking)
  Future.microtask(() async {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  });

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColor.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: getDesignSizeForScreen(context),
      builder: (context, child) => GetMaterialApp(
        navigatorKey: Get.key,
        supportedLocales: const [Locale('en'), Locale('uk')],
        initialRoute: AppRoutes.initial,
        getPages: AppPages.routes,
        localizationsDelegates: const [
          CountryLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return child!;
        },
      ),
    );
  }

  Size getDesignSizeForScreen(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    for (var screenSize in screenSizes) {
      if (screenSize.size.width >= screenWidth) {
        Logger.i("Screen Size $screenWidth $screenHeight");
        return screenSize.size;
      }
    }
    Logger.i("Screen Size Fallback $screenWidth $screenHeight");
    return const Size(1080, 2160);
  }
}