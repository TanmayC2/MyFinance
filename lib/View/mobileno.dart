// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:my_finance1/Contoller/verificationOTPcontroller.dart';
// import 'package:my_finance1/View/verificationOTP.dart';

// class PhoneNumberScreen extends StatefulWidget {
//   const PhoneNumberScreen({super.key});

//   @override
//   State createState() {
//     return PhoneNumberScreenState();
//   }
// }

// class PhoneNumberScreenState extends State {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();
//   final PhoneAuthController authController = Get.put(PhoneAuthController());

//   @override
//   void dispose() {
//     super.dispose();
//     _phoneController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Phone Verification'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 24),
//             Text(
//               'Enter your phone number',
//               style: Theme.of(
//                 context,
//               ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'We\'ll send you a verification code',
//               style: Theme.of(
//                 context,
//               ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 32),
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade400),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Obx(
//                           () => DropdownButton<String>(
//                             value: authController.countryCode.value,
//                             items: const [
//                               DropdownMenuItem(
//                                 value: '+91',
//                                 child: Text('+91 IN'),
//                               ),
//                               DropdownMenuItem(
//                                 value: '+1',
//                                 child: Text('+1 US'),
//                               ),
//                               DropdownMenuItem(
//                                 value: '+44',
//                                 child: Text('+44 UK'),
//                               ),
//                               DropdownMenuItem(
//                                 value: '+61',
//                                 child: Text('+61 AU'),
//                               ),
//                             ],
//                             onChanged: (value) {
//                               if (value != null) {
//                                 authController.countryCode.value = value;
//                               }
//                             },
//                             underline: const SizedBox(),
//                             icon: const Icon(Icons.arrow_drop_down),
//                             style: Theme.of(context).textTheme.bodyLarge,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _phoneController,
//                           keyboardType: TextInputType.phone,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                             LengthLimitingTextInputFormatter(15),
//                           ],
//                           decoration: InputDecoration(
//                             labelText: 'Phone Number',
//                             hintText: '9876543210',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Colors.grey.shade400,
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Colors.grey.shade400,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context).primaryColor,
//                                 width: 2,
//                               ),
//                             ),
//                             prefix: Padding(
//                               padding: const EdgeInsets.only(right: 5),
//                               child: Obx(
//                                 () => Text(
//                                   authController.countryCode.value,
//                                   style: Theme.of(context).textTheme.bodyLarge,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter phone number';
//                             }
//                             if (value.length < 8) {
//                               return 'Enter valid phone number';
//                             }
//                             if (authController.countryCode.value == '+91' &&
//                                 !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
//                               return 'Enter valid Indian number';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 40),
//                   Obx(
//                     () => SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed:
//                             authController.isVerifying.value
//                                 ? null
//                                 : () {
//                                   if (_formKey.currentState!.validate()) {
//                                     authController.initPhoneVerification(
//                                       _phoneController.text.trim(),
//                                     );
//                                     authController.phoneNumber.value =
//                                         _phoneController.text.trim();

//                                     authController.sendOTP();
//                                     Get.to(
//                                       () => VerificationScreenOTP(
//                                         phoneNumber:
//                                             authController.phoneNumber.value,
//                                       ),
//                                     );
//                                   }
//                                 },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Theme.of(context).primaryColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         child:
//                             authController.isVerifying.value
//                                 ? const CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 3,
//                                 )
//                                 : const Text(
//                                   'Send Verification Code',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 40),
//             if (MediaQuery.of(context).viewInsets.bottom == 0)
//               Center(
//                 child: Image.network(
//                   'https://img.freepik.com/free-vector/mobile-login-concept-illustration_114360-83.jpg',
//                   height: MediaQuery.of(context).size.height * 0.3,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
