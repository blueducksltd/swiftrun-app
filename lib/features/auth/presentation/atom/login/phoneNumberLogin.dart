// // ignore_for_file: file_names
// import 'dart:developer';
//
// import 'package:country_picker/country_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:swiftrun/common/styles/style.dart';
// import 'package:swiftrun/common/utils/extension.dart';
// import 'package:swiftrun/common/utils/size.dart';
// import 'package:swiftrun/common/widgets/customTextfield.dart';
// import 'package:swiftrun/common/widgets/custom_botton.dart';
// import 'package:swiftrun/common/widgets/inputFormater.dart';
// import 'package:swiftrun/features/auth/presentation/controller.dart';
//
// class PhoneNumberLoginScreen extends StatefulWidget {
//   const PhoneNumberLoginScreen({super.key});
//
//   @override
//   State<PhoneNumberLoginScreen> createState() => _PhoneNumberLoginScreenState();
// }
//
// class _PhoneNumberLoginScreenState extends State<PhoneNumberLoginScreen> {
//   late FocusNode _phoneNumber;
//
//   @override
//   void initState() {
//     super.initState();
//     _phoneNumber = FocusNode();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _phoneNumber.dispose();
//   }
//
//   String flag = '\u{1F1F3}\u{1F1EC}';
//   final authController = Get.put(AuthenticationController());
//   @override
//   Widget build(BuildContext context) {
//     var authstate = authController.authState;
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               100.verticalSpace,
//               Image.asset("assets/images/swiftrunlogo.png"),
//               Spacer(),
//               ...[
//                 Text(
//                   "Enter your Phone Number",
//                   style: Theme.of(context).textTheme.headlineMedium,
//                 ),
//                 Text(
//                   "Enter your phone number to receive a pin \ncode to sign up",
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyMedium!
//                       .copyWith(fontWeight: FontWeight.normal),
//                 ),
//               ].separate(10),
//               10.verticalSpace,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       showCountryPicker(
//                         context: context,
//                         showPhoneCode: true,
//                         // favorite: ['NG', '234'],
//                         countryListTheme: const CountryListThemeData(
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                           ),
//                         ),
//                         onSelect: (Country value) {
//                           debugPrint(value.countryCode.toString());
//                           log(value.phoneCode.toString());
//                           log(value.flagEmoji.toString());
//
//                           authstate.countryCode.value = "+${value.phoneCode}";
//                           flag = value.flagEmoji.toString();
//                           setState(() {});
//                         },
//                       );
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: AppColor.textFieldFill,
//                       ),
//                       child: Row(
//                         children: [
//                           Text(
//                             "$flag ",
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                           Text(
//                             authstate.countryCode.value,
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                           10.horizontalSpace,
//                           const Icon(
//                             FontAwesomeIcons.chevronDown,
//                             size: 15,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: RoundTextField(
//                       hitText: "703-214-5678",
//                       controller: authstate.phoneNumberController,
//                       inputFormater: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         NumberTextFormatter(maxLength: 10),
//                       ],
//                       keyboardType: TextInputType.phone,
//                       focusNode: _phoneNumber,
//                       onChange: (p0) {
//                         authstate.phoneNumberController.text = p0;
//                         log("${authstate.countryCode}${p0.replaceAll("-", '')}");
//                         log(authstate.phoneNumberController.text
//                             .replaceAll("-", ''));
//                       },
//                       errorText:
//                           authstate.phoneNumber.value.validatePhoneNumber(),
//                     ),
//                   )
//                 ],
//               ),
//               50.verticalSpace,
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: ButtonWidget(
//                   onTap: () {
//                     authController.loginUser();
//                   },
//                   color: AppColor.primaryColor,
//                   widget: Text(
//                     'Next',
//                     style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                           color: AppColor.whiteColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                   ),
//                 ),
//               ),
//               Spacer(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// ignore_for_file: file_names
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/widgets/inputFormater.dart';
import 'package:swiftrun/features/auth/presentation/controller.dart';
import 'package:swiftrun/common/utils/country_utils.dart';
import 'package:swiftrun/common/utils/phone_input_formatter.dart';

class PhoneNumberLoginScreen extends StatefulWidget {
  const PhoneNumberLoginScreen({super.key});

  @override
  State<PhoneNumberLoginScreen> createState() => _PhoneNumberLoginScreenState();
}

class _PhoneNumberLoginScreenState extends State<PhoneNumberLoginScreen> {
  late FocusNode _phoneNumber;

  @override
  void initState() {
    super.initState();
    _phoneNumber = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _phoneNumber.dispose();
  }

  String flag = '\u{1F1F3}\u{1F1EC}';
  final authController = Get.put(AuthenticationController());
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    var authstate = authController.authState;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                SizedBox(height: size.height * 0.06),
                // Logo
                Center(
                  child: Image.asset(
                    "assets/images/swiftrunlogo.png",
                    height: size.width * 0.2,
                    width: size.width * 0.2,
                  ),
                ),
                SizedBox(height: size.height * 0.05),
                // Title
                Text(
                  "Sign in to your account",
                  style: TextStyle(
                    fontSize: size.width * 0.065,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                      Text(
                  "Enter your phone number to continue",
                  style: TextStyle(
                    fontSize: size.width * 0.038,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                // Phone Number Label
                      Text(
                  "Phone Number",
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                      ),
                SizedBox(height: size.height * 0.012),
                // Phone input with country code
                    Row(
                      children: [
                    // Country code picker
                    GestureDetector(
                      onTap: () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode: true,
                          countryListTheme: CountryListThemeData(
                            borderRadius: BorderRadius.circular(12),
                              ),
                              onSelect: (Country value) {
                                authstate.countryCode.value = "+${value.phoneCode}";
                                authstate.countryName.value = value.name;
                                flag = value.flagEmoji.toString();
                                setState(() {});
                              },
                            );
                          },
                          child: Container(
                        height: size.height * 0.065,
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                            decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                            Text(flag, style: TextStyle(fontSize: size.width * 0.05)),
                            SizedBox(width: size.width * 0.01),
                                Text(
                                  authstate.countryCode.value,
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                color: Colors.black87,
                              ),
                                ),
                            SizedBox(width: size.width * 0.01),
                            Icon(Icons.arrow_drop_down, size: size.width * 0.05),
                              ],
                            ),
                          ),
                        ),
                    SizedBox(width: size.width * 0.03),
                    // Phone number field
                        Expanded(
                          child: Obx(() {
                            final countryCode = authstate.countryCode.value;
                            final countryConfig = CountryUtils.getCountryConfig(
                              countryCode == '+234' ? 'NG' : 
                              countryCode == '+1' ? 'US' : 
                              countryCode == '+356' ? 'MT' : 'NG'
                            );
                            
                        return Container(
                          height: size.height * 0.065,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                              controller: authstate.phoneNumberController,
                            focusNode: _phoneNumber,
                            keyboardType: TextInputType.phone,
                            inputFormatters: countryConfig['inputFormatters'] + [
                                PhoneInputFormatter(mask: countryConfig['format']),
                              ],
                            onChanged: (p0) {
                                // Only update the reactive value with digits
                                // The formatters handle the visual formatting automatically
                                authstate.phoneNumber.value = p0.replaceAll(RegExp(r'[^\d]'), '');
                            },
                            style: TextStyle(fontSize: size.width * 0.04),
                            decoration: InputDecoration(
                              hintText: countryConfig['format'],
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04,
                                vertical: size.height * 0.02,
                              ),
                            ),
                          ),
                            );
                          }),
                    ),
                      ],
                    ),
                SizedBox(height: size.height * 0.05),
                // Sign In Button
                // Sign In Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: _agreedToTerms 
                        ? () => authController.loginUser()
                        : () => _showTermsReminder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _agreedToTerms 
                          ? AppColor.primaryColor 
                          : Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                        color: _agreedToTerms 
                            ? Colors.white 
                            : Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                SizedBox(height: size.height * 0.025),
                // Footer with checkbox
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreedToTerms = !_agreedToTerms;
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          color: _agreedToTerms 
                              ? AppColor.primaryColor 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: _agreedToTerms 
                                ? AppColor.primaryColor 
                                : Colors.grey[400]!,
                            width: 1.5,
                          ),
                        ),
                        child: _agreedToTerms
                            ? Icon(
                                Icons.check,
                                size: 14.sp,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      SizedBox(width: 10.w),
                      // Text
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: "I agree to the ",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => _showTermsAndPolicySheet(context, 0),
                                  child: Text(
                                    "Terms",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: " & ",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => _showTermsAndPolicySheet(context, 1),
                  child: Text(
                                    "Privacy Policy",
                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                ),
                        ),
                      ),
                    ],
              ),
                ),
                SizedBox(height: size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  OverlayEntry? _reminderOverlay;

  void _showTermsReminder(BuildContext context) {
    // Remove existing overlay if any
    _reminderOverlay?.remove();
    
    _reminderOverlay = OverlayEntry(
      builder: (context) => _TermsReminderOverlay(
        onDismiss: () {
          _reminderOverlay?.remove();
          _reminderOverlay = null;
        },
      ),
    );

    Overlay.of(context).insert(_reminderOverlay!);
  }

  void _showTermsAndPolicySheet(BuildContext context, int initialTab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TermsAndPolicySheet(initialTab: initialTab),
    );
  }
}

class _TermsReminderOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const _TermsReminderOverlay({required this.onDismiss});

  @override
  State<_TermsReminderOverlay> createState() => _TermsReminderOverlayState();
}

class _TermsReminderOverlayState extends State<_TermsReminderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Auto dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      _dismiss();
    });
  }

  void _dismiss() async {
    if (mounted) {
      await _controller.reverse();
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.98),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.touch_app_outlined,
                            color: AppColor.primaryColor,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'One more step',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Please agree to our Terms & Privacy Policy',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
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
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsAndPolicySheet extends StatefulWidget {
  final int initialTab;
  
  const _TermsAndPolicySheet({required this.initialTab});

  @override
  State<_TermsAndPolicySheet> createState() => _TermsAndPolicySheetState();
}

class _TermsAndPolicySheetState extends State<_TermsAndPolicySheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          
          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              padding: EdgeInsets.all(4.w),
              tabs: const [
                Tab(text: "Terms & Conditions"),
                Tab(text: "Privacy Policy"),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTermsContent(),
                _buildPrivacyContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTermsSection(
            icon: Icons.location_on_outlined,
            title: "1. Real-Time Tracking",
            content: "Users consent to shipments being monitored using GPS. Tracking includes driver location, route monitoring, and delivery logs.",
          ),
          _buildTermsSection(
            icon: Icons.person_outline,
            title: "2. User Responsibilities",
            content: "Provide accurate pickup/delivery information. Ensure packages are properly packaged. Comply with all laws regarding prohibited items.",
          ),
          _buildTermsSection(
            icon: Icons.block_outlined,
            title: "3. Prohibited Items",
            content: "Users must not ship: weapons, illegal drugs, explosives, flammable materials, or stolen goods.",
            isWarning: true,
          ),
          _buildTermsSection(
            icon: Icons.local_shipping_outlined,
            title: "4. Delivery Expectations",
            content: "Delivery timelines may vary due to traffic or safety factors. Someone must be available to receive the package.",
          ),
          _buildTermsSection(
            icon: Icons.payment_outlined,
            title: "5. Payments & Fees",
            content: "Payment via cards, wallets, or approved channels. Failed payments may lead to service suspension.",
          ),
          _buildTermsSection(
            icon: Icons.cancel_outlined,
            title: "6. Cancellations & Refunds",
            content: "Cancel prior to driver pickup. Refund eligibility depends on delivery progress. Completed deliveries cannot be refunded.",
          ),
          _buildTermsSection(
            icon: Icons.gavel_outlined,
            title: "7. Governing Law",
            content: "These Terms are governed by the laws of the Federal Republic of Nigeria.",
          ),
          _buildContactCard(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTermsSection(
            icon: Icons.folder_outlined,
            title: "1. Data We Collect",
            content: "Personal identification (name, phone, email), logistics data (locations, package info), payment data, and location/GPS data.",
          ),
          _buildTermsSection(
            icon: Icons.camera_alt_outlined,
            title: "2. Device Permissions",
            content: "Camera access for photos, photo library for uploads, location services for tracking, and push notifications for updates.",
          ),
          _buildTermsSection(
            icon: Icons.analytics_outlined,
            title: "3. How We Use Data",
            content: "To enable delivery, provide real-time tracking, fraud prevention, notifications, and app improvement. We do NOT sell personal data.",
            isHighlight: true,
          ),
          _buildTermsSection(
            icon: Icons.share_outlined,
            title: "4. Data Sharing",
            content: "Shared with delivery partners, technology vendors (maps, payments), and law enforcement when required.",
          ),
          _buildTermsSection(
            icon: Icons.lock_outlined,
            title: "5. Data Security",
            content: "Protected using encryption, access controls, and security audits.",
          ),
          _buildTermsSection(
            icon: Icons.verified_user_outlined,
            title: "6. Your Rights",
            content: "Access, correct, or delete your data. Object to processing. Withdraw consent. Request data portability.",
          ),
          _buildContactCard(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildTermsSection({
    required IconData icon,
    required String title,
    required String content,
    bool isWarning = false,
    bool isHighlight = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isWarning 
            ? Colors.red.withOpacity(0.05)
            : isHighlight
                ? Colors.green.withOpacity(0.05)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isWarning 
              ? Colors.red.withOpacity(0.2)
              : isHighlight
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: isWarning 
                      ? Colors.red.withOpacity(0.1)
                      : isHighlight
                          ? Colors.green.withOpacity(0.1)
                          : AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 16.sp,
                  color: isWarning 
                      ? Colors.red
                      : isHighlight
                          ? Colors.green
                          : AppColor.primaryColor,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isWarning ? Colors.red[700] : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor,
            AppColor.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.support_agent,
            color: Colors.white,
            size: 28.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Need Help?",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "support@swiftrunapp.com",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}