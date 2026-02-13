import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingState {
  PageController pageController = PageController();
  RxInt selectPage = 0.obs;
  Timer? timer;
}
