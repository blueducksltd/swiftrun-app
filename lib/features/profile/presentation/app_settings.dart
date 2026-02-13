import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/features/profile/presentation/privacy_policy.dart';
import 'package:swiftrun/features/profile/presentation/terms_conditions.dart';

class AppSettingScreen extends StatelessWidget {
  const AppSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsItems = [
      {
        'icon': "assets/icons/terms.svg",
        'title': "Terms and Conditions",
        'subtitle': "Read our terms and conditions",
        'onTap': () {
          Get.to(() => const TermsConditionsScreen());
        },
      },
      {
        'icon': "assets/icons/privacy.svg",
        'title': "Privacy Policy",
        'subtitle': "Learn how we protect your data",
        'onTap': () {
          Get.to(() => const PrivacyPolicyScreen());
        },
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColor.primaryColor,
                        size: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    "App Settings",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColor.blackColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    // Settings Items
                    ...settingsItems.map((item) => _buildSettingsItem(
                      context,
                      icon: item['icon'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      onTap: item['onTap'],
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: SvgPicture.asset(
                        icon,
                        colorFilter: ColorFilter.mode(
                          AppColor.primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.disabledColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColor.disabledColor,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
