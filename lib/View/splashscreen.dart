import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:my_finance1/Contoller/SessionData.dart';
import 'package:my_finance1/View/onboarding.dart';
import 'package:my_finance1/View/transactiongetx.dart';
//import 'package:my_finance1/View/onboarding.dart'; // Import onboarding screen
import 'login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    navigate(context);
  }

  Future<void> navigate(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    // Get session data
    await SessionData.getSessionData();
    log("IS LOGIN : ${SessionData.isLogin}");

    // Check if onboarding was completed
    final bool onboardingCompleted =
        await SessionData.getBool(
          OnBoardingController.onboardingCompletedKey,
        ) ??
        false;
    log("ONBOARDING COMPLETED: $onboardingCompleted");

    if (mounted) {
      if (SessionData.isLogin == true) {
        // User is logged in, navigate to transaction screen
        log("NAVIGATE TO HOME");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Transaction()),
        );
      } else if (onboardingCompleted) {
        // Onboarding was completed but not logged in, go to login
        log("NAVIGATE TO LOGIN");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        // First time or app reinstalled, show onboarding
        log("NAVIGATE TO ONBOARDING");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnBoardingScreen1()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: Container(
              height: 180,
              width: 180,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(234, 238, 235, 1),
              ),
              child: Center(
                child: SvgPicture.asset("assets/images/Group 77.svg"),
              ),
            ),
          ),
          const Spacer(),
          Text(
            "Expense Manager",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
