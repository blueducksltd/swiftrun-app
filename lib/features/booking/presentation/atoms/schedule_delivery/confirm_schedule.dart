import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/api_keys.dart';
import 'package:swiftrun/common/utils/get_icon.dart';
import 'package:swiftrun/common/utils/size.dart';
import 'package:swiftrun/common/widgets/confirmation_widget.dart';
import 'package:swiftrun/common/widgets/custom_botton.dart';
import 'package:swiftrun/features/booking/presentation/atoms/schedule_delivery/controller.dart';
import 'package:swiftrun/features/payment.dart';

class ConfirmScheduleDelivery extends StatelessWidget {
  final ScrollController scrollController;
  final ScheducleDeliveryController scheducleDeliveryController;
  const ConfirmScheduleDelivery({
    super.key,
    required this.scrollController,
    required this.scheducleDeliveryController,
  });

  @override
  Widget build(BuildContext context) {
    scheducleDeliveryController.getTripAmount(
      vehicleTypeId: scheducleDeliveryController.state.vehicleTypeId.value,
    );
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: Container(
              width: 70.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColor.disabledColor,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scheduled Delivery Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColor.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14.sp,
                        color: AppColor.primaryColor,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "SCHEDULED DELIVERY",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Title
                Text(
                  "Confirm Scheduled Delivery",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList.list(
          children: [
            Obx(
              () {
                return scheducleDeliveryController
                        .state.deliveryAmount.value.isNotEmpty
                    ? ConfirmDetailsWidget(
                        pickupLocation: scheducleDeliveryController
                            .state.pickupLocation.value,
                        deliveryLocation: scheducleDeliveryController
                            .state.dropOffLocation.value,
                        receipientName: scheducleDeliveryController
                            .state.receipientname.value,
                        receipientNumber: scheducleDeliveryController
                            .state.receipientContact.value,
                        packageType:
                            scheducleDeliveryController.state.itemType.value,
                        paymentType: scheducleDeliveryController.state.paymentMethod.value,
                        amount: scheducleDeliveryController
                            .state.deliveryAmount.value,
                        widget: Container(
                          height: screenHeight(context, percent: 0.07),
                          width: screenHeight(context, percent: 0.07),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            color: AppColor.textFieldFill,
                          ),
                          child: Icon(
                            iconFromString(
                              scheducleDeliveryController
                                  .state.vehicleType.value,
                            ),
                          ),
                        ),
                        isPayment: false,
                        isSchedule: true,
                        dateTitle: "Scheduled Date",
                        date:
                            scheducleDeliveryController.state.pickupDate.value,
                        timeTitle: "Scheduled Time",
                        time:
                            scheducleDeliveryController.state.pickupTime.value,
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                        ),
                      );
              },
            ),
            20.verticalSpace,
            // Scheduled Time Reminder
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Your delivery is scheduled for ${scheducleDeliveryController.state.pickupDate.value} at ${scheducleDeliveryController.state.pickupTime.value}",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.blue.shade900,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            20.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => ButtonWidget(
                      onTap: scheducleDeliveryController.state.isSaving.value
                          ? () {} // Empty function when saving
                          : () => scheducleDeliveryController.saveToDataBase(context),
                    color: AppColor.primaryColor,
                      widget: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (scheducleDeliveryController.state.isSaving.value)
                            SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColor.whiteColor,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.check_circle_outline,
                              color: AppColor.whiteColor,
                              size: 20.sp,
                            ),
                          SizedBox(width: 8.w),
                          Text(
                            scheducleDeliveryController.state.isSaving.value
                                ? "Scheduling..."
                                : "Confirm Schedule",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                                .copyWith(
                                  color: AppColor.whiteColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                20.horizontalSpace,
                Obx(
                  () {
                    // Only show Pay Now button if payment method requires it
                    final paymentMethod = scheducleDeliveryController.state.paymentMethod.value.toLowerCase();
                    final shouldShowPayButton = paymentMethod != "cash" && 
                                                paymentMethod != "the recipient" &&
                                                paymentMethod.isNotEmpty;
                    
                    return shouldShowPayButton
                        ? SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.30,
                  child: ButtonWidget(
                    onTap: () {
                                if (scheducleDeliveryController.state.paymentStatus.isFalse) {
                                  final deliveryId = scheducleDeliveryController.state.scheduledDeliveryId.value;
                                  
                                  if (deliveryId.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please save the delivery first'),
                                      ),
                                    );
                                    return;
                                  }

                                  Payment().makePayment(
                              context: context,
                              amount: double.parse(scheducleDeliveryController
                                        .state.deliveryAmount.value),
                              secretKey: secretKey,
                              userEmail:
                                  scheducleDeliveryController.profile.email!,
                                    metadata: {
                                      'deliveryId': deliveryId,
                                      'isScheduled': 'true',
                                      'userEmail': scheducleDeliveryController.profile.email!,
                                    },
                              onSuccess: () {
                                      // Show verifying message - DO NOT update payment status yet
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Verifying payment... Please wait.'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                      // Webhook will update Firestore, listener will detect it and update UI
                                      scheducleDeliveryController.startPaymentVerificationListener(deliveryId);
                              },
                                  );
                                }
                    },
                              color: scheducleDeliveryController.state.paymentStatus.isFalse
                                  ? AppColor.errorColor
                                  : Colors.green,
                              widget: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    scheducleDeliveryController.state.paymentStatus.isFalse
                                        ? Icons.payment
                                        : Icons.check,
                                    color: AppColor.whiteColor,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                      scheducleDeliveryController.state.paymentStatus.isFalse
                          ? "Pay Now"
                          : "Paid",
                      style: Theme.of(context)
                          .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: AppColor.whiteColor,
                                          fontWeight: FontWeight.w600,
                    ),
                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox.shrink();
                  },
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
