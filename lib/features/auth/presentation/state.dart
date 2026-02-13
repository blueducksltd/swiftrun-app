import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class AuthenticationState {
  // ignore: prefer_typing_uninitialized_variables
  var onTapRecognizer;

  late StreamController<ErrorAnimationType> errorController;

  RxBool hasError = false.obs;
  RxString currentText = "".obs;
  RxBool isObsecure = true.obs;
  RxBool isObsecureConfirm = true.obs;
  RxBool isRememberMeSelected = true.obs;
  RxBool isPasswordMatched = false.obs;
  RxString verificationID = "".obs;

  Rx countryCode = "+234".obs;
  Rx countryName = "Nigeria".obs;

  final imagePicker = ImagePicker();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final verificationFormKey = GlobalKey<FormState>();
  final nameFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  final phoneNumberFormKey = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();

  var phoneNumberController = TextEditingController();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  var ninController = TextEditingController();
  final phoneNumber = ''.obs;
  var pickedImageXfile = Rxn<XFile>();
}
