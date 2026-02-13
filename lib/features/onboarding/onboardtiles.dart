import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiftrun/common/styles/style.dart';

class OnboardingTiles extends StatelessWidget {
  final String imagePath, mainText, subText;
  const OnboardingTiles({
    super.key,
    required this.imagePath,
    required this.mainText,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return SizedBox(
      //height: screen.height,
      width: screen.width,
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            color: Colors.black54.withValues(alpha: 0.5),
            filterQuality: FilterQuality.high,
            colorBlendMode: BlendMode.darken,
          ),
          Positioned(
            bottom: 180.h,
            left: 10.w,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: AppColor.whiteColor),
                  ),
                  5.verticalSpace,
                  Text(
                    subText,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColor.whiteColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
