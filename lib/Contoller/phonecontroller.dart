import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var phoneNumber = ''.obs;
  String _verificationId = '';

  Future<void> sendOtp() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.value,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification (on Android)
        await _auth.signInWithCredential(credential);
        Get.snackbar("Success", "Phone number automatically verified");
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar("Error", e.message ?? "Verification failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        Get.snackbar("OTP Sent", "OTP has been sent to your number");
        // Navigate to OTP screen if you had one
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> verifyOtp(String otpCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otpCode,
      );
      await _auth.signInWithCredential(credential);
      Get.snackbar("Verified", "Phone number verified successfully");
    } catch (e) {
      Get.snackbar("Error", "Invalid OTP or verification failed");
    }
  }
}
