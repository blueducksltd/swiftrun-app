import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:swiftrun/common/routes/route.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'package:swiftrun/features/auth/data/model/user_model.dart';
import 'package:swiftrun/features/auth/presentation/atom/register/name.dart';
import 'package:swiftrun/features/auth/presentation/atom/register/phoneNumber.dart';
import 'package:swiftrun/features/auth/presentation/atom/register/setup_password.dart';
import 'package:swiftrun/features/auth/presentation/atom/register/verification.dart';
import 'package:swiftrun/features/auth/presentation/state.dart';
import 'package:swiftrun/features/landingpage.dart';
import 'package:swiftrun/global/global.dart';
import 'package:swiftrun/services/network/network_utils.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;

class AuthenticationController extends GetxController {
  AuthenticationController();
  static AuthenticationController get to => Get.find();

  var authState = AuthenticationState();

  User? currentUser = firebaseAuth.currentUser;

  @override
  void onInit() {
    super.onInit();
    authState.onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Get.back();
      };
    authState.errorController = StreamController<ErrorAnimationType>();
  }

  validate() async {
    if (authState.firstNameController.text.trim().isEmpty ||
        authState.lastNameController.text.trim().isEmpty ||
        authState.emailController.text.trim().isEmpty) {
      errorMethod("Fill all the fields");
    } else if (!authState.emailController.text.emailValidation) {
      errorMethod('Please enter a vaild email');
    } else {
      Get.to(() => const PhoneNumberScreen());
    }
  }

  Future<void> login() async {
    ProgressDialogUtils.showProgressDialog();
    try {
      await firebaseAuth
          .signInWithEmailAndPassword(
        email: authState.emailController.text.trim(),
        password: authState.passwordController.text.trim(),
      )
          .then((value) async {
        currentUser = value.user;
        if (currentUser != null) {
          final userDoc = await fDataBase
              .collection("Customers")
              .doc(currentUser!.uid)
              .get();

          if (userDoc.exists) {
            final userData =
                UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
            SessionController.to.saveProfileData(userData);

            await _createUserSession(currentUser!);

            notifyHelper.getDeviceToken();
            onUserLogin();
            await SessionController.to.checkNotificationPermissions();

            ProgressDialogUtils.hideProgressDialog();
            Get.offAllNamed(AppRoutes.dashboard);
          } else {
            // Check if user is a driver
            final driverDoc =
                await fDataBase.collection("Drivers").doc(currentUser!.uid).get();
            if (driverDoc.exists) {
              await firebaseAuth.signOut();
              ProgressDialogUtils.hideProgressDialog();
              errorMethod("This account is registered as a Driver.");
            } else {
              await firebaseAuth.signOut();
              ProgressDialogUtils.hideProgressDialog();
              errorMethod("User record not found. Please register.");
            }
          }
        }
      });
    } on FirebaseAuthException catch (errorCode) {
      ProgressDialogUtils.hideProgressDialog();
      errorMethod(errorCode.message.toString());
    } catch (e) {
      ProgressDialogUtils.hideProgressDialog();
      errorMethod(e.toString());
    }
  }

  Future<void> forgotPassword() async {
    if (authState.emailController.text.isEmpty ||
        !authState.emailController.text.emailValidation) {
      errorMethod("Please enter a valid email address");
      return;
    }
    ProgressDialogUtils.showProgressDialog();
    try {
      await firebaseAuth.sendPasswordResetEmail(
        email: authState.emailController.text.trim(),
      );
      ProgressDialogUtils.hideProgressDialog();
      Get.snackbar(
        "Success",
        "Password reset link has been sent to your email",
        backgroundColor: AppColor.primaryColor,
        colorText: AppColor.whiteColor,
      );
    } on FirebaseAuthException catch (e) {
      ProgressDialogUtils.hideProgressDialog();
      errorMethod(e.message ?? "An error occurred");
    } catch (e) {
      ProgressDialogUtils.hideProgressDialog();
      errorMethod(e.toString());
    }
  }

  Future<void> completeRegistration() async {
    ProgressDialogUtils.showProgressDialog();
    try {
      await firebaseAuth
          .createUserWithEmailAndPassword(
        email: authState.emailController.text.trim(),
        password: authState.passwordController.text.trim(),
      )
          .then((value) {
        currentUser = value.user;
      });

      if (currentUser != null) {
        var userData = UserModel(
          userID: currentUser!.uid,
          email: authState.emailController.text.trim(),
          firstName: authState.firstNameController.text.trim(),
          lastName: authState.lastNameController.text.trim(),
          phoneNumber:
              "${authState.countryCode.value}${authState.phoneNumberController.text.replaceAll("-", "").replaceAll(' ', '')}",
          userType: "Customer",
          dateCreated: Timestamp.now(),
          countryCode: authState.countryCode.value,
          countryName: authState.countryName.value,
        );

        await fDataBase
            .collection("Customers")
            .doc(currentUser!.uid)
            .set(userData.toJson());

        SessionController.to.saveProfileData(userData);
        await _createUserSession(currentUser!);
        notifyHelper.getDeviceToken();
        onUserLogin();
        await SessionController.to.checkNotificationPermissions();

        ProgressDialogUtils.hideProgressDialog();
        Get.offAllNamed(AppRoutes.setProfilePic);
      }
    } on FirebaseAuthException catch (errorCode) {
      ProgressDialogUtils.hideProgressDialog();
      errorMethod(errorCode.message.toString());
    } catch (e) {
      ProgressDialogUtils.hideProgressDialog();
      errorMethod(e.toString());
    }
  }

  // createAccount() async {
  //   ProgressDialogUtils.showProgressDialog();

  //   bool ishasNetwork = await NetworkUtils.hasNetwork();
  //   try {
  //     if (!ishasNetwork) {
  //       return;
  //     }
  //     String phoneNumber =
  //         "${authState.countryCode.value}${authState.phoneNumberController.text.replaceAll("-", "").removeAllWhitespace}";

  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('Customers')
  //         .where('phoneNumber', isEqualTo: phoneNumber)
  //         .get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       ProgressDialogUtils.hideProgressDialog();
  //       log('User Already Exist');
  //       log("${querySnapshot.docs.length}");
  //       return errorMethod('User Already Exist');
  //     } else {
  //       log("${querySnapshot.docs.toList()}");
  //       log(phoneNumber);
  //       log("Here Checking");
  //       ProgressDialogUtils.hideProgressDialog();
  //       await firebaseAuth.verifyPhoneNumber(
  //         phoneNumber: phoneNumber,
  //         verificationCompleted: (phoneAuthCredential) {
  //           log(phoneAuthCredential.toString());
  //         },
  //         verificationFailed: (error) {
  //           ProgressDialogUtils.hideProgressDialog();
  //           log(error.toString());
  //         },
  //         codeSent: (verificationId, forceResendingToken) {
  //           authState.verificationID.value = verificationId;
  //           ProgressDialogUtils.hideProgressDialog();
  //           Get.to(
  //             () => VerificationScreen(
  //               phoneNumber: authState.phoneNumberController.text,
  //             ),
  //           );
  //         },
  //         codeAutoRetrievalTimeout: (verificationId) {},
  //       );
  //     }
  //   } catch (e) {
  //     ProgressDialogUtils.hideProgressDialog();
  //     throw Exception(e);
  //   }
  // }

  Future<void> verifyOTP({
    required String otpCode,
    verficationId,
    phoneNumber,
  }) async {
    ProgressDialogUtils.showProgressDialog();
    Logger.i("Verification Here");
    // var phoneNumber =
    //     "${authState.countryCode.value}${authState.phoneNumberController.text.replaceAll("-", "").removeAllWhitespace}";
    try {
      bool hasNetwork = await NetworkUtils.hasNetwork();
      if (!hasNetwork) {
        ProgressDialogUtils.hideProgressDialog();
        errorMethod('No network connection.');
        return;
      }

      if (verficationId == null) {
        ProgressDialogUtils.hideProgressDialog();
        Logger.i("Verification ID $verficationId.");
        Logger.i("Verification ${authState.verificationID.value}.");
        errorMethod('Verification ID is not available.');
        return;
      }

      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verficationId,
        smsCode: otpCode,
      );

      log("Signing in with credential...");
      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      User? currentUser = userCredential.user;

      if (currentUser != null) {
        log("User phone number: $phoneNumber");

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Customers')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .get();

        Logger.i("phoneNumber $phoneNumber");

        if (querySnapshot.docs.isEmpty) {
          ProgressDialogUtils.hideProgressDialog();
          log("No user found. Redirecting to registration.");
          Logger.i("phoneNumber $phoneNumber");
          Logger.i("phoneNumber ${querySnapshot.docs.length}");
          Get.to(() => const RegisterName());
        } else {
          // FIXED: Direct session tracking for login too
          // Get user data from Firestore for session tracking
          final userDoc = await fDataBase.collection("Customers").doc(currentUser.uid).get();
          if (userDoc.exists) {
            final userData = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
            SessionController.to.saveProfileData(userData);
          }

          // Create session in Firestore for admin tracking
          await _createUserSession(currentUser);

          notifyHelper.getDeviceToken();
          onUserLogin();
          
          // Check and request notification permissions after login
          await SessionController.to.checkNotificationPermissions();
          
          ProgressDialogUtils.hideProgressDialog();
          Get.offAllNamed(AppRoutes.dashboard);
          log("User logged in successfully.");
        }
      } else {
        ProgressDialogUtils.hideProgressDialog();
        errorMethod('User authentication failed.');
      }
    } on FirebaseAuthException catch (error) {
      ProgressDialogUtils.hideProgressDialog();
      log("FirebaseAuthException: ${error.code} - ${error.message}");
      if (error.code == 'invalid-verification-code') {
        errorMethod('Invalid OTP code.');
      } else {
        errorMethod(error.message ?? 'An unknown error occurred.');
      }
    } catch (e) {
      ProgressDialogUtils.hideProgressDialog();
      log("Error verifying OTP: $e");
      errorMethod(e.toString());
    }
  }

  /// Creates a session document in Firestore for admin monitoring
  Future<void> _createUserSession(User user) async {
    try {
      String deviceSessionId = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
      
      await fDataBase.collection('UserSessions').doc(deviceSessionId).set({
        'userId': user.uid,
        'userType': 'customer',
        'userName': user.displayName ?? '',
        'userEmail': user.email ?? '',
        'phoneNumber': user.phoneNumber ?? '',
        'deviceId': deviceSessionId,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'loginTime': Timestamp.now(),
        'lastActive': Timestamp.now(),
        'isActive': true,
      });
      
      log("✅ Customer session created: $deviceSessionId");
    } catch (e) {
      log("❌ Error creating customer session: $e");
    }
  }

  static void onUserLogin() async {
    // ZegoUIKit calling functionality removed - using phone app calls instead
  }

  Future<void> loginUser() async {
    bool ishasNetwork = await NetworkUtils.hasNetwork();
    try {
      if (!ishasNetwork) {
        return;
      }

      // Get the full phone number with country code
      final fullPhoneNumber = '${authState.countryCode.value}${authState.phoneNumber.value}';
      
      if (authState.phoneNumberController.text.isEmpty ||
          fullPhoneNumber.length < 10) {
        errorMethod('Please enter a valid phone number.');
        ProgressDialogUtils.hideProgressDialog();
        return;
      }
      String phoneNumber =
          "${authState.countryCode.value}${authState.phoneNumberController.text.replaceAll("-", "").replaceAll(' ', '')}";
      ProgressDialogUtils.showProgressDialog();

      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) {},
        verificationFailed: (error) {
          ProgressDialogUtils.hideProgressDialog();
          Logger.error(error.toString());

          errorMethod(
              'Verification failed. Please try again. \n Error: ${error.message}');
        },
        codeSent: (verificationId, forceResendingToken) {
          authState.verificationID.value = verificationId;
          ProgressDialogUtils.hideProgressDialog();
          Logger.i("Verification ID: ${authState.verificationID.value}");
          Get.to(
            () => VerificationScreen(
              phoneNumber: phoneNumber,
              verficationId: authState.verificationID.value,
            ),
          );
          Logger.i("Verification $phoneNumber");
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      ProgressDialogUtils.hideProgressDialog();
      Get.snackbar('Error', 'Login failed. Please try again.');
    }
  }

  Future<bool> checkIfNewUser(String uid) async {
    final docSnapshot = await fDataBase.collection("Customers").doc(uid).get();
    log(docSnapshot.toString());
    return !docSnapshot.exists;
  }

  useCamera() async {
    // final cameraPermissionStatus = await Permission.camera.request();
    // if (cameraPermissionStatus.isGranted) {
    await authState.imagePicker.pickImage(source: ImageSource.camera).then(
      (value) {
        if (value != null) {
          authState.pickedImageXfile.value = XFile(value.path);
        } else {
          authState.pickedImageXfile.value = null;
        }
      },
    );
    // }
  }

  useGallery() async {
    // final cameraPermissionStatus = await Permission.storage.request();
    // if (cameraPermissionStatus.isGranted) {
    await authState.imagePicker.pickImage(source: ImageSource.gallery).then(
      (value) {
        if (value != null) {
          authState.pickedImageXfile.value = XFile(value.path);
        } else {
          authState.pickedImageXfile.value = null;
        }
      },
    );
    // }
  }

  uploadUserProfile() async {
    ProgressDialogUtils.showProgressDialog();
    String userID = firebaseAuth.currentUser!.uid.toString();
    bool ishasNetwork = await NetworkUtils.hasNetwork();

    if (!ishasNetwork) {
      ProgressDialogUtils.hideProgressDialog();
      errorMethod("No network connection.");
      return;
    }
    if (authState.pickedImageXfile.value == null) {
      ProgressDialogUtils.hideProgressDialog();
      errorMethod("Please add your image.");
      return;
    }

    final file = File(authState.pickedImageXfile.value!.path);
    if (!file.existsSync()) {
      ProgressDialogUtils.hideProgressDialog();
      errorMethod("Selected file does not exist.");
      return;
    }

    try {
      fstorage.Reference reference = fstorage.FirebaseStorage.instance
          .ref()
          .child("vlogx/customers")
          .child(userID);

      fstorage.UploadTask uploadTask = reference.putFile(file);
      fstorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      await SessionController.to.updatedProfilePic(imageUrl);
      await fDataBase
          .collection("Customers")
          .doc(userID)
          .update({'profilePix': imageUrl});

      ProgressDialogUtils.hideProgressDialog();
      Get.offNamed(AppRoutes.dashboard);
    } catch (error, sk) {
      ProgressDialogUtils.hideProgressDialog();
      Logger.error(error.toString(), stackTrace: sk);
      errorMethod("Error: $error");
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) {
        errorMethod("No user logged in");
        return;
      }

      final String userId = currentUser!.uid;
      
      ProgressDialogUtils.showProgressDialog();

      // 1. Delete user data from Firestore (Customers collection)
      try {
        await fDataBase.collection("Customers").doc(userId).delete();
        log("✅ User data deleted from Firestore");
      } catch (e) {
        log("⚠️ Error deleting user data from Firestore: $e");
      }

      // 2. Delete profile picture from Firebase Storage
      try {
        final storageRef = fstorage.FirebaseStorage.instance
            .ref()
            .child("Customers/$userId/profile_picture");
        await storageRef.delete();
        log("✅ Profile picture deleted from Storage");
      } catch (e) {
        log("⚠️ Error deleting profile picture (may not exist): $e");
      }

      // 3. Clear local session data
      try {
        SessionController.to.signOutWithoutNavigation();
        log("✅ Local session cleared");
      } catch (e) {
        log("⚠️ Error clearing local session: $e");
      }

      // 4. Delete Firebase Auth account LAST
        await currentUser!.delete();
      log("✅ Firebase Auth account deleted");

      ProgressDialogUtils.hideProgressDialog();
      
      Get.snackbar(
        "Account Deleted",
        "Your account has been permanently deleted",
        snackPosition: SnackPosition.BOTTOM,
      );
        Get.offAll(() => const LandingPage());
      
    } on FirebaseAuthException catch (errorCode) {
      ProgressDialogUtils.hideProgressDialog();
      switch (errorCode.code) {
        case "requires-recent-login":
          errorMethod(
              "For security, please sign out and sign back in, then try again.");
          break;
        case "user-not-found":
          errorMethod("User not found");
          break;
        default:
          errorMethod("An unexpected error occurred: ${errorCode.message}");
      }
    } catch (e) {
      ProgressDialogUtils.hideProgressDialog();
      log("Delete account error: $e");
      errorMethod("Failed to delete account. Please try again.");
    }
  }
}
