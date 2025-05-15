import 'package:my_finance1/View/transactiongetx.dart';
import 'aboutus.dart';
import 'categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import "graph_screen.dart";

class CustomDrawer extends StatefulWidget {
  final int selectedIndex; // Stores the selected index

  const CustomDrawer({
    super.key,
    this.selectedIndex = 1,
  }); // Default to "Transactions"

  @override
  State createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late int selectedIndex; // Local copy of selected index

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex; // Set initial index
  }

  void navigateToPage(BuildContext context, int index, Widget page) {
    setState(() {
      selectedIndex = index; // Update selected index
    });
    Navigator.pop(context); // Close drawer before navigating
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              body: page,
              drawer: CustomDrawer(selectedIndex: index), // Preserve selection
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      elevation: 16.0,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 50, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7F3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: const Color(0xFF0EA17D),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Expense Manager",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0EA17D),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Saves all your Transactions",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Padding(
              padding: EdgeInsets.only(left: 25, bottom: 10),
              child: Text(
                "MENU",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Enhanced Drawer Items
            buildDrawerItem(
              context,
              1,
              "Transactions",
              "assets/images/Subtract.svg",
              const Transaction(),
            ),
            buildDrawerItem(
              context,
              2,
              "Graph",
              "assets/images/graph.svg",
              const Graph(),
            ),
            buildDrawerItem(
              context,
              3,
              "Category",
              "assets/images/Subtract (1).svg",
              Categories(),
            ),

            const Divider(
              height: 30,
              indent: 25,
              endIndent: 25,
              thickness: 0.5,
            ),

            buildDrawerItem(
              context,
              4,
              "About Us",
              "assets/images/Vector (1).svg",
              AboutUsPage(),
            ),

            const Spacer(),

            // Version info at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: Text(
                  "Version 1.0.0",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds individual drawer items with enhanced UI
  Widget buildDrawerItem(
    BuildContext context,
    int index,
    String title,
    String iconPath,
    Widget page,
  ) {
    final bool isSelected = selectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 54,
      width: 245,
      decoration: BoxDecoration(
        color:
            isSelected
                ? const Color.fromRGBO(14, 161, 125, 0.15)
                : Colors.transparent,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          onTap: () => navigateToPage(context, index, page),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFFE6F7F3)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconPath,
                      height: 18,
                      width: 18,
                      colorFilter:
                          isSelected
                              ? const ColorFilter.mode(
                                Color(0xFF0EA17D),
                                BlendMode.srcIn,
                              )
                              : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        isSelected ? const Color(0xFF0EA17D) : Colors.black87,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    height: 5,
                    width: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0EA17D),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
