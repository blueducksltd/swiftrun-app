
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swiftrun/common/constants/location_msg.dart';
import 'package:swiftrun/common/routes/route.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/api_keys.dart';
import 'package:swiftrun/common/widgets/widgets.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'package:swiftrun/features/auth/data/model/user_model.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/confirmation.con.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/conifrm_state.dart';
import 'package:swiftrun/features/booking/presentation/atoms/rider_widget.dart';
import 'package:swiftrun/features/messages/presentation/chat.dart';
import 'package:swiftrun/features/payment.dart';

import '../../../../common/utils/extension.dart';

class RiderDetails extends StatefulWidget {
  const RiderDetails({
    super.key,
    required this.scrollController,
    required this.confirmPackageController,
  });
  final ConfirmPackageController confirmPackageController;
  final ScrollController scrollController;

  @override
  State<RiderDetails> createState() => _RiderDetailsState();
}

class _RiderDetailsState extends State<RiderDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.confirmPackageController.bookNearestDriver();
    });
  }

  String _getCancelButtonText(UserRideRequestStatus status) {
    switch (status) {
      case UserRideRequestStatus.waiting:
        return 'Cancel Request';
      case UserRideRequestStatus.accepted:
        return 'Cancel Trip';
      case UserRideRequestStatus.arrived:
        return 'Cancel Trip';
      default:
        return 'Cancel Request';
    }
  }

  Color _getCancelButtonColor(UserRideRequestStatus status) {
    switch (status) {
      case UserRideRequestStatus.waiting:
        return AppColor.errorColor;
      case UserRideRequestStatus.accepted:
      case UserRideRequestStatus.arrived:
        return Colors.orange[700]!;
      default:
        return AppColor.errorColor;
    }
  }

  void _showCancellationDialog(BuildContext context, UserRideRequestStatus status) {
    String title = "Cancel Trip";
    String message = _getCancellationMessage(status);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep Trip'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.confirmPackageController.cancelTrip();
                Get.offAllNamed(AppRoutes.dashboard);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColor.errorColor,
              ),
              child: const Text('Cancel Trip'),
            ),
          ],
        );
      },
    );
  }

  String _getCancellationMessage(UserRideRequestStatus status) {
    switch (status) {
      case UserRideRequestStatus.waiting:
        return "Are you sure you want to cancel this delivery request?";
      case UserRideRequestStatus.accepted:
        return "The driver has accepted your request. Cancelling now may affect your rating. Are you sure?";
      case UserRideRequestStatus.arrived:
        return "The driver is at your pickup location. Cancelling now may incur charges and affect your rating. Are you sure?";
      default:
        return "Are you sure you want to cancel this trip?";
    }
  }

  // Helper method to get user-friendly status message
  String _getStatusMessage(UserRideRequestStatus status, String originalStatus) {
    switch (status) {
      case UserRideRequestStatus.waiting:
        return "Looking for a driver nearby...";
      case UserRideRequestStatus.declined:
        return "Finding another driver...";
      default:
        return originalStatus.isNotEmpty ? originalStatus : "Connecting...";
    }
  }


  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      errorMethod("Driver phone number not available");
      return;
    }

    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        errorMethod( "Cannot make phone calls on this device");
      }
    } catch (e) {
      errorMethod( "Failed to open phone dialer");
      debugPrint("Phone call error: $e");
    }
  }

  // Helper method to get status icon
  Widget _getStatusIcon(UserRideRequestStatus status) {
    switch (status) {
      case UserRideRequestStatus.waiting:
      case UserRideRequestStatus.declined:
        return Icon(
          Icons.search,
          color: AppColor.primaryColor,
          size: 16,
        );
      case UserRideRequestStatus.accepted:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 16,
        );
      case UserRideRequestStatus.arrived:
        return const Icon(
          Icons.location_on,
          color: Colors.orange,
          size: 16,
        );
      case UserRideRequestStatus.onTrip:
        return const Icon(
          Icons.local_shipping,
          color: Colors.blue,
          size: 16,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.confirmPackageController.confirmPackageState;

    return CustomScrollView(
      controller: widget.scrollController,
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
        SliverList(
          delegate: SliverChildListDelegate(
            [
              10.verticalSpace,
              Obx(
                    () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Enhanced status display
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColor.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getStatusIcon(state.userRideRequestStatus.value),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              _getStatusMessage(
                                state.userRideRequestStatus.value,
                                state.driverRideStatus.value,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    16.verticalSpace,

                    // Driver details or loading state
                    !(state.userRideRequestStatus.value == UserRideRequestStatus.waiting ||
                        state.userRideRequestStatus.value == UserRideRequestStatus.declined)
                        ? Obx(() {
                      if (state.driverDetails.value.isBlank == null) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey[300],
                                      radius: 30,
                                    ),
                                    16.horizontalSpace,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 16,
                                            color: Colors.grey[300],
                                          ),
                                          8.verticalSpace,
                                          Container(
                                            width: 120,
                                            height: 12,
                                            color: Colors.grey[300],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              12.verticalSpace,
                              Text(
                                "Loading driver details...",
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        child: RiderWidget(
                          deliveriesDone: state.totalDelivery!.value.toInt(),
                          initialRating: state.averageRating!.value == 0.0 ? 0.0 : state.averageRating!.value,
                          driverImage: CachedNetworkImage(
                            imageUrl: state.driverDetails.value.picturePath ??
                                ConstantStrings.defaultAvater,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[300]!,
                                radius: 30,
                              ),
                            ),
                            imageBuilder: (context, image) => CircleAvatar(
                              backgroundImage: image,
                              radius: 30,
                            ),
                          ),
                          name: "${state.driverDetails.value.firstName?.capitalizeFirst ?? ""} ${state.driverDetails.value.lastName?.capitalizeFirst ?? ""}",
                          widget: IconWihContainer(
                            iconData: Icons.message,
                            onPressed: () {
                              Map data = {"driverInfo": state.driverDetails.value};
                              debugPrint("Driver Data: ${data["driverInfo"]}");
                              Get.to(() => const ChatScreen(), arguments: data);
                            },
                          ),
                          icon: IconWihContainer(
                            iconData: Icons.phone,
                            onPressed: () {
                              _makePhoneCall(state.driverDetails.value.phoneNumber);
                            },
                          ),
                        ),
                      );
                    })
                        : Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(20.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircularProgressIndicator.adaptive(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.primaryColor,
                            ),
                          ),
                          16.verticalSpace,
                          Text(
                            state.userRideRequestStatus.value == UserRideRequestStatus.waiting
                                ? "Waiting for driver response..."
                                : "Finding you another driver...",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          8.verticalSpace,
                          Text(
                            "This usually takes less than 2 minutes",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    16.verticalSpace,

                    // Cancel button
                    // Cancel button
                    Obx(() {
                      final status = state.userRideRequestStatus.value;
                      final canCancel = status == UserRideRequestStatus.waiting ||
                          status == UserRideRequestStatus.accepted ||
                          status == UserRideRequestStatus.arrived;

                      if (!canCancel) {
                        return const SizedBox.shrink();
                      }

                      // Different button styles based on status
                      String buttonText = _getCancelButtonText(status);
                      Color buttonColor = _getCancelButtonColor(status);

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                            // Warning message for accepted/arrived status
                            if (status == UserRideRequestStatus.accepted || status == UserRideRequestStatus.arrived)
                              Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        status == UserRideRequestStatus.accepted
                                            ? "Driver has accepted your request"
                                            : "Driver has arrived at pickup location",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.orange[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            CustomMaterialButton(
                              onPressed: () {
                                _showCancellationDialog(context, status);
                              },
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: buttonColor,
                                fontWeight: FontWeight.w500,
                              ),
                              name: buttonText,
                            ),
                          ],
                        ),
                      );
                    }),

                    // Payment button and messages based on payment method
                    (state.userRideRequestStatus.value == UserRideRequestStatus.arrived)
                        ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 10.h),
                      child: Obx(() => _buildPaymentWidget(context, state)),
                    )
                        : const SizedBox.shrink(),

                    20.verticalSpace, // Bottom padding
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentWidget(BuildContext context, ConfirmPackageState state) {
    String paymentMethod = state.paymentMethod.value;
    var sessionController = Get.find<SessionController>();
    UserModel userData = sessionController.userData;
    
    // Debug logging to see what payment method is received
    print("🔍 Rider Details Payment Debug:");
    print("- Payment Method: '$paymentMethod'");
    print("- Payment Status: ${state.paymentStatus.value}");
    print("- Is Payment Processing: ${state.isPaymentProcessing.value}");
    print("- Payment Method Length: ${paymentMethod.length}");
    print("- Payment Method Type: ${paymentMethod.runtimeType}");
    print("- Is Cash: ${paymentMethod == "cash"}");
    print("- Is Recipient: ${paymentMethod == "recipient"}");

    // Force reactivity by accessing the update trigger
    final _ = state.paymentUIUpdateTrigger.value;

    // Show payment confirmation if payment is completed
    if (state.paymentStatus.value == true) {
      print("✅ Showing payment confirmation (trigger: ${state.paymentUIUpdateTrigger.value})");
      return _buildPaymentConfirmation(context, state);
    }

    // Show payment processing indicator if payment is being processed
    if (state.isPaymentProcessing.value) {
      print("🔄 Showing payment processing (trigger: ${state.paymentUIUpdateTrigger.value})");
      return _buildPaymentProcessing(context, state);
    }

    print("💳 Showing Pay Now button (trigger: ${state.paymentUIUpdateTrigger.value})");
    
    if (paymentMethod == "cash") {
      // Show cash payment message
      return Container(
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
              "Amount: ₦${state.tripAmount.value}",
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
      );
    } else if (paymentMethod == "recipient") {
      // Show recipient payment message
      return Container(
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
              "Amount: ₦${state.tripAmount.value}",
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
      );
    } else {
      // Show Pay Now button for card payments
      return SizedBox(
        width: double.infinity,
        child: ButtonWidget(
          onTap: () {
            // Get the delivery request ID
            final deliveryId = state.requestID?.value;
            
            if (deliveryId == null || deliveryId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: Delivery ID not found')),
              );
              return;
            }

            // Set payment processing state
            state.isPaymentProcessing.value = true;

            Payment().makePayment(
              context: context,
              amount: double.parse(state.tripAmount.toString()),
              secretKey: secretKey,
              userEmail: userData.email!,
              metadata: {
                'deliveryId': deliveryId,
                'isScheduled': 'false',
                'userEmail': userData.email!,
              },
              onSuccess: () {
                // Show verifying message - DO NOT update payment status yet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verifying payment... Please wait.'),
                    duration: Duration(seconds: 3),
                  ),
                );
                // Webhook will update Firestore, listener will detect it and update UI
                widget.confirmPackageController.startPaymentVerificationListener(deliveryId);
              },
            );
          },
          widget: Text(
            "Pay Now",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColor.whiteColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          color: AppColor.primaryColor,
        ),
      );
    }
  }

  // Payment confirmation widget for completed payments
  Widget _buildPaymentConfirmation(BuildContext context, ConfirmPackageState state) {
    return Container(
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
          const SizedBox(height: 8),
          Text(
            "Amount: ₦${state.tripAmount.value}",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Payment processing widget for when payment is being verified
  Widget _buildPaymentProcessing(BuildContext context, ConfirmPackageState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Verifying Payment",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "Please wait while we confirm your payment...",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.home,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  "Tip: You can also track your ride from the Home screen for faster updates",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to home screen (dashboard)
                      Get.offAllNamed('/dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text("Go to Home"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Amount: ₦${state.tripAmount.value}",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}