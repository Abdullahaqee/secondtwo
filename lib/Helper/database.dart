import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'helper.dart';

Database? _database;
List<Map<String, dynamic>> WholeDatalist = [];

class LocalDatabase {
  static LocalDatabase? _instance;
  late Database _database;

  LocalDatabase._(); // Private constructor

  factory LocalDatabase() {
    if (_instance == null) {
      _instance = LocalDatabase._();
    }
    return _instance!;
  }

  Future<void> initDatabase() async {
    _database = await _initializeDB('local.db');
    fetchDataFromDatabase(); // Load data into WholeDatalist
  }

  Future<Database?> get database async {
    if (_database.isOpen) return _database;
    await initDatabase();
    return _database;
  }

  Future _initializeDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filepath);
    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Localdata (
      autonumber INTEGER PRIMARY KEY AUTOINCREMENT,
      customerCode TEXT NOT NUll,
      customerName TEXT NOT NULL,
      order_data TEXT NOT NULL,
      upload TEXT DEFAULT 'No',
      date_time TEXT NOT NULL,
      isaleman TEXT NOT NULL
    )
  ''');

    //   await db.execute('''
    //   CREATE TABLE customer (
    //     autonumber INTEGER PRIMARY KEY AUTOINCREMENT,
    //     customerCode TEXT NOT NUll,
    //     customerName TEXT NOT NULL,
    //     itemCode TEXT NOT NULL,
    //     itemName TEXT NOT NULL,
    //     quantity TEXT NOT NULL
    //   )
    // ''');
  }

  // Future<int> addDataLocally(
  //   customerCode,
  //   customerName,
  //   itemCode,
  //   itemName,
  //   quantity
  // ) async {
  //   final db = await database;
  //
  //   // Handle null values for customerCode
  //   print('$customerCode');
  //   print('$customerName');
  //   print('$itemCode');
  //   print('$itemName');
  //   print('$quantity');
  //
  //   int insertedId = await db!.rawInsert(
  //     'INSERT INTO customer ('
  //         'customerCode, customerName, itemCode, itemName,quantity)'
  //         'VALUES (?, ?, ?, ?, ?)',
  //     [customerCode, customerName,itemCode, itemName,quantity],
  //   );
  //
  //   print('$customerCode Added to database Successfully');
  //   fetchDataFromDatabase();
  //   // await postData();// Reload data into WholeDatalist
  //   return insertedId;
  // }
  Future<List<Map<String, dynamic>>> readalldata() async {
    try {
      final db = await database;
      final alldata = await db!.query('Localdata');
      return List<Map<String, dynamic>>.from(alldata);
    } catch (e) {
      print('Error reading data from the database: $e');
      return []; // Return an empty list in case of an error
    }
  }

  Future<int> Updatedata(customerCode, customerName,
      List<Map<String, dynamic>> itemsAsMaps, id) async {
    final db = await database;
    int result = await db!.rawUpdate(
      'UPDATE Localdata SET customerCode = ?,customerName = ?, order_data = ? WHERE autonumber = ?',
      [customerCode, customerName, jsonEncode(itemsAsMaps), id],
    );
    fetchDataFromDatabase();
    // await postData();// Reload data into WholeDatalist
    return result;
  }

  Future Deletedb(id) async {
    final db = await database;
    await db!.delete('Localdata', where: 'autonumber=?', whereArgs: [id]);
    print('delete Successfully ${id}');
    fetchDataFromDatabase(); // Reload data into WholeDatalist
    return 'Successfully delete';
  }

  Future Deletewholedb() async {
    final db = await database;
    await db!.delete('Localdata');
    print('delete Successfully ');
    fetchDataFromDatabase(); // Reload data into WholeDatalist
    return 'Successfully delete';
  }

  Future<int> addApiDataLocally(String customerCode, String customerName,
      List<Map<String, dynamic>> items, String isaleman) async {
    try {
      return await _database.transaction((txn) async {
        // Convert the items to a list of Map<String, dynamic>
        List<Map<String, dynamic>> itemsAsMaps = items.map((item) {
          return {
            'itemCode': item['itemCode'] ?? '',
            'item': item['item'] ??
                '', // Perform null check and provide a default value if needed
            'quantity': item['quantity'] ??
                '', // Perform null check and provide a default value if needed
          };
        }).toList();

        // Get the current date and time
        DateTime now = DateTime.now();
        String formattedDateTime = now.toLocal().toString();

        // Print or log the data before inserting into the database

        // Insert the entire order into the database with the current date and time
        int insertedId = await txn.rawInsert(
          'INSERT INTO Localdata ('
          'customerCode, customerName, order_data, date_time,isaleman)'
          'VALUES (?, ?, ? ,? ,?)',
          [
            customerCode,
            customerName,
            jsonEncode(itemsAsMaps),
            formattedDateTime,
            isaleman
          ],
        );

        // Print or log the insertedId
        fetchDataFromDatabase();
        return insertedId;
      });
    } catch (e) {
      print('Error inserting data locally: $e');
      throw e;
    }
  }

  Future<void> fetchDataAndStoreLocally() async {
    try {
      // Fetch data from the API
      Map<String, dynamic> apiData =
          await ApiHandler.fetchData('your_api_path');

      // Extract customerName and items from the apiData map
      String customerCode = apiData['customerCode'] ?? '';
      String customerName = apiData['customerName'] ?? '';
      String isaleman = apiData['code'] ?? '';
      List<Map<String, dynamic>> items = apiData['items'] ?? [];

      // Store the fetched API data in the local database and get the inserted ID
      int insertedId =
          await addApiDataLocally(customerCode, customerName, items, isaleman);

      // Now you can use the insertedId to update the record if needed
      // For example, you can call Updatedata method with the new data
      await Updatedata(customerCode, customerName,
          items as List<Map<String, dynamic>>, insertedId);

      // await postData();
    } catch (e) {
      print('Error fetching and storing data from API: $e');
      throw e;
    }
  }

  // Load data into WholeDatalist
  Future<void> fetchDataFromDatabase() async {
    try {
      final db = await database;
      final alldata = await db!.query('Localdata');
      WholeDatalist = List<Map<String, dynamic>>.from(alldata);
    } catch (e) {
      print('Error reading data from the database: $e');
    }
  }

  Future<void> updateUploadStatus(String orderno) async {
    try {
      final db = await database;
      print('Before update: $orderno');
      await db!.update(
        'Localdata',
        {'upload': 'Yes'},
        where: 'autonumber = ?',
        whereArgs: [orderno],
      );
      print('After update: $orderno');
      fetchDataFromDatabase(); // Reload data into WholeDatalist
    } catch (e) {
      print('Error updating upload status: $e');
    }
  }

// postData() async {
//   try {
//     String url = 'http://isofttouch.com/eorder/insert1.php';
//
//     // Iterate through filteredData and send each item separately
//
//       var post = await http.post(Uri.parse(url),
//           body: {'icucode': 'customerCode', 'icuname': 'customerName'});
//
//       var response = jsonDecode(post.body.trim()); // Remove leading/trailing whitespaces
//       if (response == "true") {
//         print('record entered');
//       } else {
//         print('failed');
//       }
//     print("upload complete");
//
//   } catch(e){
//     print(e.toString());
//   }
//  }
}
