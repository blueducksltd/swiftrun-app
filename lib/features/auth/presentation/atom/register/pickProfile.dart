// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/routes/route.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/size.dart';
import 'package:swiftrun/common/widgets/customMaterialButton.dart';
import 'package:swiftrun/common/widgets/custom_botton.dart';
import 'package:swiftrun/features/auth/index.dart';

class SetProfilePicture extends StatefulWidget {
  const SetProfilePicture({super.key});

  @override
  State<SetProfilePicture> createState() => _SetProfilePictureState();
}

class _SetProfilePictureState extends State<SetProfilePicture> {
  var authController = Get.put(AuthenticationController());
  @override
  Widget build(BuildContext context) {
    var authState = authController.authState;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: mainPaddingWidth, vertical: mainPaddingHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pick a profile picture",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Text("Have a favourite selfie? Upload it now"),
              40.verticalSpace,
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Obx(() {
                      //  UserModel userData = SessionController.to.userData;
                      return SizedBox(
                        width: 145,
                        height: 145,
                        child: authState.pickedImageXfile.value != null
                            ? CircleAvatar(
                                radius: 30.r,
                                foregroundImage: FileImage(
                                  File(authState.pickedImageXfile.value!.path),
                                ),
                              )
                            : CircleAvatar(
                                child: Image.asset("assets/icons/avater.png"),
                              ),
                      );
                    }),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 95,
                    child: InkWell(
                      onTap: () => Get.defaultDialog(
                          backgroundColor: AppColor.whiteColor,
                          title: "Choose Source",
                          content: Column(
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColor.primaryColor,
                                ),
                                onPressed: () {
                                  authController.useCamera();
                                  Get.back();
                                },
                                child: Text(
                                  'Use Camera',
                                  style: TextStyle(
                                    color: AppColor.whiteColor,
                                  ),
                                ),
                              ),
                              10.verticalSpace,
                              OutlinedButton(
                                onPressed: () {
                                  authController.useGallery();
                                  Get.back();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColor.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  'Use Gallery',
                                  style: TextStyle(
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              )
                            ],
                          )),
                      child: Container(
                        height: 75.w,
                        width: 75.w,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: AppColor.bgColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColor.primaryColor)),
                        child: Container(
                          height: 30.w,
                          width: 30.w,
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            FontAwesomeIcons.plus,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const Spacer(),
              ButtonWidget(
                onTap: () => authController.uploadUserProfile(),
                color: AppColor.primaryColor,
                widget: Text(
                  "Next",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColor.whiteColor),
                ),
              ),
              Center(
                child: CustomMaterialButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                  style: Theme.of(context).textTheme.bodySmall!,
                  name: "Skip for now",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
