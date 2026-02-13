import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/customArrowBack.dart';
import 'package:swiftrun/features/messages/presentation/faq.dart';
import 'package:swiftrun/features/messages/presentation/send_message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String? _whatsappNumber;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWhatsAppSettings();
  }

  Future<void> _loadWhatsAppSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('AppSettings')
          .doc('general')
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _whatsappNumber = doc.data()!['whatsappHelpline'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error loading WhatsApp settings: $e');
    }
  }

  Future<void> _openWhatsApp() async {
    if (_whatsappNumber == null || _whatsappNumber!.isEmpty) {
      Get.snackbar(
        'Error',
        'WhatsApp support is not available right now. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Remove all non-numeric characters (including +)
      // WhatsApp URLs need only digits, no + sign
      final cleanNumber = _whatsappNumber!.replaceAll(RegExp(r'[^\d]'), '');

      if (cleanNumber.isEmpty) {
        throw Exception('Invalid phone number format');
      }

      // Try multiple WhatsApp URL formats for better compatibility
      final whatsappWebUrl = Uri.parse('https://wa.me/$cleanNumber');
      final whatsappAppUrl = Uri.parse('whatsapp://send?phone=$cleanNumber');

      bool launched = false;

      // First try: WhatsApp app scheme (works if app is installed)
      try {
        launched = await launchUrl(
          whatsappAppUrl,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('WhatsApp app scheme failed: $e');
      }

      // Fallback: WhatsApp web URL (opens in browser if app not installed)
      if (!launched) {
        try {
          launched = await launchUrl(
            whatsappWebUrl,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          debugPrint('WhatsApp web URL failed: $e');
        }
      }

      if (!launched) {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      debugPrint('WhatsApp launch error: $e');
      Get.snackbar(
        'Error',
        'Could not open WhatsApp. Please make sure WhatsApp is installed on your device.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  const CustomArrowBack(),
                  20.horizontalSpace,
                  Text(
                    "Help",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
              20.verticalSpace,
              Text(
                "No answer to your question? Ask our customer care",
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(fontSize: 25),
              ),
              20.verticalSpace,
              // Enhanced help options in cards
              _buildHelpCard(
                context,
                icon: "assets/icons/help.svg",
                title: "Visit our help section",
                subtitle: "FAQ & HELP",
                onTap: () => Get.to(() => const FaqScreen()),
              ),
              16.verticalSpace,
              _buildHelpCard(
                context,
                icon: "assets/icons/messageIcon.svg",
                title: "Chat with an agent",
                subtitle: _isLoading ? "OPENING..." : "START CHAT",
                onTap: _isLoading ? () {} : _openWhatsApp,
                isLoading: _isLoading,
              ),
              16.verticalSpace,
              _buildHelpCard(
                context,
                icon: "assets/icons/chatIcon.svg",
                title: "Send message to our agent",
                subtitle: "SEND MESSAGE",
                onTap: () => Get.to(() => const SendMessageScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      icon,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
                16.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      4.verticalSpace,
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                isLoading
                    ? SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16.sp,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
