import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_finance1/Contoller/verificationOTPcontroller.dart';

class VerificationScreenOTP extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  const VerificationScreenOTP({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<VerificationScreenOTP> createState() => _VerificationScreenOTPState();
}

class _VerificationScreenOTPState extends State<VerificationScreenOTP> {
  final controller = Get.put(PhoneAuthController());
  @override
  void initState() {
    super.initState();
    controller.linkPhoneNumber(widget.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Verification',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    children: [
                      const TextSpan(text: 'Enter the 6-digit code sent to '),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => _buildOtpDigitField(index, controller, context),
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Didn\'t receive code? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap:
                          controller.canResend.value
                              ? () => controller.resendOTP(widget.phoneNumber)
                              : null,
                      child: Text(
                        controller.canResend.value
                            ? 'Resend'
                            : 'Resend in ${controller.resendCountdown.value}s',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              controller.canResend.value
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final otp = controller.otpDigits.join();
                        if (otp.length == 6) {
                          controller.verifyOTP(otp);
                        } else {
                          Get.snackbar('Error', 'Please enter 6-digit code');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('VERIFY'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpDigitField(
    int index,
    PhoneAuthController controller,
    BuildContext context,
  ) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: controller.otpControllers[index],
        focusNode: controller.focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
          controller.updateOtpDigit(index, value);
        },
      ),
    );
  }
}
