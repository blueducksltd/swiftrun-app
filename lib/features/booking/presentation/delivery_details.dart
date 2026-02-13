import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/textfieldwithcontainer.dart';
import 'package:swiftrun/common/widgets/widgets.dart';
import 'package:swiftrun/features/booking/controller.dart';
import 'package:swiftrun/common/utils/country_utils.dart';
import 'package:swiftrun/core/controller/location_controller.dart';
import 'package:flutter/services.dart';
import 'package:swiftrun/common/utils/phone_input_formatter.dart';

// ignore: must_be_immutable
class DeliveryDetails extends StatefulWidget {
  final bool? isScheduleDelivery;
  bool isHasPicture;
  DeliveryDetails({
    super.key,
    this.isScheduleDelivery = false,
    this.isHasPicture = false,
  });

  @override
  State<DeliveryDetails> createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {
  var bookingController = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    var bookingState = bookingController.bookingState;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth)
              .copyWith(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CustomArrowBack(),
                  20.horizontalSpace,
                  Expanded(
                    child: Text(
                      "Delivery Details",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
              15.verticalSpace,
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Text(
                      "What are you sending ?",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.w300),
                    ),

                    TextFieldWIthContainer(
                      title: "Type of item (e.g gadget, document)",
                      controller: bookingState.itemController,
                      hint: 'What type of item',
                    ),

                    TextFieldWIthContainer(
                      controller: bookingState.quantityController,
                      title: "Quantity",
                      hint: '1',
                      keyboardType: TextInputType.number,
                    ),
                    TextFieldWIthContainer(
                      controller: bookingState.recipientNameController,
                      title: "Recipeient",
                      hint: 'Name of the recipient',
                    ),
                    Obx(() {
                      // Use current location country instead of user's registered country
                      final locationController = Get.find<LocationController>();
                      final currentCountryCode = locationController.getCurrentCountryCode();
                      final countryConfig = CountryUtils.getCountryConfig(currentCountryCode);
                      
                        return TextFieldWIthContainer(
                        controller: bookingState.recipientContactController,
                        title: "Recipient contact number",
                        hint: "000-000-0000",
                        helperText: "Format: ${countryConfig['format']}",
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          PhoneInputFormatter(mask: countryConfig['format']),
                        ],
                      );
                    }),
                    15.verticalSpace,

                    // FIXED: Picture question row with proper flex handling
                    widget.isScheduleDelivery == true
                        ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Do you have a picture of the package?",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.w300),
                          ),
                        ),
                        SizedBox(width: 8.w), // Fixed spacing instead of Spacer
                        Switch(
                          value: widget.isHasPicture,
                          onChanged: (value) {
                            setState(() {
                              widget.isHasPicture = value;
                              Logger.i("Switch value $value");
                            });
                          },
                        ),
                      ],
                    )
                        : const SizedBox.shrink(),

                    // FIXED: Image upload section with proper constraints
                    !widget.isHasPicture
                        ? const SizedBox.shrink()
                        : Padding(
                      padding: EdgeInsets.only(top: 15.h),
                      child: DottedBorder(
                        dashPattern: const [4, 4],
                        strokeWidth: 2,
                        radius: const Radius.circular(15),
                        borderType: BorderType.RRect,
                        strokeCap: StrokeCap.round,
                        color: AppColor.primaryColor,
                        child: ClipRRect(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(12)),
                          child: InkWell(
                            onTap: () {
                              bookingController.uploadImage();
                            },
                            child: Container(
                              width: double.infinity,
                              height: screenHeight(context, percent: 0.2).h,
                              decoration: BoxDecoration(
                                color: AppColor.textFieldFill,
                              ),
                              child: Obx(
                                    () => bookingState.pickedImageXfile.value ==
                                    null
                                    ? Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding:
                                      const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColor.primaryColor
                                            .withValues(alpha: 0.1),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.camera,
                                        color: AppColor.primaryColor,
                                        size: 18,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                                      child: Text(
                                        "Take a picture of the package",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                            color: AppColor
                                                .primaryColor),
                                      ),
                                    ),
                                  ],
                                )
                                    : Image.file(
                                  File(bookingState
                                      .pickedImageXfile.value!.path),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    30.verticalSpace,

                    // Continue button
                    ButtonWidget(
                      onTap: () {
                        bookingController.goToPayment(
                          isScheduleDelivery: widget.isScheduleDelivery!,
                          isPackageImage: widget.isHasPicture,
                        );
                      },
                      color: AppColor.primaryColor,
                      widget: Text(
                        "Continue",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColor.whiteColor),
                      ),
                    ),

                    // Bottom safe area
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropDownList extends StatefulWidget {
  final List<String> items;
  final String? hint;
  final ValueChanged<String>? onChanged;
  const DropDownList(
      {super.key, required this.items, this.hint, this.onChanged});

  @override
  State<DropDownList> createState() => _DropDownListState();
}

class _DropDownListState extends State<DropDownList> {
  String? selectedItem;
  var selectController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextFieldWIthContainer(
      title: "Select type of item (e.g gadget, document)",
      controller: selectController,
      hint: widget.hint.toString(),
      rightIcon: DropdownButton<String>(
        value: selectedItem,
        onChanged: (value) {
          setState(() {
            selectedItem = value;
            selectController.text = value ?? '';
          });
          if (widget.onChanged != null && value != null) {
            widget.onChanged!(value);
          }
        },
        items: widget.items.map<DropdownMenuItem<String>>(
              (String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}