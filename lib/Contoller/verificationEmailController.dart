import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_finance1/Contoller/transactioncontroolergetx.dart';
import 'package:my_finance1/View/transactiongetx.dart';

class VerificationEmailController extends GetxController {
  final TransactionController _controller = Get.put(TransactionController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  late Timer _timer;
  final RxInt secondsRemaining = 60.obs;
  final RxBool isResendEnabled = false.obs;
  final RxBool isEmailVerified = false.obs;
  final RxBool isUserAlreadyLoggedIn = false.obs;

  // Getter for user
  User? get user => _user;

  @override
  void onClose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.onClose();
  }

  // Initialize controller and check user status
  Future<void> init(String email, String password) async {
    _user = _auth.currentUser;
    await checkUserLoginStatus(email, password);
  }

  // Check if user is already logged in and verified
  Future<void> checkUserLoginStatus(String email, String password) async {
    await _user?.reload();
    _user = _auth.currentUser;

    if (_user != null) {
      if (_user!.emailVerified) {
        isEmailVerified.value = true;
        isUserAlreadyLoggedIn.value = true;
        // Get.to(() => Transaction());
      } else {
        // User exists but email is not verified, send verification
        await checkEmailVerification();
        await sendVerificationEmail();
        startTimer();
      }
    } else {
      // User is not logged in yet
      try {
        // Try to sign in with provided credentials
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        _user = userCredential.user;

        if (_user != null && _user!.emailVerified) {
          // User is already verified
          isEmailVerified.value = true;
          // isUserAlreadyLoggedIn.value = true;
        } else {
          // User exists but email is not verified, send verification
          await checkEmailVerification();
          await sendVerificationEmail();
          startTimer();
        }
      } catch (e) {
        log("MY FINANCE: Error signing in: $e");
        // Unable to sign in, might be a new user or incorrect credentials
        await checkEmailVerification();
        await sendVerificationEmail();
        startTimer();
      }
    }
  }

  // Check if email is verified
  Future<void> checkEmailVerification() async {
    await _user?.reload();
    _user = _auth.currentUser;

    if (_user != null && _user!.emailVerified) {
      isEmailVerified.value = true;
      if (_timer.isActive) {
        _timer.cancel();
      }
      //Get.to(() => Transaction());
    }
  }

  // Send verification email
  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        Get.snackbar(
          'Error',
          'User not found. Please try signing in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (user.emailVerified) {
        isEmailVerified.value = true;
        Get.snackbar(
          'Already Verified',
          'Your email is already verified!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      await user.sendEmailVerification();

      Get.snackbar(
        'Email Sent',
        'Verification email has been sent to ${user.email}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      startTimer();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Start countdown timer for resend functionality
  void startTimer() {
    secondsRemaining.value = 60;
    isResendEnabled.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value == 0) {
        timer.cancel();
        isResendEnabled.value = true;
      } else {
        secondsRemaining.value--;
      }

      // Check verification status every 5 seconds
      if (secondsRemaining.value % 5 == 0) {
        checkEmailVerification();
      }
    });
  }

  // Sign in user with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      log("MY FINANCE: Error signing in: $e");
      rethrow;
    }
  }
}
