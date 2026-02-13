
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swiftrun/common/constants/location_msg.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/api_keys.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/custom_botton.dart';
import 'package:swiftrun/common/widgets/icon_with_container.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'package:swiftrun/features/auth/data/model/user_model.dart';
import 'package:swiftrun/features/booking/presentation/atoms/rider_widget.dart';
import 'package:swiftrun/features/messages/index.dart';
import 'package:swiftrun/features/payment.dart';
import 'package:swiftrun/features/tracking/controller.dart';
import 'package:swiftrun/features/tracking/state.dart';

import '../../booking/presentation/atoms/confirm_details/confirmation.con.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final trackingController = Get.put(TrackingController());
  var sessionController = Get.put(SessionController());

  // Helper method to build payment confirmation UI
  Widget _buildPaymentConfirmation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.90,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                "Payment Completed Successfully",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "Your payment has been confirmed",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to make phone calls
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        "Error",
        "Driver phone number not available",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          "Error",
          "Cannot make phone calls on this device",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to make phone call",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.errorColor,
        colorText: Colors.white,
      );
    }
  }

  void _showTrackingCancellationDialog(BuildContext context, UserRideRequestStatus status) {
    print("Showing tracking cancellation dialog for status: $status");

    String message = status == UserRideRequestStatus.accepted
        ? "The driver has accepted your request. Cancelling may affect your rating. Continue?"
        : "The driver is at your pickup location. Cancelling may incur charges. Continue?";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cancel Trip"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                print("User chose to keep trip");
                Navigator.of(context).pop();
              },
              child: const Text('Keep Trip'),
            ),
            TextButton(
              onPressed: () {
                print("User confirmed trip cancellation");
                Navigator.of(context).pop();
                _cancelTripFromTracking();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cancel Trip'),
            ),
          ],
        );
      },
    );
  }

  void _cancelTripFromTracking() {
    print("_cancelTripFromTracking called");
    trackingController.cancelTrip();
    Get.back(); // Go back to previous screen
  }


  @override
  Widget build(BuildContext context) {
    var trackingState = trackingController.trackingState;
    UserModel userData = sessionController.userData;

    return Scaffold(
      body: Obx(() {
        // Check if tracking data is initialized using reactive flag
        if (!trackingState.isInitialized.value ||
            trackingState.pickupLatLng.value == null ||
            trackingState.dropOffLatLng.value == null) {
          return _buildLoadingState();
        }

        return _buildTrackingUI(trackingState, userData);
      }),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Tracking"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading tracking data..."),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingUI(TrackingStates trackingState, UserModel userData) {
    return Stack(
      children: [
        // Google Maps
        SizedBox(
          height: screenHeight(context, percent: 0.91),
          width: double.infinity,
          child: GoogleMap(
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            buildingsEnabled: true,
            onMapCreated: trackingController.onMapCreated,
            mapType: MapType.terrain,
            initialCameraPosition: trackingController.initalLocation,
            markers: trackingState.markerSet.value.cast<Marker>(),
            polylines: trackingState.polylineSet.value.cast<Polyline>(),
          ),
        ),

        // Top status bar
        Positioned(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth)
                .copyWith(top: 40.h),
            child: ButtonWidget(
              isEnable: false,
              onTap: () {},
              color: AppColor.primaryColor,
              widget: Text(
                "Delivery in progress",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColor.whiteColor),
              ),
            ),
          ),
        ),

        Positioned(
          top: 100.h,
          left: 0,
          right: 0,
          child: trackingController.buildDriverTrackingWidget(),
        ),

        // Bottom sheet
        Align(
          alignment: Alignment.bottomCenter,
          child: DraggableScrollableSheet(
            initialChildSize: 0.25,
            maxChildSize: 0.35,
            minChildSize: 0.15,
            builder: (context, scrollController) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, -3),
                      blurRadius: 2,
                      color: AppColor.bgColor,
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth)
                      .copyWith(top: 19.h, bottom: 5.h),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child: Container(
                            width: 70.w,
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: AppColor.disabledColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                      SliverList.list(
                        children: [
                          10.verticalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status display - FIXED: Wrapped in Flexible to prevent overflow
                              SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Obx(() => Text(
                                    trackingController.trackingState
                                        .driverRideStatus.value.isNotEmpty
                                        ? trackingController.trackingState
                                        .driverRideStatus.value
                                        : "Driver en route",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  )),
                                ),
                              ),
                              10.verticalSpace,

                              // Driver details
                              Obx(() {
                                // Check if driver info is available
                                var driverInfo = trackingController.trackingState.driverInfo.value;
                                if (driverInfo.driversId == null || driverInfo.driversId!.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 3),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            "Loading driver details...",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return RiderWidget(
                                  driverImage: CachedNetworkImage(
                                    imageUrl: driverInfo.picturePath ??
                                        ConstantStrings.defaultAvater,
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey[300]!,
                                        radius: 33.r,
                                      ),
                                    ),
                                    imageBuilder: (context, image) => CircleAvatar(
                                      backgroundImage: image,
                                      radius: 33.r,
                                    ),
                                  ),
                                  deliveriesDone: trackingState.totalDelivery.value,
                                  initialRating: trackingState.averageRating.value == 0.0 ? 0.0 : trackingState.averageRating.value,
                                  name: '${driverInfo.firstName?.capitalizeFirst ?? ""} ${driverInfo.lastName?.capitalizeFirst ?? ""}'.trim(),
                                  widget: IconWihContainer(
                                    iconData: Icons.message,
                                    onPressed: () {
                                      Map data = {"driverInfo": driverInfo};
                                      log("Chat Data: $data ${driverInfo.driversId}");
                                      Get.to(() => const ChatScreen(), arguments: data);
                                    },
                                  ),

                                  icon: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: AppColor.primaryColor.withOpacity(0.1),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        // Get driver's phone number
                                        String phoneNumber = driverInfo.phoneNumber ?? '';
                                        _makePhoneCall(phoneNumber);
                                      },
                                      icon: Icon(
                                        Icons.call,
                                        color: AppColor.primaryColor,
                                        size: 24,
                                      ),
                                      tooltip: "Call Driver",
                                    ),
                                  ),
                                );
                              }),

                              // Payment button and messages based on payment method
                              Obx(() {
                                // Show payment UI based on payment status only
                                if (trackingState.paymentStatus.value == true) {
                                  // Payment completed - show confirmation
                                  return _buildPaymentConfirmation();
                                }
                                // Payment not completed - show Pay Now button or cash message

                                String paymentMethod = trackingState.paymentMethod.value;
                                
                                // Debug logging to see what payment method is received
                                print("🔍 Tracking Payment Debug:");
                                print("- Payment Method: '$paymentMethod'");
                                print("- Payment Method Length: ${paymentMethod.length}");
                                print("- Payment Method Type: ${paymentMethod.runtimeType}");
                                print("- Is Cash: ${paymentMethod == "cash"}");
                                print("- Is Recipient: ${paymentMethod == "recipient"}");
                                
                                if (paymentMethod == "cash") {
                                  // Show cash payment message
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Container(
                                        width: MediaQuery.sizeOf(context).width * 0.90,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.orange.shade200),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.money,
                                              color: Colors.orange.shade600,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Please give cash to the driver",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                color: Colors.orange.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Amount: ₦${trackingState.tripAmount.value}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                color: Colors.orange.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (paymentMethod == "recipient") {
                                  // Show recipient payment message
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Container(
                                        width: MediaQuery.sizeOf(context).width * 0.90,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.blue.shade200),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Colors.blue.shade600,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Your payment option is recipient",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                color: Colors.blue.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Please make sure the recipient holds the agreed amount stated in the app",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                color: Colors.blue.shade700,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Amount: ₦${trackingState.tripAmount.value}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Show Pay Now button for card payments
                                  return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SizedBox(
                                      width: MediaQuery.sizeOf(context).width * 0.70,
                                      child: ButtonWidget(
                                        onTap: () {
                                          // Get the delivery ID from tracking state
                                          final deliveryId = trackingState.docRefID.value;
                                          
                                          if (deliveryId.isEmpty) {
                                            Get.snackbar(
                                              "Error",
                                              "Unable to process payment. Delivery ID not found.",
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: AppColor.errorColor,
                                              colorText: Colors.white,
                                            );
                                            return;
                                          }
                                          
                                          // Determine if this is a scheduled delivery
                                          String docPath = trackingState.docRef?.reference.path ?? '';
                                          bool isScheduled = docPath.contains('ScheduleRequest');
                                          
                                          Payment().makePayment(
                                            context: context,
                                            amount: double.parse(
                                                trackingState.tripAmount.value.toString()),
                                            secretKey: secretKey,
                                            userEmail: userData.email!,
                                            metadata: {
                                              'deliveryId': deliveryId,
                                              'isScheduled': isScheduled.toString(),
                                              'userEmail': userData.email!,
                                            },
                                            onSuccess: () {
                                              Get.snackbar(
                                                "Verifying Payment",
                                                "Please wait while we confirm your payment...",
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: AppColor.primaryColor,
                                                colorText: Colors.white,
                                                duration: const Duration(seconds: 3),
                                              );
                                              // DO NOT update payment status here - let webhook do it
                                              // This ensures button stays visible until webhook confirms
                                              trackingController.startPaymentVerificationListener(deliveryId, isScheduled);
                                            },
                                          );
                                        },
                                        widget: Text(
                                          "Pay Now",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                            color: AppColor.whiteColor,
                                          ),
                                        ),
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                  ),
                                  );
                                }
                              }),

                              // Cancel button for tracking screen
                              Obx(() {
                                final status = trackingState.userRideRequestStatus.value;
                                final canCancel = status == UserRideRequestStatus.accepted ||
                                    status == UserRideRequestStatus.arrived;

                                // Add debug logging
                                print("Tracking Cancel Debug - Status: $status, CanCancel: $canCancel");

                                if (!canCancel) {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  margin: EdgeInsets.only(top: 10.h),
                                  child: Center(
                                    child: SizedBox(
                                      width: MediaQuery.sizeOf(context).width * 0.70,
                                      child: ButtonWidget(
                                        onTap: () {
                                          print("Cancel button tapped in tracking screen");
                                          _showTrackingCancellationDialog(context, status);
                                        },
                                        widget: Text(
                                          "Cancel Trip",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                            color: AppColor.whiteColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        color: Colors.orange[600]!,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}