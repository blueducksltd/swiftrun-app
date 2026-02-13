import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/textfieldwithcontainer.dart';
import 'package:swiftrun/common/widgets/widgets.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'package:swiftrun/global/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() {
    final userData = SessionController.to.userData;
    _nameController.text = '${userData.firstName ?? ''} ${userData.lastName ?? ''}'.trim();
    _emailController.text = userData.email ?? '';
  }

  Future<void> _sendMessage() async {
    if (_nameController.text.trim().isEmpty) {
      errorMethod("Please enter your name");
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      errorMethod("Please enter your email");
      return;
    }
    if (_messageController.text.trim().isEmpty) {
      errorMethod("Please enter your message");
      return;
    }
    if (!GetUtils.isEmail(_emailController.text.trim())) {
      errorMethod("Please enter a valid email");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = SessionController.to.userData;
      
      // Create message data
      Map<String, dynamic> messageData = {
        'customerID': userData.userID,
        'customerName': _nameController.text.trim(),
        'customerEmail': _emailController.text.trim(),
        'message': _messageController.text.trim(),
        'dateCreated': Timestamp.now(),
      };

      // Save to CustomerMessages collection
      await fDataBase
          .collection('CustomerMessages')
          .add(messageData);

      // Clear form
      _messageController.clear();
      
      // Show success message
      Get.snackbar(
        'Message Sent!',
        'Thank you for contacting us. We\'ll get back to you within 24 hours.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
        borderRadius: 8.r,
        duration: const Duration(seconds: 4),
        icon: const Icon(
          Icons.check_circle,
          color: Colors.white,
        ),
        onTap: (snack) {
          Get.closeCurrentSnackbar();
          Get.back();
        },
      );

    } catch (e) {
      errorMethod("Failed to send message. Please try again.");
      print("Error sending message: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth),
          child: Column(
            children: [
              Row(
                children: [
                  const CustomArrowBack(),
                  20.horizontalSpace,
                  Text(
                    "Send a message",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
              20.verticalSpace,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          "Send your message, we will get back to you shortly"),
                       TextFieldWIthContainer(
                           title: 'Name:', 
                           hint: "Enter your name",
                           controller: _nameController,
                       ),
                       TextFieldWIthContainer(
                         title: 'Email Address:',
                         hint: "Enter your email",
                         controller: _emailController,
                       ),
                      15.verticalSpace,
                      Text(
                        'Message',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: AppColor.disabledColor),
                      ),
                      6.verticalSpace,
                       TextField(
                         controller: _messageController,
                         maxLines: 10,
                         minLines: 5,
                         decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                           filled: true,
                           fillColor: AppColor.textFieldFill,
                           hintText: "Describe your issue or question...",
                           hintStyle:
                               Theme.of(context).textTheme.bodyMedium!.copyWith(
                                     color: AppColor.disabledColor
                                         .withValues(alpha: 0.7),
                                     fontWeight: FontWeight.normal,
                                   ),
                        ),
                      ),
                      15.verticalSpace,
                      ButtonWidget(
                        onTap: _isLoading ? () {} : () => _sendMessage(),
                        color: _isLoading ? Colors.grey : AppColor.primaryColor,
                        widget: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  8.horizontalSpace,
                                  Text(
                                    "Sending...",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(color: AppColor.whiteColor),
                                  ),
                                ],
                              )
                            : Text(
                                "Send Message",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: AppColor.whiteColor),
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
