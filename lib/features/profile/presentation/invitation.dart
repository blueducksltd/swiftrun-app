import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/customArrowBack.dart';
import 'package:swiftrun/common/widgets/customTextfield.dart';
import 'package:swiftrun/common/widgets/custom_botton.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth)
                  .copyWith(top: 10, bottom: 20),
              child: Row(
                children: [
                  const CustomArrowBack(),
                  20.horizontalSpace,
                  Text(
                    "Invite and Earn",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            20.verticalSpace,
            SvgPicture.asset("assets/icons/referEarn.svg"),
            20.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth)
                  .copyWith(top: 20),
              child: const Text(
                "Receive #4000 when someone signup using your referral link and place first request",
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth)
                  .copyWith(bottom: mainPaddingHeight),
              color: AppColor.secondaryPrimary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...[
                    5.verticalSpace,
                    const Text(
                      "Your custom invitation link",
                    ),
                    const RoundTextField(
                      hitText: "vlog.com.ng/ref/wax_ref001",
                      isEnable: false,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ButtonWidget(
                            onTap: () {},
                            color: AppColor.primaryColor,
                            widget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/icons/copyLink.svg"),
                                5.horizontalSpace,
                                Text(
                                  "Copy Link",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: AppColor.whiteColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        20.horizontalSpace,
                        Expanded(
                          child: ButtonWidget(
                            onTap: () {},
                            color: AppColor.primaryColor,
                            widget: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                      "assets/icons/shareLink.svg"),
                                  5.horizontalSpace,
                                  Text(
                                    "Share Link",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: AppColor.whiteColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ].separate(20)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
