import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import 'package:my_finance1/Contoller/categorycontrollergetx.dart';
import 'package:my_finance1/Contoller/transactioncontroolergetx.dart';
import 'package:my_finance1/View/chip_select.dart';

class BarChartPainter extends CustomPainter {
  final List<String> months;
  final Map<String, Map<String, double>> data;
  final double maxValue;

  BarChartPainter(this.months, this.data) : maxValue = _calculateMaxValue(data);

  static double _calculateMaxValue(Map<String, Map<String, double>> data) {
    double max = 0;
    for (final monthData in data.values) {
      final monthMax =
          (monthData['Income'] ?? 0) + (monthData['Expenses'] ?? 0);
      if (monthMax > max) max = monthMax;
    }
    return max * 1.2; // Add 20% padding
  }

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (months.length * 3);
    final padding = barWidth * 0.5;
    final heightUnit = size.height / maxValue;

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 10,
      fontWeight: FontWeight.normal,
    );

    // Draw bars
    for (var i = 0; i < months.length; i++) {
      final month = months[i];
      final monthData = data[month] ?? {};
      final income = monthData['Income'] ?? 0;
      final expenses = monthData['Expenses'] ?? 0;

      final x = i * (barWidth * 2 + padding) + padding;

      // Income bar (green)
      _drawBar(
        canvas,
        x,
        size.height - income * heightUnit,
        barWidth,
        income * heightUnit,
        Colors.green,
      );

      // Expenses bar (red)
      _drawBar(
        canvas,
        x + barWidth,
        size.height - expenses * heightUnit,
        barWidth,
        expenses * heightUnit,
        Colors.red,
      );

      // Month label
      _drawText(
        canvas,
        month.substring(0, 3), // Short month name
        Offset(x + barWidth, size.height - 5),
        textStyle,
      );
    }
  }

  void _drawBar(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    Color color,
  ) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(x, y, width, height), paint);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      //  textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChart extends StatelessWidget {
  final List<String> months;
  final Map<String, Map<String, double>> data;
  final double height;

  const BarChart({
    super.key,
    required this.months,
    required this.data,
    this.height = 300,
  });

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: CustomPaint(
            size: Size.infinite,
            painter: BarChartPainter(months, data),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Income', Colors.green),
            const SizedBox(width: 24),
            _buildLegendItem('Expenses', Colors.red),
          ],
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  Map<String, double> dataMap;
  Map<String, Color> categoryColorMap = {};
  double total = 0;
  double strokeWidth;

  PieChartPainter({required this.dataMap, this.strokeWidth = 40.0});

  final CategoryController categoryController = Get.find<CategoryController>();
  final CategoryManager categoryManager = Get.find<CategoryManager>();
  final TransactionController transactionController =
      Get.find<TransactionController>();

  void calculateData() {
    // Reset the map and total
    categoryColorMap = {};
    total = 0;

    // Calculate total expenses
    for (var transaction in transactionController.transactions) {
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
    for (var category in categoryManager.categoryChoices) {
      categoryColorMap[category.value] = category.color;
    }

    // If no data, provide default
    if (dataMap.isEmpty) {
      dataMap = {"No expenses": 100};
      categoryColorMap["No expenses"] = Colors.grey;
      total = 100;
    }
  }

  // Get color for category
  Color getCategoryColor(String categoryId) {
    return categoryColorMap[categoryId] ?? Colors.grey;
  }

  // Find category image URL by categoryId
  String getCategoryImageUrl(String categoryId) {
    for (var category in categoryManager.categoryChoices) {
      if (category.value == categoryId) {
        return category.categoryImageUrl;
      }
    }
    return ""; // Default or placeholder URL
  }

  @override
  void paint(Canvas canvas, Size size) {
    calculateData(); // Calculate data before painting

    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (size.width < size.height ? size.width : size.height) / 2 -
        strokeWidth / 2;

    double startAngle = -pi / 2; // Start from top

    // Draw each segment
    dataMap.forEach((category, value) {
      final sweepAngle = (value / total) * 2 * pi;
      final color = categoryColorMap[category] ?? Colors.grey;

      // Draw segment
      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false, // false for stroke style
        paint,
      );

      // Only draw percentage if segment is large enough
      if (sweepAngle > 0.3) {
        final percentage = (value / total * 100).toStringAsFixed(1);

        // Use drawParagraph instead of TextPainter
        final builder =
            ParagraphBuilder(
                ParagraphStyle(
                  textAlign: TextAlign.center,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              )
              ..pushStyle(TextStyle(color: Colors.white).getTextStyle())
              ..addText('$percentage%');

        final paragraph =
            builder.build()..layout(
              ParagraphConstraints(width: 40),
            ); // 40 is width constraint for text

        // Position text in middle of segment
        final textAngle = startAngle + (sweepAngle / 2);
        final textRadius = radius * 0.6; // Position text slightly inward
        final textX = center.dx + textRadius * cos(textAngle);
        final textY = center.dy + textRadius * sin(textAngle);

        canvas.drawParagraph(
          paragraph,
          Offset(textX - paragraph.width / 2, textY - paragraph.height / 2),
        );
      }

      startAngle += sweepAngle;
    });

    // Draw inner circle (for ring chart effect)
    if (strokeWidth > 0) {
      final innerCirclePaint = Paint()..color = Colors.white;
      canvas.drawCircle(center, radius - strokeWidth / 2, innerCirclePaint);
    }

    // Draw total text in center using drawParagraph
    final totalTextBuilder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          )
          ..pushStyle(TextStyle(color: Colors.black).getTextStyle())
          ..addText('Total\n')
          ..addText('₹${total.toStringAsFixed(2)}');

    final totalParagraph =
        totalTextBuilder.build()..layout(ParagraphConstraints(width: radius));

    canvas.drawParagraph(
      totalParagraph,
      Offset(
        center.dx - totalParagraph.width / 2,
        center.dy - totalParagraph.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
