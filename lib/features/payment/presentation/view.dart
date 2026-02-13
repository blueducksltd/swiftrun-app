import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/widgets.dart';
import 'package:swiftrun/features/payment/controller.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  var paymentController = Get.put(PaymentController());
  
  @override
  Widget build(BuildContext context) {
    var payemntState = paymentController.paymentState;

    return Scaffold(
      body: Obx(
        () => SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mainPaddingWidth,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CustomArrowBack(),
                    15.horizontalSpace,
                    Text(
                      "Payment Method",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                20.verticalSpace,
                Text(
                  "How would you like to pay?",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                      ),
                ),
                15.verticalSpace,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Card Payment Option
                        _buildPaymentOption(
                          context: context,
                          title: "Pay with Card",
                          subtitle: "Pay online with debit/credit card",
                          icon: 'assets/icons/cardIcon.svg',
                          isSelected: payemntState.selectedPayment.value == "card",
                          onTap: () => paymentController.setPaymentMethod("card"),
                        ),
                        15.verticalSpace,
                        // Cash Payment Option
                        _buildPaymentOption(
                          context: context,
                          title: "Pay with Cash",
                          subtitle: "Pay with cash when driver arrives",
                          icon: 'assets/icons/cardIcon.svg',
                          isSelected: payemntState.selectedPayment.value == "cash",
                          onTap: () => paymentController.setPaymentMethod("cash"),
                        ),
                        15.verticalSpace,
                        // Recipient Pays Option
                        _buildPaymentOption(
                          context: context,
                          title: "Recipient Pays",
                          subtitle: "The receiver will pay for the delivery",
                          icon: 'assets/icons/cardIcon.svg',
                          isSelected: payemntState.selectedPayment.value == "The Recipient",
                          onTap: () => paymentController.setPaymentMethod("The Recipient"),
                        ),
                      ],
                    ),
                  ),
                ),
                20.verticalSpace,
                Row(
                  children: [
                    Checkbox.adaptive(
                      value: payemntState.acceptCondition.value,
                      onChanged: (value) {
                        paymentController.setCondition(value!);
                      },
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: "I accept the ",
                                style: Theme.of(context).textTheme.bodySmall),
                            TextSpan(
                              text: "terms & conditions",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: AppColor.errorColor,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                15.verticalSpace,
                ButtonWidget(
                  isEnable: payemntState.acceptCondition.value &&
                      payemntState.selectedPayment.value.isNotEmpty,
                  onTap: (payemntState.acceptCondition.value &&
                          payemntState.selectedPayment.value.isNotEmpty)
                      ? () => paymentController.goToPackageDetails()
                      : () {},
                  color: AppColor.primaryColor,
                  widget: Text(
                    "Continue",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColor.whiteColor),
                  ),
                ),
                10.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
              ? AppColor.primaryColor.withOpacity(0.1)
              : AppColor.textFieldFill,
          border: Border.all(
            color: isSelected 
                ? AppColor.primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColor.primaryColor
                    : AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 24.w,
                  height: 24.w,
                  // ignore: deprecated_member_use
                  color: isSelected 
                      ? AppColor.whiteColor
                      : AppColor.primaryColor,
                ),
              ),
            ),
            15.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? AppColor.primaryColor
                              : Colors.black,
                        ),
                  ),
                  4.verticalSpace,
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColor.primaryColor,
                size: 28.sp,
              ),
          ],
        ),
      ),
    );
  }

}
