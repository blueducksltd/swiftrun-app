import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class BookingState {
  var pickedImageXfile = Rxn<XFile>();

  final imagePicker = ImagePicker();
  final RxString selectedVehicleType = "".obs;
  final RxString selectedVehicleId = "".obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  var dateController = TextEditingController();
  var timeController = TextEditingController();
  var itemController = TextEditingController();
  var quantityController = TextEditingController();
  var recipientNameController = TextEditingController();
  var recipientContactController = TextEditingController();

  RxList vehicleTypesData = [].obs;
}
