import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_finance1/Contoller/SessionData.dart';
//import 'package:get/get_core/src/get_main.dart';
import 'package:my_finance1/View/transactiongetx.dart';
import 'package:my_finance1/customwidget.dart';
import 'register_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State createState() {
    return _Login();
  }
}

class _Login extends State {
  final _formkey = GlobalKey<FormFieldState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final RxBool _showPassword = true.obs;

  void clearController() {
    _emailcontroller.clear();
    _passwordcontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              const SizedBox(height: 80),
              SvgPicture.asset("assets/images/Group 77.svg"),
              const SizedBox(height: 20),
              Form(
                key: _formkey,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Login to your Account",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 10,
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _emailcontroller,
                          decoration: const InputDecoration(
                            hintText: "Email",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(0, 0, 0, 0.15),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(0, 0, 0, 0.15),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(0, 0, 0, 0.15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 10,
                                color: Color.fromRGBO(0, 0, 0, 0.15),
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _passwordcontroller,

                            decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _showPassword.value = !_showPassword.value;
                                },
                                child: Icon(
                                  (_showPassword.value)
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.green[300],
                                ),
                              ),
                              hintText: "Password",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(0, 0, 0, 0.15),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(0, 0, 0, 0.15),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(0, 0, 0, 0.15),
                                ),
                              ),
                            ),
                            obscureText: _showPassword.value,
                            obscuringCharacter: "*",
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.46,
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => ChangePassword());
                            },
                            child: Text(
                              "Forget Password?",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          if (_emailcontroller.text.trim().isNotEmpty &&
                              _passwordcontroller.text.trim().isNotEmpty) {
                            try {
                              UserCredential userCredential =
                                  await _firebaseAuth
                                      .signInWithEmailAndPassword(
                                        email: _emailcontroller.text,
                                        password: _passwordcontroller.text,
                                      );
                              log(
                                "MY FINANCE :UserCredentials :${userCredential.user!.email}",
                              );
                              clearController();
                              //On Login Store
                              await SessionData.storeSessionData(
                                loginData: true,
                                emailId: userCredential.user!.email!,
                              );
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return Transaction();
                                  },
                                ),
                              );
                            } on FirebaseAuthException catch (error) {
                              log("My Finance : ERROR :${error.code}");
                              log("My Finance : ERROR :${error.message}");
                              CustomSnackbar.showCustomSnackbar(
                                message: error.code,
                                context: context,
                              );
                            }
                          }
                        },
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color.fromRGBO(14, 161, 125, 1),
                          ),
                          child: Center(
                            child: Text(
                              "Log in",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account? ",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Regestration(),
                        ),
                      );
                    },
                    child: Text(
                      " Sign Up",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});
  @override
  State createState() {
    return _ChangePasswordState();
  }
}

class _ChangePasswordState extends State {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Success',
        'Password reset email sent',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.to(() => VerificationLinkScreen());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SvgPicture.asset("assets/images/Group 77.svg"),
                SizedBox(height: 70),
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Enter your email address and we will send you a link to reset your password',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
                SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter Registered Email",
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.black),

                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                SizedBox(height: 32),
                PrimaryButton(
                  text: 'Reset Password',
                  onPressed: () {
                    if (emailController.text.isNotEmpty) {
                      resetPassword(emailController.text.trim());
                    } else {
                      Get.snackbar(
                        'Error',
                        'Please enter your email',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.black,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable Components
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

//Screen to be redirected when email is sent for change of password

class VerificationLinkScreen extends StatelessWidget {
  // Controller to manage the verification state
  final VerificationController controller = Get.put(VerificationController());

  VerificationLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsiveness
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding and sizing
    final double verticalPadding = screenHeight * 0.03;
    final double horizontalPadding = screenWidth * 0.06;
    final bool isSmallScreen = screenWidth < 400;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(), // 4. Use Get.back() instead of Navigator
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            children: [
              // Header with close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () => Get.to(() => Login()),
                ),
              ),

              // Content area with centered logo and text
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo
                        SizedBox(
                          width: screenWidth * 0.7,
                          child: ClipOval(
                            child: Image.network(
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfCliqXktdGYOUPMBUaBETMvRDEFkRB1MqmA&s",
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    height: screenHeight * 0.25,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.email_outlined,
                                        size: 80,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // Verification text
                        Text(
                          'Verification Link',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 22 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // Email info with Obx to reactively update
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Obx(
                            () => RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 15 : 16,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        'Please check your inbox for verification link sent to ',
                                  ),
                                  TextSpan(
                                    text: controller.userEmail.value,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' not in inbox or spam folder?',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // Resend button with cooldown timer
                        Obx(
                          () => GestureDetector(
                            onTap:
                                controller.isResendEnabled.value
                                    ? controller.sendVerificationEmail
                                    : null,
                            child: Text(
                              controller.isResendEnabled.value
                                  ? 'Resend verification link'
                                  : 'Resend in ${controller.secondsRemaining.value}s',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 15 : 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    controller.isResendEnabled.value
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Close button at bottom
              Padding(
                padding: EdgeInsets.only(bottom: verticalPadding),
                child: SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => Login()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 12 : 16,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

// GetX controller to handle verification logic and state
class VerificationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxString userEmail = "".obs;
  final RxInt secondsRemaining = 60.obs;
  final RxBool isResendEnabled = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Get current user's email
    final User? user = _auth.currentUser;
    if (user != null) {
      userEmail.value = user.email ?? "your email";
    }

    // Start cooldown timer
    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startTimer() {
    secondsRemaining.value = 60;
    isResendEnabled.value = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value == 0) {
        timer.cancel();
        isResendEnabled.value = true;
      } else {
        secondsRemaining.value--;
      }
    });
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        Get.snackbar(
          'Success',
          'Verification link sent to ${user.email}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        _startTimer();
      }
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
}
