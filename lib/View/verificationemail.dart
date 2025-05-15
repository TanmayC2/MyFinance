import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_finance1/Contoller/SessionData.dart';
import 'package:my_finance1/Contoller/transactioncontroolergetx.dart';
import 'package:my_finance1/Contoller/verificationEmailController.dart';
import 'package:my_finance1/View/transactiongetx.dart';
import 'package:my_finance1/customwidget.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final String password;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.password,
  });
  @override
  State<VerificationScreen> createState() {
    return _VerificationScreenState();
  }
}

class _VerificationScreenState extends State<VerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;
  late Timer _timer;
  final RxInt _secondsRemaining = 60.obs;
  final RxBool _isResendEnabled = false.obs;
  final RxBool _isEmailVerified = false.obs;
  final RxBool _isUserAlreadyLoggedIn = false.obs;
  final TransactionController _controller = Get.put(TransactionController());

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _checkUserLoginStatus();
  }

  // Check if user is already logged in and verified
  Future<void> _checkUserLoginStatus() async {
    await _user?.reload();
    _user = _auth.currentUser;

    if (_user != null) {
      if (_user!.emailVerified) {
        _isEmailVerified.value = true;
        _isUserAlreadyLoggedIn.value = true;
        // Navigate to home page after a short delay

        _controller.getuserId();
        _controller.fetchTransactions(_controller.userId.value);
        Get.to(() => Transaction());
      } else {
        // User exists but email is not verified, send verification
        _checkEmailVerification();
        sendVerification();
        _startTimer();
      }
    } else {
      // User is not logged in yet
      try {
        // Try to sign in with provided credentials
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: widget.email,
          password: widget.password,
        );

        _user = userCredential.user;

        if (_user != null && _user!.emailVerified) {
          // User is already verified
          _isEmailVerified.value = true;
          _isUserAlreadyLoggedIn.value = true;

          // Store session data
          await SessionData.storeSessionData(
            loginData: true,
            emailId: _user!.email!,
          );

          // Navigate to transaction screen

          _controller.getuserId();
          _controller.fetchTransactions(_controller.userId.value);
          Get.to(() => Transaction());
        } else {
          // User exists but email is not verified, send verification
          _checkEmailVerification();
          sendVerification();
          _startTimer();
        }
      } catch (e) {
        log("MY FINANCE: Error signing in: $e");
        // Unable to sign in, might be a new user or incorrect credentials
        _checkEmailVerification();
        sendVerification();
        _startTimer();
      }
    }
  }

  void sendVerification() {
    _sendVerificationEmail();
  }

  // Check if email is verified
  Future<void> _checkEmailVerification() async {
    await _user?.reload();
    _user = _auth.currentUser;

    if (_user != null && _user!.emailVerified) {
      _isEmailVerified.value = true;
      if (_timer.isActive) {
        _timer.cancel();
      }
      _controller.getuserId();
      _controller.fetchTransactions(_controller.userId.value);
      // Navigate to home page or next screen after verification

      Get.to(() => Transaction()); // Replace with your route
    }
  }

  // Send verification email
  Future<void> _sendVerificationEmail() async {
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
        _isEmailVerified.value = true;
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

      _startTimer();
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

  void _startTimer() {
    _secondsRemaining.value = 60;
    _isResendEnabled.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining.value == 0) {
        timer.cancel();
        _isResendEnabled.value = true;
      } else {
        _secondsRemaining.value--;
      }

      // Check verification status every 5 seconds
      if (_secondsRemaining.value % 5 == 0) {
        _checkEmailVerification();
      }
    });
  }

  @override
  void dispose() {
    if (this._timer != null && this._timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06, // Responsive padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.03),
              Text(
                'Verification',
                style: TextStyle(
                  fontSize: isSmallScreen ? 22 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Obx(
                () =>
                    _isEmailVerified.value
                        ? Text(
                          'Your email has been verified successfully!',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 15 : 16,
                            color: Colors.green,
                          ),
                        )
                        : RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: isSmallScreen ? 15 : 16,
                              color: Colors.grey[600],
                            ),
                            children: [
                              TextSpan(
                                text: 'We have sent a verification link to ',
                              ),
                              TextSpan(
                                text: _user?.email ?? 'your email',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.6,
                  child: Image.network(
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfCliqXktdGYOUPMBUaBETMvRDEFkRB1MqmA&s", // If you don't have this asset, you can use a placeholder
                    // or create an empty container with proper dimensions
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: screenHeight * 0.20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.email_outlined,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Center(
                child: Obx(
                  () =>
                      _isEmailVerified.value
                          ? Text(
                            'Redirecting you shortly...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          )
                          : Column(
                            children: [
                              Text(
                                'Please check your email and click on the',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'verification link to continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: ElevatedButton(
                  onPressed: () => _checkEmailVerification(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  child: Text(
                    'I\'ve verified my email',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: Obx(
                  () =>
                      _isUserAlreadyLoggedIn.value
                          ? Container() // Hide resend controls if already logged in
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Didn\'t receive the email? ',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    _isResendEnabled.value
                                        ? _sendVerificationEmail
                                        : null,
                                child: Text(
                                  _isResendEnabled.value
                                      ? 'Resend'
                                      : '${_secondsRemaining.value}s',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _isResendEnabled.value
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                child: SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_user != null && _user!.emailVerified) {
                        try {
                          UserCredential userCredential = await _auth
                              .signInWithEmailAndPassword(
                                email: widget.email,
                                password: widget.password,
                              );

                          log(
                            "MY FINANCE :UserCredentials :${userCredential.user!.email}",
                          );
                          await SessionData.storeSessionData(
                            loginData: true,
                            emailId: userCredential.user!.email!,
                          );
                          _controller.getuserId();
                          _controller.fetchTransactions(
                            _controller.userId.value,
                          );
                          Get.to(
                            () => Transaction(),
                          ); //To To Transactions on verification
                        } on FirebaseAuthException catch (error) {
                          log("My Finance : ERROR :${error.message}");
                          CustomSnackbar.showCustomSnackbar(
                            message: error.code,
                            context: context,
                          );
                        } // Replace with your route  //To To Transactions on verification
                      } else {
                        _checkEmailVerification();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Obx(
                      () => Text(
                        _isEmailVerified.value ? 'Continue' : 'Verify',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
