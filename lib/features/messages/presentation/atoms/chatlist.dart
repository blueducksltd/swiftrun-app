import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:swiftrun/features/messages/model/msgcontent.dart';
import 'package:swiftrun/features/messages/index.dart';
import 'package:swiftrun/features/messages/presentation/atoms/chat_right.dart';

class ChatList extends GetView<MessageController> {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    var data = [
      Msgcontent(
        addtime: Timestamp.now(),
        content: "Hello",
        receiverID: "123",
        senderID: "qwerty",
      ),
      Msgcontent(
        addtime: Timestamp.now(),
        content: "Hi",
        receiverID: "qwerty",
        senderID: "123",
      ),
      Msgcontent(
        addtime: Timestamp.now(),
        content: "Great",
        receiverID: "123",
        senderID: "qwerty",
      ),
      Msgcontent(
        addtime: Timestamp.now(),
        content: "Greater ",
        receiverID: "qwerty",
        senderID: "123",
      ),
    ];
    // bool isSender = true;
    return Container(
      padding: EdgeInsets.only(bottom: 70.h, top: 60.h),
      child: CustomScrollView(
        controller: ScrollController(),
        reverse: true,
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.symmetric(
              vertical: 0.w,
              horizontal: 0.w,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var item = data[index];
                  if (item.senderID == item.senderID) {
                    return chatRightItem(item, context);
                  }
                  return null;
                  //return chatLeftItem(item, addTime, context);
                },
                childCount: data.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
