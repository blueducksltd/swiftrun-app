import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/routes/route.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/extension.dart';
import 'package:swiftrun/common/utils/size.dart';
import 'package:swiftrun/common/widgets/widgets.dart';
import 'package:swiftrun/features/auth/presentation/controller.dart';
import 'package:swiftrun/features/auth/presentation/state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final authController = Get.put(AuthenticationController());
  bool _agreedToTerms = false;
  OverlayEntry? _reminderOverlay;

  @override
  Widget build(BuildContext context) {
    var authstate = authController.authState;

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 20.h,
              ),
              child: Column(
                children: [
                   50.verticalSpace,
                  // Logo Section
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/swiftrunlogo.png',
                        height: 70.h,
                        width: 70.h,
                      ),
                    ),
                  ),
                  40.verticalSpace,
                  
                  // Main Card
                  Container(
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back",
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        8.verticalSpace,
                        Text(
                          "Sign in to continue your journey",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        30.verticalSpace,
                        Form(
                          key: authstate.loginFormKey,
                          child: Column(
                            children: [
                              RoundTextField(
                                hitText: "Email Address",
                                controller: authstate.emailController,
                                icon: Icon(Icons.email_outlined, size: 20.sp, color: Colors.grey[600]),
                                validator: (p0) {
                                  if (!p0!.emailValidation || p0.isEmpty) {
                                    return "Please enter a valid email address";
                                  }
                                  return null;
                                },
                              ),
                              RoundTextField(
                                hitText: "Password",
                                obscureText: authstate.isObsecure.value,
                                controller: authstate.passwordController,
                                icon: Icon(Icons.lock_outline, size: 20.sp, color: Colors.grey[600]),
                                validator: (p0) {
                                  if (p0!.isEmpty) {
                                    return "Please enter your password";
                                  }
                                  return null;
                                },
                                rigtIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      authstate.isObsecure.value = !authstate.isObsecure.value;
                                    });
                                  },
                                  icon: Icon(
                                    authstate.isObsecure.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ].separate(16),
                          ),
                        ),
                        16.verticalSpace,
                        Row(
                          children: [
                            Obx(
                              () => GestureDetector(
                                onTap: () {
                                  authstate.isRememberMeSelected.value =
                                      !authstate.isRememberMeSelected.value;
                                },
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 20.w,
                                      height: 20.w,
                                      decoration: BoxDecoration(
                                        color: authstate.isRememberMeSelected.value 
                                            ? AppColor.primaryColor 
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6.r),
                                        border: Border.all(
                                          color: authstate.isRememberMeSelected.value 
                                              ? AppColor.primaryColor 
                                              : Colors.grey[400]!,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: authstate.isRememberMeSelected.value
                                          ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                                          : null,
                                    ),
                                    8.horizontalSpace,
                                    Text(
                                      "Remember me",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                authController.forgotPassword();
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: AppColor.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                ),
                              ),
                            )
                          ],
                        ),
                        30.verticalSpace,
                        ButtonWidget(
                          onTap: () {
                            if (_agreedToTerms) {
                              if (authstate.loginFormKey.currentState!.validate()) {
                                authController.login();
                              }
                            } else {
                              _showTermsReminder(context);
                            }
                          },
                          color: _agreedToTerms ? AppColor.primaryColor : Colors.grey[300]!,
                          widget: Text(
                            "Login",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: _agreedToTerms ? Colors.white : Colors.grey[500],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  30.verticalSpace,
                  
                  // Terms Checkbox
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreedToTerms = !_agreedToTerms;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 18.w,
                            height: 18.w,
                            decoration: BoxDecoration(
                              color: _agreedToTerms ? AppColor.primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(5.r),
                              border: Border.all(
                                color: _agreedToTerms ? AppColor.primaryColor : Colors.grey[500]!,
                                width: 1.5,
                              ),
                            ),
                            child: _agreedToTerms
                                ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                                : null,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: "I agree to the ",
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], height: 1.4),
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () => _showTermsAndPolicySheet(context, 0),
                                    child: Text(
                                      "Terms",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColor.primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: " & ",
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () => _showTermsAndPolicySheet(context, 1),
                                    child: Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColor.primaryColor,
                                        fontWeight: FontWeight.w700,
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
                  
                  30.verticalSpace,
                  
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.register),
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  20.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTermsReminder(BuildContext context) {
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

class _TermsReminderOverlayState extends State<_TermsReminderOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 200),
        vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2500), () => _dismiss());
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
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                      border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
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
                          child: Icon(Icons.touch_app_outlined, color: AppColor.primaryColor, size: 22.sp),
                        ),
                        SizedBox(width: 14.w),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('One more step', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                              SizedBox(height: 2.h),
                              Text('Please agree to our Terms & Privacy Policy', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
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
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(height: 16.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12.r)),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(color: AppColor.primaryColor, borderRadius: BorderRadius.circular(10.r)),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              padding: EdgeInsets.all(4.w),
              tabs: const [Tab(text: "Terms & Conditions"), Tab(text: "Privacy Policy")],
            ),
          ),
          SizedBox(height: 16.h),
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
          _buildTermsSection(icon: Icons.location_on_outlined, title: "1. Real-Time Tracking", content: "Users consent to shipments being monitored using GPS. Tracking includes driver location, route monitoring, and delivery logs."),
          _buildTermsSection(icon: Icons.person_outline, title: "2. User Responsibilities", content: "Provide accurate pickup/delivery information. Ensure packages are properly packaged. Comply with all laws regarding prohibited items."),
          _buildTermsSection(icon: Icons.block_outlined, title: "3. Prohibited Items", content: "Users must not ship: weapons, illegal drugs, explosives, flammable materials, or stolen goods.", isWarning: true),
          _buildTermsSection(icon: Icons.local_shipping_outlined, title: "4. Delivery Expectations", content: "Delivery timelines may vary due to traffic or safety factors. Someone must be available to receive the package."),
          _buildTermsSection(icon: Icons.payment_outlined, title: "5. Payments & Fees", content: "Payment via cards, wallets, or approved channels. Failed payments may lead to service suspension."),
          _buildTermsSection(icon: Icons.cancel_outlined, title: "6. Cancellations & Refunds", content: "Cancel prior to driver pickup. Refund eligibility depends on delivery progress. Completed deliveries cannot be refunded."),
          _buildTermsSection(icon: Icons.gavel_outlined, title: "7. Governing Law", content: "These Terms are governed by the laws of the Federal Republic of Nigeria."),
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
          _buildTermsSection(icon: Icons.folder_outlined, title: "1. Data We Collect", content: "Personal identification (name, phone, email), logistics data (locations, package info), payment data, and location/GPS data."),
          _buildTermsSection(icon: Icons.camera_alt_outlined, title: "2. Device Permissions", content: "Camera access for photos, photo library for uploads, location services for tracking, and push notifications for updates."),
          _buildTermsSection(icon: Icons.analytics_outlined, title: "3. How We Use Data", content: "To enable delivery, provide real-time tracking, fraud prevention, notifications, and app improvement. We do NOT sell personal data.", isHighlight: true),
          _buildTermsSection(icon: Icons.share_outlined, title: "4. Data Sharing", content: "Shared with delivery partners, technology vendors (maps, payments), and law enforcement when required."),
          _buildTermsSection(icon: Icons.lock_outlined, title: "5. Data Security", content: "Protected using encryption, access controls, and security audits."),
          _buildTermsSection(icon: Icons.verified_user_outlined, title: "6. Your Rights", content: "Access, correct, or delete your data. Object to processing. Withdraw consent. Request data portability."),
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
        color: isWarning ? Colors.red.withOpacity(0.05) : isHighlight ? Colors.green.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isWarning ? Colors.red.withOpacity(0.2) : isHighlight ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(color: isWarning ? Colors.red.withOpacity(0.1) : isHighlight ? Colors.green.withOpacity(0.1) : AppColor.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
                child: Icon(icon, size: 16.sp, color: isWarning ? Colors.red : isHighlight ? Colors.green : AppColor.primaryColor),
              ),
              SizedBox(width: 10.w),
              Expanded(child: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: isWarning ? Colors.red[700] : Colors.black87))),
            ],
          ),
          SizedBox(height: 10.h),
          Text(content, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColor.primaryColor, AppColor.primaryColor.withOpacity(0.8)]), borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          Icon(Icons.support_agent, color: Colors.white, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Need Help?", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                SizedBox(height: 2.h),
                Text("support@swiftrunapp.com", style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
