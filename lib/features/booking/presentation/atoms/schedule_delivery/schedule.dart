// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/size.dart';
import 'package:swiftrun/core/controller/location_controller.dart';
import 'package:swiftrun/features/booking/presentation/atoms/schedule_delivery/confirm_schedule.dart';
import 'package:swiftrun/features/booking/presentation/atoms/schedule_delivery/controller.dart';

class ConfirmSchedule extends StatefulWidget {
  const ConfirmSchedule({super.key});

  @override
  State<ConfirmSchedule> createState() => _ConfirmScheduleState();
}

class _ConfirmScheduleState extends State<ConfirmSchedule> {
  final locationController = Get.put(LocationController());
  final scheduleController = Get.put(ScheducleDeliveryController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            SizedBox(
              height: screenHeight(context, percent: .95),
              width: double.infinity,
              child: GoogleMap(
                zoomControlsEnabled: true,
                mapToolbarEnabled: true,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: scheduleController.onMapDetail,
                mapType: MapType.terrain,
                initialCameraPosition: locationController.initalLocation,
                polylines: locationController.polylineSet.value,
                markers: locationController.riderMaker.value,
                circles: locationController.circleMarker.value,
              ),
            ),
            Positioned(
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth)
                    .copyWith(top: 40),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primaryColor,
                  ),
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                initialChildSize: screenHeight(context, percent: 0.00060),
                maxChildSize: screenHeight(context, percent: 0.00060),
                minChildSize: screenHeight(context, percent: 0.00007),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: mainPaddingWidth)
                              .copyWith(top: 15.h, bottom: 5.h),
                      child: ConfirmScheduleDelivery(
                        scheducleDeliveryController: scheduleController,
                        scrollController: scrollController,
                      ),
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
