import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swiftrun/common/constants/location_msg.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/core/controller/session_controller.dart';

class EditProfilePictureScreen extends StatefulWidget {
  const EditProfilePictureScreen({super.key});

  @override
  State<EditProfilePictureScreen> createState() => _EditProfilePictureScreenState();
}

class _EditProfilePictureScreenState extends State<EditProfilePictureScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploading = false;
  String? _currentProfilePic;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfilePic();
  }

  void _loadCurrentProfilePic() {
    final sessionController = Get.find<SessionController>();
    _currentProfilePic = sessionController.userData.profilePix;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Try to pick image directly - image_picker handles permissions internally
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      // If permission is denied, show our custom dialog
      if (e.toString().contains('permission') || e.toString().contains('denied')) {
        _showPermissionDialog(
          source == ImageSource.camera 
            ? 'Camera permission is required to take photos.'
            : 'Photo library permission is required to select images.',
          source,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to pick image: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _showPermissionDialog(String message, ImageSource source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Permission Required',
          style: TextStyle(
            color: AppColor.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: AppColor.blackColor,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColor.disabledColor,
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // Try requesting permission again
              await _requestPermissionAgain(source);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text(
              'Open Settings',
              style: TextStyle(
                color: AppColor.primaryColor,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissionAgain(ImageSource source) async {
    try {
      // Try to pick image again - this will trigger the system permission dialog
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      } else {
        Get.snackbar(
          'Permission Denied',
          'Please grant permission to continue.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to access ${source == ImageSource.camera ? 'camera' : 'gallery'}: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('vlogx/customers/${user.uid}_${DateTime.now().millisecondsSinceEpoch}');
      
      final uploadTask = await ref.putFile(File(_selectedImage!.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update user document in Firestore
      await FirebaseFirestore.instance
          .collection('Customers')
          .doc(user.uid)
          .update({'profilePix': downloadUrl});

      // Update local session data immediately using the proper method
      final sessionController = Get.find<SessionController>();
      await sessionController.updatedProfilePic(downloadUrl);

      // Show success dialog with better feedback
      _showSuccessDialog();
      
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      
      Get.snackbar(
        'Error',
        'Failed to update profile picture: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'Success!',
              style: TextStyle(
                color: AppColor.blackColor,
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        content: Text(
          'Your profile picture has been updated successfully!',
          style: TextStyle(
            color: AppColor.blackColor,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to profile page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColor.blackColor,
            size: 20.sp,
          ),
        ),
        title: Text(
          'Edit Profile Picture',
          style: TextStyle(
            color: AppColor.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // Current Profile Picture
              Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.primaryColor.withOpacity(0.3),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.r),
                  child: _selectedImage != null
                      ? Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: _currentProfilePic ?? ConstantStrings.defaultAvater,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColor.primaryColor,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColor.primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: AppColor.primaryColor,
                              size: 80.sp,
                            ),
                          ),
                        ),
                ),
              ),

              SizedBox(height: 32.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.camera_alt,
                      title: 'Take Photo',
                      subtitle: 'Use camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.photo_library,
                      title: 'Choose from Gallery',
                      subtitle: 'Select existing photo',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Upload Button
              if (_selectedImage != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadProfilePicture,
                    icon: _isUploading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.upload, color: Colors.white),
                    label: Text(
                      _isUploading ? 'Uploading...' : 'Update Profile Picture',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isUploading 
                          ? AppColor.primaryColor.withOpacity(0.7)
                          : AppColor.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColor.disabledColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Help Text
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
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
                        'For best results, use a square image with good lighting.',
                        style: TextStyle(
                          color: AppColor.primaryColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
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
            child: Column(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: AppColor.primaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColor.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColor.disabledColor,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
