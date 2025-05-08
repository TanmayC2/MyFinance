import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_finance1/Contoller/SessionData.dart';
import 'package:my_finance1/View/verificationemail.dart';
import 'login_screen.dart';
import 'dart:developer';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_finance1/customwidget.dart';

class Regestration extends StatefulWidget {
  const Regestration({super.key});

  @override
  State createState() {
    return _Regestration();
  }
}

class _Regestration extends State {
  final _formkey = GlobalKey<FormFieldState>();

  bool _showPassword = true;
  final _passwordcontroller = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _confirmpasswordcontroller = TextEditingController();
  final _phonecontroller = TextEditingController();

  void clearController() {
    _emailcontroller.clear();
    _passwordcontroller.clear();
    _confirmpasswordcontroller.clear();
    _phonecontroller.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _passwordcontroller.dispose();
    _emailcontroller.dispose();
    _confirmpasswordcontroller.dispose();
    _phonecontroller.dispose();
  }

  void showTermsDialog(BuildContext context) {
    // Color scheme from previous code
    const primaryColor = Color.fromRGBO(14, 161, 125, 1);
    const secondaryColor = Color.fromRGBO(241, 245, 249, 1);
    const textColor = Color.fromRGBO(30, 41, 59, 1);
    const accentColor = Color.fromRGBO(226, 232, 240, 1);
    const buttonTextColor = Colors.white;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8,
          backgroundColor: secondaryColor,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? screenWidth * 0.9 : 500,
              maxHeight: screenHeight * 0.7,
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and close icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terms of Service',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () => Navigator.of(context).pop(false),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: accentColor, thickness: 1.5),
                ),

                // Content with scrollable text
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor, width: 1),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to Our Financial App',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 14 : 15,
                              color: textColor,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Privacy Policy',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 14 : 15,
                              color: textColor,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Business Associate Agreement',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 14 : 15,
                              color: textColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Decline Button
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 24,
                          vertical: 12,
                        ),
                        foregroundColor: textColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        // Add your decline logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Terms declined',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.red.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Decline',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Accept Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 24,
                          vertical: 12,
                        ),
                        backgroundColor: primaryColor,
                        foregroundColor: buttonTextColor,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        // Add your accept logic here
                        if (_emailcontroller.text.trim().isNotEmpty &&
                            _passwordcontroller.text.trim().isNotEmpty &&
                            _confirmpasswordcontroller.text.trim().isNotEmpty) {
                          // Validate email format
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(_emailcontroller.text.trim())) {
                            CustomSnackbar.showCustomSnackbar(
                              message: "Please enter a valid email address",
                              context: context,
                            );
                            return;
                          }

                          // Strong password validation
                          if (_passwordcontroller.text.trim().length < 8) {
                            CustomSnackbar.showCustomSnackbar(
                              message:
                                  "Password must be at least 8 characters long",
                              context: context,
                            );
                            return;
                          }

                          if (!RegExp(
                            r'[A-Z]',
                          ).hasMatch(_passwordcontroller.text.trim())) {
                            CustomSnackbar.showCustomSnackbar(
                              message:
                                  "Password must contain at least one uppercase letter",
                              context: context,
                            );
                            return;
                          }

                          if (!RegExp(
                            r'[a-z]',
                          ).hasMatch(_passwordcontroller.text.trim())) {
                            CustomSnackbar.showCustomSnackbar(
                              message:
                                  "Password must contain at least one lowercase letter",
                              context: context,
                            );
                            return;
                          }

                          if (!RegExp(
                            r'[0-9]',
                          ).hasMatch(_passwordcontroller.text.trim())) {
                            CustomSnackbar.showCustomSnackbar(
                              message:
                                  "Password must contain at least one number",
                              context: context,
                            );
                            return;
                          }

                          if (!RegExp(
                            r'[!@#$%^&*(),.?":{}|<>]',
                          ).hasMatch(_passwordcontroller.text.trim())) {
                            CustomSnackbar.showCustomSnackbar(
                              message:
                                  "Password must contain at least one special character",
                              context: context,
                            );
                            return;
                          }

                          // Check if passwords match
                          if (_passwordcontroller.text.trim() !=
                              _confirmpasswordcontroller.text.trim()) {
                            CustomSnackbar.showCustomSnackbar(
                              message: "Passwords do not match",
                              context: context,
                            );
                            return;
                          } else if (_passwordcontroller.text.trim() ==
                              _confirmpasswordcontroller.text.trim()) {
                            final FirebaseAuth auth = FirebaseAuth.instance;
                            try {
                              UserCredential userCredential = await auth
                                  .createUserWithEmailAndPassword(
                                    email: _emailcontroller.text.trim(),
                                    password: _passwordcontroller.text.trim(),
                                  );
                              log("USER CREDENTIALS :$userCredential");
                              Get.to(
                                () => VerificationScreen(
                                  email: _emailcontroller.text.trim(),
                                  password: _passwordcontroller.text.trim(),
                                ),
                              );
                              CustomSnackbar.showCustomSnackbar(
                                message: "User registered successfully",
                                context: context,
                              );
                            } on FirebaseAuthException catch (error) {
                              CustomSnackbar.showCustomSnackbar(
                                message:
                                    error.message ??
                                    "Registration failed. Please try again.",
                                context: context,
                              );
                            }
                            clearController();
                          } else {
                            CustomSnackbar.showCustomSnackbar(
                              message: "Please fill all fields",
                              context: context,
                            );
                          }
                        }
                      },
                      child: Text(
                        'Accept',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create your Account",
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
                          keyboardType: TextInputType.phone,
                          controller: _phonecontroller,
                          decoration: const InputDecoration(
                            labelText: "Enter Mobile Number",
                            prefixText: "+91 ",
                            hintText: "Phone No",
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
                          obscureText: _showPassword,
                          obscuringCharacter: '*',
                          controller: _passwordcontroller,
                          decoration: const InputDecoration(
                            hintText: "Password",
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
                          obscureText: _showPassword,
                          obscuringCharacter: '*',
                          controller: _confirmpasswordcontroller,
                          decoration: InputDecoration(
                            hintText: "Confirm Password",
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
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _showPassword = !_showPassword;
                                setState(() {});
                              },
                              child: Icon(
                                (_showPassword)
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.green[300],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => showTermsDialog(context),

                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color.fromRGBO(14, 161, 125, 1),
                          ),
                          child: Center(
                            child: Text(
                              "Create Account",
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
                    "Already have an Account",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => Login());
                    },
                    child: Text(
                      "     Login",
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
