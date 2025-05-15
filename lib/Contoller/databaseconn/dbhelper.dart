import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:my_finance1/Model/transactionmodel.dart';

//import 'package:Model/transactionmodel.dart';
class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._init(); //Singlton Design Pattern to acess Database
  DatabaseHelper._init();

  static Database? _database;

  Future<Database> getdatabase() async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('myfinance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final relpath = path.join(
      dbPath,
      filePath,
    ); //relpath: relative path      dbpath:database path

    return await openDatabase(relpath, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS Users (
    userId INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT
  )''');

    await db.execute('''CREATE TABLE IF NOT EXISTS UserTransactions (
    transactionid INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    amount TEXT NOT NULL,
    transactiontype TEXT,
    categoryId TEXT,
    categoryImageUrl TEXT,
    date TEXT NOT NULL,
    userId INTEGER NOT NULL,
    FOREIGN KEY (userId) REFERENCES Users(userId) ON DELETE CASCADE
  )''');
  }

  Future<void> insertUser({
    required String username,
    required String email,
    int? userId, // Optional parameter but will be auto-generated if null
  }) async {
    final localDB = await instance.getdatabase();

    await localDB.insert('Users', {
      'userId': userId,
      'username': username,
      'email': email,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> getUserIdByEmail(String email) async {
    final db = await instance.getdatabase();
    final result = await db.query(
      'Users',
      columns: ['userId'], // Only select the userId column
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    log("${result.first['userId']}");

    if (result.isNotEmpty) {
      // Properly convert integer to string
      final userId = result.first['userId'];
      // Handle the case where userId might be null
      if (userId != null) {
        return int.parse(userId.toString()); // Explicit conversion to String
      }
    }

    // Return empty string if no result or userId is null
    return 0;
  }

  //why here because we cant write async and await in class where we can call list of tasks directly
  //List<Transaction> initialList = await getData();
  //return initialList;
  //after deletion data present in database should be displayed on screen so set state
  //-----------------------------------------------------------------------------------------------------------
  //CURD OPERATIONS TRANSACTIONS
  Future<void> insertTransactionData(
    UserTransaction userobj,
    int userId,
  ) async {
    final localDB = await DatabaseHelper.instance.getdatabase();
    log("In Insert Transaction");
    await localDB.insert('UserTransactions', {
      ...userobj.toMap(),
      'userId': userId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    log("In Insert End");
  }

  Future<List<UserTransaction>> getTransactionData(int userId) async {
    log("DATA RETRIVE");
    final localDB = await DatabaseHelper.instance.getdatabase();

    final List<Map<String, dynamic>> transactionlist = await localDB.query(
      "UserTransactions",
      where: 'userId = ?',
      whereArgs: [userId],
    );

    log("DATA Convert1");
    return List.generate(transactionlist.length, (index) {
      log("{$transactionlist}");
      log("DATA Convert");
      return UserTransaction(
        userId: transactionlist[index]["userId"],
        transactionid: transactionlist[index]["transactionid"],
        title: transactionlist[index]["title"],
        categoryImageUrl: transactionlist[index]['categoryImageUrl'],
        amount: transactionlist[index]["amount"],
        transactiontype: transactionlist[index]["transactiontype"],
        categoryId: transactionlist[index]["categoryId"],
        date: transactionlist[index]["date"],
      );
    });
  }

  Future<void> updateTransactionData(
    UserTransaction userobj,
    int userId,
  ) async {
    final localDB = await DatabaseHelper.instance.getdatabase();
    log("In Update Start");
    log("${userobj.transactionid}}");
    await localDB.update(
      'UserTransactions',
      {...userobj.toMap(), 'userId': userId},
      where: 'transactionid = ?',
      whereArgs: [userobj.transactionid],
    );
  }

  Future<void> deleteTransactionData(UserTransaction userobj) async {
    final localDB = await DatabaseHelper.instance.getdatabase();
    log("In Delete Start");
    log("${userobj.transactionid}}");
    await localDB.delete(
      'UserTransactions',
      where: 'transactionid = ?',
      whereArgs: [userobj.transactionid],
    );
  }
}
