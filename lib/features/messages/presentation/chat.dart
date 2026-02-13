import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swiftrun/common/constants/location_msg.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/customArrowBack.dart';
import 'package:swiftrun/features/messages/index.dart';
import 'package:swiftrun/features/messages/presentation/atoms/chat_bubble.dart';
import 'package:swiftrun/global/global.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final MessageController chatController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Get controller only once during initialization
    chatController = Get.put(MessageController());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth),
          child: Column(
            children: [
              // Header - Separated to prevent rebuilds
              _ChatHeader(messageState: chatController.messageState),
              
              SizedBox(height: 15.h),
              
              // Messages list - takes remaining space
              Expanded(
                child: _messageList(),
              ),
              
              SizedBox(height: 10.h),
              
              // Input field - Separated to prevent rebuilds
              _ChatInput(
                messageState: chatController.messageState,
                onSend: () => chatController.sendChat(),
              ),
              
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatController.getMessage(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          errorMethod("An error occured while loading chats");
          return const Center(child: Text("An Error Occured"));
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              height: screenWidth(context, percent: .2).w,
              width: screenWidth(context, percent: .2).w,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColor.blackColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CircularProgressIndicator(
                color: AppColor.whiteColor,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No messages yet",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        // Use ListView.builder for better performance
        final messages = snapshot.data!.docs.reversed.toList();
        
        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          itemCount: messages.length,
          // Add cache extent to reduce rebuilds
          cacheExtent: 1000,
          itemBuilder: (context, index) {
            return _buildMessageItem(messages[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot value) {
    Map<String, dynamic> data = value.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == firebaseAuth.currentUser!.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    
    return Container(
      key: ValueKey(value.id), // Add unique key to prevent rebuilds
      alignment: alignment,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ChatBubble(
        content: data['content'],
        timeStamp: data['addtime'],
        isCurrentUser: isCurrentUser,
      ),
    );
  }

}

// Separate Header Widget to prevent rebuilds
class _ChatHeader extends StatelessWidget {
  final MessageState messageState;

  const _ChatHeader({required this.messageState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Row(
          children: [
            const CustomArrowBack(),
            const Spacer(),
            Text(
              "${messageState.driverInfo.value.firstName!} ${messageState.driverInfo.value.lastName!}",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            CachedNetworkImage(
              imageUrl: messageState.driverInfo.value.picturePath ??
                  ConstantStrings.defaultAvater,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300]!,
                  radius: 20.r,
                ),
              ),
              imageBuilder: (context, image) => CircleAvatar(
                backgroundImage: image,
                radius: 20.r,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Separate Input Widget to prevent rebuilds
class _ChatInput extends StatelessWidget {
  final MessageState messageState;
  final VoidCallback onSend;

  const _ChatInput({
    required this.messageState,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.textFieldFill,
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: messageState.messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (value) {
                  // Send on Enter key press (controller handles duplicate prevention)
                  if (value.trim().isNotEmpty) {
                    onSend();
                  }
                },
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.normal, // Explicitly set normal weight
                  color: AppColor.blackColor,
                ),
                decoration: InputDecoration(
                  filled: false,
                  fillColor: AppColor.whiteColor,
                  hintText: "Chat driver..",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 12.h,
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  hintStyle: TextStyle(
                    color: AppColor.disabledColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Obx(() => GestureDetector(
            onTap: () {
              // Prevent sending if already sending or input is empty
              if (!messageState.isSending.value && 
                  messageState.messageController.text.trim().isNotEmpty) {
                onSend();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: messageState.isSending.value 
                    ? AppColor.disabledColor 
                    : AppColor.primaryColor,
              ),
              width: 50.w,
              height: 50.w,
              child: messageState.isSending.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.whiteColor,
                      ),
                    )
                  : Icon(
                      Icons.send,
                      color: AppColor.whiteColor,
                      size: 20.sp,
                    ),
            ),
          ))
        ],
      ),
    );
  }
}
