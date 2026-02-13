import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/utils/date.dart';

Widget leftRichTextContainer(String textContent, BuildContext context) {
  const urlPattern =
      r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+-~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&\/\/=]*)";
  List<InlineSpan> widgets = [];

  textContent.splitMapJoin(
    RegExp(urlPattern, caseSensitive: false, multiLine: false),
    onMatch: (Match match) {
      final matchText = match[0];
      if (matchText != null) {
        widgets.add(
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Uri url = Uri.parse(matchText);
                launchUrl(url);
              },
            text: matchText,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColor.whiteColor,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      }
      return '';
    },
    onNonMatch: (String text) {
      if (text.isNotEmpty) {
        widgets.add(
          TextSpan(text: text, style: Theme.of(context).textTheme.bodyMedium),
        );
      }
      return '';
    },
  );

  return RichText(
    text: TextSpan(children: [...widgets]),
  );
}

Widget chatLeftItem(String item, Timestamp addTime, BuildContext context) {
  return Container(
    padding: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w, bottom: 10.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: 250.w, //
              minHeight: 40.w //
              ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.only(left: 0.w, top: 0.w),
                    padding: EdgeInsets.only(
                        top: 10.w, bottom: 10.w, left: 10.w, right: 10.w),
                    decoration: BoxDecoration(
                      color: AppColor.disabledColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10.w),
                        topLeft: Radius.circular(10.w),
                        topRight: Radius.circular(10.w),
                      ),
                    ),
                    child:
                        //  item.receiverID == "text"
                        //     ?
                        leftRichTextContainer(item, context)
                    // : ConstrainedBox(
                    //     constraints: BoxConstraints(maxWidth: 90.w),
                    //     child: GestureDetector(
                    //       child:
                    //           CachedNetworkImage(imageUrl: "${item.content}"),
                    //       onTap: () {
                    //         // Get.toNamed(AppRoutes.Photoimgview,parameters: {"url": item.content??""});
                    //       },
                    //     )),
                    ),
                Container(
                  margin: EdgeInsets.only(top: 5.h),
                  child: Text(
                    duTimeLineFormat((addTime).toDate()),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: 12),
                  ),
                ),
              ]),
        ),
      ],
    ),
  );
}
