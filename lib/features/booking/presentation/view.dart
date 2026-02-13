// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:swiftrun/common/styles/style.dart';
// import 'package:swiftrun/common/utils/get_icon.dart';
// import 'package:swiftrun/common/utils/utils.dart';
// import 'package:swiftrun/common/widgets/custom_botton.dart';
// import 'package:swiftrun/core/controller/location_controller.dart';
// import 'package:swiftrun/features/booking/controller.dart';
// import 'package:swiftrun/features/booking/presentation/atoms/schedule_screen.dart';
// import 'package:swiftrun/common/widgets/textfieldwithcontainer.dart';
// import 'package:swiftrun/features/booking/states.dart';
// import 'package:swiftrun/services/network/network.dart';
//
// class BookingScreen extends StatefulWidget {
//   final bool isInstant;
//
//   const BookingScreen({
//     super.key,
//     this.isInstant = true,
//   });
//
//   @override
//   State<BookingScreen> createState() => _BookingScreenState();
// }
//
// class _BookingScreenState extends State<BookingScreen> {
//   final locationController = Get.put(LocationController());
//   final bookingController = Get.put(BookingController());
//   // final confirmPackageController = Get.put(ConfirmPackageController());
//   final List<String> imagePath = [
//     "assets/icons/bike.svg",
//     "assets/icons/car.svg",
//     "assets/icons/truck.svg",
//   ];
//
//   // List<String> imageTitle = ["Bike", "Car", "Truck"];
//
//   @override
//   Widget build(BuildContext context) {
//     var bookingState = bookingController.bookingState;
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           SizedBox(
//             height: screenHeight(context, percent: 0.95),
//             width: double.infinity,
//             child: GoogleMap(
//               zoomControlsEnabled: true,
//               mapToolbarEnabled: false,
//               myLocationButtonEnabled: true,
//               onMapCreated: locationController.onMapCreated,
//               mapType: MapType.normal,
//               initialCameraPosition: locationController.initalLocation,
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: DraggableScrollableSheet(
//               initialChildSize: widget.isInstant
//                   ? screenHeight(context, percent: 0.0005)
//                   : screenHeight(context, percent: .0006),
//               maxChildSize: widget.isInstant
//                   ? screenHeight(context, percent: 0.0005)
//                   : screenHeight(context, percent: .0006),
//               minChildSize: screenHeight(context, percent: 0.00008),
//               builder: (context, scrollController) {
//                 return DecoratedBox(
//                   decoration: BoxDecoration(
//                     color: AppColor.whiteColor,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(20),
//                       topRight: Radius.circular(20),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         offset: const Offset(0, -3),
//                         blurRadius: 2,
//                         color: AppColor.bgColor,
//                       )
//                     ],
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth)
//                         .copyWith(top: 15.h, bottom: 15.h),
//                     child: widget.isInstant
//                         ? InstantDelivery(
//                             imagePath: imagePath,
//                             bookingController: bookingController,
//                             bookingState: bookingState,
//                             // imageTitle: carTitle,
//                             scrollController: scrollController,
//                           )
//                         : ScheduleScreen(
//                             bookingController: bookingController,
//                             bookingState: bookingState,
//                             imagePath: imagePath,
//                             // imageTitle: imageTitle,
//                             scrollController: scrollController,
//                           ),
//                   ),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class InstantDelivery extends StatefulWidget {
//   const InstantDelivery({
//     super.key,
//     this.imagePath,
//     required this.bookingController,
//     required this.bookingState,
//     // this.imageTitle,
//     required this.scrollController,
//   });
//
//   final List<String>? imagePath;
//   final BookingController bookingController;
//   final BookingState bookingState;
//   // final Future<List<String>>? imageTitle;
//   final ScrollController scrollController;
//
//   @override
//   State<InstantDelivery> createState() => _InstantDeliveryState();
// }
//
// class _InstantDeliveryState extends State<InstantDelivery> {
//   late final LocationController locationController;
//
//   @override
//   void initState() {
//     super.initState();
//     locationController = Get.put(LocationController(), permanent: true);
//   }
//   @override
//   Widget build(BuildContext context) {
//     // final locationController = Get.put(LocationController());
//     return CustomScrollView(
//       controller: widget.scrollController,
//       keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//       slivers: [
//         SliverToBoxAdapter(
//           child: Center(
//             child: Container(
//               width: 70.w,
//               height: 5.h,
//               decoration: BoxDecoration(
//                 color: AppColor.disabledColor,
//                 borderRadius: BorderRadius.circular(50),
//               ),
//             ),
//           ),
//         ),
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Text(
//               "Instant Delivery",
//               style: Theme.of(context)
//                   .textTheme
//                   .headlineMedium!
//                   .copyWith(fontWeight: FontWeight.w300),
//             ),
//           ),
//         ),
//         SliverList.list(
//           children: [
//             TextFieldWIthContainer(
//               hint: "Pickup location",
//               controller: locationController.pickupText,
//               onChange: (placeName) {
//                 if (placeName.length >= 5) {
//                   locationController.getPlaceAutoComplete(placeName, true);
//                 }
//               },
//               icon: Icon(
//                 Icons.location_on,
//                 color: AppColor.errorColor,
//               ),
//               title: 'Pickup Location',
//               rightIcon: IconButton(
//                 onPressed: () => locationController.getCurrentLocation(),
//                 icon: const Icon(
//                   Icons.my_location_outlined,
//                 ),
//               ),
//             ),
//             Obx(
//               () => Visibility(
//                 visible: locationController.pickupPredictionList.isNotEmpty,
//                 child: ListView.builder(
//                   padding: EdgeInsets.zero,
//                   shrinkWrap: true,
//                   itemCount: locationController.pickupPredictionList.length,
//                   itemBuilder: (context, index) {
//                     final predictionResults =
//                         locationController.pickupPredictionList[index];
//                     return Container(
//                         color: AppColor.whiteColor,
//                         child: InkWell(
//                           onTap: () async {
//                             Logger.error(predictionResults.toString());
//                             locationController.pickupText.text =
//                                 predictionResults.description!;
//                             await Network.getLatLngFromPlaceID(
//                               predictionResults,
//                               LocationType.pickupAddress,
//                             );
//                             locationController.pickupPredictionList.clear();
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.only(bottom: 8.0),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.location_on),
//                                 Expanded(
//                                   child: Text(
//                                     predictionResults.description ?? "",
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style:
//                                         Theme.of(context).textTheme.bodySmall,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ));
//                   },
//                 ),
//               ),
//             ),
//             TextFieldWIthContainer(
//               title: "Delivery Location",
//               hint: "Dropoff Location",
//               controller: locationController.dropOffText,
//               onChange: (dropOffAddress) {
//                 if (dropOffAddress.length >= 5) {
//                   locationController.getPlaceAutoComplete(
//                       dropOffAddress, false);
//                 }
//               },
//               icon: Padding(
//                 padding: const EdgeInsets.all(15),
//                 child: SvgPicture.asset(
//                   width: 10,
//                   height: 10,
//                   "assets/icons/dropofficon.svg",
//                 ),
//               ),
//               rightIcon: InkWell(
//                 onTap: () {
//                   locationController.dropOffText.clear();
//                   locationController.dropOffpredictionList.clear();
//                 },
//                 child: const Icon(Icons.close),
//               ),
//             ),
//             Obx(
//               () => Visibility(
//                 visible: locationController.dropOffpredictionList.isNotEmpty,
//                 child: ListView.builder(
//                   padding: EdgeInsets.zero,
//                   shrinkWrap: true,
//                   itemCount: locationController.dropOffpredictionList.length,
//                   itemBuilder: (context, index) {
//                     final dropOffResults =
//                         locationController.dropOffpredictionList[index];
//
//                     return InkWell(
//                       onTap: () async {
//                         locationController.dropOffText.text =
//                             dropOffResults.description!;
//                         await Network.getLatLngFromPlaceID(
//                           dropOffResults,
//                           LocationType.dropoffAddres,
//                         );
//
//                         locationController.dropOffpredictionList.clear();
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.only(bottom: 8.0),
//                         child: Container(
//                           padding: const EdgeInsets.all(5),
//                           color: AppColor.whiteColor,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.location_on,
//                                 size: 15,
//                                 color: AppColor.primaryColor,
//                               ),
//                               Expanded(
//                                 child: Text(
//                                   dropOffResults.description ?? "",
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: Theme.of(context).textTheme.bodySmall,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 10.h),
//               child: Text(
//                 "Vehicle Type",
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodySmall!
//                     .copyWith(color: AppColor.disabledColor),
//               ),
//             ),
//             Obx(
//               () => Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(
//                   widget.bookingState.vehicleTypesData.length,
//                   (index) => Obx(() {
//                     var vehicleIndex =
//                         widget.bookingState.vehicleTypesData[index];
//                     return InkWell(
//                       onTap: () {
//                         widget.bookingController.setSelectedCar(
//                           type: vehicleIndex['type'].toString(),
//                           id: vehicleIndex['vehicleRef'].toString(),
//                         );
//                       },
//                       child: Container(
//                         height: 100.w,
//                         width: 100.w,
//                         // margin: const EdgeInsets.all(5),
//                         padding: const EdgeInsets.all(10)
//                             .copyWith(top: 15, left: 10, right: 10),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border:
//                               widget.bookingState.selectedVehicleType.value ==
//                                       vehicleIndex['type']
//                                   ? Border.all(color: AppColor.primaryColor)
//                                   : const Border(),
//                           color:
//                               widget.bookingState.selectedVehicleType.value ==
//                                       vehicleIndex['type']
//                                   ? AppColor.textFieldFill
//                                   : AppColor.unSelected,
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Icon(
//                               iconFromString(vehicleIndex['vehicleIcon']),
//                               size: 30,
//                             ),
//                             Text(
//                               vehicleIndex['type'].toString().toUpperCase(),
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodySmall!
//                                   .copyWith(
//                                     fontWeight: FontWeight.normal,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                             )
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//             ),
//             30.verticalSpace,
//             ButtonWidget(
//               isHeight: true,
//               height: screenHeight(context, percent: 0.06),
//               onTap: () {
//                 log(screenHeight(context).toString());
//                 log(screenWidth(context).toString());
//
//                 if (widget.bookingState.selectedVehicleType.isEmpty &&
//                     widget.bookingState.selectedVehicleId.isEmpty) {
//                   errorMethod("Please select vehicle type");
//                   return;
//                 }
//                 widget.bookingController.validate();
//               },
//               color: AppColor.primaryColor,
//               widget: Text(
//                 "Next",
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodyMedium!
//                     .copyWith(color: AppColor.whiteColor),
//               ),
//             )
//           ],
//         )
//       ],
//     );
//   }
// }








import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/get_icon.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/custom_botton.dart';
import 'package:swiftrun/core/controller/location_controller.dart';
import 'package:swiftrun/features/booking/controller.dart';
import 'package:swiftrun/features/booking/presentation/atoms/schedule_screen.dart';
import 'package:swiftrun/common/widgets/textfieldwithcontainer.dart';
import 'package:swiftrun/features/booking/states.dart';
import 'package:swiftrun/services/network/network.dart';

class BookingScreen extends StatefulWidget {
  final bool isInstant;

  const BookingScreen({
    super.key,
    this.isInstant = true,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final locationController = Get.put(LocationController());
  final bookingController = Get.put(BookingController());
  final List<String> imagePath = [
    "assets/icons/bike.svg",
    "assets/icons/car.svg",
    "assets/icons/truck.svg",
  ];

  @override
  Widget build(BuildContext context) {
    var bookingState = bookingController.bookingState;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: screenHeight(context, percent: 0.95),
            width: double.infinity,
            child: GoogleMap(
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: true,
              onMapCreated: locationController.onMapCreated,
              mapType: MapType.normal,
              initialCameraPosition: locationController.initalLocation,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: widget.isInstant
                  ? screenHeight(context, percent: 0.0005)
                  : screenHeight(context, percent: .0006),
              maxChildSize: widget.isInstant
                  ? screenHeight(context, percent: 0.0005)
                  : screenHeight(context, percent: .0006),
              minChildSize: screenHeight(context, percent: 0.00008),
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
                        .copyWith(top: 15.h, bottom: 15.h),
                    child: widget.isInstant
                        ? InstantDelivery(
                      imagePath: imagePath,
                      bookingController: bookingController,
                      bookingState: bookingState,
                      scrollController: scrollController,
                    )
                        : ScheduleScreen(
                      bookingController: bookingController,
                      bookingState: bookingState,
                      imagePath: imagePath,
                      scrollController: scrollController,
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class InstantDelivery extends StatefulWidget {
  const InstantDelivery({
    super.key,
    this.imagePath,
    required this.bookingController,
    required this.bookingState,
    required this.scrollController,
  });

  final List<String>? imagePath;
  final BookingController bookingController;
  final BookingState bookingState;
  final ScrollController scrollController;

  @override
  State<InstantDelivery> createState() => _InstantDeliveryState();
}

class _InstantDeliveryState extends State<InstantDelivery> {
  late final LocationController locationController;

  @override
  void initState() {
    super.initState();
    locationController = Get.put(LocationController(), permanent: true);
  }

  // Method to switch pickup and delivery addresses
  void _switchAddresses() {
    final pickupText = locationController.pickupText.text;
    final dropOffText = locationController.dropOffText.text;

    if (pickupText.isNotEmpty || dropOffText.isNotEmpty) {
      locationController.pickupText.text = dropOffText;
      locationController.dropOffText.text = pickupText;

      // Clear prediction lists to avoid confusion
      locationController.pickupPredictionList.clear();
      locationController.dropOffpredictionList.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Instant Delivery",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w300),
            ),
          ),
        ),
        SliverList.list(
          children: [
            // Enhanced Pickup Location Field
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
              rightIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Clear pickup field button
                  if (locationController.pickupText.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        locationController.pickupText.clear();
                        locationController.pickupPredictionList.clear();
                      },
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: AppColor.disabledColor,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  // Current location button for pickup
                  IconButton(
                    onPressed: () => locationController.getCurrentLocation(isForDelivery: false),
                    icon: Icon(
                      Icons.my_location,
                      color: AppColor.primaryColor,
                      size: 22,
                    ),
                    tooltip: 'Use current location',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            // Pickup prediction list
            Obx(
                  () => Visibility(
                visible: locationController.pickupPredictionList.isNotEmpty,
                child: Container(
                  margin: EdgeInsets.only(top: 5.h),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.disabledColor.withOpacity(0.3)),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
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
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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

            // Switch addresses button
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.textFieldFill,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColor.disabledColor.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    onPressed: _switchAddresses,
                    icon: Icon(
                      Icons.swap_vert,
                      color: AppColor.primaryColor,
                      size: 24,
                    ),
                    tooltip: 'Switch pickup and delivery locations',
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ),

            // Enhanced Delivery Location Field
            TextFieldWIthContainer(
              title: "Delivery Location",
              hint: "Dropoff Location",
              controller: locationController.dropOffText,
              onChange: (dropOffAddress) {
                if (dropOffAddress.length >= 3) {
                  locationController.getPlaceAutoComplete(dropOffAddress, false);
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
              rightIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Clear delivery field button
                  if (locationController.dropOffText.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        locationController.dropOffText.clear();
                        locationController.dropOffpredictionList.clear();
                      },
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: AppColor.disabledColor,
                      ),
                      tooltip: 'Clear field',
                      visualDensity: VisualDensity.compact,
                    ),
                  // Current location button for delivery
                  IconButton(
                    onPressed: () {
                      // You'll need to add this method to your LocationController
                      // to set current location as delivery address
                      locationController.getCurrentLocation(isForDelivery: true);
                    },
                    icon: Icon(
                      Icons.my_location_outlined,
                      // Icons.my_location,
                      color: AppColor.primaryColor,
                      size: 22,
                    ),
                    tooltip: 'Use current location',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            // Delivery prediction list
            Obx(
                  () => Visibility(
                visible: locationController.dropOffpredictionList.isNotEmpty,
                child: Container(
                  margin: EdgeInsets.only(top: 5.h),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.disabledColor.withOpacity(0.3)),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
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
                          locationController.dropOffText.text =
                          dropOffResults.description!;
                          await Network.getLatLngFromPlaceID(
                            dropOffResults,
                            LocationType.dropoffAddres,
                          );
                          locationController.dropOffpredictionList.clear();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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

            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.h),
              child: Text(
                "Choose Vehicle Type",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColor.disabledColor),
              ),
            ),

            // Enhanced Vehicle Selection with better performance
            Obx(
                  () {
                final vehicleData = widget.bookingState.vehicleTypesData;
                final selectedType = widget.bookingState.selectedVehicleType.value;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    vehicleData.length,
                        (index) {
                      var vehicleIndex = vehicleData[index];
                      final isSelected = selectedType == vehicleIndex['type'];

                      return InkWell(
                        onTap: () {
                          widget.bookingController.setSelectedCar(
                            type: vehicleIndex['type'].toString(),
                            id: vehicleIndex['vehicleRef'].toString(),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 100.w,
                          width: 100.w,
                          padding: const EdgeInsets.all(10)
                              .copyWith(top: 15, left: 10, right: 10),
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
                              Icon(
                                iconFromString(vehicleIndex['vehicleIcon']),
                                size: 30,
                                color: isSelected
                                    ? AppColor.primaryColor
                                    : Colors.black,
                              ),
                              Text(
                                vehicleIndex['type'].toString().toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColor.primaryColor
                                      : Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            30.verticalSpace,

            // Enhanced Next Button
            ButtonWidget(
              isHeight: true,
              height: screenHeight(context, percent: 0.06),
              onTap: () {
                log(screenHeight(context).toString());
                log(screenWidth(context).toString());

                if (widget.bookingState.selectedVehicleType.isEmpty &&
                    widget.bookingState.selectedVehicleId.isEmpty) {
                  errorMethod("Please select vehicle type");
                  return;
                }
                widget.bookingController.validate();
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
            )
          ],
        )
      ],
    );
  }
}


