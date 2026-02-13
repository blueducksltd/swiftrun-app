import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/date.dart';

class ChatBubble extends StatelessWidget {
  final String content;
  final Timestamp timeStamp;
  final bool isCurrentUser;

  const ChatBubble(
      {super.key,
      required this.content,
      required this.timeStamp,
      required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5.w, left: 0.w, right: 0.w, bottom: 0.w),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 250.w, minHeight: 25.w),
              child: Column(
                mainAxisAlignment: isCurrentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 0.w, top: 0.w),
                    padding: EdgeInsets.only(
                        top: 5.w, bottom: 5.w, left: 5.w, right: 5.w),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? AppColor.balanceBox.withValues(alpha: 0.5)
                          : AppColor.bgColor,
                      borderRadius: isCurrentUser
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(10.w),
                              topLeft: Radius.circular(10.w),
                              topRight: Radius.circular(10.w),
                            )
                          : BorderRadius.only(
                              bottomRight: Radius.circular(10.w),
                              topLeft: Radius.circular(10.w),
                              topRight: Radius.circular(10.w),
                            ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: content,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 0.h),
                    child: Text(
                      duTimeLineFormat((timeStamp).toDate()),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: 10),
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
