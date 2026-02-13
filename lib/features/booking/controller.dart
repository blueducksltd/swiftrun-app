import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:swiftrun/common/routes/route_name.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/fare_cal.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/widgets.dart';
import 'package:swiftrun/core/controller/location_controller.dart';
import 'package:swiftrun/features/booking/index.dart';
import 'package:swiftrun/features/booking/model/booking_model.dart';
import 'package:swiftrun/services/network/network.dart';
import 'package:swiftrun/common/utils/country_utils.dart';

class BookingController extends GetxController {
  var locationController = Get.put(LocationController());
  static BookingController get to => Get.find();

  var bookingState = BookingState();

  //dynamic bookingInfos;

  @override
  void onInit() {
    super.onInit();
    getVehicle();
  }

  void getVehicle() async {
    bookingState.vehicleTypesData.value = await FareCalculator.vehicleTypes();

    Logger.i(bookingState.vehicleTypesData);
  }

  validate() async {
    if (locationController.pickupText.text.trim().isEmpty ||
        locationController.pickupText.text.trim().length <= 15 ||
        locationController.dropOffText.text.trim().isEmpty ||
        locationController.dropOffText.text.trim().length <= 15) {
      errorMethod("Fill all the fields");
    } else {
      Get.to(() => DeliveryDetails(isHasPicture: true));
    }
  }

  validateScheduleDelivery() async {
    if (locationController.pickupText.text.trim().isEmpty ||
        locationController.pickupText.text.trim().length <= 15 ||
        locationController.dropOffText.text.trim().isEmpty ||
        locationController.dropOffText.text.trim().length <= 15 ||
        bookingState.dateController.text.isEmpty ||
        bookingState.timeController.text.isEmpty) {
      errorMethod("Fill all the fields");
    } else {
      Get.to(() => DeliveryDetails(
            isScheduleDelivery: true,
          ));
      // successMethod("successmsg");
    }
  }

  setSelectedCar({required String type, required String id}) {
    bookingState.selectedVehicleType.value = type;
    bookingState.selectedVehicleId.value = id;
    Logger.i("Selected Vehicle $type with id $id");
  }

  setSelectedCarId(String index) {
    bookingState.selectedVehicleId.value = index;
    Logger.i(index);
  }

  pickDate(BuildContext context) async {
    DateTime? dataPicker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: "Select the pickup date",
    );

    //bookingState.selectedDate.value = dataPicker!;
    dataPicker != null
        ? bookingState.dateController.text =
            DateFormat.yMMMd().format(dataPicker)
        : null;
  }

  pickTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: TimeOfDay.now(),
    );

    pickedTime != null
        // ignore: use_build_context_synchronously
        ? bookingState.timeController.text = pickedTime.format(context)
        : null;
  }

  uploadImage() async {
    Get.defaultDialog(
      title: "Select Source",
      content: Column(
        children: [
          ButtonWidget(
            color: AppColor.primaryColor,
            onTap: () async {
              // Close dialog FIRST, before launching the image picker.
              // This prevents iOS lifecycle events from popping the wrong route
              // when the camera/gallery opens and the app goes to background.
              if (Get.isDialogOpen == true) {
                Get.back();
              }
              await imageSource(source: ImageSource.gallery);
            },
            widget: Text(
              "Gallery",
              style: Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(
                    color: AppColor.whiteColor,
                  ),
            ),
          ),
          10.verticalSpace,
          ButtonWidget(
            color: AppColor.primaryColor,
            onTap: () async {
              // Close dialog FIRST, before launching the image picker.
              if (Get.isDialogOpen == true) {
                Get.back();
              }
              await imageSource(source: ImageSource.camera);
            },
            widget: Text(
              "Camera",
              style: Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(
                    color: AppColor.whiteColor,
                  ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> imageSource({required ImageSource source}) async {
    await bookingState.imagePicker.pickImage(source: source).then(
      (value) {
        if (value != null) {
          bookingState.pickedImageXfile.value = XFile(value.path);
        } else {
          bookingState.pickedImageXfile.value = null;
        }
      },
    );
  }

  goToPayment({
    bool isScheduleDelivery = false,
    bool isPackageImage = false,
  }) async {
    //var confCon = Get.put(ConfirmPackageController());
    if ((isScheduleDelivery && isPackageImage) || (!isScheduleDelivery)) {
      if (bookingState.pickedImageXfile.value == null) {
        return errorMethod("Please upload a package image.");
      }
    }
    Logger.i("$isScheduleDelivery $isPackageImage");

    // Get current location country for phone validation (more accurate than user's registered country)
    final locationController = Get.find<LocationController>();
    final currentCountryCode = locationController.getCurrentCountryCode();
    final phoneDigits = bookingState.recipientContactController.text
        .replaceAll(RegExp(r'[^\d]'), '');

    // Debug logging
    Logger.i("Phone validation debug:");
    Logger.i("- Current location country: $currentCountryCode");
    Logger.i("- Phone text: ${bookingState.recipientContactController.text}");
    Logger.i("- Phone digits: $phoneDigits");
    Logger.i("- Phone digits length: ${phoneDigits.length}");
    Logger.i(
        "- Is valid: ${CountryUtils.isValidPhoneNumber(phoneDigits, currentCountryCode)}");

    if (bookingState.recipientNameController.text.isEmpty ||
        bookingState.recipientNameController.text.isEmpty ||
        bookingState.recipientNameController.text.length <= 1 ||
        bookingState.recipientContactController.text.isEmpty ||
        !CountryUtils.isValidPhoneNumber(phoneDigits, currentCountryCode) ||
        bookingState.quantityController.text.isEmpty ||
        bookingState.quantityController.text.length.isEqual(0)) {
      return errorMethod("Please fill all the options correctly");
    }

    var bookingData = BookingModel(
      courierType: bookingState.selectedVehicleType.toString(),
      dropOffAddress: locationController.dropLocation,
      pickupAddress: locationController.pickupLocation,
      imageUrl: bookingState.pickedImageXfile.value?.path,
      recipientName: bookingState.recipientNameController.text,
      recipientNumber: CountryUtils.getFullPhoneNumber(
          bookingState.recipientContactController.text, currentCountryCode),
      quantity: bookingState.quantityController.text,
      items: bookingState.itemController.text.split(" "),
    );

    Map<String, String> data = {
      "vehicleType": bookingData.courierType?.toLowerCase() ?? "",
      "pickupLocation": bookingData.pickupAddress!.description ?? "",
      "dropOffLocation": bookingData.dropOffAddress!.description ?? "",
      "dropOffLat": bookingData.dropOffAddress!.latitude.toString(),
      "dropOffLng": bookingData.dropOffAddress!.longitude.toString(),
      "pickupLat": bookingData.pickupAddress!.latitude.toString(),
      "pickupLng": bookingData.pickupAddress!.longitude.toString(),
      "itemType": bookingData.items.toString(),
      "receipientName": bookingData.recipientName ?? "",
      "receipientNumber": CountryUtils.getFullPhoneNumber(
          bookingState.recipientContactController.text, currentCountryCode),
      "imagePath": bookingData.imageUrl ?? "",
      "vehicleTypeId": bookingState.selectedVehicleId.value,
    };

    // Both instant and scheduled deliveries go through payment selection first
    // Add schedule data to the arguments if it's a scheduled delivery
    if (isScheduleDelivery) {
      // Merge schedule-specific data into the main data map
      data["dateScheduled"] = bookingState.dateController.text;
      data["timeScheduled"] = bookingState.timeController.text;
      data["isScheduled"] = "true";
    }

    Get.toNamed(
      AppRoutes.paymentScreen,
      arguments: data,
    );
  }
}
