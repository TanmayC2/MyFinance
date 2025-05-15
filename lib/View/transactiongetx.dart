//import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_finance1/Contoller/transactioncontroolergetx.dart';
import 'package:my_finance1/Model/transactionmodel.dart';
import 'package:my_finance1/View/chip_select.dart';
import 'package:my_finance1/View/search.dart';
import 'package:my_finance1/View/drawer.dart';

class Transaction extends StatefulWidget {
  const Transaction({super.key});

  @override
  State createState() => _TransactionState();
}

class _TransactionState extends State {
  final CategoryManager categoryManager = Get.put(CategoryManager());
  final TransactionController _controller = Get.put(TransactionController());

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _dateController.dispose();
    _amountController.dispose();
  }

  void clearController() {
    _titleController.clear();
    _amountController.clear();
    _dateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "MY FINANCE",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: Colors.green,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 25),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionSearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              _buildWelcomeSection(constraints),
              Expanded(
                child: Obx(() {
                  if (_controller.transactions.isEmpty) {
                    return const Center(child: Text("No transactions found"));
                  }
                  return ListView.builder(
                    itemCount: _controller.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _controller.transactions[index];
                      return _buildTransactionItem(
                        context,
                        transaction,
                        index,
                        constraints,
                      );
                    },
                  );
                }),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        onPressed: () => _showAddTransactionBottomSheet(context),
        icon: const Icon(
          Icons.add_circle_rounded,
          color: Colors.green,
          size: 35,
        ),
        label: const Text("Add Transaction"),
      ),
    );
  }

  //--------------------------------------------

  Widget _buildWelcomeSection(BoxConstraints constraints) {
    double fontSize = constraints.maxWidth < 350 ? 25 : 35;
    double subheadingSize = constraints.maxWidth < 350 ? 18 : 24;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: constraints.maxWidth * 0.06,
        vertical: 5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome",
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "Let's Manage Your Finances",
            style: TextStyle(
              fontSize: subheadingSize,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    UserTransaction transaction,
    int index,
    BoxConstraints constraints,
  ) {
    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const DrawerMotion(),
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  onTap:
                      () =>
                          _showEditTransactionBottomSheet(context, transaction),
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  onTap: () => _controller.deleteTransaction(transaction),
                ),
              ],
            ),
          ),
        ],
      ),
      child: _buildTransactionContent(transaction, constraints),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTransactionImage(bool isSmallScreen, String? imageUrl) {
    double size = isSmallScreen ? 50 : 70;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        image:
            imageUrl != null && imageUrl.isNotEmpty
                ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child:
          imageUrl == null || imageUrl.isEmpty
              ? Icon(Icons.category, size: size * 0.5)
              : null,
    );
  }

  // Update the usage in _buildTransactionContent:
  Widget _buildTransactionContent(
    UserTransaction transaction,
    BoxConstraints constraints,
  ) {
    bool isSmallScreen = constraints.maxWidth < 350;

    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            _buildTransactionImage(isSmallScreen, transaction.categoryImageUrl),
            const SizedBox(width: 10),
            _buildTransactionDetails(transaction, isSmallScreen),
            _buildTransactionAmount(transaction, isSmallScreen),
          ],
        ),
        _buildTransactionDate(transaction),
      ],
    );
  }

  Widget _buildTransactionDetails(
    UserTransaction transaction,
    bool isSmallScreen,
  ) {
    double titleSize = isSmallScreen ? 16 : 20;
    double categorySize = isSmallScreen ? 14 : 16;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: titleSize,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            transaction.categoryId,
            style: GoogleFonts.poppins(
              fontSize: categorySize,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionAmount(
    UserTransaction transaction,
    bool isSmallScreen,
  ) {
    double fontSize = isSmallScreen ? 14 : 16;

    return Row(
      children: [
        Icon(
          Icons.account_balance_sharp,
          color:
              (transaction.transactiontype == "Income")
                  ? Colors.green[300]
                  : Colors.red[400],
        ),
        const SizedBox(width: 10),
        Text(
          "₹${transaction.amount}",
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color:
                (transaction.transactiontype == "Income")
                    ? Colors.green[600]
                    : Colors.red[400],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildTransactionDate(UserTransaction transaction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          transaction.date,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color:
                (transaction.transactiontype == "Income")
                    ? Colors.green[300]
                    : Colors.red[400],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  void _showAddTransactionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Add Transaction",
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Transaction Type Chips - Improved layout
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Transaction Type:",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            return Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('Income'),
                                  selected: _controller.isTypeSelected(
                                    "Income",
                                  ),
                                  selectedColor: Colors.green,
                                  onSelected: (bool selected) {
                                    _controller.setType(
                                      selected ? 'Income' : '',
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                ChoiceChip(
                                  label: const Text('Expenses'),
                                  selected: _controller.isTypeSelected(
                                    'Expenses',
                                  ),
                                  selectedColor: Colors.red,
                                  onSelected: (bool selected) {
                                    _controller.setType(
                                      selected ? 'Expenses' : '',
                                    );
                                  },
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Category Chips - Fixed to allow only one selection
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Category:",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                                  categoryManager.categoryChoices.map((
                                    category,
                                  ) {
                                    return ChoiceChip(
                                      label: Text(
                                        category.label,
                                        style: TextStyle(
                                          color:
                                              _controller
                                                          .selectedCategoryType
                                                          .value ==
                                                      category.value
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                      //backgroundColor: category.color,
                                      selectedColor: category.color,

                                      selected:
                                          _controller
                                              .selectedCategoryType
                                              .value ==
                                          category.value,
                                      onSelected: (bool selected) {
                                        if (selected) {
                                          _controller.setCategoryType(
                                            category.value,
                                          );
                                        } else {
                                          _controller.setCategoryType('');
                                        }
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          barrierColor: Colors.green,
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );

                        if (pickedDate != null) {
                          _dateController.text = DateFormat.yMMMd().format(
                            pickedDate,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: constraints.maxWidth > 400 ? 200 : double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          textStyle: WidgetStatePropertyAll(
                            GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          backgroundColor: WidgetStatePropertyAll(Colors.green),
                        ),
                        onPressed: () {
                          // Validate and add transaction
                          if (_titleController.text.isNotEmpty &&
                              _amountController.text.isNotEmpty &&
                              _controller.selectedType.isNotEmpty &&
                              _controller.selectedCategoryType.isNotEmpty &&
                              _dateController.text.isNotEmpty) {
                            // Get the selected category
                            final selectedCategory = categoryManager
                                .categoryChoices
                                .firstWhere(
                                  (c) =>
                                      c.value ==
                                      _controller.selectedCategoryType.value,
                                );

                            final newTransaction = UserTransaction(
                              title: _titleController.text,
                              amount: _amountController.text,
                              transactiontype: _controller.selectedType.value,
                              categoryId:
                                  _controller.selectedCategoryType.value,
                              categoryImageUrl:
                                  selectedCategory
                                      .categoryImageUrl, // Add image URL
                              date: _dateController.text,
                            );

                            _controller.addTransaction(newTransaction);
                            _controller.fetchTransactions();
                            clearController();
                            Navigator.of(context).pop();
                          } else {
                            // Show error or validation message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                              ),
                            );
                          }
                        },
                        child: const Text('Add Transaction'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTransactionBottomSheet(
    BuildContext context,
    UserTransaction transaction,
  ) {
    final titleController = TextEditingController(text: transaction.title);
    final amountController = TextEditingController(text: transaction.amount);
    final dateController = TextEditingController(text: transaction.date);

    _controller.selectedType.value = transaction.transactiontype;
    _controller.selectedCategoryType.value = transaction.categoryId;

    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "Edit Transaction",
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Transaction Type Chips - Improved layout
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Transaction Type:",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            return Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('Income'),
                                  selected: _controller.isTypeSelected(
                                    "Income",
                                  ),
                                  selectedColor: Colors.green,
                                  onSelected: (bool selected) {
                                    _controller.setType(
                                      selected ? 'Income' : '',
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                ChoiceChip(
                                  label: const Text('Expenses'),
                                  selected: _controller.isTypeSelected(
                                    'Expenses',
                                  ),
                                  selectedColor: Colors.red,
                                  onSelected: (bool selected) {
                                    _controller.setType(
                                      selected ? 'Expenses' : '',
                                    );
                                  },
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Category Chips - Improved layout
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Category:",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                                  categoryManager.categoryChoices.map((
                                    category,
                                  ) {
                                    return ChoiceChip(
                                      label: Text(
                                        category.label,
                                        style: TextStyle(
                                          color:
                                              _controller
                                                          .selectedCategoryType
                                                          .value ==
                                                      category.value
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                      //backgroundColor: category.color,
                                      selectedColor: category.color,

                                      selected:
                                          _controller
                                              .selectedCategoryType
                                              .value ==
                                          category.value,
                                      onSelected: (bool selected) {
                                        if (selected) {
                                          _controller.setCategoryType(
                                            category.value,
                                          );
                                        } else {
                                          _controller.setCategoryType('');
                                        }
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: 'Edit Date',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          barrierColor: Colors.green,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );

                        if (pickedDate != null) {
                          dateController.text = DateFormat.yMMMd().format(
                            pickedDate,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: constraints.maxWidth > 400 ? 200 : double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          textStyle: WidgetStatePropertyAll(
                            GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          backgroundColor: WidgetStatePropertyAll(Colors.green),
                        ),
                        onPressed: () {
                          // Validate and update transaction

                          //
                          if (titleController.text.isNotEmpty &&
                              amountController.text.isNotEmpty &&
                              _controller.selectedType.isNotEmpty &&
                              _controller.selectedCategoryType.isNotEmpty &&
                              dateController.text.isNotEmpty) {
                            // Get the selected category
                            final selectedCategory = categoryManager
                                .categoryChoices
                                .firstWhere(
                                  (c) =>
                                      c.value ==
                                      _controller.selectedCategoryType.value,
                                );

                            final updatedTransaction = UserTransaction(
                              transactionid: transaction.transactionid,
                              title: titleController.text,
                              amount: amountController.text,
                              transactiontype: _controller.selectedType.value,
                              categoryId:
                                  _controller.selectedCategoryType.value,
                              categoryImageUrl:
                                  selectedCategory
                                      .categoryImageUrl, // Update image URL
                              date: dateController.text,
                            );

                            _controller.updateTransaction(updatedTransaction);
                            _controller.fetchTransactions();
                            clearController();
                            Navigator.of(context).pop();
                          } else {
                            // Show error or validation message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                              ),
                            );
                          }
                        },
                        child: const Text('Update Transaction'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
