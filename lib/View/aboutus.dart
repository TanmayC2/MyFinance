import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_finance1/Contoller/SessionData.dart';
import 'package:my_finance1/View/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});
  @override
  State createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url); // Convert the URL string to a Uri object
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        webOnlyWindowName: url,
        mode: LaunchMode.externalApplication,
      ); // Use launchUrl
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About Developer",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0, // Remove shadow
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: AnimatedOpacity(
            duration: Duration(seconds: 1),
            opacity: _opacity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Section
                  FadeTransition(
                    opacity: _animation,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green,
                            spreadRadius: 2,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            "assets/images/Tanmay Photo.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Name and Title
                  Text(
                    "Tanmay Chaudhari",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Flutter Developer & Computer Engineering Student",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  SizedBox(height: 25),

                  // Education Card
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 1,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.school, color: Colors.green),
                              SizedBox(width: 10),
                              Text(
                                "Education",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Bachelor of Engineering in Computer Engineering",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Pursuing my degree with a focus on mobile application development and software engineering.",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // About MyFinance App
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 1,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.money, color: Colors.green),
                              SizedBox(width: 10),
                              Text(
                                "About MyFinance",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            "MyFinance is a personal finance tracking application designed to help users manage their expenses and income efficiently. The app features expense categorization, visual analytics, and budget planning tools.",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            "This project was developed as part of my passion for creating practical solutions using Flutter technology.",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Skills Section
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 1,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.code, color: Colors.green),
                              SizedBox(width: 10),
                              Text(
                                "Skills & Interests",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildSkillChip("Flutter"),
                              _buildSkillChip("Dart/Java/Python"),
                              _buildSkillChip("Firebase"),
                              _buildSkillChip("RDBMS/SQL"),
                              _buildSkillChip("UI/UX"),
                              _buildSkillChip("Mobile Development"),
                              _buildSkillChip("Web Development"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Social Links
                  Text(
                    "Connect With Me",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        Icons.mail,
                        Colors.white,
                        "Email",
                        "tchaudhari2205@gmail.com",
                      ),
                      SizedBox(width: 20),
                      _buildSocialButton(
                        Icons.code,
                        Colors.transparent,
                        "GitHub",
                        "https://github.com/TanmayC2",
                      ),
                      SizedBox(width: 20),
                      _buildSocialButton(
                        Icons.work,
                        Colors.blue,
                        "LinkedIn",
                        "https://linkedin.com/in/tanmay-chaudhari-867895254",
                      ),
                    ],
                  ),

                  SizedBox(height: 40),

                  // Logout Button
                  Container(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () async {
                        // Show confirmation dialog
                        bool confirm =
                            await showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text("Confirm Logout"),
                                    content: Text(
                                      "Are you sure you want to logout?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                        child: Text("Logout"),
                                      ),
                                    ],
                                  ),
                            ) ??
                            false;

                        if (confirm) {
                          await SessionData.storeSessionData(
                            loginData: false,
                            emailId: "",
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Logged out successfully")),
                          );
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 10),
                          Text(
                            "Logout",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Footer
                  Text(
                    "© 2025 MyFinance App. All rights reserved.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Chip(
      label: Text(
        label,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: Colors.green,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
  }

  Widget _buildSocialButton(
    IconData icon,
    Color color,
    String label,
    String url,
  ) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
