// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:my_finance1/Contoller/verificationOTPcontroller.dart';

// class VerificationScreenOTP extends StatefulWidget {
//   final String phoneNumber;

//   const VerificationScreenOTP({super.key, required this.phoneNumber});

//   @override
//   State<VerificationScreenOTP> createState() => _VerificationScreenOTPState();
// }

// class _VerificationScreenOTPState extends State<VerificationScreenOTP> {
//   final controller = Get.put(PhoneAuthController());

//   @override
//   void initState() {
//     super.initState();
//     // Start the resend timer
//     controller.startResendTimer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isSmallScreen = screenSize.width < 360;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           'Verification',
//           style: TextStyle(color: Colors.black),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Obx(
//             () => Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 30),
//                 Icon(
//                   Icons.verified_user_outlined,
//                   size: 56,
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'OTP Verification',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 RichText(
//                   textAlign: TextAlign.center,
//                   text: TextSpan(
//                     style: Theme.of(
//                       context,
//                     ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
//                     children: [
//                       const TextSpan(
//                         text: 'We have sent a verification code to\n',
//                       ),
//                       TextSpan(
//                         text: widget.phoneNumber,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // OTP Input Fields
//                 _buildOtpInputRow(isSmallScreen),

//                 const SizedBox(height: 20),

//                 // Error message if OTP is invalid
//                 if (controller.isVerifying.value)
//                   const Padding(
//                     padding: EdgeInsets.only(top: 8.0),
//                     child: CircularProgressIndicator(),
//                   ),

//                 const SizedBox(height: 20),

//                 // Resend code option
//                 _buildResendOption(context),

//                 const Spacer(),

//                 // Verify button
//                 _buildVerifyButton(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildOtpInputRow(bool isSmallScreen) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         spacing: 5,
//         children: List.generate(
//           6,
//           (index) => SizedBox(
//             width: isSmallScreen ? 40 : 48,
//             child: _buildOtpDigitField(index, controller, context),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildOtpDigitField(
//     int index,
//     PhoneAuthController controller,
//     BuildContext context,
//   ) {
//     return TextField(
//       controller: controller.otpControllers[index],
//       focusNode: controller.focusNodes[index],
//       textAlign: TextAlign.center,
//       keyboardType: TextInputType.number,
//       maxLength: 1,
//       style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//       decoration: InputDecoration(
//         counterText: '',
//         filled: true,
//         fillColor: Colors.grey[100],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(
//             color: Theme.of(context).primaryColor,
//             width: 2,
//           ),
//         ),
//         contentPadding: const EdgeInsets.symmetric(vertical: 12),
//       ),
//       inputFormatters: [
//         FilteringTextInputFormatter.digitsOnly,
//         LengthLimitingTextInputFormatter(1),
//       ],
//       onChanged: (value) {
//         controller.updateOtpDigit(index, value);

//         // Auto-focus logic
//         if (value.isNotEmpty && index < 5) {
//           FocusScope.of(context).requestFocus(controller.focusNodes[index + 1]);
//         } else if (value.isEmpty && index > 0) {
//           FocusScope.of(context).requestFocus(controller.focusNodes[index - 1]);
//         }

//         // Auto-verify when all digits are entered
//         if (index == 5 && value.isNotEmpty) {
//           final otp = controller.otpDigits.join();
//           if (otp.length == 6) {
//             // Give slight delay for better UX
//             Future.delayed(const Duration(milliseconds: 300), () {
//               controller.verifyOTP(otp);
//             });
//           }
//         }
//       },
//     );
//   }

//   Widget _buildResendOption(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           'Didn\'t receive code? ',
//           style: Theme.of(
//             context,
//           ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
//         ),
//         GestureDetector(
//           onTap:
//               controller.canResend.value
//                   ? () => controller.resendOTP(widget.phoneNumber)
//                   : null,
//           child: Text(
//             controller.canResend.value
//                 ? 'Resend'
//                 : 'Resend in ${controller.resendCountdown.value}s',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color:
//                   controller.canResend.value
//                       ? Theme.of(context).primaryColor
//                       : Colors.grey,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildVerifyButton() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 24.0),
//       child: SizedBox(
//         width: double.infinity,
//         height: 50,
//         child: ElevatedButton(
//           onPressed:
//               controller.isVerifying.value
//                   ? null
//                   : () {
//                     final otp = controller.otpDigits.join();
//                     if (otp.length == 6) {
//                       controller.verifyOTP(otp);
//                     } else {
//                       Get.snackbar(
//                         'Incomplete Code',
//                         'Please enter the complete 6-digit verification code',
//                         snackPosition: SnackPosition.BOTTOM,
//                         backgroundColor: Colors.red,
//                         colorText: Colors.white,
//                       );
//                     }
//                   },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Theme.of(context).primaryColor,
//             foregroundColor: Colors.white,
//             disabledBackgroundColor: Colors.grey[300],
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child:
//               controller.isVerifying.value
//                   ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                   : const Text(
//                     'VERIFY',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//         ),
//       ),
//     );
//   }
// }
