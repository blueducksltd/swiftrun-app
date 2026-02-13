import 'dart:developer';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/utils/phone_input_formatter.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/utils/country_utils.dart';
import 'package:swiftrun/common/widgets/inputFormater.dart';
import 'package:swiftrun/common/widgets/widgets.dart';
import 'package:swiftrun/features/auth/presentation/atom/register/setup_password.dart';
import 'package:swiftrun/features/auth/presentation/controller.dart';
import 'package:swiftrun/features/auth/presentation/state.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  late FocusNode _phoneNumber;

  @override
  void initState() {
    super.initState();
    _phoneNumber = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _phoneNumber.dispose();
  }

  String flag = '\u{1F1F3}\u{1F1EC}'; // Nigeria flag as default
  final authController = Get.put(AuthenticationController());

  @override
  Widget build(BuildContext context) {
    var authstate = authController.authState;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: mainPaddingWidth,
            vertical: mainPaddingHeight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              40.verticalSpace,
              ...[
                Text(
                  "Enter your Phone Number",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  "Provide your phone number for contact and delivery purposes",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.normal),
                ),
              ].separate(10),
              30.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        favorite: ['NG', 'US', 'GB'],
                        countryListTheme: const CountryListThemeData(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                          ),
                        ),
                        onSelect: (Country value) {
                          log(value.phoneCode.toString());
                          log(value.flagEmoji.toString());

                          authstate.countryCode.value = "+${value.phoneCode}";
                          flag = value.flagEmoji.toString();
                          setState(() {});
                        },
                      );
                    },
                    child: Container(
                      height: 55,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColor.textFieldFill,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "$flag ",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Obx(() => Text(
                                authstate.countryCode.value,
                                style: Theme.of(context).textTheme.bodyMedium,
                              )),
                          10.horizontalSpace,
                          Icon(
                            FontAwesomeIcons.chevronDown,
                            color: AppColor.blackColor,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: Obx(() {
                        final countryCode = authstate.countryCode.value;
                        final countryConfig = CountryUtils.getCountryConfig(
                            countryCode == '+234' ? 'NG' :
                            countryCode == '+1' ? 'US' :
                            countryCode == '+356' ? 'MT' : 'NG'
                        );
                        
                        return RoundTextField(
                          hitText: countryConfig['format'],
                          controller: authstate.phoneNumberController,
                          inputFormater: countryConfig['inputFormatters'] + [
                            PhoneInputFormatter(mask: countryConfig['format']),
                          ],
                          keyboardType: TextInputType.phone,
                          focusNode: _phoneNumber,
                          onChange: (p0) {
                            authstate.phoneNumber.value = p0.replaceAll(RegExp(r'[^\d]'), '');
                          },
                        );
                      }),
                  )
                ],
              ),
              (MediaQuery.of(context).size.height * 0.4).verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmallButton(
                    onTap: () => Get.back(),
                    width: 40.h,
                    child: const Icon(
                      FontAwesomeIcons.arrowLeft,
                      size: 21,
                    ),
                  ),
                  SmallButton(
                    onTap: () {
                      if (authstate.phoneNumber.value.length < 7) {
                        errorMethod("Please enter a valid phone number");
                        return;
                      }
                      Get.to(() => const SetupPasswordScreen());
                    },
                    width: 85.h,
                    isColor: true,
                    child: Text(
                      'Next',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColor.whiteColor,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
