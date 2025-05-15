import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_finance1/Contoller/verificationOTPcontroller.dart';
import 'package:my_finance1/View/verificationOTP.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.put(PhoneAuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Mobile Number')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'We will send you an OTP to verify your number',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: Obx(
                        () => DropdownButton<String>(
                          value: _controller.countryCode.value,
                          items: const [
                            DropdownMenuItem(
                              value: '+91',
                              child: Text('+91 India'),
                            ),
                            DropdownMenuItem(
                              value: '+1',
                              child: Text('+1 USA'),
                            ),
                            DropdownMenuItem(
                              value: '+44',
                              child: Text('+44 UK'),
                            ),
                            DropdownMenuItem(
                              value: '+61',
                              child: Text('+61 Australia'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _controller.countryCode.value = value;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        hintText: '9876543210',
                        border: OutlineInputBorder(),
                        // Removed the prefixText: '+' that was causing the issue
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mobile number';
                        }
                        if (value.length != 10) {
                          return 'Enter 10 digit mobile number';
                        }
                        // Adjust validator based on selected country code
                        if (_controller.countryCode.value == '+91' &&
                            !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                          return 'Enter valid Indian number';
                        }
                        return null;
                      },
                      onChanged:
                          (value) => _controller.phoneNumber.value = value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final fullPhoneNumber =
                          '${_controller.countryCode.value.trim()}${_controller.phoneNumber.value.trim()}';
                      log('Sending verification to: $fullPhoneNumber');

                      FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: fullPhoneNumber,
                        verificationCompleted: (
                          PhoneAuthCredential credential,
                        ) {
                          log('Verification completed automatically');
                        },
                        verificationFailed: (FirebaseAuthException ex) {
                          log('Verification failed: ${ex.message}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${ex.message}')),
                          );
                        },
                        codeSent: (String verificationId, int? resendToken) {
                          log('Code sent to $fullPhoneNumber');
                          Get.to(
                            () => VerificationScreenOTP(
                              phoneNumber: _controller.phoneNumber.value,
                              verificationId:
                                  _controller
                                      .verificationId
                                      .value, // Pass verification ID to OTP screen
                            ),
                          );
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {
                          log('Auto retrieval timeout');
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Send OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
