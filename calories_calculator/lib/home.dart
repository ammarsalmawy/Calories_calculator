import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dbManagement.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'Food.dart';
import 'userDishes.dart';
import 'selection.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();}

class _HomeState extends State<Home> {

  List<SelectedFood> selectedFoods = [];
  List<Food> foods = [];
  late TextEditingController targetCaloriesController;
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    // Call the method to insert food items and update the UI
    targetCaloriesController = TextEditingController();
    dateController = TextEditingController();
    insertFoodItems();
  }

  Future<void> insertFoodItems() async {


    // Check if the initial insertion has already occurred
    final bool isInitialInsertionDone = await FoodsDatabase.instance
        .isInitialInsertionDone();

    print("is or not");
    print(isInitialInsertionDone);
    if (isInitialInsertionDone) {
      final String jsonString = await rootBundle.loadString(
          'assets/foods.json');
      final data = jsonDecode(jsonString);
      for (final foodItem in data) {
        await FoodsDatabase.instance.create(
          Food(
            name: foodItem['name'],
            calories: foodItem['calories'],
          ),
        );
      }


    }

    // Read all food items from the database
    final List<Food> allFoods = await FoodsDatabase.instance.ReeadAllfoodsItem();
    setState(() {
      foods = allFoods;
      print("the lenght");
      print(foods.length);
    });
  }

  Future<bool> _saveDish() async {
    final int userTargetCalories = int.tryParse(targetCaloriesController.text) ?? 0;
    final DateTime selectedDate = DateTime.parse(dateController.text);


    final int totalCalories = selectedFoods.fold(
      0,(sum, selectedFood) => sum + int.parse(selectedFood.food.calories),
    );
    if (totalCalories <= userTargetCalories) {
      final List<Food> selectedFoodItems = selectedFoods.map((sf) => sf.food).toList();
      final String foodItemsJson = userDishes.foodItemsToJson(selectedFoodItems);
      final userDish = userDishes(
        date: selectedDate.toString(),
        food_items: foodItemsJson,
        target: targetCaloriesController.text,
      );

      await FoodsDatabase.instance.createUserDish(userDish);

      // Clear the selections and inputs
      setState(() {
        targetCaloriesController.clear();
        dateController.clear();
        // Reset isSelected for all items in selectedFoods
        selectedFoods.forEach((sf) => sf.isSelected = false);
      });

      // Show a success message
      return true;

    } else {
      // Show an error message if the target calories are exceeded

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('CaloriesCalulator',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
              letterSpacing: 2.0
          ),),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {

              if (value == 'search') {
                Navigator.pushNamed(context, '/search');
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'search',
                child: Text('Search for a specific meal plan'),
              ),

            ],
          ),
        ],
      ),
        body:
        Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0,30.0,10.0,0),
            child:
            Column(

              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0,5.0,20.0,0.0),
                      child: Text('Target Calories:',style: TextStyle(
                        letterSpacing: 2.0,
                        color: Colors.grey[800],
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,


                      ),),
                    ),],
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child:
                  TextFormField(
                    controller: targetCaloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'Enter target calories',
                        hintStyle: TextStyle(

                          fontSize: 20.0,
                        )
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0,20.0,20.0,0.0),
                      child: Text('Date:',style: TextStyle(
                        color: Colors.grey[800],

                          letterSpacing: 2.0,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,

                      ),),
                    ),],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),

                  child: InkWell(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [   Text(
                          dateController.text,
                          style: TextStyle(
                            fontSize: 20.0,

                          ),
                        ),
                          Icon(Icons.calendar_today, color: Colors.grey[800],),
                        ],
                    ),

                  ),
                ),
                Divider(),
                Text('Food Items:',style: TextStyle(color: Colors.grey[800],letterSpacing: 2.0,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,),),
                Expanded(
              child: ListView.builder(
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final food = foods[index];
                  final selectedFood = selectedFoods.firstWhere(
                        (sf) => sf.food.id == food.id,
                    orElse: () => SelectedFood(food),
                  );
                  return CheckboxListTile(
                    title: Text(
                      food.name,
                      style: TextStyle(
                        fontSize: 18.0,

                        color: Colors.grey[800],
                      ),
                    ),
                    subtitle: Text(
                      'Calories: ${food.calories}',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'JosefinSans',
                        color: Colors.grey[600],
                      ),
                    ),
                    value: selectedFood.isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        selectedFood.isSelected = value ?? false;
                        if (selectedFood.isSelected) {
                          selectedFoods.add(selectedFood);
                        } else {
                          selectedFoods.remove(selectedFood);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: OutlinedButton(
                        onPressed: () async {
                          bool savedSuccessfully = await _saveDish();
                          if (savedSuccessfully) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Meal plan saved!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                          else {
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                              content: Text('Total calories exceed the target. Please adjust your selection.'),
                              duration: Duration(seconds: 2),
                                 ),);
                                }
                          },
                        child:

                        Text('Add',
                          style: TextStyle(

                            color: Colors.grey[800],
                            fontSize: 18.0,

                          ),),
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(50,16,50,16)),
                          backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.green),

                        ),

                      ),
                    ),
                    Text(
                      'Total Calories: ${calculateTotalCalories()}',
                    ),
                  ],
                )


            ],
            ),
            ),
          ),

    );

  }

  int calculateTotalCalories() {
    return selectedFoods.fold<int>(
      0,
          (sum, selectedFood) => sum + int.parse(selectedFood.food.calories),
    );
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        dateController.text = picked.toString().substring(0, 10);
      });
    }
  }


  Widget noteTemplate(String name, String cal){
    return Card(
      margin: EdgeInsets.fromLTRB(16.0,16.0, 16.0, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'JosefinSans',
                color: Colors.grey[800],
              ),
            ),
          ),
          SizedBox(height: 6.0,),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,8.0),
            child: Text(
              cal,
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'JosefinSans',
                color: Colors.grey[600],
              ),
            ),
          )
        ],
      ) ,
    );
  }



  }

