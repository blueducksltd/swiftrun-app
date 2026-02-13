
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RiderWidget extends StatelessWidget {
  final String name;
  final double initialRating;
  final int deliveriesDone;
  final Widget widget, icon;
  final Widget? driverImage;
  const RiderWidget({
    super.key,
    required this.name,
    required this.deliveriesDone,
    required this.initialRating,
    required this.widget,
    required this.icon,
    this.driverImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        driverImage!,
        15.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                deliveriesDone <= 1
                    ? "$deliveriesDone Delivery,"
                    : "$deliveriesDone Deliveries,",
                style:
                Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: RatingBar.builder(
                      initialRating: initialRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      ignoreGestures: true,
                      itemSize: 16,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.only(right: 1),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                    ),
                  ),
                  4.horizontalSpace,
                  Flexible(
                    child: Text(
                      initialRating == 0.0 ? 'No ratings yet' : initialRating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        8.horizontalSpace,
        widget,
        8.horizontalSpace,
        icon,
      ],
    );
  }
}