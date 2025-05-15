import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_finance1/Contoller/transactioncontroolergetx.dart';
import 'package:my_finance1/Model/transactionmodel.dart';
import 'package:my_finance1/View/chip_select.dart';
import 'package:my_finance1/View/insights.dart';
import 'package:my_finance1/View/search.dart';
import 'package:my_finance1/View/drawer.dart';

class Transaction extends StatefulWidget {
  const Transaction({super.key});

  @override
  State createState() => _TransactionState();
}

class _TransactionState extends State {
  InsightsDetails obj = InsightsDetails();
  final CategoryManager categoryManager = Get.put(CategoryManager());
  final TransactionController _controller = Get.put(TransactionController());

  final ScrollController _scrollController = ScrollController();
  bool _showWelcome = true;

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _searchController = TextEditingController();

  // Active filter options
  final RxString _activeFilter = "All".obs;

  @override
  void initState() {
    super.initState();
    _controller.getuserId();
    _controller.fetchTransactions(_controller.userId.value);
    log("${_controller.userId.value}");
    // Set today's date as default
    _scrollController.addListener(() {
      // Hide welcome message when scrolling down, show when at top
      _showWelcome = _scrollController.position.pixels <= 0;
    });
    _dateController.text = DateFormat.yMMMd().format(DateTime.now());
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _searchController.dispose();
  }

  void clearController() {
    _titleController.clear();
    _amountController.clear();
    // Reset to today's date
    _dateController.text = DateFormat.yMMMd().format(DateTime.now());
  }

  void _addTransaction(BuildContext context) {
    // Validate inputs
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _controller.selectedType.value.isEmpty ||
        _controller.selectedCategoryType.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Create transaction object
    final transaction = UserTransaction(
      title: _titleController.text,
      amount: _amountController.text,
      transactiontype: _controller.selectedType.value,
      categoryId: _controller.selectedCategoryType.value,
      categoryImageUrl: '', // Will be set in controller
      date: _dateController.text,
    );

    // Add transaction and close bottom sheet
    _controller.addTransaction(transaction, _controller.userId.value);
    clearController();
    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction added successfully',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateTransaction(
    BuildContext context,
    UserTransaction transaction,
    TextEditingController titleController,
    TextEditingController amountController,
    TextEditingController dateController,
  ) {
    // Validate inputs
    if (titleController.text.isEmpty ||
        amountController.text.isEmpty ||
        _controller.selectedType.value.isEmpty ||
        _controller.selectedCategoryType.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Get category image URL
    final category = categoryManager.categoryChoices.firstWhereOrNull(
      (c) => c.value == _controller.selectedCategoryType.value,
    );

    // Create updated transaction
    final updatedTransaction = UserTransaction(
      transactionid: transaction.transactionid,
      title: titleController.text,
      amount: amountController.text,
      transactiontype: _controller.selectedType.value,
      categoryId: _controller.selectedCategoryType.value,
      categoryImageUrl: category?.categoryImageUrl ?? '',
      date: _dateController.text,
    );

    // Update transaction and close bottom sheet
    _controller.updateTransaction(updatedTransaction, _controller.userId.value);
    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction updated successfully',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: CustomDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              _buildFilterChips(),
              // Only show welcome section when at top or no transactions
              (_showWelcome && _controller.transactions.isEmpty)
                  ? _buildWelcomeSection(constraints)
                  : const SizedBox(),

              _buildSummaryCards(),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Transactions',

                      textAlign: TextAlign.start,

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Obx(() {
                  if (_controller.transactions.isEmpty) {
                    return _buildEmptyState();
                  }

                  final groupedTransactions = _controller
                      .getGroupedTransactions(
                        filterType:
                            _activeFilter.value == "All"
                                ? null
                                : _activeFilter.value,
                      );

                  if (groupedTransactions.isEmpty) {
                    return Center(
                      child: Text(
                        "No ${_activeFilter.value == 'All' ? '' : _activeFilter.value} transactions found",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollUpdateNotification) {
                        _showWelcome = _scrollController.position.pixels <= 0;
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: groupedTransactions.length,
                      itemBuilder: (context, index) {
                        final date = groupedTransactions.keys.elementAt(index);
                        final transactions = groupedTransactions[date]!;
                        return _buildDateSection(
                          date,
                          transactions,
                          context,
                          constraints,
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        "MY FINANCE",
        style: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.green,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 25, color: Colors.green),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionSearchScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.insights, size: 25, color: Colors.green),
          onPressed: () {
            // Show analytics or insights
            obj.showInsightsBottomSheet(context);
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(BoxConstraints constraints) {
    double fontSize = constraints.maxWidth < 350 ? 25 : 30;
    double subheadingSize = constraints.maxWidth < 350 ? 16 : 20;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: constraints.maxWidth * 0.06,
        vertical: 10,
      ),
      //decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "Let's Manage Your Finances",
            style: GoogleFonts.poppins(
              fontSize: subheadingSize,
              fontWeight: FontWeight.w300,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: [
              _buildFilterChip(
                "All",
                _activeFilter.value == "All",
                () => _activeFilter.value = "All",
              ),
              const SizedBox(width: 10),
              _buildFilterChip(
                "Income",
                _activeFilter.value == "Income",
                () => _activeFilter.value = "Income",
                Colors.green[100]!,
              ),
              const SizedBox(width: 10),
              _buildFilterChip(
                "Expenses",
                _activeFilter.value == "Expenses",
                () => _activeFilter.value = "Expenses",
                Colors.red[100]!,
              ),
              const SizedBox(width: 10),
              _buildFilterChip(
                "Today",
                _activeFilter.value == "Today",
                () => _activeFilter.value = "Today",
                Colors.blue[100]!,
              ),
              const SizedBox(width: 10),
              _buildFilterChip(
                "This Week",
                _activeFilter.value == "This Week",
                () => _activeFilter.value = "This Week",
                Colors.purple[100]!,
              ),
              const SizedBox(width: 10),
              _buildFilterChip(
                "This Month",
                _activeFilter.value == "This Month",
                () => _activeFilter.value = "This Month",
                Colors.orange[100]!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, [
    Color? chipColor,
  ]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? (chipColor ?? Colors.green[50]) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? (chipColor ?? Colors.green) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      final summary = _controller.getTransactionSummary(
        filterType: _activeFilter.value,
      );

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            _buildSummaryCard(
              "Income",
              "₹${summary['income']}",
              Colors.green[50]!,
              Colors.green,
              Icons.arrow_upward,
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              "Expenses",
              "₹${summary['expenses']}",
              Colors.red[50]!,
              Colors.red,
              Icons.arrow_downward,
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              "Balance",
              "₹${summary['balance']}",
              Colors.blue[50]!,
              Colors.blue,
              Icons.account_balance_wallet,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color bgColor,
    Color? textColor,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor, size: 16),
                const SizedBox(width: 3),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No transactions yet",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,

              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // Removed the extra Center widget
            "Tap the + button to add your first transaction",
            textAlign: TextAlign.center, // Added textAlign
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(
    String date,
    List<UserTransaction> transactions,
    BuildContext context,
    BoxConstraints constraints,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: Colors.grey[300])),
              const SizedBox(width: 8),
              Text(
                "₹${_calculateDayTotal(transactions)}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        ...transactions.map(
          (transaction) => _buildTransactionItem(
            context,
            transaction,
            transactions.length,
            constraints,
          ),
        ),
      ],
    );
  }

  String _calculateDayTotal(List<UserTransaction> transactions) {
    double income = 0;
    double expenses = 0;

    for (var transaction in transactions) {
      if (transaction.transactiontype == "Income") {
        income += double.parse(transaction.amount);
      } else if (transaction.transactiontype == "Expenses") {
        expenses += double.parse(transaction.amount);
      }
    }

    return (income - expenses).toStringAsFixed(2);
  }

  //Start editing Here
  Widget _buildTransactionItem(
    BuildContext context,
    UserTransaction transaction,
    int index,
    BoxConstraints constraints,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemHeight = screenWidth * 0.26; // 25% of screen width for height
    final horizontalMargin = screenWidth * 0.04;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 6),
      height: itemHeight, // Set fixed height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const DrawerMotion(),
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.edit,
                    onTap:
                        () => _showEditTransactionBottomSheet(
                          context,
                          transaction,
                        ),
                    color: Colors.green,
                  ),
                  _buildActionButton(
                    icon: Icons.delete,
                    onTap: () => _showDeleteConfirmation(context, transaction),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
        child: _buildTransactionContent(transaction, constraints),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildTransactionContent(
    UserTransaction transaction,
    BoxConstraints constraints,
  ) {
    bool isSmallScreen = constraints.maxWidth < 350;

    return InkWell(
      onTap: () => _showTransactionDetails(context, transaction),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildTransactionImage(isSmallScreen, transaction),
            const SizedBox(width: 16),
            _buildTransactionDetails(transaction, isSmallScreen),
            _buildTransactionAmount(transaction, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionImage(
    bool isSmallScreen,
    UserTransaction transaction,
  ) {
    double size = isSmallScreen ? 40 : 50;
    Color backgroundColor =
        transaction.transactiontype == "Income"
            ? Colors.green[50]!
            : Colors.red[50]!;
    Color iconColor =
        transaction.transactiontype == "Income"
            ? Colors.green[600]!
            : Colors.red[600]!;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child:
          transaction.categoryImageUrl!.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(size),
                child: Image.network(
                  transaction.categoryImageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: Icon(
                        Icons.category,
                        size: size * 0.5,
                        color: iconColor,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.category,
                        size: size * 0.5,
                        color: iconColor,
                      ),
                    );
                  },
                ),
              )
              : Center(
                child: Icon(
                  _getCategoryIcon(transaction.categoryId),
                  size: size * 0.5,
                  color: iconColor,
                ),
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

  Widget _buildTransactionDetails(
    UserTransaction transaction,
    bool isSmallScreen,
  ) {
    double titleSize = isSmallScreen ? 14 : 16;
    double categorySize = isSmallScreen ? 12 : 14;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: titleSize,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            transaction.categoryId,
            style: GoogleFonts.poppins(
              fontSize: categorySize,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
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
    Color amountColor =
        transaction.transactiontype == "Income"
            ? Colors.green[600]!
            : Colors.red[600]!;

    IconData typeIcon =
        transaction.transactiontype == "Income"
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(typeIcon, color: amountColor, size: 16),
            const SizedBox(width: 4),
            Text(
              "₹${transaction.amount}",
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          transaction.date,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.green,
      onPressed: () => _showAddTransactionBottomSheet(context),
      icon: const Icon(Icons.add_circle_rounded, color: Colors.white, size: 24),
      label: Text(
        "Add Transaction",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showAddTransactionBottomSheet(BuildContext context) {
    // Reset controllers and selections
    clearController();
    _controller.selectedType.value = "";
    _controller.selectedCategoryType.value = "";

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return _buildTransactionForm(
          context,
          isEditing: false,
          title: "Add Transaction",
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
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return _buildTransactionForm(
          context,
          isEditing: true,
          title: "Edit Transaction",
          transaction: transaction,
          titleController: titleController,
          amountController: amountController,
          dateController: dateController,
        );
      },
    );
  }

  Widget _buildTransactionForm(
    BuildContext context, {
    required bool isEditing,
    required String title,
    UserTransaction? transaction,
    TextEditingController? titleController,
    TextEditingController? amountController,
    TextEditingController? dateController,
  }) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form fields
                      _buildTextField(
                        isEditing ? titleController! : _titleController,
                        'Title',
                        Icons.title,
                        TextInputType.text,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        isEditing ? amountController! : _amountController,
                        'Amount',
                        Icons.attach_money,
                        TextInputType.number,
                        prefix: '₹',
                      ),
                      const SizedBox(height: 16),

                      // Transaction Type Chips
                      _buildSelectionSection(
                        "Transaction Type",
                        _buildTransactionTypeChips(),
                      ),
                      const SizedBox(height: 16),

                      // Category Chips
                      _buildSelectionSection("Category", _buildCategoryChips()),
                      const SizedBox(height: 16),

                      // Date Picker
                      _buildDatePicker(
                        isEditing ? dateController! : _dateController,
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            if (isEditing) {
                              _updateTransaction(
                                context,
                                transaction!,
                                titleController!,
                                amountController!,
                                dateController!,
                              );
                            } else {
                              _addTransaction(context);
                            }
                          },
                          child: Text(
                            isEditing
                                ? 'Update Transaction'
                                : 'Add Transaction',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    TextInputType keyboardType, {
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.sentences,
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.green),
        prefixText: prefix,
        prefixStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildSelectionSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        content,
      ],
    );
  }

  Widget _buildTransactionTypeChips() {
    return Obx(() {
      return Row(
        children: [
          _buildTypeChip(
            "Income",
            _controller.isTypeSelected("Income"),
            () => _controller.setType("Income"),
            Colors.green[200]!,
          ),
          const SizedBox(width: 16),
          _buildTypeChip(
            "Expenses",
            _controller.isTypeSelected("Expenses"),
            () => _controller.setType("Expenses"),
            Colors.red[200]!,
          ),
        ],
      );
    });
  }

  Widget _buildTypeChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Add this
          children: [
            // Fixed children property
            Icon(
              label == "Income" ? Icons.arrow_upward : Icons.arrow_downward,
              color: isSelected ? color : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 8), // Added spacing
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Obx(() {
      if (categoryManager.categoryChoices.isEmpty) {
        return Center(
          child: Text(
            "No categories available",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        );
      }

      // Filter categories based on transaction type - pure boolean logic
      List<CategoryChoice> filteredCategories;

      // if (_controller.selectedType.value == "Income") {
      //   filteredCategories =
      //       categoryManager.categoryChoices.where((c) => c.isIncome).toList();
      // } else if (_controller.selectedType.value == "Expenses") {
      //   filteredCategories =
      //       categoryManager.categoryChoices.where((c) => !c.isIncome).toList();
      // } else {
      filteredCategories = categoryManager.categoryChoices;

      return Wrap(
        spacing: 10,
        runSpacing: 12,
        children:
            filteredCategories.map((category) {
              bool isSelected = _controller.isCategoryTypeSelected(
                category.value,
              );

              return GestureDetector(
                onTap: () => _controller.setCategoryType(category.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? category.color : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? category.color : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(category.value),
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.value,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      );
    });
  }

  Widget _buildDatePicker(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'Date',
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          controller.text = DateFormat.yMMMd().format(pickedDate);
        }
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    UserTransaction transaction,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Delete Transaction',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to delete this transaction?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _controller.deleteTransaction(
                    transaction,
                    _controller.userId.value,
                  );
                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Transaction deleted successfully',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    UserTransaction transaction,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction Details',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Transaction type and amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          transaction.transactiontype == "Income"
                              ? Colors.green[50]
                              : Colors.red[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          transaction.transactiontype == "Income"
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color:
                              transaction.transactiontype == "Income"
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          transaction.transactiontype,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                transaction.transactiontype == "Income"
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹${transaction.amount}",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color:
                          transaction.transactiontype == "Income"
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Transaction details
              _buildDetailItem("Title", transaction.title),
              _buildDetailItem("Category", transaction.categoryId),
              _buildDetailItem("Date", transaction.date),
              _buildDetailItem(
                "Transaction ID",
                transaction.transactionid.toString(),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditTransactionBottomSheet(context, transaction);
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(context, transaction);
                      },
                      icon: const Icon(Icons.delete),
                      label: Text(
                        'Delete',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
