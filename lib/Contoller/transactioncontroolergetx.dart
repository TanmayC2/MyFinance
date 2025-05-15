import 'dart:developer';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_finance1/Contoller/SessionData.dart';
import 'package:my_finance1/Model/transactionmodel.dart';
import 'package:my_finance1/Contoller/databaseconn/dbhelper.dart';
import 'package:my_finance1/View/chip_select.dart';

class TransactionController extends GetxController {
  final RxInt userId = 0.obs;
  Future<void> getuserId() async {
    try {
      int id = await DatabaseHelper.instance.getUserIdByEmail(
        SessionData.emailId!,
      );
      fetchTransactions(userId.value);
      log('User ID retrieved: $id');
      // Update the reactive userId
      userId.value = id;
      log('User ID retrieved: ${userId.value}');
    } catch (e) {
      log('Error getting user ID: $e');
      // Handle error
    }
  }

  // Reactive list of transactions
  final RxList<UserTransaction> transactions = <UserTransaction>[].obs;
  final CategoryManager categoryManager = Get.put(CategoryManager());
  Rx<String> selectedType = "".obs; // Holds the selected chip value
  Rx<String> selectedCategoryType = "".obs;
  final Rx<String> _activeFilter = ''.obs;

  // Getter for active filter
  String get activeFilter => _activeFilter.value;

  // Setter for active filter
  set activeFilter(String filter) => _activeFilter.value = filter;

  // Database helper
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  setType(String selectedvalue) {
    selectedType.value = selectedvalue;
    update();
    return selectedType.value;
  }

  setCategoryType(String selectedCategoryvalue) {
    selectedCategoryType.value = selectedCategoryvalue;
    update();
    return selectedCategoryType.value;
  }

  //to check true or false
  bool isTypeSelected(String type) {
    return selectedType.value == type;
  }

  // Helper function for checking selected category type in Obx
  bool isCategoryTypeSelected(String categoryValue) {
    return selectedCategoryType.value == categoryValue;
  }

  // Fetching transactions
  Future<void> fetchTransactions(int userId) async {
    try {
      final fetchedTransactions = await _dbHelper.getTransactionData(userId);
      transactions.assignAll(fetchedTransactions);
    } catch (e) {
      log('Error fetching transactions: $e');
      transactions.clear();
    }
  }

  // Add new transaction
  Future<void> addTransaction(UserTransaction transaction, int userId) async {
    // Get the category image URL from CategoryManager
    final category = categoryManager.categoryChoices.firstWhereOrNull(
      (c) => c.value == transaction.categoryId,
    );
    try {
      final transactionWithImage = UserTransaction(
        userId: userId,
        transactionid: transaction.transactionid,
        title: transaction.title,
        amount: transaction.amount,
        transactiontype: transaction.transactiontype,
        categoryId: transaction.categoryId,
        categoryImageUrl: category?.categoryImageUrl ?? '', // Add image URL
        date: transaction.date,
      );

      await _dbHelper.insertTransactionData(transactionWithImage, userId);
      await fetchTransactions(userId);
    } catch (e) {
      log('Error adding transaction: $e');
    }
  }

  // Update existing transaction
  Future<void> updateTransaction(UserTransaction transaction, userId) async {
    try {
      await _dbHelper.updateTransactionData(transaction, userId);
      await fetchTransactions(userId);
    } catch (e) {
      log('Error updating transaction: $e');
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(UserTransaction transaction, userId) async {
    try {
      await _dbHelper.deleteTransactionData(transaction);
      await fetchTransactions(userId);
    } catch (e) {
      log('Error deleting transaction: $e');
    }
  }

  // Method to get grouped transactions based on filter
  Map<String, List<UserTransaction>> getGroupedTransactions({
    String? filterType,
  }) {
    // Apply filter if provided
    final filteredTransactions =
        filterType != null && filterType != "All"
            ? transactions.where((t) => matchesFilter(t, filterType)).toList()
            : transactions;

    // Group transactions by date
    return _groupTransactions(filteredTransactions);
  }

  bool matchesFilter(UserTransaction transaction, String filter) {
    // Convert transaction.date string to DateTime
    DateTime transactionDate;
    try {
      transactionDate = DateFormat.yMMMd().parse(transaction.date);
    } catch (e) {
      transactionDate = DateTime.now();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    switch (filter.toLowerCase()) {
      case 'income':
        return transaction.transactiontype.toLowerCase() == "income";
      case 'expenses':
        return transaction.transactiontype.toLowerCase() == "expenses";
      case 'today':
        return transactionDate.year == today.year &&
            transactionDate.month == today.month &&
            transactionDate.day == today.day;
      case 'this week':
        return transactionDate.isAfter(weekAgo);
      case 'this month':
        return transactionDate.isAfter(monthAgo);
      default:
        return true;
    }
  }

  // Helper method to group transactions
  Map<String, List<UserTransaction>> _groupTransactions(
    List<UserTransaction> transactions,
  ) {
    final grouped = <String, List<UserTransaction>>{};

    for (final transaction in transactions) {
      // Format the date consistently
      String dateKey;
      try {
        final date = DateFormat.yMMMd().parse(transaction.date);
        dateKey = DateFormat.yMMMd().format(date);
      } catch (e) {
        dateKey = transaction.date;
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    // Sort by date (newest first)
    final sortedKeys =
        grouped.keys.toList()..sort((a, b) {
          try {
            final dateA = DateFormat.yMMMd().parse(a);
            final dateB = DateFormat.yMMMd().parse(b);
            return dateB.compareTo(dateA);
          } catch (e) {
            return 0;
          }
        });

    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  //Summary
  //
  //For all Transactions
  Map<String, double> getTransactionSummary({String? filterType}) {
    final transactions = getGroupedTransactions(filterType: filterType);

    double income = 0;
    double expenses = 0;

    // Flatten all grouped transactions and calculate totals
    for (var group in transactions.values) {
      for (final transaction in group) {
        if (transaction.transactiontype == "Income") {
          income += double.parse(transaction.amount);
        } else {
          expenses += double.parse(transaction.amount);
        }
      }
    }

    return {
      'income': income,
      'expenses': expenses,
      'balance': income - expenses,
    };
  }
}
