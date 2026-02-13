import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/geofire_assistant.dart';
import 'package:swiftrun/common/utils/get_icon.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/features/history/presentation/history_details.dart';
import 'package:swiftrun/features/tracking/presentation/view.dart';

class DeliveryHistory extends StatefulWidget {
  const DeliveryHistory({super.key});

  @override
  State<DeliveryHistory> createState() => _DeliveryHistoryState();
}

class _DeliveryHistoryState extends State<DeliveryHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
      child: Column(
          children: [
            // Professional Header
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.history,
                          color: AppColor.primaryColor,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery History",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColor.blackColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 20.sp,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "Track your past deliveries",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColor.disabledColor,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
              Container(
                        width: 36.w,
                        height: 36.w,
                decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Add filter functionality
                          },
                          icon: Icon(
                            Icons.filter_list,
                            color: AppColor.primaryColor,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
              ),
            ],
          ),
            ),

            // Content Area
          Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: FutureBuilder<Map<String, List<DocumentSnapshot>>>(
                    future: GeoFireAssistant.getDeliveriesHistory(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState();
                    } else if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildHistoryList(snapshot.data!);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: CircularProgressIndicator(
              color: AppColor.primaryColor,
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "Loading your delivery history...",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColor.disabledColor,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "Something went wrong",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColor.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Please try again later",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColor.disabledColor,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
                        return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
                            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: AppColor.primaryColor,
              size: 40.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "No Deliveries Yet",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColor.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Your delivery history will appear here",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColor.disabledColor,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed('/booking');
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text("Book a Delivery"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(Map<String, List<DocumentSnapshot>> activeDeliveries) {
                      List<dynamic> combinedList = [];

                      activeDeliveries.forEach((status, deliveries) {
                        combinedList.add(status);
                        combinedList.addAll(deliveries);
                      });

                      return ListView.builder(
                        itemCount: combinedList.length,
                        itemBuilder: (context, index) {
                          var currentItem = combinedList[index];

                          if (currentItem is DocumentSnapshot) {
                            var deliveryData = currentItem.data() as Map<String, dynamic>;
                            final requestStatus = deliveryData['status'];
                            // Check both driverID and driverAssigned fields (scheduled requests use driverAssigned)
                            final driverID = deliveryData['driverID'] ?? deliveryData['driverAssigned'] ?? '';

                            // Only show valid delivery requests
                            if (_shouldShowDelivery(requestStatus, driverID)) {
            return _buildDeliveryCard(
              context,
              currentItem,
              deliveryData,
              requestStatus,
              driverID,
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      );
  }

  Widget _buildDeliveryCard(
    BuildContext context,
    DocumentSnapshot currentItem,
    Map<String, dynamic> deliveryData,
    String requestStatus,
    String driverID,
  ) {
    Timestamp timestamp = deliveryData['dateCreated'];
    DateTime dateTime = timestamp.toDate();

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
          onTap: () => _handleDeliveryTap(requestStatus, driverID, currentItem, deliveryData),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: _getStatusColor(requestStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        _getStatusIcon(requestStatus),
                        color: _getStatusColor(requestStatus),
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order #${deliveryData['orderID'] ?? currentItem.id.substring(0, 8)}",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColor.blackColor,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "Recipient: ${deliveryData['recipientName']?.toString().capitalizeFirst ?? 'N/A'}",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColor.disabledColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(requestStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        _getStatusDisplayText(requestStatus),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(requestStatus),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Location and Vehicle Info
                Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(
                        iconFromString(deliveryData['vehicleType']?.toString().toLowerCase() ?? 'bike'),
                        size: 12.sp,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              // Debug logging to diagnose unknown location issue
                              print('🔍 === Recent Activity Item Debug ===');
                              print('🔍 All keys in deliveryData: ${deliveryData.keys.toList()}');
                              print('🔍 dropOffLocation: ${deliveryData['dropOffLocation']}');
                              print('🔍 dropOffAddress: ${deliveryData['dropOffAddress']}');
                              print('🔍 pickupLocation: ${deliveryData['pickupLocation']}');
                              print('🔍 pickupAddress: ${deliveryData['pickupAddress']}');
                              print('🔍 Status: ${deliveryData['status']}');
                              print('🔍 Full data: $deliveryData');
                              print('🔍 ================================');

                              String location = deliveryData['dropOffLocation'] ??
                                  deliveryData['dropOffAddress'] ??
                                  'Not specified';

                              return Text(
                                location,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.blackColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "${DateFormat('d MMM, yyyy').format(dateTime)} • ${DateFormat.jm().format(dateTime)}",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11.sp,
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
      ),
    );
  }

  bool _shouldShowDelivery(String status, String driverID) {
    // Show completed trips
    if (status == "ended") return true;

    // Show canceled/declined trips
    if (status == "cancelled" || status == "declined") return true;

    // Show scheduled deliveries (with or without driver)
    if (status == "scheduled") return true;

    // Show active trips with assigned drivers
    final activeStatuses = ["accepted", "arrived", "onTrip"];
    return activeStatuses.contains(status) && driverID.trim().isNotEmpty;
  }

  void _handleDeliveryTap(String requestStatus, String driverID, DocumentSnapshot currentItem, Map<String, dynamic> deliveryData) {
    // Check if driver is actually assigned (not null, not empty, not whitespace)
    // Also check driverAssigned field for scheduled requests
    final actualDriverID = driverID.trim().isNotEmpty 
        ? driverID 
        : (deliveryData['driverAssigned']?.toString().trim() ?? '');
    bool hasDriver = actualDriverID.isNotEmpty;

    if (requestStatus == "ended") {
      Map arguments = {
        "driverID": actualDriverID,
        "requestData": deliveryData,
        "request": currentItem,
      };
      log("History details arguments: $arguments");
      Get.to(() => HistoryDetailsScreen(requestData: deliveryData), arguments: arguments);
    } else if (requestStatus == "scheduled" && !hasDriver) {
      // Scheduled delivery without driver - show details screen
      Map arguments = {
        "driverID": "",
        "requestData": deliveryData,
        "request": currentItem,
      };
      log("Scheduled delivery (no driver) arguments: $arguments");
      Get.to(() => HistoryDetailsScreen(requestData: deliveryData), arguments: arguments);
    } else if (requestStatus == "scheduled" && hasDriver) {
      // Scheduled delivery with driver - show details screen
      Map arguments = {
        "driverID": actualDriverID,
        "requestData": deliveryData,
        "request": currentItem,
      };
      log("Scheduled delivery (with driver) arguments: $arguments");
      Get.to(() => HistoryDetailsScreen(requestData: deliveryData), arguments: arguments);
    } else if (requestStatus == "cancelled") {
      // Show bottom message for cancelled trips
      Get.snackbar(
        'Trip Cancelled',
        'This trip was cancelled and cannot be opened',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        icon: const Icon(Icons.cancel, color: Colors.white),
        margin: EdgeInsets.all(16.w),
        borderRadius: 8.r,
        duration: const Duration(seconds: 3),
      );
    } else if (requestStatus == "declined") {
      // Show bottom message for declined trips
      Get.snackbar(
        'Trip Declined',
        'This trip was declined and cannot be opened',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        icon: const Icon(Icons.info, color: Colors.white),
        margin: EdgeInsets.all(16.w),
        borderRadius: 8.r,
        duration: const Duration(seconds: 3),
      );
    } else if (hasDriver && (requestStatus == "accepted" || requestStatus == "arrived" || requestStatus == "onTrip")) {
      // Active delivery with driver - go to tracking
      Map data = {
        "request": currentItem,
        "driverID": actualDriverID,
      };
      log("Tracking data: $data");
      Get.to(() => const TrackingScreen(), arguments: data);
    } else {
      errorMethod("Cannot track: Driver not assigned");
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case "ended": return "Completed";
      case "declined": return "Declined";
      case "cancelled": return "Cancelled";
      case "scheduled": return "Scheduled";
      case "accepted": return "Assigned";
      case "arrived": return "Arrived";
      case "onTrip": return "In Transit";
      case "waiting": return "Finding Driver";
      default: return "Processing";
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "ended": return Colors.green;
      case "declined":
      case "cancelled": return Colors.red;
      case "scheduled": return const Color(0xFF06B6D4); // Cyan for scheduled
      case "accepted":
      case "arrived":
      case "onTrip": return Colors.orange;
      default: return AppColor.primaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "ended": return Icons.check_circle;
      case "declined": return Icons.cancel;
      case "cancelled": return Icons.close;
      case "scheduled": return Icons.schedule; // Clock icon for scheduled
      case "accepted": return Icons.person_add;
      case "arrived": return Icons.location_on;
      case "onTrip": return Icons.local_shipping;
      case "waiting": return Icons.search;
      default: return Icons.schedule;
    }
  }
}
