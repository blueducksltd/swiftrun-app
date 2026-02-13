


// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/core/controller/get_driver_near.dart';
import 'package:swiftrun/core/controller/location_controller.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/confirmation.con.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/details_confirmation.dart';
import 'package:swiftrun/features/booking/presentation/atoms/rider_details.dart';

class ConfirmDeliveryScreen extends StatefulWidget {
  final int? fromPage;
  const ConfirmDeliveryScreen({super.key, this.fromPage});

  @override
  State<ConfirmDeliveryScreen> createState() => _ConfirmDeliveryScreenState();
}

class _ConfirmDeliveryScreenState extends State<ConfirmDeliveryScreen> {
  final confirmPackage = Get.put(ConfirmPackageController());
  final locationController = Get.put(LocationController());

  bool? showPackageConfirmation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locationController.createActiveNearByDriverIconMarker(context);
  }

  @override
  void initState() {
    super.initState();
    showPackageConfirmation = widget.fromPage == 0;

    // Ensure we get current location when this screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (locationController.position == null) {
        locationController.getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    GetNearByDriver.disposeGetActiveDriver();
    super.dispose();
  }

  void switchPackageConfirmation() {
    setState(() {
      showPackageConfirmation = !showPackageConfirmation!;
    });
  }

  @override
  Widget build(BuildContext context) {
    var confirmState = confirmPackage.confirmPackageState;
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            // Google Map
            SizedBox(
              height: screenHeight(context, percent: .95),
              width: double.infinity,
              child: Obx(() => GoogleMap(
                zoomControlsEnabled: true,
                mapToolbarEnabled: true,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  confirmPackage.onMapDetail(controller);
                  // Also set it in location controller for consistency
                  locationController.onMapCreated(controller);
                },
                mapType: MapType.terrain,
                // Use dynamic initial camera position that updates with current location
                initialCameraPosition: locationController.hasSetCurrentLocation.value
                    ? locationController.initalLocation
                    : const CameraPosition(
                  zoom: 12,
                  target: LatLng(6.5244, 7.4989), // Enugu fallback
                ),
                polylines: locationController.polylineSet.value,
                markers: locationController.riderMaker.value,
                circles: locationController.circleMarker.value,
              )),
            ),

            // Modern close button with gradient
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              right: mainPaddingWidth,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor,
                      AppColor.primaryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withValues(alpha: 0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColor.whiteColor,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Modern bottom sheet with enhanced design
            Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                initialChildSize: showPackageConfirmation! ? 0.55 : 0.45,
                maxChildSize: showPackageConfirmation! ? 0.55 : 0.45,
                minChildSize: 0.35,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, -5),
                          blurRadius: 20,
                          spreadRadius: 0,
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                        BoxShadow(
                          offset: const Offset(0, -2),
                          blurRadius: 10,
                          spreadRadius: 0,
                          color: AppColor.primaryColor.withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Modern drag handle
                        Container(
                          margin: EdgeInsets.only(top: 12.h),
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColor.disabledColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth)
                                .copyWith(top: 8.h, bottom: 5.h),
                            child: Obx(
                              () {
                                return showPackageConfirmation!
                                    ? PackageConfirmation(
                                  isScheduleDelivery: false,
                                  confirmPackageController: confirmPackage,
                                  scrollController: scrollController,
                                  bookDriver: confirmState.isSearchingDrivers.value
                                      ? () {
                                        // Still searching - show loading message
                                        infoMethod("Searching for drivers, please wait...");
                                      }
                                      : confirmState.driversFound.value
                                          ? switchPackageConfirmation
                                          : () {
                                            Logger.i("Status ${confirmState.driversFound.value}");
                                            errorMethod("No Available Driver At The Moment");
                                          },
                                )
                                    : RiderDetails(
                                  scrollController: scrollController,
                                  confirmPackageController: confirmPackage,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}