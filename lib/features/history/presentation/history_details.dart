import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swiftrun/common/constants/location_msg.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/get_icon.dart';
import 'package:swiftrun/features/history/controller.dart';
import 'package:swiftrun/global/global.dart';
import 'package:swiftrun/services/network/network.dart';

class HistoryDetailsScreen extends StatefulWidget {
  final Map requestData;
  const HistoryDetailsScreen({super.key, required this.requestData});

  @override
  State<HistoryDetailsScreen> createState() => _HistoryDetailsScreenState();
}

class _HistoryDetailsScreenState extends State<HistoryDetailsScreen> {
  late HistoryController historyController;

  // Store arguments to use in cancel function
  Map<String, dynamic>? storedArguments;
  Map<String, dynamic>? storedRequestData;
  dynamic storedRequestDoc;

  @override
  void initState() {
    super.initState();

    debugPrint('📱 HistoryDetailsScreen initState called');

    // Initialize controller with proper arguments
    historyController = Get.put(HistoryController());

    // Set the driver ID and request ID from arguments if available
    var arguments = Get.arguments;

    debugPrint('🔍 InitState - Get.arguments: $arguments');
    debugPrint('🔍 InitState - Get.arguments type: ${arguments?.runtimeType}');
    debugPrint('🔍 InitState - widget.requestData: ${widget.requestData}');
    debugPrint('🔍 InitState - widget.requestData type: ${widget.requestData.runtimeType}');

    // Store arguments for later use - use widget.requestData as fallback
    if (arguments != null && arguments is Map<String, dynamic>) {
      storedArguments = arguments;
      storedRequestData = arguments['requestData'] != null
          ? Map<String, dynamic>.from(arguments['requestData'])
          : Map<String, dynamic>.from(widget.requestData);
      storedRequestDoc = arguments['request'];
      debugPrint('💾 Stored arguments from Get.arguments');
      debugPrint('💾 storedRequestData keys: ${storedRequestData?.keys}');
      debugPrint('💾 storedRequestDoc: ${storedRequestDoc?.id}');
    } else {
      // Fallback: use widget.requestData if Get.arguments is null
      storedRequestData = Map<String, dynamic>.from(widget.requestData);
      debugPrint('💾 Stored requestData from widget parameter');
      debugPrint('💾 storedRequestData keys: ${storedRequestData?.keys}');
    }

    if (arguments != null && arguments is Map<String, dynamic>) {
      String? driverID = arguments['driverID'];

      // Check if driver ID is actually valid (not null, not empty, not whitespace)
      bool hasDriver = driverID != null &&
                       driverID.trim().isNotEmpty &&
                       driverID != 'null';

      // Only fetch driver details if there's actually a driver assigned
      if (hasDriver) {
        historyController.historyState.driverID!.value = driverID;

        // Set request ID if available (this will be the document ID)
        if (arguments['request'] != null) {
          var requestDoc = arguments['request'];
          historyController.historyState.requestID!.value = requestDoc.id;
        } else if (arguments['requestID'] != null) {
          historyController.historyState.requestID!.value = arguments['requestID'];
        }

        // Reset rating status first
        historyController.historyState.hasRatedDriver.value = false;

        // Fetch driver details and ratings
        historyController.getDriverDetails();
        historyController.getRatingAndDeliveries();
        historyController.checkIfUserHasRated();
      } else {
        // For scheduled deliveries without driver, don't try to fetch driver info
        // Set empty value to prevent null errors
        historyController.historyState.driverID!.value = '';
        historyController.historyState.hasRatedDriver.value = false;
      }
    }
  }

  @override
  void dispose() {
    debugPrint('📱 HistoryDetailsScreen dispose called');
    debugPrint('📱 Stored data before dispose - requestData: ${storedRequestData != null}, requestDoc: ${storedRequestDoc != null}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var historyState = historyController.historyState;
    var vehicleType = widget.requestData['vehicleType']?.toString() ?? 'car';
    var requestDetails = widget.requestData;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
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
            child: Column(
              children: [
                    // Header with back button
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            "Delivery Details",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            _getStatusLabel(widget.requestData['status']),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Driver Info Card - Only show if not a scheduled delivery without driver
                    // Check if this is a scheduled delivery
                    Builder(
                      builder: (context) {
                        bool isScheduled = requestDetails['status'] == 'scheduled';
                        String? driverID = requestDetails['driverID'];
                        bool hasDriver = driverID != null && driverID.trim().isNotEmpty;

                        // If scheduled without driver, show info message instead
                        if (isScheduled && !hasDriver) {
                          return _buildAwaitingDriverCard(context);
                        }

                        // Otherwise show driver info with Obx
                        return Obx(() {
                          // Access the observable to make Obx work properly
                          var driverFirstName = historyState.driverInfo.value.firstName;

                          if (driverFirstName == null || driverFirstName.isEmpty) {
                            return _buildDriverLoadingCard(context);
                          } else {
                            return _buildDriverCard(context, historyState, vehicleType);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Delivery Information Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    _buildDeliveryInfoCard(context, requestDetails),
                    SizedBox(height: 16.h),
                    _buildPaymentInfoCard(context, requestDetails),
                    SizedBox(height: 16.h),
                    _buildImagesSection(context, requestDetails),
                    SizedBox(height: 16.h),

                    // Cancel button for scheduled, waiting, and accepted deliveries
                    if (requestDetails['status'] == 'scheduled' || 
                        requestDetails['status'] == 'waiting' || 
                        requestDetails['status'] == 'accepted')
                      _buildCancelButton(context),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty || text.trim().isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Helper method to format amount and remove question marks
  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';

    String amountStr = amount.toString();

    // Remove any question marks and non-numeric characters except decimal point
    amountStr = amountStr.replaceAll(RegExp(r'[^\d.]'), '');

    // If empty after cleaning, return 0
    if (amountStr.isEmpty) return '0';

    // Try to parse as double and format
    try {
      double parsedAmount = double.parse(amountStr);
      return parsedAmount.toStringAsFixed(0);
    } catch (e) {
      return '0';
    }
  }

  // Helper methods for the new UI
  Widget _buildAwaitingDriverCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.person_search,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Awaiting Driver Assignment",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "A driver will be assigned before your scheduled time",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverLoadingCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
              width: 60.w,
              height: 60.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 16.h,
                    width: 120.w,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 8.h),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 12.h,
                    width: 80.w,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, dynamic historyState, String vehicleType) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Driver Profile Picture
          Container(
            decoration: BoxDecoration(
                          shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
                        ),
                        child: ClipRRect(
              borderRadius: BorderRadius.circular(30.r),
                          child: CachedNetworkImage(
                width: 60.w,
                height: 60.w,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                    width: 60.w,
                    height: 60.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                imageUrl: (historyState.driverInfo.value.picturePath ?? ConstantStrings.defaultAvater) as String,
                            fit: BoxFit.cover,
                memCacheWidth: 120,
                memCacheHeight: 120,
                maxWidthDiskCache: 200,
                maxHeightDiskCache: 200,
                errorWidget: (context, url, error) {
                  return Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  );
                },
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

          SizedBox(width: 16.w),

          // Driver Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_capitalizeFirst(historyState.driverInfo.value.firstName ?? "")} ${_capitalizeFirst(historyState.driverInfo.value.lastName ?? "")}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 4.h,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          historyState.averageRating.value == 0.0
                              ? "No ratings yet"
                              : "${historyState.averageRating.value.toStringAsFixed(1)}",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "•",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      "${historyState.totalDelivery?.value ?? 0} deliveries",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Vehicle Type Icon
          Container(
            padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
                        child: Icon(
              iconFromString(vehicleType.toLowerCase()),
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard(BuildContext context, Map requestDetails) {
    return Container(
      padding: EdgeInsets.all(20.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.local_shipping,
                          color: AppColor.primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "Delivery Information",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Pickup Location - check both field names (instant vs scheduled)
          _buildLocationRow(
            context,
            icon: Icons.location_on,
            iconColor: const Color(0xFFEF4444),
            title: "Pickup Location",
            address: requestDetails["pickupLocation"] ??
                     requestDetails["pickupAddress"] ??
                     "Not specified",
          ),

          SizedBox(height: 12.h),

          // Delivery Location - check both field names (instant vs scheduled)
          _buildLocationRow(
            context,
            icon: Icons.location_on,
            iconColor: const Color(0xFF10B981),
            title: "Delivery Location",
            address: requestDetails["dropOffLocation"] ??
                     requestDetails["dropOffAddress"] ??
                     "Not specified",
          ),

          SizedBox(height: 12.h),

          // Recipient Info
          _buildInfoRow(
            context,
            icon: Icons.person,
            title: "Recipient",
            value: requestDetails["recipientName"] ?? "Unknown",
          ),

          SizedBox(height: 8.h),

          _buildInfoRow(
            context,
            icon: Icons.phone,
            title: "Contact",
            value: requestDetails["recipientNumber"] ?? "Unknown",
          ),
        ],
                      ),
                    );
                  }

  Widget _buildPaymentInfoCard(BuildContext context, Map requestDetails) {
    bool isScheduled = requestDetails['status'] == 'scheduled';

    return Container(
      padding: EdgeInsets.all(20.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: (isScheduled ? const Color(0xFF06B6D4) : const Color(0xFF10B981)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  isScheduled ? Icons.schedule : Icons.payment,
                  color: isScheduled ? const Color(0xFF06B6D4) : const Color(0xFF10B981),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                isScheduled ? "Delivery Details" : "Payment Information",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Show scheduled time if this is a scheduled delivery
          if (isScheduled) ...[
            // Prominent scheduled delivery banner
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF06B6D4),
                    Color(0xFF0891B2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SCHEDULED DELIVERY",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _formatScheduledTime(requestDetails['dateScheduled']),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFF06B6D4).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF06B6D4),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "A driver will be assigned closer to your scheduled time.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF06B6D4),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delivery Amount",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.disabledColor,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "₦",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                        fontSize: 18.sp,
                        fontFamily: 'Arial',
                      ),
                    ),
                    TextSpan(
                      text: _formatAmount(requestDetails['deliveryAmount'] ?? requestDetails['amount'] ?? requestDetails['price'] ?? requestDetails['cost']),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Only show payment method for non-scheduled deliveries
          if (!isScheduled)
          _buildInfoRow(
            context,
            icon: Icons.credit_card,
            title: "Payment Method",
            value: _capitalizeFirst((requestDetails["paymentMethod"]?.toString() ?? "Not specified")),
          ),

          if (!isScheduled) SizedBox(height: 8.h),

          _buildInfoRow(
            context,
            icon: Icons.inventory,
            title: "Package Type",
            value: _capitalizeFirst((requestDetails["itemType"]?.toString() ?? requestDetails["items"]?.toString() ?? "Not specified")),
          ),

          // Show quantity if available
          if (requestDetails["quantity"] != null && requestDetails["quantity"].toString().isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildInfoRow(
              context,
              icon: Icons.format_list_numbered,
              title: "Quantity",
              value: requestDetails["quantity"].toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context, Map requestDetails) {
    return Container(
      padding: EdgeInsets.all(20.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: const Color(0xFF8B5CF6),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "Delivery Photos",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Package/Item images - check both field names (scheduled vs instant delivery)
          if ((requestDetails['imageUrl'] != null && requestDetails['imageUrl'].toString().isNotEmpty) ||
              (requestDetails['imageSent'] != null && requestDetails['imageSent'].toString().isNotEmpty))
            _buildImageSection(
              context,
              title: requestDetails['imageSent'] != null ? "Picked Up" : "Package Photo",
              imageUrl: requestDetails['imageUrl'] ?? requestDetails['imageSent'] ?? '',
            ),

          if ((requestDetails['imageUrl'] != null && requestDetails['imageUrl'].toString().isNotEmpty) ||
              (requestDetails['imageSent'] != null && requestDetails['imageSent'].toString().isNotEmpty))
            SizedBox(height: 12.h),

          // Delivered images
          if (requestDetails['imageDelivered'] != null && requestDetails['imageDelivered'].toString().isNotEmpty)
            _buildImageSection(
              context,
              title: "Delivered",
              imageUrl: requestDetails['imageDelivered'],
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, {required String title, required String imageUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColor.disabledColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Tap image to view full size",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.disabledColor.withOpacity(0.7),
                fontSize: 11.sp,
              ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            if (imageUrl.isNotEmpty) {
              _openImagePreview(context, imageUrl, title);
            }
          },
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.disabledColor.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.grey[300],
                  ),
                ),
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[100],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        color: AppColor.disabledColor,
                        size: 32.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Image not available",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColor.disabledColor,
                            ),
                      ),
                    ],
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
        ),
      ],
    );
  }

  void _openImagePreview(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) {
        return Dialog(
          insetPadding: EdgeInsets.all(12.w),
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationRow(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColor.disabledColor,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                address,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColor.disabledColor,
          size: 16.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          "$title: ",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColor.disabledColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    String status = widget.requestData['status']?.toString().toLowerCase() ?? '';
    String buttonText = (status == 'accepted' || status == 'arrived' || status == 'ontrip') 
        ? "Cancel Trip" 
        : "Cancel Delivery Request";

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: () => _showCancelDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFEF4444),
            elevation: 0,
            side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    String status = widget.requestData['status']?.toString().toLowerCase() ?? '';
    bool isScheduled = status == 'scheduled';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFEF4444),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(isScheduled ? "Cancel Scheduled Delivery?" : "Cancel Delivery?"),
            ],
          ),
          content: Text(
            isScheduled 
                ? "Are you sure you want to cancel this scheduled delivery? This action cannot be undone."
                : "Are you sure you want to cancel this delivery request? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Keep Delivery",
                style: TextStyle(
                  color: AppColor.disabledColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first
                await _cancelDelivery(); // Then execute cancellation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text("Cancel Delivery"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelDelivery() async {
    try {
      debugPrint('🔍 Starting cancellation process...');

      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Use stored arguments instead of Get.arguments
      debugPrint('🔍 Checking stored arguments...');
      debugPrint('🔍 storedRequestData: ${storedRequestData != null}');
      debugPrint('🔍 storedRequestDoc: ${storedRequestDoc != null}');

      if (storedRequestData == null) {
        debugPrint('❌ No request data available');
        Get.back();
        Get.snackbar(
          'Error',
          'Delivery data not found.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      var requestData = storedRequestData!;

      // Get request ID - try multiple sources
      String? requestID;
      if (storedRequestDoc != null) {
        requestID = storedRequestDoc.id;
        debugPrint('📄 Request ID from storedRequestDoc: $requestID');
      } else if (requestData['documentId'] != null) {
        // Try to get from enriched requestData (added in homepage navigation)
        requestID = requestData['documentId'];
        debugPrint('📄 Request ID from requestData[documentId]: $requestID');
      } else {
        // Try to get from controller's requestID
        requestID = historyController.historyState.requestID?.value;
        debugPrint('📄 Request ID from controller: $requestID');

        // If still null, this is a problem
        if (requestID == null || requestID.isEmpty) {
          debugPrint('❌ Could not determine request ID');
          debugPrint('❌ Available keys in requestData: ${requestData.keys.toList()}');
          Get.back();
          Get.snackbar(
            'Error',
            'Could not identify the delivery to cancel.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }
      }

      debugPrint('✅ Using stored request data');
      debugPrint('📄 Final Request ID: $requestID');

      String currentStatus = requestData['status'] ?? '';
      debugPrint('📊 Current status: $currentStatus');

      // Check if delivery can be cancelled
      if (currentStatus == 'ended' || currentStatus == 'cancelled') {
        Get.back(); // Close loading
        Get.snackbar(
          'Cannot Cancel',
          'This delivery has already been ${currentStatus == 'ended' ? 'completed' : 'cancelled'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Determine collection name - check if scheduled delivery
      bool isScheduled = currentStatus == 'scheduled';
      String collectionName = isScheduled ? 'ScheduleRequest' : 'DeliveryRequests';

      if (storedRequestDoc != null) {
        String docPath = storedRequestDoc.reference.path;
        isScheduled = docPath.contains('ScheduleRequest') || currentStatus == 'scheduled';
        collectionName = isScheduled ? 'ScheduleRequest' : 'DeliveryRequests';
        debugPrint('🔄 Document path: $docPath');
      }

      debugPrint('🔄 Is scheduled: $isScheduled');
      debugPrint('🔄 Collection: $collectionName');
      debugPrint('🔄 Updating status to cancelled...');

      try {
        // Update the status to cancelled with timestamp and reason
        await fDataBase.collection(collectionName).doc(requestID).update({
          'status': 'cancelled',
          'dateCancelled': Timestamp.now(),
          'cancelReason': 'Cancelled by user from history',
          'dateUpdated': Timestamp.now(), // Also update the dateUpdated field
        });

        debugPrint('✅ Status updated successfully');
        
        // Verify the update by reading the document back
        DocumentSnapshot verifyDoc = await fDataBase
            .collection(collectionName)
            .doc(requestID)
            .get();
        
        if (verifyDoc.exists) {
          Map<String, dynamic>? verifyData = verifyDoc.data() as Map<String, dynamic>?;
          String verifyStatus = verifyData?['status'] ?? '';
          debugPrint('✅ Verified status update - current status: "$verifyStatus"');
          
          if (verifyStatus != 'cancelled') {
            debugPrint('⚠️ WARNING: Status update may have failed. Expected "cancelled", got "$verifyStatus"');
            // Try updating again
            await fDataBase
                .collection(collectionName)
                .doc(requestID)
                .update({"status": "cancelled"});
            debugPrint('✅ Retried status update');
          }
        }
      } catch (updateError) {
        debugPrint('❌ Error updating document: $updateError');
        Get.back(); // Close loading
        Get.snackbar(
          'Error',
          'Failed to update delivery status: $updateError',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // Notify driver if one was assigned - check both field names
      String? driverID = requestData['driverAssigned'] ?? requestData['driverID'];
      debugPrint('👤 Driver ID: $driverID');

      if (driverID != null && driverID.isNotEmpty && driverID != 'null') {
        try {
          debugPrint('📞 Fetching driver details...');
          // Get driver details to send notification
          var driverDoc = await fDataBase.collection('Drivers').doc(driverID).get();
          if (driverDoc.exists) {
            Map<String, dynamic> driverData = driverDoc.data() as Map<String, dynamic>;
            String? driverToken = driverData['userToken'];
            debugPrint('🔑 Driver token found: ${driverToken != null}');

            if (driverToken != null && driverToken.isNotEmpty) {
              await Network.notifyDriver(
                driverToken: driverToken,
                requestID: requestID!, // Safe to use ! because we verified it's not null earlier
                title: "🚫 Delivery Cancelled",
                message: "The customer has cancelled this ${isScheduled ? 'scheduled ' : ''}delivery.",
                status: "cancelled",
                type: isScheduled ? "scheduled_cancelled" : "delivery_cancelled"
              );
              debugPrint('✅ Driver notified about cancellation');
            }
          } else {
            debugPrint('⚠️ Driver document does not exist');
          }
        } catch (notifyError) {
          debugPrint('⚠️ Could not notify driver: $notifyError');
          // Continue with cancellation even if notification fails
        }
      } else {
        debugPrint('ℹ️ No driver assigned to notify');
      }

      Get.back(); // Close loading dialog
          Get.back(); // Go back to previous screen
          Get.snackbar(
            'Delivery Cancelled',
        'Your ${isScheduled ? 'scheduled ' : ''}delivery has been cancelled successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
    } catch (e) {
      Get.back(); // Close loading dialog if still open
      Get.snackbar(
        'Error',
        'Failed to cancel delivery. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      debugPrint('❌ Error cancelling scheduled delivery: $e');
    }
  }

  String _getStatusLabel(String? status) {
    if (status == null) return "Unknown";

    switch (status.toLowerCase()) {
      case 'scheduled':
        return "Scheduled";
      case 'accepted':
        return "Accepted";
      case 'arrived':
        return "Driver Arrived";
      case 'ontrip':
        return "In Progress";
      case 'ended':
        return "Completed";
      case 'cancelled':
        return "Cancelled";
      case 'declined':
        return "Declined";
      default:
        return status.toUpperCase();
    }
  }

  String _formatScheduledTime(dynamic timeScheduled) {
    try {
      if (timeScheduled == null) return "Not specified";

      DateTime scheduledTime;
      if (timeScheduled is Timestamp) {
        scheduledTime = timeScheduled.toDate();
      } else if (timeScheduled is DateTime) {
        scheduledTime = timeScheduled;
      } else {
        return "Not specified";
      }

      // Format: "Monday, Jan 15, 2025 at 2:30 PM"
      final weekday = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][scheduledTime.weekday - 1];
      final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][scheduledTime.month - 1];
      final day = scheduledTime.day;
      final year = scheduledTime.year;
      final hour = scheduledTime.hour > 12 ? scheduledTime.hour - 12 : (scheduledTime.hour == 0 ? 12 : scheduledTime.hour);
      final minute = scheduledTime.minute.toString().padLeft(2, '0');
      final period = scheduledTime.hour >= 12 ? 'PM' : 'AM';

      return "$weekday, $month $day, $year at $hour:$minute $period";
    } catch (e) {
      debugPrint('Error formatting scheduled time: $e');
      return "Not specified";
    }
  }
}

class DisplayImageWidget extends StatelessWidget {
  final String title;
  final Widget? imageProvider;
  const DisplayImageWidget({
    super.key,
    required this.title,
    this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: AppColor.disabledColor),
        ),
        5.verticalSpace,
        Row(
            children: List.generate(
          2,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              height: 70.h,
              width: 70.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: AppColor.disabledColor,
                // image: DecorationImage(image: imageProvider!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: imageProvider,
              ),
            ),
          ),
        ))
      ],
    );
  }
}
