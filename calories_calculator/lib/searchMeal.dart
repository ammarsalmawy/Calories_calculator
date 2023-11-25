import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dbManagement.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'Food.dart';
import 'userDishes.dart';
import 'selection.dart';
import 'updateMealPlan.dart';

class SearchMeal extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _SearchMeal();

}
class _SearchMeal extends State<SearchMeal>{

  List<userDishes> userdishesbydate = [];
  late TextEditingController dateController;
  List<userDishes> udishes = [];

  List<Food> foodItems= [];
  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();
    addtolist();


  }

  Future<void> addtolist() async{
    final List<userDishes> alludishes = await FoodsDatabase.instance.reedAllUserDishes();
    setState(() {
      userdishesbydate = alludishes;
      for (final userDish in alludishes) {
        final List<Food> foodItemss = userDishes.jsonToFoodItems(userDish.food_items);
        if (foodItemss.isNotEmpty) {
          foodItems.addAll(foodItemss);
        }

      }
      print("this for knowing the userdishes ${udishes.length}");



    });
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
        automaticallyImplyLeading: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle the selected option
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
    padding: const EdgeInsets.fromLTRB(10.0,70.0,10.0,0),
    child: Column(

    crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Text('Select Date:', style: TextStyle(
          letterSpacing: 2.0,
          color: Colors.grey[800],
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        ),),
        InkWell(
        onTap: () => _selectDate(context),
        child: IgnorePointer(
        child: TextFormField(
        controller: dateController,
        decoration: InputDecoration(
        suffixIcon: Icon(Icons.calendar_today),
          ),),),          ),
        SizedBox(height: 70.0),
        ElevatedButton(
          onPressed: () async {
            await _searchMealPlan(context);
          },
          child: Text('Search',style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18.0,
          ),),
          style: ButtonStyle(  padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(50,16,50,16)),
            backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.green),
          ),
        ),



      ],

    ),
       ),
      ),

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

  Future<void> _searchMealPlan(BuildContext context) async {
    final String selectedDate = dateController.text;
    final DateTime selectedDateformated = DateTime.parse(dateController.text);
    try {
      final List<userDishes> udishesbydate = await FoodsDatabase.instance.readUserDishesByDate(selectedDateformated.toString());

      setState(() {
        userdishesbydate = List.from(udishesbydate);
      });
      final List<userDishes> test = await FoodsDatabase.instance.reedAllUserDishes();
        print("this is a test ${test.first.date}");
        print("this is a selecteddate ${selectedDateformated}");
      if (udishesbydate.isNotEmpty) {

        // Use a Column to allow for vertical expansion
        Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            title: Text('Search Results'),
            backgroundColor: Colors.green[600],
          ),
          body:

          Padding(
            padding: const EdgeInsets.fromLTRB(20.0,15.0,20.0,0.0),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Expanded(
                  child: ListView.builder(
                    itemCount: udishesbydate.length,
                    itemBuilder: (context, index) {
                      final List<Food> foodItemsforuserBydate = userDishes.jsonToFoodItems(udishesbydate[index].food_items);
                      int totalCalories = 0;
                      for (final calc in foodItemsforuserBydate) {
                        totalCalories += int.parse(calc.calories);
                      }
                      return Container(
                        color: Colors.grey[400],

                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10.0,5.0,5.0,5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target Calories: ${udishesbydate[index].target}',style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.grey[800],
                              ), ),
                              Text('User Dish Date: ${udishesbydate[index].date}', style:
                                TextStyle( fontSize: 20.0,
                                  color: Colors.grey[800],),),
                              SizedBox(height: 8.0),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: foodItemsforuserBydate.length,
                                itemBuilder: (context, foodIndex) {
                                  final foodItema = foodItemsforuserBydate[foodIndex];

                                  for (final calc in foodItemsforuserBydate) {
                                    totalCalories += int.parse(calc.calories);
                                  }

                                  for (final foodItem in foodItemsforuserBydate) {

                                    return Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Food item: ${foodItema.name}',style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.grey[800],
                                          ),),
                                          Text('Calories: ${foodItema.calories}',style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.grey[800],
                                          ),),
                                          // Add more details as needed...
                                         // Optional: Add a divider between food items

                                        ],

                                      ),


                                    );

                                  }

                                },
                              ),
                              Text('Total Calories: ${totalCalories}',style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.grey[800],
                              ),) ,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [

                                  IconButton(onPressed: () async {
                                    bool confirmDelete = await showDeleteConfirmationDialog(context);
                                    if (confirmDelete) {
                                      await deleteMealPlan(udishesbydate[index].id);
                                      setState(() {
                                        // Assuming udishesbydate is a state variable that holds your meal plans
                                        userdishesbydate.removeAt(index);
                                      });
                                      Navigator.pop(context);}
                                  },icon: Icon(Icons.delete,color: Colors.red,),
                                  ),
                                  Divider(color: Colors.grey[800],),
                                  IconButton(onPressed: (){
                          // Navigate to the update screen with the meal plan details
                                      Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                      builder: (context) => UpdateMealPlan(
                                      userDish: udishesbydate[index],
                                      ),),);
                                      },
                                      icon: Icon(Icons.edit))
                                ],
                              ),
                             SizedBox(height: 5.0,),
                              Divider(color: Colors.grey[800],),
                             // Optional: Add a divider between user dishes
                            ],
                          ),
                        ),
                      );

                    },
                  ),

                ),
                Divider(color: Colors.grey[800],),
              ],
            ),
          ),
        )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No meal plan found for $selectedDate'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error searching for meal plan: $e');
    }
  }
  Future<void> deleteMealPlan(int? mealPlanId) async {
    await FoodsDatabase.instance.deleteUserDish(mealPlanId);
  }
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this meal plan?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User chose not to delete
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false; // Return false if the dialog is dismissed without a choice
  }


}