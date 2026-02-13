import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swiftrun/features/onboarding/data/local/dataconstants.dart';
import 'package:swiftrun/features/onboarding/state.dart';

class OnBoardingController extends GetxController {
  var onBoardingState = OnboardingState();

  @override
  void onInit() {
    onBoardingState.pageController.addListener(
      () {
        onBoardingState.selectPage.value =
            onBoardingState.pageController.page?.round() ?? 0;
      },
    );
    _autoStart();
    super.onInit();
  }

  void _autoStart() async {
    onBoardingState.timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (onBoardingState.selectPage.value <
          DataConstants.onBoradingList.length - 1) {
        onBoardingState.selectPage.value++;
      } else {
        onBoardingState.selectPage.value = 0;
      }

      if (onBoardingState.pageController.hasClients) {
        onBoardingState.pageController.animateToPage(
          onBoardingState.selectPage.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void stopAutoStart() {
    onBoardingState.pageController.dispose();
  }

  @override
  void dispose() {
    super.dispose();
    stopAutoStart();
    onBoardingState.pageController.dispose();
  }
}
