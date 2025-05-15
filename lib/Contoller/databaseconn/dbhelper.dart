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
    await db.execute(''' CREATE TABLE  IF NOT EXISTS  UserTransactions (
        transactionid INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        amount TEXT NOT NULL,
        transactiontype TEXT,
        categoryId TEXT ,
        categoryImageUrl TEXT,
        date TEXT NOT NULL
      )''');
  }
  //why here because we cant write async and await in class where we can call list of tasks directly
  //List<Transaction> initialList = await getData();
  //return initialList;
  //after deletion data present in database should be displayed on screen so set state
  //-----------------------------------------------------------------------------------------------------------

  //CURD OPERATIONS CATEGORY

  //Insert
  /*
  Future<int> insertCategorySQ(CategorySQ categoryobj) async {
    log("In Insert Category");
    final localDB = await DatabaseHelper.instance.getdatabase();
    return await localDB.insert('Category', categoryobj.toMap());
  }

  //Retrive
  Future<List<CategorySQ>> getCategoriesSQ() async {
    log("Retrive Category Data");
    final localDB = await DatabaseHelper.instance.getdatabase();
    final List<Map<String, dynamic>> categorylist = await localDB.query(
      'Category',
    );
    log("{$categorylist}");

    log("DATA Conversion of Category");
    return List.generate(categorylist.length, (index) {
      return CategorySQ(
        idSQ: categorylist[index]['idSQ'],
        name: categorylist[index]['name'],
        color: categorylist[index]['color'],
        categoryImageUrl: categorylist[index]['categoryImageUrl'],
        firebaseid: categorylist[index]['firebaseid'],
      );
    });
  }

  Future<int> deleteCategorySQ(String firebaseid) async {
    final localDB = await DatabaseHelper.instance.getdatabase();
    return await localDB.delete(
      'Category',
      where: 'firebaseid = ?',
      whereArgs: [firebaseid],
    );
  }
  */
  /*------------------------------------------------------------------------------------------------------------ */

  //CURD OPERATIONS TRANSACTIONS
  Future<void> insertTransactionData(UserTransaction userobj) async {
    final localDB = await DatabaseHelper.instance.getdatabase();
    log("In Insert Transaction");
    await localDB.insert(
      'UserTransactions',
      userobj.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    log("In Insert End");
  }

  Future<List<UserTransaction>> getTransactionData() async {
    log("DATA RETRIVE");
    final localDB = await DatabaseHelper.instance.getdatabase();

    final List<Map<String, dynamic>> transactionlist = await localDB.query(
      "UserTransactions",
    );

    log("DATA Convert1");
    return List.generate(transactionlist.length, (index) {
      log("{$transactionlist}");
      log("DATA Convert");
      return UserTransaction(
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

  Future<void> updateTransactionData(UserTransaction userobj) async {
    final localDB = await DatabaseHelper.instance.getdatabase();
    log("In Update Start");
    log("${userobj.transactionid}}");
    await localDB.update(
      'UserTransactions',
      userobj.toMap(),
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
