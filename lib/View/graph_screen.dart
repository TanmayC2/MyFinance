import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_finance1/Contoller/categorycontrollergetx.dart';
import 'package:my_finance1/Contoller/transactioncontroolergetx.dart';
import 'package:my_finance1/View/chip_select.dart';
import 'drawer.dart';
import 'package:pie_chart/pie_chart.dart';

class Graph extends StatefulWidget {
  const Graph({super.key});

  @override
  State createState() => _GraphState();
}

class _GraphState extends State {
  final CategoryController categoryController = Get.find<CategoryController>();
  final CategoryManager categorymanager = Get.find<CategoryManager>();
  final TransactionController _controller = Get.find<TransactionController>();
  double total = 0;
  Map<String, double> dataMap = {};
  Map<String, Color> categoryColorMap = {};

  @override
  void initState() {
    super.initState();
    calculateData();
  }

  void calculateData() {
    // Reset the map and total
    dataMap = {};
    categoryColorMap = {};
    total = 0;

    // Calculate total expenses
    for (var transaction in _controller.transactions) {
      // Only include expenses in the pie chart
      if (transaction.transactiontype == 'Expenses') {
        double amount = double.tryParse(transaction.amount) ?? 0;
        total += amount;

        // Add amount to category in dataMap
        if (dataMap.containsKey(transaction.categoryId)) {
          dataMap[transaction.categoryId] =
              (dataMap[transaction.categoryId] ?? 0) + amount;
        } else {
          dataMap[transaction.categoryId] = amount;
        }
      }
    }

    // Create a map of category colors
    for (var category in categorymanager.categoryChoices) {
      categoryColorMap[category.value] = category.color;
    }

    // If no data, provide default
    if (dataMap.isEmpty) {
      dataMap = {"No expenses": 100};
    }
  }

  // Get color for category
  Color getCategoryColor(String categoryId) {
    return categoryColorMap[categoryId] ?? Colors.grey;
  }

  // Find category image URL by categoryId
  String getCategoryImageUrl(String categoryId) {
    for (var category in categorymanager.categoryChoices) {
      if (category.value == categoryId) {
        return category.categoryImageUrl;
      }
    }
    return ""; // Default or placeholder URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text(
          "Expense Analytics",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Obx(() {
        // Recalculate when transactions change
        if (_controller.transactions.isNotEmpty) {
          calculateData();
        }

        return Column(
          children: [
            const SizedBox(height: 20),
            dataMap.isEmpty
                ? const Center(child: Text("No expense data available"))
                : PieChart(
                  animationDuration: const Duration(milliseconds: 1500),
                  dataMap: dataMap,
                  chartLegendSpacing: 32,
                  chartRadius: MediaQuery.of(context).size.width / 2.2,
                  initialAngleInDegree: 0,
                  chartType: ChartType.ring,
                  ringStrokeWidth: 40,
                  centerText: "Total\n₹${total.toStringAsFixed(2)}",
                  legendOptions: LegendOptions(
                    showLegendsInRow: false,
                    legendPosition: LegendPosition.right,
                    showLegends: true,
                    legendShape: BoxShape.circle,
                    legendTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValueBackground: false,
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                    showChartValuesOutside: false,
                    decimalPlaces: 1,
                  ),
                  colorList:
                      dataMap.keys.map((key) => getCategoryColor(key)).toList(),
                ),
            const SizedBox(height: 20),
            const Divider(thickness: 0.3, color: Color.fromRGBO(0, 0, 0, 0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Expense Breakdown",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              child:
                  _controller.transactions.isEmpty
                      ? Center(
                        child: Text(
                          "No transactions found",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                      : ListView.separated(
                        itemCount: _controller.transactions.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(height: 1);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final transaction = _controller.transactions[index];
                          final categoryImageUrl = getCategoryImageUrl(
                            transaction.categoryId,
                          );

                          return ListTile(
                            leading: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                //color: getCategoryColor(transaction.categoryId),
                                shape: BoxShape.circle,
                              ),
                              child:
                                  categoryImageUrl.isNotEmpty
                                      ? Image.network(categoryImageUrl)
                                      : Icon(
                                        Icons.category,
                                        color: getCategoryColor(
                                          transaction.categoryId,
                                        ),
                                      ),
                            ),
                            title: Text(
                              transaction.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              "${transaction.categoryId} • ${transaction.date}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              "₹${transaction.amount}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    transaction.transactiontype == 'Income'
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Expenses",
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    "₹${total.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
