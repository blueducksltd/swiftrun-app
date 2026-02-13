// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:swiftrun/common/styles/style.dart';
// import 'package:swiftrun/features/auth/presentation/atom/login/phoneNumberLogin.dart';
// import 'package:swiftrun/features/onboarding/controller.dart';
// import 'package:swiftrun/features/onboarding/data/local/dataconstants.dart';
//
// import '../../common/widgets/widgets.dart';
//
// class OnBoardingScreen extends StatefulWidget {
//   const OnBoardingScreen({super.key});
//
//   @override
//   State<OnBoardingScreen> createState() => _OnBoardingScreenState();
// }
//
// class _OnBoardingScreenState extends State<OnBoardingScreen> {
//   final onBoardingController = Get.put(OnBoardingController());
//   @override
//   Widget build(BuildContext context) {
//     var onBoardState = onBoardingController.onBoardingState;
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: onBoardState.pageController,
//             itemBuilder: (context, index) =>
//                 DataConstants.onBoradingList[index],
//           ),
//           Positioned(
//             bottom: 150.h,
//             left: 10.w,
//             child: Align(
//               alignment: Alignment.bottomLeft,
//               child: SmoothPageIndicator(
//                 controller: onBoardState.pageController,
//                 count: DataConstants.onBoradingList.length,
//                 effect: ExpandingDotsEffect(
//                   activeDotColor: AppColor.disabledColor,
//                   dotHeight: 8.h,
//                   dotWidth: 8.h,
//                   dotColor: AppColor.whiteColor,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             left: 10.w,
//             right: 10.w,
//             bottom: 10.h,
//             child: Align(
//               alignment: Alignment.bottomCenter,
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20)
//                         .copyWith(bottom: 15),
//                     child: ButtonWidget(
//                       color: AppColor.primaryColor,
//                       onTap: () => Get.to(() => const PhoneNumberLoginScreen()),
//                       widget: Text(
//                         "Get Started",
//                         style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                               color: AppColor.whiteColor,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20,
//                             ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/routes/route.dart';
import 'package:swiftrun/features/auth/presentation/atom/login/login.dart';
import 'package:swiftrun/features/onboarding/controller.dart';
import 'package:swiftrun/features/onboarding/data/local/dataconstants.dart';

import '../../common/widgets/widgets.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final onBoardingController = Get.put(OnBoardingController());

  @override
  Widget build(BuildContext context) {
    var onBoardState = onBoardingController.onBoardingState;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: onBoardState.pageController,
            itemCount: DataConstants.onBoradingList.length, // ADD THIS LINE
            itemBuilder: (context, index) {
              // Add safety check
              if (index >= DataConstants.onBoradingList.length) {
                return Container(); // Return empty container if index is out of bounds
              }
              return DataConstants.onBoradingList[index];
            },
          ),
          Positioned(
            bottom: 150.h,
            left: 10.w,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: SmoothPageIndicator(
                controller: onBoardState.pageController,
                count: DataConstants.onBoradingList.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColor.disabledColor,
                  dotHeight: 8.h,
                  dotWidth: 8.h,
                  dotColor: AppColor.whiteColor,
                ),
              ),
            ),
          ),
          Positioned(
            left: 10.w,
            right: 10.w,
            bottom: 10.h,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20)
                        .copyWith(bottom: 15),
                    child: ButtonWidget(
                      color: AppColor.primaryColor,
                      onTap: () => Get.toNamed(AppRoutes.signin),
                      widget: Text(
                        "Get Started",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColor.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}