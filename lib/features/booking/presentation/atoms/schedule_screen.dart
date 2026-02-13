


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/get_icon.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/custom_botton.dart';
import 'package:swiftrun/core/controller/location_controller.dart';
import 'package:swiftrun/features/booking/controller.dart';
import 'package:swiftrun/common/widgets/textfieldwithcontainer.dart';
import 'package:swiftrun/features/booking/states.dart';
import 'package:swiftrun/services/network/network.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({
    super.key,
    required this.bookingController,
    required this.bookingState,
    required this.imagePath,
    required this.scrollController,
  });

  final BookingController bookingController;
  final ScrollController scrollController;
  final BookingState bookingState;
  final List<String> imagePath;

  @override
  Widget build(BuildContext context) {
    final locationController = Get.put(LocationController());

    return CustomScrollView(
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        // Drag Handle
        SliverToBoxAdapter(
          child: Center(
            child: Container(
              width: 70.w,
              height: 5.h,
              margin: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColor.disabledColor,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),

        // Title
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              "Schedule Delivery",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        // Main Content
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList.list(
            children: [
              // Pickup Location
              TextFieldWIthContainer(
                hint: "Pickup location",
                controller: locationController.pickupText,
                onChange: (placeName) {
                  if (placeName.length >= 3) {
                    locationController.getPlaceAutoComplete(placeName, true);
                  }
                },
                icon: Icon(
                  Icons.location_on,
                  color: AppColor.errorColor,
                ),
                title: 'Pickup Location',
                rightIcon: IconButton(
                  onPressed: () => locationController.getCurrentLocation(),
                  icon: const Icon(
                    Icons.my_location_outlined,
                  ),
                ),
              ),

              // Pickup Predictions with proper constraints
              Obx(
                    () => Visibility(
                  visible: locationController.pickupPredictionList.isNotEmpty,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 200.h, // Prevent overflow
                    ),
                    margin: EdgeInsets.only(top: 8.h),
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColor.disabledColor.withOpacity(0.3)),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: locationController.pickupPredictionList.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppColor.disabledColor.withOpacity(0.2),
                      ),
                      itemBuilder: (context, index) {
                        final predictionResults =
                        locationController.pickupPredictionList[index];
                        return InkWell(
                          onTap: () async {
                            Logger.error(predictionResults.toString());
                            locationController.pickupText.text =
                            predictionResults.description!;
                            await Network.getLatLngFromPlaceID(
                              predictionResults,
                              LocationType.pickupAddress,
                            );
                            locationController.pickupPredictionList.clear();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: AppColor.disabledColor,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    predictionResults.description ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Delivery Location
              TextFieldWIthContainer(
                title: "Delivery Location",
                hint: "Dropoff Location",
                controller: locationController.dropOffText,
                onChange: (dropOffAddress) {
                  if (dropOffAddress.length >= 3) {
                    locationController.getPlaceAutoComplete(
                        dropOffAddress, false);
                  }
                },
                icon: Padding(
                  padding: const EdgeInsets.all(15),
                  child: SvgPicture.asset(
                    width: 10,
                    height: 10,
                    "assets/icons/dropofficon.svg",
                  ),
                ),
              ),

              // Delivery Predictions with proper constraints
              Obx(
                    () => Visibility(
                  visible: locationController.dropOffpredictionList.isNotEmpty,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 200.h, // Prevent overflow
                    ),
                    margin: EdgeInsets.only(top: 8.h),
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColor.disabledColor.withOpacity(0.3)),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: locationController.dropOffpredictionList.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppColor.disabledColor.withOpacity(0.2),
                      ),
                      itemBuilder: (context, index) {
                        final dropOffResults =
                        locationController.dropOffpredictionList[index];

                        return InkWell(
                          onTap: () async {
                            Logger.error(dropOffResults.toString());
                            locationController.dropOffText.text =
                            dropOffResults.description!;
                            await Network.getLatLngFromPlaceID(
                              dropOffResults,
                              LocationType.dropoffAddres,
                            );
                            locationController.dropOffpredictionList.clear();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: AppColor.primaryColor,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    dropOffResults.description ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Date and Time Row with proper flex
              Obx(
                    () => Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => bookingController.pickDate(context),
                        child: TextFieldWIthContainer(
                          controller: bookingState.dateController,
                          isEnable: false,
                          title: "Date",
                          hint: DateFormat.yMMMMd().format(
                            bookingState.selectedDate.value,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => bookingController.pickTime(context),
                        child: TextFieldWIthContainer(
                          controller: bookingState.timeController,
                          isEnable: false,
                          title: "Time",
                          hint: 'HH:MM',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Vehicle Type Label
              Text(
                "Choose Vehicle Type",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColor.disabledColor),
              ),

              SizedBox(height: 12.h),

              // Vehicle Selection with responsive sizing
              Obx(
                    () {
                  final vehicleData = bookingState.vehicleTypesData;
                  final screenWidth = MediaQuery.of(context).size.width;
                  final itemWidth = (screenWidth - 48.w) / vehicleData.length - 8.w;
                  final itemSize = itemWidth.clamp(80.0, 120.0);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        vehicleData.length,
                            (index) {
                          var vehicleIndex = vehicleData[index];
                          final isSelected = bookingState.selectedVehicleType.value ==
                              vehicleIndex['type'];

                          return Container(
                            margin: EdgeInsets.only(right: index < vehicleData.length - 1 ? 8.w : 0),
                            child: InkWell(
                              onTap: () {
                                bookingController.setSelectedCar(
                                  type: vehicleIndex['type'].toString(),
                                  id: vehicleIndex['vehicleRef'].toString(),
                                );
                                debugPrint('Index $index Clicked');
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: itemSize,
                                width: itemSize,
                                padding: EdgeInsets.all(8.w).copyWith(
                                  top: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                    color: AppColor.primaryColor,
                                    width: 2,
                                  )
                                      : Border.all(
                                    color: AppColor.disabledColor.withOpacity(0.3),
                                  ),
                                  color: isSelected
                                      ? AppColor.textFieldFill
                                      : AppColor.unSelected,
                                  boxShadow: isSelected
                                      ? [
                                    BoxShadow(
                                      color: AppColor.primaryColor.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: Icon(
                                        iconFromString(
                                          vehicleIndex['vehicleIcon'],
                                        ),
                                        size: (itemSize * 0.3).clamp(20.0, 35.0),
                                        color: isSelected
                                            ? AppColor.primaryColor
                                            : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        vehicleIndex['type'].toString().toUpperCase(),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                          fontSize: (itemSize * 0.12).clamp(10.0, 14.0),
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? AppColor.primaryColor
                                              : Colors.black,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 30.h),

              // Next Button with proper constraints
              ButtonWidget(
                onTap: () {
                  if (bookingState.selectedVehicleType.isEmpty &&
                      bookingState.selectedVehicleId.isEmpty) {
                    errorMethod("Please select vehicle type");
                    return;
                  }
                  bookingController.validateScheduleDelivery();
                },
                color: AppColor.primaryColor,
                widget: Text(
                  "Next",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(
                    color: AppColor.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Bottom safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
            ],
          ),
        ),
      ],
    );
  }
}