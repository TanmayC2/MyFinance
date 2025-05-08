import 'dart:developer';
import 'package:get/get.dart';
import 'package:my_finance1/Model/transactionmodel.dart';
import 'package:my_finance1/Contoller/databaseconn/dbhelper.dart';
import 'package:my_finance1/View/chip_select.dart';

class TransactionController extends GetxController {
  // Reactive list of transactions
  final RxList<UserTransaction> transactions = <UserTransaction>[].obs;
  final CategoryManager categoryManager = Get.find<CategoryManager>();
  Rx<String> selectedType = "".obs; // Holds the selected chip value
  Rx<String> selectedCategoryType = "".obs;

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
  Future<void> fetchTransactions() async {
    try {
      final fetchedTransactions = await _dbHelper.getTransactionData();
      transactions.assignAll(fetchedTransactions);
    } catch (e) {
      log('Error fetching transactions: $e');
      transactions.clear();
    }
  }

  // Add new transaction
  Future<void> addTransaction(UserTransaction transaction) async {
    // Get the category image URL from CategoryManager
    final category = categoryManager.categoryChoices.firstWhereOrNull(
      (c) => c.value == transaction.categoryId,
    );
    try {
      final transactionWithImage = UserTransaction(
        transactionid: transaction.transactionid,
        title: transaction.title,
        amount: transaction.amount,
        transactiontype: transaction.transactiontype,
        categoryId: transaction.categoryId,
        categoryImageUrl: category?.categoryImageUrl ?? '', // Add image URL
        date: transaction.date,
      );

      await _dbHelper.insertTransactionData(transactionWithImage);
      await fetchTransactions();
    } catch (e) {
      log('Error adding transaction: $e');
    }
  }

  // Update existing transaction
  Future<void> updateTransaction(UserTransaction transaction) async {
    try {
      await _dbHelper.updateTransactionData(transaction);
      await fetchTransactions();
    } catch (e) {
      log('Error updating transaction: $e');
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(UserTransaction transaction) async {
    try {
      await _dbHelper.deleteTransactionData(transaction);
      await fetchTransactions();
    } catch (e) {
      log('Error deleting transaction: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }
}
