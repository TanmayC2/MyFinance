import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_finance1/Contoller/SessionData.dart';
import 'package:my_finance1/View/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  // Key for storing onboarding status
  static const String onboardingCompletedKey = "isOnboardingCompleted";

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < 3) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Mark onboarding as completed and navigate to login
  Future<void> completeOnboarding(BuildContext context) async {
    try {
      // Store that onboarding is completed
      await SessionData.setBool(onboardingCompletedKey, true);
      log("ONBOARDING COMPLETED AND SAVED");

      // Navigate to login screen
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      log("Error in completeOnboarding: $e");
    }
  }

  // Static method to check if onboarding was completed before
  static Future<bool> wasOnboardingCompleted() async {
    try {
      final result = await SessionData.getBool(onboardingCompletedKey) ?? false;
      log("WAS ONBOARDING COMPLETED: $result");
      return result;
    } catch (e) {
      log("Error in wasOnboardingCompleted: $e");
      return false;
    }
  }
}

class OnBoardingScreen1 extends StatefulWidget {
  const OnBoardingScreen1({super.key});

  @override
  State<OnBoardingScreen1> createState() => OnBoardingScreen1State();
}

class OnBoardingScreen1State extends State<OnBoardingScreen1> {
  final OnBoardingController controller = Get.put(OnBoardingController());

  // Color palette - match with your app's color scheme
  static const primaryColor = Color.fromRGBO(14, 161, 125, 1);
  static const secondaryColor = Color.fromRGBO(241, 245, 249, 1);
  static const textColor = Color.fromRGBO(30, 41, 59, 1);
  static const accentColor = Color.fromRGBO(226, 232, 240, 1);
  static const buttonTextColor = Colors.white;

  // Onboarding content - change this to your actual content
  final List<OnboardingPage> onboardingPages = [
    OnboardingPage(
      image:
          "https://img.freepik.com/free-vector/saving-money-financial-concept_74855-7849.jpg", // Green and white expense tracking illustration
      title: "Track Your Expenses",
      description:
          "Easily record and categorize your daily transactions to maintain complete control over your finances",
    ),
    OnboardingPage(
      image:
          "https://img.freepik.com/free-vector/budget-planning-abstract-concept-vector-illustration-budget-plan-market-analysis-financial-management-company-accounting-estimate-income-expenses-resources-allocation-abstract-metaphor_335657-2753.jpg", // Green budget planning illustration
      title: "Smart Budget Planning",
      description:
          "Create custom budgets for different spending categories and receive alerts when you're close to limits",
    ),
    OnboardingPage(
      image:
          "https://img.freepik.com/free-vector/investor-with-laptop-monitoring-growth-dividends-trader-with-computer-analyzing-profit-graph-man-investing-stock-market-flat-vector-illustration-finance-trading-investment-concept_74855-24618.jpg", // Green investment tracking illustration
      title: "Financial Insights",
      description:
          "Gain valuable insights with interactive charts and personalized recommendations to grow your savings",
    ),
    OnboardingPage(
      image:
          "https://img.freepik.com/free-vector/money-saving-concept_52683-8031.jpg", // Green savings illustration
      title: "Achieve Your Goals",
      description:
          "Set financial targets and track your progress with visual milestones and achievement rewards",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: onboardingPages.length,
              itemBuilder: (context, index) {
                final page = onboardingPages[index];
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 24 : 40,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.05),
                        // Image container
                        SizedBox(
                          height: isSmallScreen ? screenHeight * 0.3 : 300,
                          width: isSmallScreen ? screenWidth * 0.7 : 350,
                          child: Image.network(page.image, fit: BoxFit.cover),
                        ),

                        SizedBox(height: screenHeight * 0.05),
                        // Title
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 22 : 28,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        // Description
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w400,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.1),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Skip button
            Positioned(
              top: 16,
              right: 24,
              child: TextButton(
                onPressed: () => _completeOnboarding(context),
                child: Text(
                  "Skip",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ),

            // Dots indicator
            Positioned(
              bottom: screenHeight * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: controller.pageController,
                  count: onboardingPages.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: primaryColor,
                    dotColor: accentColor,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                    spacing: 6,
                  ),
                ),
              ),
            ),

            // Next/Get Started button
            Positioned(
              bottom: screenHeight * 0.05,
              right: 24,
              child: Obx(
                () =>
                    controller.currentPage.value == onboardingPages.length - 1
                        ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 24 : 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _completeOnboarding(context),
                          child: Text(
                            "Get Started",
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: buttonTextColor,
                            ),
                          ),
                        )
                        : FloatingActionButton(
                          backgroundColor: primaryColor,
                          onPressed: controller.nextPage,
                          child: const Icon(
                            Icons.arrow_forward,
                            color: buttonTextColor,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to mark onboarding as completed and navigate to login
  Future<void> _completeOnboarding(BuildContext context) async {
    // Store that onboarding is completed
    await SessionData.setBool(
      OnBoardingController.onboardingCompletedKey,
      true,
    );

    // Navigate to login screen
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
    }
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}
