

import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swiftrun/common/constants/location_msg.dart';
import 'package:swiftrun/common/routes/route.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'package:swiftrun/features/auth/data/model/user_model.dart';
import 'package:swiftrun/features/booking/presentation/view.dart';
import 'package:swiftrun/features/history/presentation/history_details.dart';
import 'package:swiftrun/features/homepage/controller.dart';
import 'package:swiftrun/features/tracking/presentation/view.dart';
import 'package:swiftrun/features/dashboard/controller.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  var homeController = Get.put(HomeController());
  var sessionController = Get.put(SessionController());
  DashboardController? dashboardController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<DashboardController>()) {
      dashboardController = Get.find<DashboardController>();
    }
    // Only check for app updates on initial load
    // Note: No need to call refreshHistory() here because 
    // HomeController.onInit() already calls getRequests() and sets up listeners
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      homeController.checkAppUpdate();
    });
  }

  Future<void> _onRefresh() async {
    // Add haptic feedback
    try {
      homeController.refreshHistory();
      // Wait a bit for the refresh to complete
      await Future.delayed(const Duration(milliseconds: 1500));
    } catch (e) {
      // Handle error if needed
      debugPrint("Error during refresh: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final homeState = homeController.homeState;

    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColor.primaryColor,
          backgroundColor: Colors.white,
          child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
            slivers: [
                // Modern Header with Gradient
              SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(20.w),
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColor.primaryColor,
                          AppColor.primaryColor.withOpacity(0.8),
                          const Color(0xFF4A90E2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Obx(() {
                        UserModel profile = sessionController.userData;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: "Welcome back!"
                            Text(
                              "Welcome back!",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14.sp,
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Bottom row: Profile picture on left, greeting text on right
                            Row(
                          children: [
                          // Enhanced Profile Picture (navigates to profile tab)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => dashboardController?.goToProfile(),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(35.r),
                                  child: CachedNetworkImage(
                                    width: 70.w,
                                    height: 70.w,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 70.w,
                                        height: 70.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                    imageUrl: profile.profilePix ??
                                        ConstantStrings.defaultAvater,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Container(
                                      width: 70.w,
                                      height: 70.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 30.sp,
                                      ),
                                    ),
                                    errorListener: (e) {
                                      if (e is SocketException) {
                                        debugPrint(
                                            'Error with ${e.address} and message ${e.message}');
                                      } else {
                                        debugPrint(
                                            'Image Exception is: ${e.runtimeType}');
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(width: 16.w),

                                // Greeting Text
                            Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                        "Hi, ${profile.firstName}",
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "Ready for your next delivery?",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                              ],
                            ),
                          ],
                        );
                      }),
                  ),
                ),

                // Quick Actions Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                          "Quick Actions",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),

                // Enhanced Delivery Options
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        // Enhanced Instant Delivery Card
                        Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColor.primaryColor, const Color(0xFF4A90E2)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16.r),
                        onTap: () => Get.toNamed(AppRoutes.booking),
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                        child: Image.asset(
                          "assets/icons/deliveryCar.png",
                          height: 25.h,
                          width: 25.w,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Instant Delivery",
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Courier takes only your package and deliver instantly',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    FaIcon(
                                      FontAwesomeIcons.arrowRight,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 16.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Enhanced Schedule Delivery Card
                        Container(
                          margin: EdgeInsets.only(bottom: 20.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16.r),
                              onTap: () => Get.to(() => const BookingScreen(isInstant: false)),
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                        child: FaIcon(
                          FontAwesomeIcons.clock,
                                        color: Colors.white,
                                        size: 24.sp,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Schedule Delivery",
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Plan your delivery for later',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    FaIcon(
                                      FontAwesomeIcons.arrowRight,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 16.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Enhanced History Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                          "Recent Activity",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                          ),
                          GestureDetector(
                            onTap: () => homeController.refreshHistory(),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.refresh,
                              color: AppColor.primaryColor,
                              size: 20.sp,
                            ),
                          ),
                      ),
                    ],
                  ),
                ),
              ),

                // Enhanced History List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return Obx(() {
                      if (homeState.isLoading.value) {
                          return Container(
                            margin: EdgeInsets.all(20.w),
                            padding: EdgeInsets.all(40.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  color: AppColor.primaryColor,
                                    strokeWidth: 3,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Loading your deliveries...',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColor.disabledColor,
                                    ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (homeState.requestData.isEmpty) {
                          return Container(
                            margin: EdgeInsets.all(20.w),
                            padding: EdgeInsets.all(40.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          child: Center(
                            child: Column(
                              children: [
                                  Container(
                                    padding: EdgeInsets.all(24.w),
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(50.r),
                                    ),
                                    child: Icon(
                                      Icons.local_shipping_outlined,
                                  size: 50.sp,
                                      color: AppColor.primaryColor,
                                    ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                    'No deliveries yet',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                    ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                    'Your delivery history will appear here',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColor.disabledColor,
                                    ),
                                  textAlign: TextAlign.center,
                                ),
                                  SizedBox(height: 20.h),
                                  ElevatedButton.icon(
                                    onPressed: () => Get.toNamed(AppRoutes.booking),
                                    icon: FaIcon(FontAwesomeIcons.plus, size: 14.sp),
                                    label: const Text('Create Delivery'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primaryColor,
                                    foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                  ),
                                    ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final visibleCount = math.min(homeState.requestData.length, 10);

                      return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 20.h),
                          itemCount: visibleCount,
                          itemBuilder: (context, index) {
                            final request = homeState.requestData[index];
                            var requestData = request.data() as Map<String, dynamic>;
                            final requestStatus = requestData['status'];
                            final isDeclined = requestStatus == 'declined' || requestStatus == 'cancelled';
                            Timestamp timestamp = requestData['dateCreated'];
                            DateTime dateTime = timestamp.toDate();

                              return Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12.r),
                                onTap: () {
                                  if (!isDeclined) {
                                    // Extract driver ID - check both 'driverID' and 'driverAssigned' fields
                                    // Scheduled deliveries use 'driverAssigned', instant use 'driverID'
                                    String? driverID = requestData['driverID'] ?? requestData['driverAssigned'];
                                    bool hasDriver = driverID != null && driverID.isNotEmpty && driverID != 'null';

                                    // Add document ID to requestData for easier access
                                    Map<String, dynamic> enrichedRequestData = Map<String, dynamic>.from(requestData);
                                    enrichedRequestData['documentId'] = request.id;

                                    Map data = {
                                      "request": request,
                                      "driverID": driverID ?? "",
                                      "requestData": enrichedRequestData,
                                    };

                                    // Determine which screen to show
                                    Widget targetScreen;

                                    // Priority 1: Completed deliveries -> History Details
                                    if (requestStatus == 'ended') {
                                      targetScreen = HistoryDetailsScreen(requestData: enrichedRequestData);
                                    }
                                    // Priority 2: Active deliveries with driver (accepted, arrived, onTrip) -> Tracking Screen
                                    // This applies to BOTH instant and scheduled deliveries
                                    else if (hasDriver && (requestStatus == 'accepted' || requestStatus == 'arrived' || requestStatus == 'onTrip')) {
                                      targetScreen = const TrackingScreen();
                                    }
                                    // Priority 3: Deliveries without driver (waiting, scheduled) -> History Details
                                    else if (!hasDriver && (requestStatus == 'waiting' || requestStatus == 'scheduled')) {
                                      targetScreen = HistoryDetailsScreen(requestData: enrichedRequestData);
                                    }
                                    // Fallback: Show history details for any other case
                                    else {
                                      targetScreen = HistoryDetailsScreen(requestData: enrichedRequestData);
                                    }

                                    Get.to(() => targetScreen, arguments: data);
                                  } else {
                                    Get.snackbar(
                                      'Request ${requestStatus.toUpperCase()}',
                                      'This delivery request was $requestStatus',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: AppColor.disabledColor.withOpacity(0.1),
                                      colorText: AppColor.blackColor,
                                      duration: const Duration(seconds: 2),
                                    );
                                  }
                                },
                                    child: Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Row(
                                        children: [
                                          // Status Icon with enhanced styling
                                          Container(
                                            padding: EdgeInsets.all(12.w),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(requestStatus).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8.r),
                                            ),
                                            child: Icon(
                                              _getStatusIcon(requestStatus),
                                              color: _getStatusColor(requestStatus),
                                              size: 20.sp,
                                            ),
                                          ),

                                          SizedBox(width: 12.w),

                                          // Enhanced Delivery Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  requestData['recipientName'] ?? 'Unknown Recipient',
                                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.sp,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  requestData['dropOffLocation'] ??
                                                  requestData['dropOffAddress'] ??
                                                  'Unknown Location',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: AppColor.disabledColor,
                                                    fontSize: 12.sp,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4.h),
                                                Row(
                                                  children: [
                                                    Text(
                                                      DateFormat('MMM d, yyyy').format(dateTime),
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: AppColor.disabledColor,
                                                        fontSize: 11.sp,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(requestStatus).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(4.r),
                                                      ),
                                                      child: Text(
                                                        requestStatus.toUpperCase(),
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: _getStatusColor(requestStatus),
                                                          fontSize: 10.sp,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Enhanced Arrow Icon
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
                          },
                        ),
                      );
                    });
                  },
                  childCount: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for status styling
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ended':
        return const Color(0xFF10B981);
      case 'ontrip':
        return const Color(0xFF3B82F6);
      case 'arrived':
        return const Color(0xFF8B5CF6);
      case 'accepted':
        return const Color(0xFFF59E0B);
      case 'scheduled':
        return const Color(0xFF06B6D4); // Cyan color for scheduled
      case 'cancelled':
      case 'declined':
        return const Color(0xFFEF4444);
      default:
        return AppColor.disabledColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'ended':
        return Icons.check_circle;
      case 'ontrip':
        return Icons.local_shipping;
      case 'arrived':
        return Icons.location_on;
      case 'accepted':
        return Icons.person;
      case 'scheduled':
        return Icons.schedule; // Clock icon for scheduled
      case 'cancelled':
      case 'declined':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

class DeliveryType extends StatelessWidget {
  final bool isFontBack;
  final Color bgColor;
  final Widget child;
  final String title, subtitle;
  final Function() onTap;

  const DeliveryType({
    super.key,
    required this.bgColor,
    required this.child,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isFontBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: bgColor,
          border: Border.all(
            color: AppColor.primaryColor,
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            // Icon/Image Container
            Container(
              width: 40.w,
              height: 40.h,
              alignment: Alignment.center,
              child: child,
            ),

            SizedBox(width: 16.w),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: isFontBack
                          ? AppColor.blackColor
                          : AppColor.whiteColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: isFontBack
                          ? AppColor.blackColor.withOpacity(0.7)
                          : AppColor.whiteColor.withOpacity(0.8),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
