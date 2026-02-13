import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/date.dart';
import 'package:swiftrun/features/messages/model/msgcontent.dart';

Widget rightRichText(String textContent, BuildContext context) {
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
              style: Theme.of(context).textTheme.bodyMedium),
        );
      }
      return '';
    },
    onNonMatch: (String text) {
      if (text.isNotEmpty) {
        widgets.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColor.whiteColor,
            ),
          ),
        );
      }
      return '';
    },
  );
  return RichText(
    text: TextSpan(children: [...widgets]),
  );
}

Widget chatRightItem(Msgcontent item, BuildContext context) {
  return Container(
    padding: EdgeInsets.only(top: 10.w, left: 20.w, right: 20.w, bottom: 10.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: 250.w, //
                minHeight: 40.w //
                ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 0.w, top: 0.w),
                  padding: EdgeInsets.only(
                      top: 10.w, bottom: 10.w, left: 10.w, right: 10.w),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.w),
                      topLeft: Radius.circular(10.w),
                      topRight: Radius.circular(10.w),
                    ),
                  ),
                  child: item.receiverID == "text"
                      ? rightRichText("${item.content}", context)
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 90.w, //
                          ),
                          child: GestureDetector(
                            child:
                                CachedNetworkImage(imageUrl: "${item.content}"),
                            onTap: () {
                              // Get.toNamed(AppRoutes.Photoimgview,parameters: {"url": item.content??""});
                            },
                          )),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.h),
                  child: Text(
                    item.addtime == null
                        ? ""
                        : duTimeLineFormat(
                            (item.addtime as Timestamp).toDate()),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: 12.sp),
                  ),
                )
              ],
            )),
      ],
    ),
  );
}
