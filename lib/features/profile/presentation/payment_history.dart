import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/features/profile/controller.dart';

class PaymentHistory extends StatelessWidget {
  const PaymentHistory({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header with Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.primaryColor,
                    AppColor.primaryColor.withOpacity(0.8),
                    const Color(0xFF4A90E2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          "Payment History",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Track all your delivery payments",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                future: profileController.fetchPaymentHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  final groupedPayments = snapshot.data!;

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: groupedPayments.keys.length,
                    itemBuilder: (context, index) {
                      String monthYear = groupedPayments.keys.elementAt(index);
                      List<Map<String, dynamic>> payments = groupedPayments[monthYear]!;

                      return _buildMonthSection(context, monthYear, payments, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 90.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 64.sp,
              color: AppColor.primaryColor.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "No Payment History",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColor.disabledColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Your payment history will appear here",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColor.disabledColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(BuildContext context, String monthYear, List<Map<String, dynamic>> payments, int index) {
    // Calculate total for the month
    double monthTotal = 0;
    for (var payment in payments) {
      monthTotal += double.tryParse(payment['deliveryAmount'] ?? '0') ?? 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Header
        Container(
          margin: EdgeInsets.only(bottom: 12.h, top: index == 0 ? 0 : 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.primaryColor.withOpacity(0.1),
                AppColor.primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: AppColor.primaryColor,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        monthYear,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryColor,
                          fontSize: 16.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${payments.length} transaction${payments.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Payment Tiles
        ...payments.map((payment) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: PaymentTile(
              imageSent: payment['imageSent'] ?? '',
              paymentMethod: payment['paymentMethod'] ?? 'Unknown',
              amount: payment['deliveryAmount'] ?? '0',
              dateTime: (payment['dateCreated'] as Timestamp).toDate(),
            ),
          );
        }),

        // Month Total
        Container(
          margin: EdgeInsets.only(bottom: 20.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics,
                      color: const Color(0xFF10B981),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        "Total for $monthYear",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${"NGN".getCurrencySymbol()} ${monthTotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                  fontFamily: "NotoSans",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PaymentTile extends StatelessWidget {
  final String paymentMethod;
  final String amount;
  final DateTime dateTime;
  final String imageSent;

  const PaymentTile({
    super.key,
    required this.paymentMethod,
    required this.amount,
    required this.dateTime,
    required this.imageSent,
  });

  // Get payment method display info
  Map<String, dynamic> _getPaymentMethodInfo() {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return {
          'title': 'Cash Payment',
          'subtitle': 'Cash on Delivery',
          'icon': Icons.money,
          'color': const Color(0xFF10B981),
        };
      case 'wallet':
        return {
          'title': 'Wallet Payment',
          'subtitle': 'Wallet Transaction',
          'icon': Icons.account_balance_wallet,
          'color': const Color(0xFF8B5CF6),
        };
      case 'card':
        return {
          'title': 'Card Payment',
          'subtitle': 'Card Transaction',
          'icon': Icons.credit_card,
          'color': const Color(0xFF3B82F6),
        };
      case 'bank':
      case 'bank_transfer':
      case 'transfer':
        return {
          'title': 'Bank Transfer',
          'subtitle': 'Bank Transfer Payment',
          'icon': Icons.account_balance,
          'color': const Color(0xFFF59E0B),
        };
      case 'bank_app':
      case 'bankapp':
        return {
          'title': 'Bank App Payment',
          'subtitle': 'Bank App Transaction',
          'icon': Icons.smartphone,
          'color': const Color(0xFFEF4444),
        };
      default:
        return {
          'title': 'Online Payment',
          'subtitle': paymentMethod.isNotEmpty ? paymentMethod : 'Digital Transaction',
          'icon': Icons.payment,
          'color': const Color(0xFF6B7280),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentInfo = _getPaymentMethodInfo();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            // Optional: Navigate to payment details
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Package Image
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: AppColor.bgColor,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: imageSent.isNotEmpty
                        ? CachedNetworkImage(
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                color: Colors.grey[300],
                              ),
                            ),
                            imageUrl: imageSent,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(
                              Icons.local_shipping,
                              color: AppColor.primaryColor.withOpacity(0.5),
                              size: 30.sp,
                            ),
                            errorListener: (value) => debugPrint(value.toString()),
                          )
                        : Icon(
                            Icons.local_shipping,
                            color: AppColor.primaryColor.withOpacity(0.5),
                            size: 30.sp,
                          ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Payment Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Delivery Payment",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            paymentInfo['icon'],
                            color: paymentInfo['color'],
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              paymentInfo['subtitle'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColor.disabledColor,
                                fontSize: 12.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppColor.disabledColor.withOpacity(0.5),
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formatDateTime(dateTime),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColor.disabledColor.withOpacity(0.7),
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '${"NGN".getCurrencySymbol()} ${double.tryParse(amount)?.toStringAsFixed(2) ?? '0.00'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: const Color(0xFF10B981),
                            fontFamily: "NotoSans",
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _formatDate(dateTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.disabledColor,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat("dd MMM").format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat("hh:mm a").format(date);
  }
}
