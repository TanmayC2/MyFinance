import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:my_finance1/Contoller/transactioncontroolergetx.dart';
import 'package:my_finance1/Model/transactionmodel.dart';

class TransactionSearchScreen extends StatefulWidget {
  const TransactionSearchScreen({super.key});

  @override
  State createState() => _TransactionSearchScreenState();
}

class _TransactionSearchScreenState extends State {
  final TransactionController _controller = Get.find();
  final RxString _searchQuery = ''.obs;
  final RxList<UserTransaction> _filteredTransactions = <UserTransaction>[].obs;

  @override
  void initState() {
    super.initState();
    _filteredTransactions.value = List.from(_controller.transactions);
  }

  // Function to handle changes in the search query
  void _onSearchChanged(String input) {
    _searchQuery.value = input.toLowerCase();
    if (input.isNotEmpty) {
      _filteredTransactions.value =
          _controller.transactions
              .where(
                (transaction) =>
                    transaction.title.toLowerCase().contains(
                      _searchQuery.value,
                    ) ||
                    transaction.categoryId.toLowerCase().contains(
                      _searchQuery.value,
                    ),
              )
              .toList();
    } else {
      _filteredTransactions.value = List.from(_controller.transactions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  const SizedBox(height: 25),
                  TextField(
                    onChanged: _onSearchChanged,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Search Transactions',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Obx(
                      () =>
                          _filteredTransactions.isEmpty
                              ? Center(
                                child: Text(
                                  _searchQuery.value.isNotEmpty
                                      ? 'No transactions found for "${_searchQuery.value}"'
                                      : 'No transactions available.',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                              : ListView.builder(
                                itemCount: _filteredTransactions.length,
                                itemBuilder: (context, index) {
                                  final transaction =
                                      _filteredTransactions[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                transaction.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                'Category: ${transaction.categoryId}',
                                              ),
                                            ],
                                          ),

                                          Text(
                                            '₹${transaction.amount}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  (transaction.transactiontype ==
                                                          "Income")
                                                      ? Colors.green
                                                      : Colors.red,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
