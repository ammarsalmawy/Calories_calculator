import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'Food.dart';
import 'userDishes.dart';

class FoodsDatabase {
  static final FoodsDatabase instance = FoodsDatabase._init();
  static const int _databaseVersion = 2;
  static Database? _database;

  FoodsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('calories_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: _databaseVersion, onCreate: _createDB ,onUpgrade: _onUpgrade);
  }

   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop the existing table and recreate it with the new column
      await db.execute('DROP TABLE IF EXISTS user_dishes;');
      await _create(db, newVersion);
    }
    // Add more migration steps if needed
  }
  Future _create(Database db, int version) async {
    await db.execute('''
CREATE TABLE user_dishes ( 
  ${dishesFeild.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
  ${dishesFeild.food_items} TEXT NOT NULL,
  ${dishesFeild.date} TEXT NOT NULL,
  ${dishesFeild.target} TEXT NOT NULL
  )
''');
  }

  Future _createDB (Database db, int version) async {
    await db.execute('''
CREATE TABLE foods ( 
  ${FoodItemsFields.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
  ${FoodItemsFields.name} TEXT NOT NULL,
  ${FoodItemsFields.calories} TEXT NOT NULL
  )
''');

    await db.execute('''
CREATE TABLE user_dishes ( 
  ${dishesFeild.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
  ${dishesFeild.food_items} TEXT NOT NULL,
  ${dishesFeild.date} TEXT NOT NULL
  ${dishesFeild.target} TEXT NOT NULL
  )
''');
  }

  Future<Food> create(Food food) async {
    final db = await instance.database;

    final id = await db.insert('foods', food.toJson());
    return food.copy(id: id);
  }

  Future<userDishes> createUserDish(userDishes userDish) async {
    final db = await instance.database;

    final userDishId = await db.insert('user_dishes',userDish.toJson()
    );

    return userDish.copy(id: userDishId);
  }

  Future<List<userDishes>> readUserDishesByDate(String date) async {
    final db = await instance.database;

    final result = await db.query(
      'user_dishes',
      where: '${dishesFeild.date} = ?',
      whereArgs: [date],
    );

    return result.map((json) => userDishes.fromJson(json)).toList();
  }
  Future<List<userDishes>> reedAllUserDishes() async{
    final db = await instance.database;

    final result = await db.query('user_dishes');
    return result.map((json) => userDishes.fromJson(json)).toList();
  }


  Future<void> updateUserDish(int id, String newDate, String newFoodItems, String target) async {
    final Database db = await instance.database;

    // Convert the list of new food items to a JSON string
    // final String newFoodItemsJson = userDishes.foodItemsToJson(newFoodItems);

    await db.rawUpdate(
      'UPDATE user_dishes SET date = ?, fooditems = ? , target = ?  WHERE id_dish = ?',
      [newDate, newFoodItems,target, id],
    );
    // Update the user dish in the database

  }




  Future<void> deleteUserDish(int? id) async {
    final db = await instance.database;

    if (id != null) {
      await db.delete(
        'user_dishes',
        where: '${dishesFeild.id} = ?',
        whereArgs: [id],
      );
    }
  }

  Future<List<Food>> ReeadAllfoodsItem() async {
    final db = await instance.database;

    final result = await db.query('foods');

    return result.map((json) => Food.fromJson(json)).toList();
  }
  Future<bool> isInitialInsertionDone() async {
    final db = await instance.database;

    final result = await db.rawQuery('SELECT COUNT(*) FROM foods');

    // If the 'foods' table is empty, consider the initial insertion not done
    return result.isNotEmpty && result.first['COUNT(*)'] == 0;
  }
}