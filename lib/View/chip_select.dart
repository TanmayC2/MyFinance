import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_finance1/Model/categorymodelgetx.dart';
import 'package:my_finance1/Contoller/categorycontrollergetx.dart';

class CategoryChoice {
  final String label;
  final String value;
  final Color color;
  final String categoryImageUrl;
  final bool isIncome; // Add this property

  CategoryChoice({
    required this.label,
    required this.value,
    required this.color,
    required this.categoryImageUrl,
    required this.isIncome, // Add to constructor
  });

  // Remove the getter that returns null
}

class CategoryManager extends GetxController {
  // Original static list (will be replaced with dynamic data)
  final RxList<CategoryChoice> categoryChoices = <CategoryChoice>[].obs;

  // Reference to your category controller that has the Firebase data
  final CategoryController _categoryController = Get.put(CategoryController());

  @override
  void onInit() {
    super.onInit();
    // Listen for changes in the categoryList from Firebase
    ever(_categoryController.categoryList, _updateCategoryChoices);
    // Initial fetch from Firebase
    _updateCategoryChoices(_categoryController.categoryList);
  }

  // Update category choices whenever the Firebase list changes
  void _updateCategoryChoices(List<CategoryModal> firebaseCategories) {
    List<CategoryChoice> updatedChoices =
        firebaseCategories.map((category) {
          return CategoryChoice(
            categoryImageUrl: category.categoryImageUrl,
            label: category.name,
            value: category.name,
            color: _parseColor(category.color),
            isIncome:
                category.type ==
                'Income', // Add this based on your CategoryModal
          );
        }).toList();

    categoryChoices.assignAll(updatedChoices);
  }

  Color _parseColor(String colorString) {
    final colorName = colorString.trim().toLowerCase();

    // Extended color map with more variations
    final colorMap = {
      'red': Colors.red,
      'red accent': Colors.redAccent,
      'pink': Colors.pink,
      'pink accent': Colors.pinkAccent,
      'purple': Colors.purple,
      'purple accent': Colors.purpleAccent,
      'deep purple': Colors.deepPurple,
      'deep purple accent': Colors.deepPurpleAccent,
      'indigo': Colors.indigo,
      'indigo accent': Colors.indigoAccent,
      'blue': Colors.blue,
      'blue accent': Colors.blueAccent,
      'light blue': Colors.lightBlue,
      'light blue accent': Colors.lightBlueAccent,
      'cyan': Colors.cyan,
      'cyan accent': Colors.cyanAccent,
      'teal': Colors.teal,
      'teal accent': Colors.tealAccent,
      'green': Colors.green,
      'green accent': Colors.greenAccent,
      'light green': Colors.lightGreen,
      'light green accent': Colors.lightGreenAccent,
      'lime': Colors.lime,
      'lime accent': Colors.limeAccent,
      'yellow': Colors.yellow,
      'yellow accent': Colors.yellowAccent,
      'amber': Colors.amber,
      'amber accent': Colors.amberAccent,
      'orange': Colors.orange,
      'orange accent': Colors.orangeAccent,
      'deep orange': Colors.deepOrange,
      'deep orange accent': Colors.deepOrangeAccent,
      'brown': Colors.brown,
      'grey': Colors.grey,
      'blue grey': Colors.blueGrey,
      'black': Colors.black,
      'white': Colors.white,
      'transparent': Colors.transparent,
    };

    // Try to find the color
    final color = colorMap[colorName];

    // If not found, try to parse as hex code
    if (color == null) {
      try {
        if (colorString.startsWith('#')) {
          return Color(int.parse('0xFF${colorString.substring(1)}'));
        }
        return Colors.blue; // Default color
      } catch (e) {
        return Colors.blue; // Default color
      }
    }

    return color;
  }

  List<CategoryChoice> getIncomeCategories() {
    return categoryChoices.where((c) => c.isIncome).toList();
  }

  List<CategoryChoice> getExpenseCategories() {
    return categoryChoices.where((c) => !c.isIncome).toList();
  }
}
