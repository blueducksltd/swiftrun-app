import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/customTextfield.dart';
import 'package:swiftrun/common/widgets/custom_botton.dart';
import 'package:swiftrun/features/rating/controller.dart';
import 'package:swiftrun/common/routes/route_name.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final RatingController ratingController = Get.put(RatingController());

  @override
  Widget build(BuildContext context) {
    var ratingState = ratingController.ratingState;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rate Driver"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mainPaddingWidth,
              vertical: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text(
                "Rate Driver",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "How was your experience?",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.disabledColor,
                ),
              ),
              ...[
                Center(
                  child: RatingBar.builder(
                    initialRating: ratingState.initialRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemSize: 50,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        ratingState.initialRating = rating;
                      });
                      print('⭐ User selected rating: $rating');
                    },
                  ),
                ),
                // Show selected rating
                if (ratingState.initialRating > 0)
                  Text(
                    "${ratingState.initialRating.toStringAsFixed(0)} Star${ratingState.initialRating > 1 ? 's' : ''}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    "Tap to select your rating",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                RoundTextField(
                  maxLine: 8,
                  keyboardType: TextInputType.multiline,
                  controller: ratingState.commentController,
                  hitText: "Leave a comment",
                ),
                ButtonWidget(
                  onTap: () => ratingController.rateDriver(),
                  color: AppColor.primaryColor,
                  widget: Text(
                    "Submit",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColor.whiteColor),
                  ),
                ),
              ].separate(25)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
