import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';

class ConfirmDetailsWidget extends StatelessWidget {
  final String pickupLocation,
      deliveryLocation,
      receipientName,
      receipientNumber,
      packageType,
      amount;

  final String? paymentType, date, dateTitle, time, timeTitle;
  final Widget widget;
  final bool? isCompleted;
  final bool? isPayment;
  final bool? isSchedule;
  const ConfirmDetailsWidget({
    super.key,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.receipientName,
    required this.receipientNumber,
    required this.packageType,
    this.paymentType,
    required this.amount,
    required this.widget,
    this.isCompleted = false,
    this.date,
    this.dateTitle,
    this.time,
    this.timeTitle,
    this.isPayment = true,
    this.isSchedule = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location section
          Row(
            children: [
              // Location indicator
              Column(
                children: [
                  dotLocation(),
                  SizedBox(height: 8.h),
                  Container(
                    width: 2.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  dotLocation(),
                ],
              ),
              SizedBox(width: 16.w),
              // Location details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Pickup Location: ",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColor.disabledColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: pickupLocation,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColor.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Delivery Location: ",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColor.disabledColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: deliveryLocation,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColor.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Vehicle type widget
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColor.textFieldFill,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: widget,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Information section
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: isCompleted! ? "Sent Item: " : "What you are sending: ",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.disabledColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: packageType.toString().replaceAll("[", "").replaceAll("]", ""),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Recipient: ",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.disabledColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: receipientName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Contact number
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Contact Number: ",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColor.disabledColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: receipientNumber,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColor.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          
          // Payment and amount section
          Row(
            children: [
              if (isPayment!) ...[
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Payment Method: ",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColor.disabledColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: paymentType == "recipient"
                              ? "The Recipient"
                              : paymentType == "Cash"
                              ? "Cash"
                              : paymentType == "Wallet"
                              ? "Wallet"
                              : paymentType == "Others"
                              ? "Others"
                              : paymentType ?? "Not specified",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColor.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
              ],
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: isCompleted! ? "Amount Paid: " : "Estimated Fee: ",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.disabledColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: "${"NGN".getCurrencySymbol()} $amount",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Schedule section
          if (isSchedule!) ...[
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${dateTitle ?? "Date"}: ",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColor.disabledColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: date ?? "",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColor.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${timeTitle ?? "Time"}: ",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColor.disabledColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: time ?? "",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColor.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Container dotLocation() {
    return Container(
      width: 5.h,
      height: 5.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.primaryColor,
      ),
    );
  }
}