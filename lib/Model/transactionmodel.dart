import 'dart:developer' show log;

class UserTransaction {
  int? transactionid;
  int? userId;
  String title;
  String amount;
  String transactiontype;
  String categoryId;
  String date;
  String? categoryImageUrl;

  UserTransaction({
    this.transactionid,
    this.userId,
    this.categoryImageUrl,
    required this.title,
    required this.amount,
    required this.transactiontype,
    required this.categoryId,
    required this.date,
  });

  // Convert a Transaction to a Map for storage
  Map<String, dynamic> toMap() {
    log("in Model");
    return {
      'userId': userId,
      'transactionid': transactionid,
      'title': title,
      'categoryImageUrl': categoryImageUrl,
      'amount': amount,
      'transactiontype': transactiontype,
      'categoryId': categoryId,
      'date': date,
    };
  }

  // Utility method to validate transaction
  bool validate() {
    return title.isNotEmpty &&
        amount.isNotEmpty &&
        transactiontype.isNotEmpty &&
        categoryId.isNotEmpty &&
        date.isNotEmpty;
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'UserTransaction(id: $transactionid, userId : $userId,title: $title, amount: $amount, type: $transactiontype, category: $categoryId, date: $date,categoryImageUrl:$categoryImageUrl)';
  }
}
