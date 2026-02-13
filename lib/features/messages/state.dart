import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swiftrun/core/model/driver_model.dart';
import 'package:swiftrun/features/messages/model/msgcontent.dart';

class MessageState {
  RxList msgContentList = <Msgcontent>[].obs;
  String? ids;

  var driverInfo = DriverModel().obs;
  var messageController = TextEditingController();
  var isSending = false.obs; // Prevent duplicate sends
}
