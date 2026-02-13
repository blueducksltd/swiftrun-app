import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Hero Section
                    _buildHeroSection(context),
                    
                    // Terms Content
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          _buildIntroCard(context),
                          
                          _buildSection(
                            context,
                            number: "1",
                            icon: Icons.location_on_outlined,
                            title: "Real-Time Tracking Notice",
                            content: "Users consent to their shipments being monitored using GPS and related tracking technologies. Tracking may include:",
                            bulletPoints: [
                              "Driver GPS location",
                              "Route monitoring",
                              "Timestamps and delivery logs",
                            ],
                            additionalContent: "Tracking is visible to: Sender, Recipient, and Swiftrun operations team. This enhances safety, delivery accuracy, and dispute resolution.",
                          ),
                          
                          _buildSection(
                            context,
                            number: "2",
                            icon: Icons.person_outline,
                            title: "User Responsibilities",
                            content: null,
                            bulletPoints: [
                              "Provide accurate pickup and delivery information.",
                              "Ensure packages are properly packaged and safe to transport.",
                              "Comply with all laws regarding prohibited or restricted items.",
                              "Treat Swiftrun drivers, partners, and personnel respectfully.",
                            ],
                          ),
                          
                          _buildSection(
                            context,
                            number: "3",
                            icon: Icons.block_outlined,
                            title: "Prohibited Items",
                            content: "Users must not ship dangerous, illegal, or hazardous items, including but not limited to:",
                            bulletPoints: [
                              "Weapons or ammunition",
                              "Illegal drugs or controlled substances",
                              "Explosives or flammable materials",
                              "Stolen goods",
                            ],
                            isWarning: true,
                          ),
                          
                          _buildSection(
                            context,
                            number: "4",
                            icon: Icons.local_shipping_outlined,
                            title: "Delivery & Service Expectations",
                            content: "Swiftrun aims to provide timely and secure deliveries. However:",
                            bulletPoints: [
                              "Delivery timelines may vary due to traffic or safety factors.",
                              "Users must ensure someone is available to receive the package.",
                              "Additional verification may be required for sensitive items.",
                            ],
                          ),
                          
                          _buildSection(
                            context,
                            number: "5",
                            icon: Icons.payment_outlined,
                            title: "Payments & Fees",
                            content: "Users agree to pay all service charges as displayed in the app.",
                            bulletPoints: [
                              "Payment may be made via cards, wallets, or approved channels.",
                              "Failed or reversed payments may lead to service suspension.",
                              "Card details are processed securely by third-party payment providers.",
                            ],
                          ),
                          
                          _buildSection(
                            context,
                            number: "6",
                            icon: Icons.warning_amber_outlined,
                            title: "Liability & Limitations",
                            content: "Swiftrun is not responsible for losses resulting from incorrect user-provided delivery information, unpermitted items, or factors outside operational control (such as accidents, theft, or weather).",
                          ),
                          
                          _buildSection(
                            context,
                            number: "7",
                            icon: Icons.cancel_outlined,
                            title: "Cancellations & Refunds",
                            content: null,
                            bulletPoints: [
                              "Users may cancel prior to driver pickup.",
                              "Refund eligibility depends on delivery progress and expenses incurred.",
                              "Completed or in-progress deliveries cannot be refunded.",
                            ],
                          ),
                          
                          _buildSection(
                            context,
                            number: "8",
                            icon: Icons.security_outlined,
                            title: "Indemnity",
                            content: "Users assume responsibility for package contents and accuracy of delivery details. Swiftrun is not liable for damages caused by prohibited items or misleading declarations.",
                          ),
                          
                          _buildSection(
                            context,
                            number: "9",
                            icon: Icons.edit_note_outlined,
                            title: "Modifications to Terms",
                            content: "Swiftrun may update these Terms periodically. Continued use of the platform constitutes acceptance of the updated Terms.",
                          ),
                          
                          _buildSection(
                            context,
                            number: "10",
                            icon: Icons.gavel_outlined,
                            title: "Governing Law",
                            content: "These Terms are governed by the laws of the Federal Republic of Nigeria. Unless stated otherwise, Lagos State courts have jurisdiction over disputes.",
                          ),
                          
                          // Contact Section
                          _buildContactSection(context),
                          
                          // Acceptance Card
                          _buildAcceptanceCard(context),
                          
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColor.primaryColor,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            "Terms & Conditions",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColor.blackColor,
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6B46C1),
            const Color(0xFF805AD5),
            const Color(0xFF9F7AEA),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B46C1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 30.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "Terms of Service",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "These Terms govern your use of the Swiftrun App and logistics services. By accessing our platform, you agree to all terms outlined below.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              "Effective: December 2025",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColor.primaryColor,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "Please read these terms carefully before using our services.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.primaryColor,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String number,
    required IconData icon,
    required String title,
    String? content,
    List<String>? bulletPoints,
    String? additionalContent,
    bool isWarning = false,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isWarning
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isWarning
                      ? Colors.red.withOpacity(0.1)
                      : const Color(0xFF6B46C1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isWarning ? Colors.red : const Color(0xFF6B46C1),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: isWarning
                      ? Colors.red.withOpacity(0.1)
                      : AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: isWarning ? Colors.red : AppColor.primaryColor,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isWarning ? Colors.red[700] : AppColor.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (content != null)
            Text(
              content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
                fontSize: 13.sp,
                height: 1.6,
              ),
            ),
          if (bulletPoints != null) ...[
            if (content != null) SizedBox(height: 10.h),
            ...bulletPoints.map((point) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6.h),
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: isWarning ? Colors.red : const Color(0xFF6B46C1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      point,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                        fontSize: 13.sp,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (additionalContent != null) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                additionalContent,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.contact_support_outlined,
            color: Colors.white,
            size: 32.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            "Contact Us",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 16.h),
          _buildContactItem(
            context,
            icon: Icons.email_outlined,
            text: "support@swiftrunapp.com",
          ),
          SizedBox(height: 10.h),
          _buildContactItem(
            context,
            icon: Icons.phone_outlined,
            text: "+234 916 706 6539",
          ),
          SizedBox(height: 10.h),
          _buildContactItem(
            context,
            icon: Icons.location_on_outlined,
            text: "No. 10 Ajali Crescent, Independence Layout, Enugu, Nigeria",
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: 18.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green[700],
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "By using Swiftrun, you acknowledge that you have read and agree to these Terms & Conditions.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.green[700],
                fontSize: 12.sp,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

