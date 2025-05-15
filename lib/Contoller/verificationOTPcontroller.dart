// import 'dart:async';
// import 'dart:developer';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:my_finance1/View/transactiongetx.dart';

// class PhoneAuthController extends GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   RxString verificationId = ''.obs;
//   RxBool isCodeSent = false.obs;
//   RxInt resendToken = 0.obs;
//   RxString countryCode = '+91'.obs;
//   RxString phoneNumber = ''.obs;
//   Timer? _resendTimer;

//   // Controllers for OTP input fields
//   final List<TextEditingController> otpControllers = List.generate(
//     6,
//     (_) => TextEditingController(),
//   );

//   // Focus nodes for OTP input fields
//   final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

//   // Observable OTP digits array
//   final otpDigits = List<String>.filled(6, '').obs;

//   // Loading states
//   final isVerifying = false.obs;
//   final canResend = false.obs;
//   final resendCountdown = 30.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     // Initialize with resend disabled and start countdown
//     startResendTimer();
//   }

//   @override
//   void onClose() {
//     // Clean up controllers and focus nodes
//     for (var controller in otpControllers) {
//       controller.dispose();
//     }
//     for (var node in focusNodes) {
//       node.dispose();
//     }
//     _resendTimer?.cancel();
//     super.onClose();
//   }

//   void sendOTP() {
//     FirebaseAuth.instance.verifyPhoneNumber(
//       verificationCompleted: (PhoneAuthCredential credential) {},
//       verificationFailed: (FirebaseAuthException ex) {},
//       codeSent: (String verificationId1, int? resendToken) {
//         verificationId.value = verificationId1;
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         log('Auto retrieval timeout');
//       },
//       phoneNumber: phoneNumber.value,
//     );
//     log(phoneNumber.value);
//   }

//   // Initialize verification process for a new phone number
//   Future<void> initPhoneVerification(
//     String phoneNumber, {
//     bool isResend = false,
//   }) async {
//     try {
//       final fullPhoneNumber = '$countryCode$phoneNumber';
//       log('Initiating verification for $fullPhoneNumber');

//       isVerifying.value = true;

//       await _auth.verifyPhoneNumber(
//         phoneNumber: fullPhoneNumber,
//         timeout: const Duration(seconds: 60),
//         forceResendingToken: isResend ? resendToken.value : null,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           log('Auto verification completed');
//           await _signInWithCredential(credential);
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           log('Verification failed: ${e.message}');
//           Get.snackbar(
//             'Verification Failed',
//             e.message ?? 'An error occurred during verification',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             duration: const Duration(seconds: 5),
//           );
//           isVerifying.value = false;
//         },
//         codeSent: (String vId, int? token) {
//           log('Verification code sent. Token: $token');
//           verificationId.value = vId;
//           if (token != null) resendToken.value = token;
//           isCodeSent.value = true;
//           isVerifying.value = false;

//           if (!isResend) {
//             // Only show this message on initial send, not resend
//             Get.snackbar(
//               'Code Sent',
//               'Verification code sent to $fullPhoneNumber',
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: Colors.green,
//               colorText: Colors.white,
//             );
//           }

//           // Start the resend timer
//           startResendTimer();
//         },
//         codeAutoRetrievalTimeout: (String vId) {
//           log('Auto retrieval timeout');
//           verificationId.value = vId;
//         },
//       );
//     } catch (e) {
//       log('Error in phone verification: $e');
//       isVerifying.value = false;
//       Get.snackbar(
//         'Error',
//         'Failed to send verification code: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // Update OTP digit at specified index
//   void updateOtpDigit(int index, String value) {
//     otpDigits[index] = value;
//     update(); // Trigger UI update
//   }

//   // Start countdown timer for OTP resend
//   void startResendTimer() {
//     canResend.value = false;
//     resendCountdown.value = 30;

//     // Cancel existing timer if any
//     _resendTimer?.cancel();

//     _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (resendCountdown.value > 0) {
//         resendCountdown.value--;
//       } else {
//         canResend.value = true;
//         timer.cancel();
//       }
//     });
//   }

//   // Verify entered OTP
//   Future<void> verifyOTP(String smsCode) async {
//     if (verificationId.value.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Verification ID is missing. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     try {
//       isVerifying.value = true;

//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: verificationId.value,
//         smsCode: smsCode,
//       );

//       await _signInWithCredential(credential);
//     } catch (e) {
//       log('OTP verification failed: $e');
//       isVerifying.value = false;
//       Get.snackbar(
//         'Invalid Code',
//         'The verification code entered is invalid. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // Sign in with phone credential
//   Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
//     try {
//       final userCredential = await _auth.signInWithCredential(credential);
//       isVerifying.value = false;

//       if (userCredential.user != null) {
//         Get.offAll(() => Transaction()); // Navigate and remove previous screens
//         Get.snackbar(
//           'Success',
//           'Phone number verified successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       isVerifying.value = false;
//       log('Sign in failed: $e');
//       Get.snackbar(
//         'Authentication Failed',
//         'Failed to verify your identity. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // Resend OTP
//   Future<void> resendOTP(String phoneNumber) async {
//     if (!canResend.value) return;

//     Get.snackbar(
//       'Resending',
//       'Sending a new verification code...',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//     );

//     // Clear existing OTP fields
//     for (var controller in otpControllers) {
//       controller.clear();
//     }
//     otpDigits.value = List<String>.filled(6, '');

//     // Set focus to first field
//     if (focusNodes.isNotEmpty) {
//       focusNodes[0].requestFocus();
//     }

//     // Resend verification code
//     await initPhoneVerification(phoneNumber, isResend: true);
//   }
// }
