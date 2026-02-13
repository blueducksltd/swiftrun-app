import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swiftrun/common/constants/location_msg.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'package:swiftrun/features/auth/data/model/user_model.dart';
import 'package:swiftrun/features/auth/presentation/controller.dart';
import 'package:swiftrun/features/profile/presentation/app_settings.dart';
import 'package:swiftrun/features/profile/presentation/edit_profile_picture.dart';
import 'package:swiftrun/features/profile/presentation/help.dart';
import 'package:swiftrun/features/profile/presentation/invitation.dart';
import 'package:swiftrun/features/profile/presentation/payment_history.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var sessionController = Get.put(SessionController());
    
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
              child: Text(
                "Profile",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColor.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 20.sp,
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    // User Profile Card
                    _buildUserProfileCard(context, sessionController),
                    
                    SizedBox(height: 24.h),
                    
                    // Menu Items
                    _buildMenuSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, SessionController sessionController) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        UserModel profile = sessionController.userData;
        return Column(
          children: [
            // Profile Picture with Edit Icon
            GestureDetector(
              onTap: () async {
                // Navigate to edit screen and wait for result
                await Get.to(() => const EditProfilePictureScreen());
                // Force refresh of the profile data when returning
                sessionController.refreshUserData();
              },
              child: Stack(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColor.primaryColor.withOpacity(0.2),
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40.r),
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                        imageUrl: profile.profilePix ?? ConstantStrings.defaultAvater,
                        fit: BoxFit.cover,
                        // Add cache key to force refresh
                        memCacheWidth: 160,
                        memCacheHeight: 160,
                        maxWidthDiskCache: 160,
                        maxHeightDiskCache: 160,
                        errorWidget: (context, url, error) => Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppColor.primaryColor,
                            size: 32.sp,
                          ),
                        ),
                        errorListener: (e) {
                          if (e is SocketException) {
                            debugPrint('Error with ${e.address} and message ${e.message}');
                          } else {
                            debugPrint('Image Exception is: ${e.runtimeType}');
                          }
                        },
                      ),
                    ),
                  ),
                  // Edit Icon
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // User Name
            Text(
              "${profile.firstName} ${profile.lastName}".toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColor.blackColor,
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // Phone Number
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone,
                    color: AppColor.primaryColor,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    profile.phoneNumber ?? 'N/A',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': "assets/icons/payment.svg",
        'title': "Payment History",
        'subtitle': "View your payment records",
        'onTap': () => Get.to(() => const PaymentHistory()),
      },
      {
        'icon': "assets/icons/invite.svg",
        'title': "Invite Friends",
        'subtitle': "Earn rewards by inviting friends",
        'onTap': () {
          Get.snackbar(
            "Coming Soon",
            "u can still invite frinds while we work on rewards feature!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black.withOpacity(0.7),
            colorText: Colors.white,
            margin: EdgeInsets.all(20.w),
            borderRadius: 12.r,
            duration: const Duration(seconds: 2),
            barBlur: 10,
          );
        },
      },
      {
        'icon': "assets/icons/setting.svg",
        'title': "App Settings",
        'subtitle': "Customize your app experience",
        'onTap': () => Get.to(() => const AppSettingScreen()),
      },
      {
        'icon': "assets/icons/help.svg",
        'title': "Help & Support",
        'subtitle': "Get help and contact support",
        'onTap': () => Get.to(() => const HelpScreen()),
      },
    ];

    return Column(
      children: [
        // Regular menu items
        ...menuItems.map((item) => _buildMenuItem(
          context,
          icon: item['icon'],
          title: item['title'],
          subtitle: item['subtitle'],
          onTap: item['onTap'],
        )),
        
        SizedBox(height: 16.h),
        
        // Delete Account (dangerous action)
        _buildMenuItem(
          context,
          icon: "assets/icons/delete.svg",
          title: "Delete Account",
          subtitle: "Permanently delete your account",
          onTap: () => _showDeleteAccountDialog(context),
          isDangerous: true,
        ),
        
        SizedBox(height: 16.h),
        
        // Sign Out
        _buildMenuItem(
          context,
          icon: "assets/icons/signout.svg",
          title: "Sign Out",
          subtitle: "Sign out of your account",
          onTap: () => SessionController.to.signOut(),
          isSignOut: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDangerous = false,
    bool isSignOut = false,
  }) {
    Color iconColor = isDangerous 
        ? Colors.red 
        : isSignOut 
            ? AppColor.primaryColor 
            : AppColor.primaryColor;
    
    Color titleColor = isDangerous 
        ? Colors.red 
        : isSignOut 
            ? AppColor.primaryColor 
            : AppColor.blackColor;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDangerous 
              ? Colors.red.withOpacity(0.2)
              : isSignOut 
                  ? AppColor.primaryColor.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
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
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: SvgPicture.asset(
                        icon,
                        colorFilter: ColorFilter.mode(
                          iconColor,
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
                          color: titleColor,
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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const _DeleteAccountDialog();
      },
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _showCountdown = false;
  int _countdown = 30;
  Timer? _timer;
  bool _canDelete = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _showCountdown = true;
      _countdown = 30;
      _canDelete = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canDelete = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              'Delete Account',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              _showCountdown
                  ? 'This action is irreversible. All your data, delivery history, and account information will be permanently deleted.'
                  : 'Are you sure you want to delete your account? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // Countdown Section
            if (_showCountdown) ...[
              // Countdown Circle
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _canDelete ? Colors.red : Colors.orange,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: _canDelete
                      ? Icon(
                          Icons.check,
                          color: Colors.red,
                          size: 40.sp,
                        )
                      : Text(
                          '$_countdown',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16.h),

              Text(
                _canDelete
                    ? 'You can now delete your account'
                    : 'Please wait $_countdown seconds...',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: _canDelete ? Colors.red : Colors.grey[600],
                  fontWeight: _canDelete ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _timer?.cancel();
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_showCountdown) {
                        // First click - start countdown
                        _startCountdown();
                      } else if (_canDelete) {
                        // Countdown finished - delete account
                        Get.back();
                        AuthenticationController.to.deleteAccount();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showCountdown && !_canDelete
                          ? Colors.grey[400]
                          : Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _showCountdown
                          ? (_canDelete ? 'Confirm Delete' : 'Wait...')
                          : 'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}