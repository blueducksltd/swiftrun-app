import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/utils/utils.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> dateStrings = [
      '2024-05-12',
      '2024-05-11',
      '2024-05-11',
      '2024-05-10',
      '2024-05-10',
      '2024-05-09',
    ];

    // Group the date strings by their respective dates
    Map<DateTime, List<String>> groupedDates = groupDates(dateStrings);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Notification",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SliverList.builder(
            // itemExtent: 250,
            itemCount: groupedDates.length,
            itemBuilder: (context, index) {
              DateTime date = groupedDates.keys.elementAt(index);
              List<String> dates = groupedDates[date] ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      formatDate(date),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      return const NotificationWidget(
                        title: "Courier Arrived",
                        message:
                            "The Courier has arrived to your \ndestination",
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<String>> groupDates(List<String> dateStrings) {
    Map<DateTime, List<String>> groupedDates = {};
    for (String dateString in dateStrings) {
      DateTime date = DateTime.parse(dateString);
      DateTime formattedDate = DateTime(date.year, date.month, date.day);
      if (groupedDates.containsKey(formattedDate)) {
        groupedDates[formattedDate]!.add(dateString);
      } else {
        groupedDates[formattedDate] = [dateString];
      }
    }
    return groupedDates;
  }
}

class NotificationWidget extends StatelessWidget {
  final String title, message;
  const NotificationWidget({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColor.primaryColor.withValues(alpha: 0.1),
              radius: 30,
              child: SvgPicture.asset(
                "assets/icons/truck.svg",
                height: 20,
                width: 20,
              ),
            ),
            15.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                ),
                Text(
                  message,
                  maxLines: 3,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColor.disabledColor),
                )
              ],
            ),
          ],
        ),
        10.verticalSpace,
        Divider(color: AppColor.disabledColor.withValues(alpha: 0.3)),
        10.verticalSpace,
      ],
    );
  }
}

String formatDate(DateTime date) {
  DateTime now = DateTime.now();
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  } else if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day - 1) {
    return 'Yesterday';
  } else {
    return '${date.day}-${_getMonthName(date.month)}-${date.year}';
  }
}

String _getMonthName(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return '';
  }
}
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text(
          //       formatDate(DateTime.now()),
          //       style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          //             fontWeight: FontWeight.w600,
          //             color: AppColor.disabledColor,
          //           ),
          //     ),
          //     20.verticalSpace,
          //     const NotificationWidget(
          //       title: "Courier Arrived",
          //       message: "The Courier has arrived to your \ndestination",
          //     ),
          //     const NotificationWidget(
          //       title: "Courier Arrived",
          //       message: "The Courier has arrived to your \ndestination",
          //     ),
          //     Text(
          //       formatDate(DateTime.now().subtract(Duration(days: 1))),
          //       style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          //             fontWeight: FontWeight.w600,
          //             color: AppColor.disabledColor,
          //           ),
          //     ),
          //   ],
          // )