import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:my_finance1/View/transactiongetx.dart';

class PhoneAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxString verificationId = ''.obs;
  RxBool isCodeSent = false.obs;
  RxInt resendToken = 0.obs;
  RxString countryCode = '+91'.obs;
  RxString phoneNumber = ''.obs;
  // In your PhoneAuthController
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  Future<void> linkPhoneNumber(String phoneNumber) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // First verify the phone number
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await user!.linkWithCredential(credential);
          log('Phone number linked automatically');
        },
        verificationFailed: (FirebaseAuthException e) {
          log('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verificationId and show SMS code input dialog
          _showSmsCodeDialog(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      log('Error linking phone number: $e');
    }
  }

  // Helper to show SMS code input dialog
  void _showSmsCodeDialog(String verificationId) {
    // Implement dialog to get SMS code from user
  }
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  final otpDigits = List<String>.filled(6, '').obs;
  final isVerifying = false.obs;
  final canResend = false.obs;
  final resendCountdown = 30.obs;

  void updateOtpDigit(int index, String value) {
    otpDigits[index] = value;
  }

  void startResendTimer() {
    canResend.value = false;
    resendCountdown.value = 30;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  // Send OTP to phone number

  // Future<void> sendOTP() async {
  //   try {
  //     final fullPhoneNumber = '${countryCode.value}${phoneNumber.value}';

  //     await _auth.verifyPhoneNumber(
  //       phoneNumber: fullPhoneNumber,
  //       verificationCompleted: (PhoneAuthCredential credential) async {
  //         await _auth.signInWithCredential(credential);
  //         Get.back();
  //         Get.snackbar('Success', 'Auto verified!');
  //       },
  //       verificationFailed: (FirebaseAuthException e) {
  //         Get.snackbar('Error', e.message ?? 'Verification failed');
  //       },
  //       codeSent: (String vId, int? resendToken) {
  //         verificationId.value = vId;
  //         Get.toNamed('/verify-otp', arguments: fullPhoneNumber);
  //       },
  //       codeAutoRetrievalTimeout: (String vId) {
  //         verificationId.value = vId;
  //       },
  //       timeout: const Duration(seconds: 60),
  //     );
  //   } catch (e) {
  //     Get.snackbar('Error', e.toString());
  //   }
  // }

  // Verify entered OTP
  Future<void> verifyOTP(String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);

      Get.to(() => Transaction()); // Navigate to home after verification
      Get.snackbar('Success', 'Phone number verified');
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
    }
  }

  // Resend OTP
  Future<void> resendOTP(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken.value,
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        Get.snackbar('Error', e.message ?? 'Resend failed');
      },
      codeSent: (String vId, int? token) {
        verificationId.value = vId;
        resendToken.value = token ?? 0;
        Get.snackbar('Success', 'OTP resent');
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }
}
