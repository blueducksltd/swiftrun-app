import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/get_icon.dart';

import 'package:swiftrun/common/utils/size.dart';
import 'package:swiftrun/common/widgets/widgets.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/confirmation.con.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/conifrm_state.dart';

class PackageConfirmation extends StatelessWidget {
  final ScrollController scrollController;
  final ConfirmPackageController confirmPackageController;
  final VoidCallback? bookDriver;
  final bool? isScheduleDelivery;

  const PackageConfirmation({
    super.key,
    required this.scrollController,
    required this.confirmPackageController,
    this.bookDriver,
    this.isScheduleDelivery,
  });

  @override
  Widget build(BuildContext context) {
    ConfirmPackageState confState =
        confirmPackageController.confirmPackageState;


    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
            child: Column(
              children: [
                // Modern header with icon and title
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: AppColor.primaryColor,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Confirm Details",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColor.blackColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Review your delivery information",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColor.disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverList.list(children: [
          10.verticalSpace,
          Obx(
            () => ConfirmDetailsWidget(
              isSchedule: isScheduleDelivery!,
              amount: confState.tripAmount.value,
              deliveryLocation: confirmPackageController
                  .confirmPackageState.dropOffLocation.value,
              packageType:
                  confirmPackageController.confirmPackageState.itemType.value,
              paymentType: confirmPackageController
                  .confirmPackageState.paymentMethod.value,
              pickupLocation: confirmPackageController
                  .confirmPackageState.pickupLocation.value,
              receipientName: confirmPackageController
                  .confirmPackageState.receipientname.value,
              receipientNumber: confirmPackageController
                  .confirmPackageState.receipientContact.value,
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
                    confirmPackageController
                        .confirmPackageState.vehicleType.value,
                  ),
                ),
              ),
            ),
          ),

          24.verticalSpace,
          // Modern gradient button
          Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor,
                  AppColor.primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withValues(alpha: 0.3),
                  spreadRadius: 0,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: bookDriver!,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_shipping_rounded,
                        color: AppColor.whiteColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Book a courier",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
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
          ),
          20.verticalSpace,
        ])
      ],
    );
  }
}
///access denied: when the driver accepts a request,
/// it it taks them to the appropriate screen but says access denied: ,
/// and the user doesnt recieve a notification that the driver has accepted,