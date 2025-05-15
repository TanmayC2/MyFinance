// // File: lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'dart:math';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Expense Manager',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const ExpenseManagerHome(),
//     );
//   }
// }

// // Models
// class Transaction {
//   final String id;
//   final String title;
//   final double amount;
//   final DateTime date;
//   final String category;
//   final bool isExpense;

//   Transaction({
//     required this.id,
//     required this.title,
//     required this.amount,
//     required this.date,
//     required this.category,
//     required this.isExpense,
//   });
// }

// // Controllers
// class ExpenseController extends GetxController {
//   var transactions = <Transaction>[].obs;
//   var filteredTransactions = <Transaction>[].obs;
//   var selectedDate = DateTime.now().obs;
//   var isLoading = false.obs;
//   var totalBalance = 0.0.obs;
//   var income = 0.0.obs;
//   var expense = 0.0.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadDummyData();
//     filterTransactionsByDate(selectedDate.value);
//     calculateBalances();
//   }

//   void loadDummyData() {
//     isLoading.value = true;

//     // Create a random number generator
//     final random = Random();

//     // Generate random transactions for the past 30 days
//     final List<Transaction> dummyData = [];
//     final categories = [
//       'Food',
//       'Transport',
//       'Entertainment',
//       'Shopping',
//       'Bills',
//       'Salary',
//       'Freelance',
//       'Gift',
//     ];

//     for (int i = 0; i < 50; i++) {
//       final isExpense = random.nextBool();
//       final daysAgo = random.nextInt(30);
//       final amount = (random.nextDouble() * 100).roundToDouble() + 10;

//       dummyData.add(
//         Transaction(
//           id: 'tx$i',
//           title:
//               isExpense
//                   ? '${categories[random.nextInt(5)]} expense'
//                   : '${categories[5 + random.nextInt(3)]} income',
//           amount: amount,
//           date: DateTime.now().subtract(Duration(days: daysAgo)),
//           category:
//               isExpense
//                   ? categories[random.nextInt(5)]
//                   : categories[5 + random.nextInt(3)],
//           isExpense: isExpense,
//         ),
//       );
//     }

//     transactions.value = dummyData;
//     isLoading.value = false;
//   }

//   void filterTransactionsByDate(DateTime date) {
//     filteredTransactions.value =
//         transactions
//             .where(
//               (tx) =>
//                   tx.date.year == date.year &&
//                   tx.date.month == date.month &&
//                   tx.date.day == date.day,
//             )
//             .toList();
//   }

//   void calculateBalances() {
//     double totalInc = 0.0;
//     double totalExp = 0.0;

//     for (var tx in transactions) {
//       if (tx.isExpense) {
//         totalExp += tx.amount;
//       } else {
//         totalInc += tx.amount;
//       }
//     }

//     income.value = totalInc;
//     expense.value = totalExp;
//     totalBalance.value = totalInc - totalExp;
//   }

//   void addTransaction(
//     String title,
//     double amount,
//     DateTime date,
//     String category,
//     bool isExpense,
//   ) {
//     final newTx = Transaction(
//       id: 'tx${DateTime.now().millisecondsSinceEpoch}',
//       title: title,
//       amount: amount,
//       date: date,
//       category: category,
//       isExpense: isExpense,
//     );

//     transactions.add(newTx);
//     filterTransactionsByDate(selectedDate.value);
//     calculateBalances();
//   }

//   void deleteTransaction(String id) {
//     transactions.removeWhere((tx) => tx.id == id);
//     filterTransactionsByDate(selectedDate.value);
//     calculateBalances();
//   }

//   void changeSelectedDate(DateTime date) {
//     selectedDate.value = date;
//     filterTransactionsByDate(date);
//   }
// }

// // Main Screen
// class ExpenseManagerHome extends StatelessWidget {
//   const ExpenseManagerHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ExpenseController controller = Get.put(ExpenseController());

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('Expense Manager'),
//         centerTitle: true,
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Obx(
//         () =>
//             controller.isLoading.value
//                 ? const Center(child: CircularProgressIndicator())
//                 : SafeArea(
//                   child: CustomScrollView(
//                     slivers: [
//                       SliverToBoxAdapter(
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildHeaderBalanceCard(controller),
//                               const SizedBox(height: 20),
//                               _buildDateSelector(controller),
//                               const SizedBox(height: 20),
//                               _buildTransactionHeader(controller),
//                             ],
//                           ),
//                         ),
//                       ),
//                       _buildTransactionList(controller),
//                     ],
//                   ),
//                 ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddTransactionModal(context, controller),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildHeaderBalanceCard(ExpenseController controller) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Colors.deepPurple, Colors.deepPurpleAccent],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.deepPurple,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Total Balance',
//             style: TextStyle(color: Colors.white70, fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           Obx(
//             () => Text(
//               '\$${controller.totalBalance.value.toStringAsFixed(2)}',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildBalanceItem(
//                 'Income',
//                 controller.income.value,
//                 Icons.arrow_upward,
//                 Colors.green,
//               ),
//               _buildBalanceItem(
//                 'Expense',
//                 controller.expense.value,
//                 Icons.arrow_downward,
//                 Colors.red,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBalanceItem(
//     String title,
//     double amount,
//     IconData icon,
//     Color color,
//   ) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(color: Colors.white70, fontSize: 14),
//             ),
//             Text(
//               '\$${amount.toStringAsFixed(2)}',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildDateSelector(ExpenseController controller) {
//     return Hero(
//       tag: 'dateSelector',
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Obx(
//                 () => Text(
//                   DateFormat(
//                     'MMMM dd, yyyy',
//                   ).format(controller.selectedDate.value),
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(
//                   Icons.calendar_month,
//                   color: Colors.deepPurple,
//                 ),
//                 onPressed: () async {
//                   final DateTime? picked = await showDatePicker(
//                     context: Get.context!,
//                     initialDate: controller.selectedDate.value,
//                     firstDate: DateTime(2020),
//                     lastDate: DateTime.now(),
//                     builder: (context, child) {
//                       return Theme(
//                         data: ThemeData.light().copyWith(
//                           colorScheme: const ColorScheme.light(
//                             primary: Colors.deepPurple,
//                           ),
//                         ),
//                         child: child!,
//                       );
//                     },
//                   );
//                   if (picked != null) {
//                     controller.changeSelectedDate(picked);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTransactionHeader(ExpenseController controller) {
//     return Obx(
//       () => Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Transactions (${controller.filteredTransactions.length})',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           if (controller.filteredTransactions.isNotEmpty)
//             TextButton(
//               onPressed: () {
//                 // Sort functionality can be added here
//               },
//               child: const Row(
//                 children: [
//                   Text('Sort', style: TextStyle(color: Colors.deepPurple)),
//                   Icon(Icons.sort, size: 16, color: Colors.deepPurple),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionList(ExpenseController controller) {
//     return Obx(() {
//       if (controller.filteredTransactions.isEmpty) {
//         return SliverFillRemaining(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No transactions on this date',
//                   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }

//       return SliverList(
//         delegate: SliverChildBuilderDelegate((context, index) {
//           final tx = controller.filteredTransactions[index];
//           return _buildTransactionItem(tx, controller, index);
//         }, childCount: controller.filteredTransactions.length),
//       );
//     });
//   }

//   Widget _buildTransactionItem(
//     Transaction tx,
//     ExpenseController controller,
//     int index,
//   ) {
//     return Hero(
//       tag: 'transaction-${tx.id}',
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: AnimatedOpacity(
//           duration: Duration(milliseconds: 500),
//           opacity: 1.0,
//           child: AnimatedContainer(
//             duration: Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             transform: Matrix4.translationValues(0, 0, 0)..scale(1.0),
//             child: Material(
//               color: Colors.transparent,
//               child: Dismissible(
//                 key: Key(tx.id),
//                 background: Container(
//                   alignment: Alignment.centerRight,
//                   padding: const EdgeInsets.only(right: 20),
//                   color: Colors.red,
//                   child: const Icon(Icons.delete, color: Colors.white),
//                 ),
//                 direction: DismissDirection.endToStart,
//                 onDismissed: (direction) {
//                   controller.deleteTransaction(tx.id);
//                   Get.snackbar(
//                     'Transaction Deleted',
//                     'The transaction has been removed',
//                     snackPosition: SnackPosition.BOTTOM,
//                     backgroundColor: Colors.red,
//                     colorText: Colors.white,
//                     margin: const EdgeInsets.all(16),
//                   );
//                 },
//                 child: Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     leading: Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: _getCategoryColor(tx.category),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         _getCategoryIcon(tx.category),
//                         color: _getCategoryColor(tx.category),
//                       ),
//                     ),
//                     title: Text(
//                       tx.title,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(
//                       tx.category,
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                     trailing: Text(
//                       '${tx.isExpense ? '-' : '+'}\$${tx.amount.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: tx.isExpense ? Colors.red : Colors.green,
//                       ),
//                     ),
//                     onTap: () => _showTransactionDetails(tx),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _getCategoryIcon(String category) {
//     switch (category.toLowerCase()) {
//       case 'food':
//         return Icons.restaurant;
//       case 'transport':
//         return Icons.directions_car;
//       case 'entertainment':
//         return Icons.movie;
//       case 'shopping':
//         return Icons.shopping_bag;
//       case 'bills':
//         return Icons.receipt;
//       case 'salary':
//         return Icons.work;
//       case 'freelance':
//         return Icons.laptop;
//       case 'gift':
//         return Icons.card_giftcard;
//       default:
//         return Icons.payments;
//     }
//   }

//   Color _getCategoryColor(String category) {
//     switch (category.toLowerCase()) {
//       case 'food':
//         return Colors.orange;
//       case 'transport':
//         return Colors.blue;
//       case 'entertainment':
//         return Colors.purple;
//       case 'shopping':
//         return Colors.pink;
//       case 'bills':
//         return Colors.red;
//       case 'salary':
//         return Colors.green;
//       case 'freelance':
//         return Colors.teal;
//       case 'gift':
//         return Colors.amber;
//       default:
//         return Colors.grey;
//     }
//   }

//   void _showTransactionDetails(Transaction tx) {
//     Get.dialog(
//       Hero(
//         tag: 'transaction-${tx.id}',
//         child: AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Text(
//             tx.title,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildDetailRow(
//                 'Amount',
//                 '${tx.isExpense ? '-' : '+'}\$${tx.amount.toStringAsFixed(2)}',
//                 tx.isExpense ? Colors.red : Colors.green,
//               ),
//               _buildDetailRow(
//                 'Category',
//                 tx.category,
//                 _getCategoryColor(tx.category),
//               ),
//               _buildDetailRow(
//                 'Date',
//                 DateFormat('MMM dd, yyyy').format(tx.date),
//                 Colors.grey[700]!,
//               ),
//               _buildDetailRow(
//                 'Time',
//                 DateFormat('hh:mm a').format(tx.date),
//                 Colors.grey[700]!,
//               ),
//               _buildDetailRow(
//                 'Type',
//                 tx.isExpense ? 'Expense' : 'Income',
//                 tx.isExpense ? Colors.red : Colors.green,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Get.back(),
//               child: const Text(
//                 'Close',
//                 style: TextStyle(color: Colors.deepPurple),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String title, String value, Color valueColor) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: valueColor,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddTransactionModal(
//     BuildContext context,
//     ExpenseController controller,
//   ) {
//     final _formKey = GlobalKey<FormState>();
//     final _titleController = TextEditingController();
//     final _amountController = TextEditingController();
//     final _categories = [
//       'Food',
//       'Transport',
//       'Entertainment',
//       'Shopping',
//       'Bills',
//       'Salary',
//       'Freelance',
//       'Gift',
//     ];
//     final _typeOptions = ['Expense', 'Income'];

//     String _selectedCategory = _categories[0];
//     String _selectedType = _typeOptions[0];
//     DateTime _selectedDate = DateTime.now();

//     Get.bottomSheet(
//       Container(
//         padding: const EdgeInsets.all(16),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Add New Transaction',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     prefixIcon: const Icon(Icons.title),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a title';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _amountController,
//                   decoration: InputDecoration(
//                     labelText: 'Amount',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     prefixIcon: const Icon(Icons.attach_money),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter an amount';
//                     }
//                     if (double.tryParse(value) == null) {
//                       return 'Please enter a valid number';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: StatefulBuilder(
//                         builder: (context, setState) {
//                           return DropdownButtonFormField<String>(
//                             value: _selectedCategory,
//                             decoration: InputDecoration(
//                               labelText: 'Category',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             items:
//                                 _categories.map((category) {
//                                   return DropdownMenuItem(
//                                     value: category,
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           _getCategoryIcon(category),
//                                           color: _getCategoryColor(category),
//                                           size: 20,
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(category),
//                                       ],
//                                     ),
//                                   );
//                                 }).toList(),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 setState(() {
//                                   _selectedCategory = value;
//                                 });
//                               }
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: StatefulBuilder(
//                         builder: (context, setState) {
//                           return DropdownButtonFormField<String>(
//                             value: _selectedType,
//                             decoration: InputDecoration(
//                               labelText: 'Type',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             items:
//                                 _typeOptions.map((type) {
//                                   return DropdownMenuItem(
//                                     value: type,
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           type == 'Income'
//                                               ? Icons.arrow_upward
//                                               : Icons.arrow_downward,
//                                           color:
//                                               type == 'Income'
//                                                   ? Colors.green
//                                                   : Colors.red,
//                                           size: 20,
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(type),
//                                       ],
//                                     ),
//                                   );
//                                 }).toList(),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 setState(() {
//                                   _selectedType = value;
//                                 });
//                               }
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 StatefulBuilder(
//                   builder: (context, setState) {
//                     return InkWell(
//                       onTap: () async {
//                         final DateTime? picked = await showDatePicker(
//                           context: context,
//                           initialDate: _selectedDate,
//                           firstDate: DateTime(2020),
//                           lastDate: DateTime.now(),
//                           builder: (context, child) {
//                             return Theme(
//                               data: ThemeData.light().copyWith(
//                                 colorScheme: const ColorScheme.light(
//                                   primary: Colors.deepPurple,
//                                 ),
//                               ),
//                               child: child!,
//                             );
//                           },
//                         );
//                         if (picked != null) {
//                           setState(() {
//                             _selectedDate = picked;
//                           });
//                         }
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 15,
//                         ),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.calendar_today),
//                             const SizedBox(width: 8),
//                             Text(
//                               DateFormat('MMMM dd, yyyy').format(_selectedDate),
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         controller.addTransaction(
//                           _titleController.text,
//                           double.parse(_amountController.text),
//                           _selectedDate,
//                           _selectedCategory,
//                           _selectedType == 'Expense',
//                         );
//                         Get.back();
//                         Get.snackbar(
//                           'Success',
//                           'Transaction added successfully',
//                           snackPosition: SnackPosition.BOTTOM,
//                           backgroundColor: Colors.green,
//                           colorText: Colors.white,
//                           margin: const EdgeInsets.all(16),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Add Transaction',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       isScrollControlled: true,
//     );
//   }
// }

// // File: pubspec.yaml (Should be created separately)
// // This is just a reference for the dependencies needed
// /*
// name: expense_manager_app
// description: A new Flutter project for expense management.
// publish_to: 'none'
// version: 1.0.0+1

// environment:
//   sdk: '>=2.17.0 <3.0.0'

// dependencies:
//   flutter:
//     sdk: flutter
//   get: ^4.6.5
//   intl: ^0.17.0
//   cupertino_icons: ^1.0.2

// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//   flutter_lints: ^2.0.0

// flutter:
//   uses-material-design: true
// */
