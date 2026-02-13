import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/utils/utils.dart';

import 'package:swiftrun/features/history/presentation/history.dart';
import 'package:swiftrun/features/homepage/presentation/view.dart';
import 'package:swiftrun/features/profile/presentation/view.dart';
import 'package:swiftrun/features/dashboard/controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController dashboardController =
      Get.put(DashboardController());

  final pages = [
    const HomePageScreen(),
    const DeliveryHistory(),
    //const TrackingScreen(),
    // const NotificationScreen(),
    const ProfileScreen(),
  ];

  final List<String> _pageTiles = [
    'Home',
    'History',
    // 'Tracking',
    // 'Notification',
    'Profile',
  ];
  final List<String> _iconPath = [
    "assets/icons/home.png",
    "assets/icons/history.png",
    // "assets/icons/notification.png",
    "assets/icons/profile.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: SafeArea(
          bottom: false,
          child: pages[dashboardController.pageIndex.value],
        ),
        bottomNavigationBar: Container(
          height: screenHeight(context, percent: 0.09),
          padding: EdgeInsets.only(bottom: 2.h, top: 2.h),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            boxShadow: [
              BoxShadow(
                color: AppColor.blackColor.withValues(alpha: 0.4),
                spreadRadius: 0.5,
                blurRadius: 2,
                // offset: const Offset(0, -2), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => InkWell(
                onTap: () {
                  dashboardController.changePage(index);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 25,
                      height: 25,
                      child: Image.asset(
                        _iconPath[index],
                        color: dashboardController.pageIndex.value == index
                            ? AppColor.primaryColor
                            : AppColor.disabledColor,
                        width: 25.w,
                        height: 25.w,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _pageTiles[index],
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: dashboardController.pageIndex.value == index
                                ? AppColor.primaryColor
                                : AppColor.disabledColor,
                            fontSize: 12.sp,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
