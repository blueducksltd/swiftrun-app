import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                    
                    // Policy Content
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          _buildSection(
                            context,
                            icon: Icons.shield_outlined,
                            title: "Our Commitment",
                            content: "Swiftrun Logistic Limited (\"Swiftrun\") respects your privacy and is committed to safeguarding your personal data in compliance with the Nigeria Data Protection Regulation (NDPR) 2019 and applicable laws. By using the Swiftrun App or logistics services, you agree to this policy.",
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.folder_outlined,
                            title: "1. Types of Data We Collect",
                            content: null,
                            bulletPoints: [
                              "Personal Identification: Name, phone number, email, pickup/delivery addresses, verification data.",
                              "Logistics Data: Locations, package description, photos, timestamps, proof of delivery.",
                              "Payment Data: Billing info, transaction history (card details handled by third-party processors).",
                              "Device Data: Information collected automatically by third-party services (Firebase, Google Maps, Paystack) to provide app functionality.",
                              "Location/GPS Data: Real-time driver and shipment tracking (requires permission).",
                              "Communication Records: Calls, chats, complaints, feedback.",
                            ],
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.camera_alt_outlined,
                            title: "Device Permissions We Request",
                            content: null,
                            bulletPoints: [
                              "Camera Access: To capture profile pictures, package photos, and proof of delivery images.",
                              "Photo Library Access: To upload existing images from your device gallery.",
                              "Location Services: To provide real-time delivery tracking and accurate pickup/delivery services.",
                              "Push Notifications: To send delivery updates, status changes, and important alerts.",
                            ],
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.analytics_outlined,
                            title: "2. How We Use Your Data",
                            content: null,
                            bulletPoints: [
                              "To enable pickup, routing, and delivery.",
                              "To provide real-time tracking visibility.",
                              "Fraud prevention and security monitoring.",
                              "Notifications and customer service.",
                              "App analytics and performance improvement.",
                              "Regulatory compliance.",
                            ],
                            footer: "We do NOT sell personal data.",
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.gavel_outlined,
                            title: "3. Legal Basis for Processing",
                            content: null,
                            bulletPoints: [
                              "Performance of a contract.",
                              "Legitimate business interests.",
                              "Legal obligations.",
                              "Consent (GPS tracking, marketing).",
                            ],
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.share_outlined,
                            title: "4. Who We Share Data With",
                            content: null,
                            bulletPoints: [
                              "Delivery partners.",
                              "Technology vendors (hosting, maps, payments).",
                              "Law enforcement (when required).",
                              "Successor companies (business restructuring).",
                            ],
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.location_on_outlined,
                            title: "5. Real-Time Tracking & Monitoring",
                            content: null,
                            bulletPoints: [
                              "Shipments are monitored with GPS until completed.",
                              "Drivers must keep GPS active during delivery.",
                              "Tracking supports safety, proof of delivery, and dispute resolution.",
                            ],
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.photo_camera_outlined,
                            title: "6. Camera & Photo Permissions",
                            content: null,
                            bulletPoints: [
                              "We request camera access to capture package photos and proof of delivery.",
                              "We request photo library access to allow you to upload images from your gallery.",
                              "Photos are used solely for delivery verification and dispute resolution.",
                            ],
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.lock_outlined,
                            title: "7. Data Security",
                            content: "Your data is protected using encryption, access controls, and security audits. No system is 100% secure, but we employ industry-standard measures to protect your information.",
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.timer_outlined,
                            title: "8. Data Retention",
                            content: "Data is kept only as long as needed for delivery, legal compliance, and disputes. Tracking data may later be anonymized.",
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.verified_user_outlined,
                            title: "9. Your Rights",
                            content: "You have the right to:",
                            bulletPoints: [
                              "Access your data.",
                              "Request correction or deletion.",
                              "Object to processing.",
                              "Withdraw consent.",
                              "Request data portability.",
                            ],
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.child_care_outlined,
                            title: "10. Children",
                            content: "Our services are not intended for users under 18 years old.",
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.link_outlined,
                            title: "11. External Links",
                            content: "We are not responsible for third-party privacy policies.",
                          ),
                          
                          _buildSection(
                            context,
                            icon: Icons.update_outlined,
                            title: "12. Updates",
                            content: "We may update this Policy anytime. Continued use means acceptance.",
                          ),
                          
                          // Contact Section
                          _buildContactSection(context),
                          
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
            "Privacy Policy",
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
            AppColor.primaryColor,
            AppColor.primaryColor.withOpacity(0.8),
            const Color(0xFF4A90E2),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
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
              Icons.privacy_tip_outlined,
              color: Colors.white,
              size: 30.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "Your Privacy Matters",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "We are committed to protecting your personal information and being transparent about how we use it.",
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
              "Last Updated: December 2025",
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

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? content,
    List<String>? bulletPoints,
    String? footer,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: AppColor.primaryColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColor.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
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
            if (content != null) SizedBox(height: 8.h),
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
                      color: AppColor.primaryColor,
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
          if (footer != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[700],
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    footer,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
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
}

