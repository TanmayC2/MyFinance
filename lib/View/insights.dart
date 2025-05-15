import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_finance1/Contoller/transactioncontroolergetx.dart';
import 'package:my_finance1/Model/transactionmodel.dart';
import 'package:my_finance1/View/barchartdetails.dart';
import 'package:my_finance1/View/chip_select.dart';

class InsightsDetails {
  final CategoryManager categoryManager = Get.put(CategoryManager());
  final TransactionController _controller = Get.put(TransactionController());

  void showInsightsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    'Financial Insights',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Insights content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildInsightSection(
                          "Spending by Category",
                          _buildCategoryExpensesChart(),
                        ),
                        const SizedBox(height: 24),
                        _buildInsightSection(
                          "Income vs Expenses",
                          _buildIncomeExpensesChart(context),
                        ),
                        const SizedBox(height: 24),
                        _buildInsightSection(
                          "Monthly Overview",
                          _buildMonthlyOverview(),
                        ),
                        const SizedBox(height: 24),
                        _buildInsightSection(
                          "Top Spending Categories",
                          _buildTopSpendingCategories(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInsightSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildCategoryExpensesChart() {
    return Obx(() {
      if (_controller.transactions.isEmpty) {
        return _buildEmptyInsightState("No data to display");
      }

      // Generate category data
      final expenseTransactions =
          _controller.transactions
              .where((t) => t.transactiontype == "Expenses")
              .toList();

      if (expenseTransactions.isEmpty) {
        return _buildEmptyInsightState("No expense data to display");
      }

      // Get unique categories and their total amounts
      final Map<String, double> categoryTotals = {};
      for (var transaction in expenseTransactions) {
        if (categoryTotals.containsKey(transaction.categoryId)) {
          categoryTotals[transaction.categoryId] =
              categoryTotals[transaction.categoryId]! +
              double.parse(transaction.amount);
        } else {
          categoryTotals[transaction.categoryId] = double.parse(
            transaction.amount,
          );
        }
      }

      // Create pie chart segments
      return Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: PieChartPainter(dataMap: categoryTotals),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children:
                  categoryTotals.entries.map((entry) {
                    final category = categoryManager.categoryChoices
                        .firstWhereOrNull((c) => c.value == entry.key);
                    final color =
                        category != null ? category.color : Colors.grey;

                    return Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildIncomeExpensesChart(BuildContext context) {
    return Obx(() {
      // Early return for empty state
      if (_controller.transactions.isEmpty) {
        return _buildEmptyInsightState("No transactions to display");
      }

      try {
        // Process transaction data
        final monthlyData = _processMonthlyData(_controller.transactions);

        // Return the chart with proper error handling
        return _buildChartContainer(monthlyData, context);
      } catch (e) {
        debugPrint('Error building income/expenses chart: $e');
        return _buildEmptyInsightState("Could not display chart data");
      }
    });
  }

  Map<String, Map<String, double>> _processMonthlyData(
    List<UserTransaction> transactions,
  ) {
    final monthlyData = <String, Map<String, double>>{};

    for (final transaction in transactions) {
      try {
        final date = DateFormat.yMMMd().parse(transaction.date);
        final monthYear = DateFormat('MMM yyyy').format(date);

        monthlyData.putIfAbsent(monthYear, () => {'Income': 0, 'Expenses': 0});

        final amount = double.tryParse(transaction.amount) ?? 0;
        final typeKey =
            transaction.transactiontype == "Income" ? 'Income' : 'Expenses';

        monthlyData[monthYear]![typeKey] =
            monthlyData[monthYear]![typeKey]! + amount;
      } catch (e) {
        debugPrint('Error processing transaction: $e');
        continue;
      }
    }

    return monthlyData;
  }

  List<String> _getSortedMonths(Map<String, Map<String, double>> monthlyData) {
    return monthlyData.keys.toList()..sort((a, b) {
      try {
        final dateA = DateFormat('MMM yyyy').parse(a);
        final dateB = DateFormat('MMM yyyy').parse(b);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });
  }

  Widget _buildChartContainer(
    Map<String, Map<String, double>> monthlyData,
    BuildContext context,
  ) {
    final sortedMonths = _getSortedMonths(monthlyData);

    // Filter to show only last 6 months for better readability
    final displayMonths =
        sortedMonths.length > 6
            ? sortedMonths.sublist(sortedMonths.length - 6)
            : sortedMonths;

    final displayData = {
      for (final month in displayMonths)
        month: monthlyData[month] ?? {'Income': 0, 'Expenses': 0},
    };

    return Container(
      height: 280, // Slightly reduced height
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Adjusted padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Income vs Expenses',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              months: displayMonths,
              data: displayData,
              height: 200, // Fixed height for chart area
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview() {
    return Obx(() {
      if (_controller.transactions.isEmpty) {
        return _buildEmptyInsightState("No data to display");
      }

      // Get current month's data
      final now = DateTime.now();
      final currentMonth = DateFormat('MMM yyyy').format(now);

      double totalIncome = 0;
      double totalExpenses = 0;

      for (var transaction in _controller.transactions) {
        try {
          final date = DateFormat.yMMMd().parse(transaction.date);
          final monthYear = DateFormat('MMM yyyy').format(date);

          if (monthYear == currentMonth) {
            if (transaction.transactiontype == "Income") {
              totalIncome += double.parse(transaction.amount);
            } else if (transaction.transactiontype == "Expenses") {
              totalExpenses += double.parse(transaction.amount);
            }
          }
        } catch (e) {
          // Handle date parsing errors
        }
      }

      final balance = totalIncome - totalExpenses;
      final savingsRate =
          totalIncome > 0
              ? ((totalIncome - totalExpenses) / totalIncome * 100)
              : 0;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              "Summary for $currentMonth",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildOverviewItem(
              "Total Income",
              "₹${totalIncome.toStringAsFixed(2)}",
              Icons.arrow_upward,
              Colors.green,
            ),
            const Divider(),
            _buildOverviewItem(
              "Total Expenses",
              "₹${totalExpenses.toStringAsFixed(2)}",
              Icons.arrow_downward,
              Colors.red,
            ),
            const Divider(),
            _buildOverviewItem(
              "Balance",
              "₹${balance.toStringAsFixed(2)}",
              balance >= 0 ? Icons.check_circle : Icons.warning,
              balance >= 0 ? Colors.green : Colors.orange,
            ),
            const Divider(),
            _buildOverviewItem(
              "Savings Rate",
              "${savingsRate.toStringAsFixed(1)}%",
              Icons.savings,
              Colors.blue,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOverviewItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSpendingCategories() {
    return Obx(() {
      if (_controller.transactions.isEmpty) {
        return _buildEmptyInsightState("No data to display");
      }

      // Filter expense transactions
      final expenseTransactions =
          _controller.transactions
              .where((t) => t.transactiontype == "Expenses")
              .toList();

      if (expenseTransactions.isEmpty) {
        return _buildEmptyInsightState("No expense data to display");
      }

      // Get category totals
      final Map<String, double> categoryTotals = {};
      for (var transaction in expenseTransactions) {
        if (categoryTotals.containsKey(transaction.categoryId)) {
          categoryTotals[transaction.categoryId] =
              categoryTotals[transaction.categoryId]! +
              double.parse(transaction.amount);
        } else {
          categoryTotals[transaction.categoryId] = double.parse(
            transaction.amount,
          );
        }
      }

      // Sort categories by amount
      final sortedCategories =
          categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      // Get top 5 categories
      final topCategories = sortedCategories.take(5).toList();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            for (var entry in topCategories)
              _buildTopCategoryItem(entry.key, entry.value),
          ],
        ),
      );
    });
  }

  Widget _buildTopCategoryItem(String category, double amount) {
    // Find category color
    final categoryObj = categoryManager.categoryChoices.firstWhereOrNull(
      (c) => c.value == category,
    );
    final color = categoryObj != null ? categoryObj.color : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Icon(_getCategoryIcon(category), color: color, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: amount / 10000, // Normalize to some max value
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "₹${amount.toStringAsFixed(0)}",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    // Map category IDs to appropriate icons
    switch (categoryId.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transportation':
        return Icons.directions_car;
      case 'utilities':
        return Icons.water_drop;
      case 'housing':
        return Icons.home;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.category;
    }
  }

  Widget _buildEmptyInsightState(String message) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
