import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:swiftrun/features/messages/model/msgcontent.dart';
import 'package:swiftrun/features/messages/index.dart';
import 'package:swiftrun/global/global.dart';

class MessageController extends GetxController {
  var messageState = MessageState();
  final currentUser = firebaseAuth.currentUser;

  @override
  void onInit() {
    var driverInfo = Get.arguments;
    messageState.driverInfo.value = driverInfo["driverInfo"];

    log(messageState.driverInfo.value.firstName.toString());
    var ids = [messageState.driverInfo.value.driversId!, currentUser!.uid];

    ids.sort();
    String callID = ids.join('_');
    messageState.ids = callID;
    log("CallID: ${messageState.ids}");
    super.onInit();
  }

//Send Message
  sendChat() async {
    // Prevent duplicate sends
    if (messageState.isSending.value) {
      return;
    }

    final content = messageState.messageController.text.trim();

    if (content.isEmpty) {
      return;
    }

    // Set sending flag and clear input immediately (optimistic update)
    messageState.isSending.value = true;
    messageState.messageController.clear();

    // Prepare message data
    Msgcontent newNessage = Msgcontent(
      senderID: currentUser!.uid,
      receiverID: messageState.driverInfo.value.driversId,
      content: content,
      addtime: Timestamp.now(), // Create fresh timestamp for each message
    );

    List<String> ids = [
      currentUser!.uid,
      messageState.driverInfo.value.driversId!
    ];

    ids.sort();
    String chatID = ids.join('_');

    // Send message asynchronously without blocking UI
    // Use a timeout to ensure isSending is always reset
    fDataBase
        .collection("ChatMessages")
        .doc(chatID)
        .collection("messages")
        .add(newNessage.toFirestore())
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            log("⏰ Message send timeout");
            throw TimeoutException("Message send timeout", const Duration(seconds: 10));
          },
        )
        .then((_) {
      // Message sent successfully
      log("✅ Message sent successfully");
      messageState.isSending.value = false;
    }).catchError((error) {
      // Handle error - always reset sending flag
      log("❌ Error sending message: $error");
      messageState.isSending.value = false;
      // Optionally restore the message text
      // messageState.messageController.text = content;
    });
    
    // Safety net: Reset sending flag after a maximum delay
    // This ensures the button never stays stuck in loading state
    Future.delayed(const Duration(seconds: 12), () {
      if (messageState.isSending.value) {
        log("⚠️ Force resetting isSending flag (safety net)");
        messageState.isSending.value = false;
      }
    });
  }

  // Get Message

  Stream<QuerySnapshot> getMessage() {
    List<String> ids = [
      currentUser!.uid,
      messageState.driverInfo.value.driversId!
    ];

    ids.sort();
    String chatID = ids.join('_');

    // CollectionReference messages = fDataBase.collection("chatMessages");

    return fDataBase
        .collection("ChatMessages")
        .doc(chatID)
        .collection("messages")
        .orderBy("addtime", descending: false)
        .snapshots();
  }
}
