import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/widgets.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/confirm_details.dart';
import 'package:swiftrun/features/payment/controller.dart';
import 'package:swiftrun/services/network/network.dart';

import '../../../common/styles/style.dart';

class CardDetailsScreen extends StatefulWidget {
  const CardDetailsScreen({super.key});

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  var paymentController = Get.put(PaymentController());
  dynamic bookingInfosUpdate;

  @override
  void initState() {
    bookingInfosUpdate = Get.arguments;
    paymentController.paymentState.pickupLocation.value =
        bookingInfosUpdate['pickupLocation'];
    paymentController.paymentState.dropOffLocation.value =
        bookingInfosUpdate['dropOffLocation'];
    paymentController.paymentState.receipientContact.value =
        bookingInfosUpdate['receipientNumber'];
    paymentController.paymentState.receipientname.value =
        bookingInfosUpdate['receipientName'];
    paymentController.paymentState.vehicleType.value =
        bookingInfosUpdate['vehicleType'];
    paymentController.paymentState.itemType.value =
        bookingInfosUpdate['itemType'];
    paymentController.paymentState.imagePath = bookingInfosUpdate['imagePath'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var paymentState = paymentController.paymentState;
    return Scaffold(
      body: Obx(
        () => SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mainPaddingWidth,
              vertical: mainPaddingHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomArrowBack(),
                15.verticalSpace,
                const Text("Card Details"),
                ...List.generate(
                  2,
                  (index) => Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: InkWell(
                      onTap: () => paymentController.setCardPayment(index),
                      child: Container(
                        width: double.infinity,
                        height: 60.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColor.bgColor,
                          border:
                              paymentState.selectedPaymentCard.value == index
                                  ? Border.all(
                                      color: AppColor.primaryColor,
                                      width: 1.5,
                                    )
                                  : const Border(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/cardIcon.svg",
                              width: 20,
                              height: 20,
                            ),
                            20.horizontalSpace,
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Bank"),
                                Text("**** **** **** 896"),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: InkWell(
                    onTap: () => showModalBottomSheet(
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      backgroundColor: AppColor.whiteColor,
                      enableDrag: false,
                      isDismissible: false,
                      context: context,
                      builder: (context) => Expanded(
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: mainPaddingWidth)
                                  .copyWith(top: mainPaddingHeight),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () => Get.back(),
                                    child: const Icon(
                                      Icons.close,
                                    ),
                                  ),
                                ],
                              ),
                              15.verticalSpace,
                              Text(
                                "Enter Your Card Details",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.w500),
                              ),
                              10.verticalSpace,
                              const RoundTextField(hitText: "Card Holder Name"),
                              10.verticalSpace,
                              const RoundTextField(hitText: "Card Number"),
                              10.verticalSpace,
                              Row(
                                children: [
                                  const Expanded(
                                    child: RoundTextField(
                                      hitText: 'MM/YY',
                                    ),
                                  ),
                                  15.horizontalSpace,
                                  const Expanded(
                                    child: RoundTextField(
                                      hitText: 'CVV',
                                    ),
                                  ),
                                ],
                              ),
                              Obx(
                                () => Row(
                                  children: [
                                    Checkbox.adaptive(
                                      value:
                                          paymentState.saveCardCondidion.value,
                                      onChanged: (value) {
                                        paymentController
                                            .saveCardCondition(value!);
                                      },
                                      fillColor:
                                          WidgetStateProperty.resolveWith(
                                        (states) => states
                                                .contains(WidgetState.selected)
                                            ? AppColor.primaryColor
                                            : AppColor.primaryColor,
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Save card Details",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              5.verticalSpace,
                              ButtonWidget(
                                onTap: () {},
                                color: AppColor.primaryColor,
                                widget: Text(
                                  "Save",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(color: AppColor.whiteColor),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 60.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColor.bgColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: AppColor.vlogOrange,
                          ),
                          20.horizontalSpace,
                          const Text("Add New Card")
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                ButtonWidget(
                  onTap: () async {
                    Map<String, dynamic> data = {
                      "vehicleType": paymentState.vehicleType.value,
                      "pickupLocation": paymentState.pickupLocation.value,
                      "dropOffLocation": paymentState.dropOffLocation.value,
                      "itemType": paymentState.itemType.value,
                      "receipientName": paymentState.receipientname.value,
                      "receipientNumber": paymentState.receipientContact.value,
                      "paymentMethod": paymentState.selectedPayment.value,
                      "pickupLatLng": paymentState.pickupLatLng,
                      "dropOffLatLng": paymentState.dropOffLatLng,
                      "imagePath": paymentState.imagePath,
                    };
                    ProgressDialogUtils.showProgressDialog();
                    await Network.getRiderDirection(
                      paymentState.pickupLatLng,
                      paymentState.dropOffLatLng,
                    );
                    ProgressDialogUtils.hideProgressDialog();
                    Get.to(() => const ConfirmDeliveryScreen(fromPage: 0),
                        arguments: data);
                  },
                  color: AppColor.primaryColor,
                  widget: Text(
                    "Continue",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColor.whiteColor),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
