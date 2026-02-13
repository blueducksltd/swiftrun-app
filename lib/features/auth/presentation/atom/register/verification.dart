// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:swiftrun/common/styles/style.dart';
// import 'package:swiftrun/common/utils/size.dart';
// import 'package:swiftrun/common/widgets/widgets.dart';
// import 'package:swiftrun/features/auth/presentation/controller.dart';
//
// class VerificationScreen extends StatefulWidget {
//   final String phoneNumber, verficationId;
//
//   const VerificationScreen({
//     super.key,
//     required this.phoneNumber,
//     required this.verficationId,
//   });
//
//   @override
//   State<VerificationScreen> createState() => _VerificationScreenState();
// }
//
// class _VerificationScreenState extends State<VerificationScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Get.delete<AuthenticationController>();
//   }
//
//   final authController = Get.put(AuthenticationController());
//
//   @override
//   Widget build(BuildContext context) {
//     var pinController = TextEditingController();
//
//     var authstate = authController.authState;
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: PopScope(
//         canPop: false,
//         child: Obx(
//           () => Padding(
//             padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth),
//             child: SizedBox(
//               height: size.height,
//               width: size.width,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   100.verticalSpace,
//                   Center(child: Image.asset("assets/images/swiftrunlogo.png")),
//                   100.verticalSpace,
//                   Text(
//                     'Verification code OTP',
//                     style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                   RichText(
//                     text: TextSpan(
//                       text: "Enter the code sent to ",
//                       children: [
//                         TextSpan(
//                           text: widget.phoneNumber,
//                           style:
//                               Theme.of(context).textTheme.bodyMedium!.copyWith(
//                                     fontSize: 18,
//                                     color: AppColor.primaryColor,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                         ),
//                       ],
//                       style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                           fontWeight: FontWeight.normal,
//                           color: AppColor.blackColor.withValues(alpha: 0.5)),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   20.verticalSpace,
//                   Form(
//                     // key: authst.formKey,
//                     child: Padding(
//                       padding: EdgeInsets.only(right: 10.w),
//                       child: PinCodeTextField(
//                         appContext: context,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                         ],
//                         pastedTextStyle: TextStyle(
//                           color: Colors.green.shade600,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         length: 6,
//                         obscureText: false,
//                         obscuringCharacter: '*',
//                         animationType: AnimationType.fade,
//                         validator: (value) {
//                           if (value!.length < 6) {
//                             return "Fill all the fields";
//                           } else {
//                             return null;
//                           }
//                         },
//                         pinTheme: PinTheme(
//                           shape: PinCodeFieldShape.box,
//                           borderRadius: BorderRadius.circular(15),
//                           fieldHeight: 50,
//                           fieldWidth: 50,
//                           selectedFillColor: AppColor.bgColor,
//                           inactiveFillColor: AppColor.bgColor,
//                           inactiveColor: AppColor.bgColor,
//                           selectedColor: AppColor.bgColor,
//                           activeFillColor: authstate.hasError.value
//                               ? AppColor.whiteColor
//                               : Colors.white,
//                           activeColor: AppColor.bgColor,
//                         ),
//                         cursorColor: Colors.black,
//                         animationDuration: const Duration(milliseconds: 300),
//                         textStyle: const TextStyle(fontSize: 20, height: 1.6),
//                         enableActiveFill: true,
//                         errorAnimationController: authstate.errorController,
//                         controller: pinController,
//                         keyboardType: TextInputType.number,
//                         boxShadows: const [
//                           BoxShadow(
//                             offset: Offset(0, 1),
//                             color: Colors.black12,
//                             blurRadius: 10,
//                           )
//                         ],
//                         onCompleted: (v) {
//                           debugPrint("Completed $v");
//
//                           authstate.verificationFormKey.currentState
//                               ?.validate();
//                           // conditions for validating
//                           if (authstate.currentText.value.length != 6) {
//                             authstate.errorController.add(ErrorAnimationType
//                                 .shake); // Triggering error shake animation
//
//                             authstate.hasError.value = true;
//                           } else {
//                             authstate.hasError.value = false;
//                             authController.verifyOTP(
//                               otpCode: v.toString(),
//                               verficationId: widget.verficationId,
//                               phoneNumber: widget.phoneNumber,
//                             );
//                           }
//                         },
//                         onChanged: (value) {
//                           authstate.currentText.value = value;
//                         },
//                         beforeTextPaste: (text) {
//                           return true;
//                         },
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 30.0),
//                     child: Text(
//                       authstate.hasError.value
//                           ? "*Please fill up all the cells properly"
//                           : "",
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium!
//                           .copyWith(color: AppColor.errorColor),
//                     ),
//                   ),
//                   //10.verticalSpace,
//                   RichText(
//                     textAlign: TextAlign.center,
//                     text: TextSpan(
//                       text: "Didn't receive the code? ",
//                       style:
//                           const TextStyle(color: Colors.black54, fontSize: 15),
//                       children: [
//                         TextSpan(
//                           text: "Resend Code",
//                           recognizer: authstate.onTapRecognizer,
//                           style: Theme.of(context)
//                               .textTheme
//                               .bodyMedium!
//                               .copyWith(color: AppColor.errorColor),
//                         )
//                       ],
//                     ),
//                   ),
//                   20.verticalSpace,
//                   ButtonWidget(
//                     onTap: () => authController.verifyOTP(
//                       otpCode: pinController.text.toString(),
//                       phoneNumber: widget.phoneNumber,
//                       verficationId: widget.verficationId,
//                     ),
//                     color: AppColor.primaryColor,
//                     widget: Text(
//                       "Verify",
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium!
//                           .copyWith(color: AppColor.whiteColor),
//                     ),
//                   ),
//                   Spacer(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/features/auth/presentation/controller.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber, verficationId;

  const VerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verficationId,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  void initState() {
    super.initState();
    Get.delete<AuthenticationController>();
  }

  final authController = Get.put(AuthenticationController());

  @override
  Widget build(BuildContext context) {
    var pinController = TextEditingController();
    var authstate = authController.authState;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    SizedBox(height: size.height * 0.06),
                    // Logo
                    Center(
                      child: Image.asset(
                        "assets/images/swiftrunlogo.png",
                        height: size.width * 0.2,
                        width: size.width * 0.2,
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    // Title
                    Text(
                      "Verification Code",
                      style: TextStyle(
                        fontSize: size.width * 0.065,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    RichText(
                      text: TextSpan(
                        text: "Enter the code sent to ",
                        style: TextStyle(
                          fontSize: size.width * 0.038,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: widget.phoneNumber,
                            style: TextStyle(
                              fontSize: size.width * 0.038,
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    // PIN Code input - Clean design
                    Form(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final availableWidth = constraints.maxWidth;
                          final fieldWidth = (availableWidth - 50) / 6;
                          final fieldSize = fieldWidth.clamp(45.0, 58.0);
                          
                          return PinCodeTextField(
                            appContext: context,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            length: 6,
                            obscureText: false,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(8),
                              fieldHeight: fieldSize,
                              fieldWidth: fieldSize,
                              activeFillColor: Colors.white,
                              inactiveFillColor: Colors.white,
                              selectedFillColor: Colors.white,
                              activeColor: AppColor.primaryColor,
                              inactiveColor: Colors.grey[300]!,
                              selectedColor: AppColor.primaryColor,
                              borderWidth: 1.5,
                            ),
                            cursorColor: AppColor.primaryColor,
                            animationDuration: const Duration(milliseconds: 200),
                            textStyle: TextStyle(
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            enableActiveFill: true,
                            controller: pinController,
                            keyboardType: TextInputType.number,
                            onCompleted: (v) {
                              authController.verifyOTP(
                                otpCode: v.toString(),
                                verficationId: widget.verficationId,
                                phoneNumber: widget.phoneNumber,
                              );
                            },
                            onChanged: (value) {
                              authstate.currentText.value = value;
                            },
                            beforeTextPaste: (text) => true,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    // Resend code
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Didn't receive the code? ",
                          style: TextStyle(
                            fontSize: size.width * 0.038,
                            color: Colors.grey[600],
                          ),
                          children: [
                            TextSpan(
                              text: "Resend",
                              recognizer: authstate.onTapRecognizer,
                              style: TextStyle(
                                fontSize: size.width * 0.038,
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: () => authController.verifyOTP(
                          otpCode: pinController.text.toString(),
                          phoneNumber: widget.phoneNumber,
                          verficationId: widget.verficationId,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}