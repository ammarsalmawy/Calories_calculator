import 'package:flutter/material.dart';
import 'dbManagement.dart';
import 'userDishes.dart';
import 'Food.dart';
import 'searchMeal.dart';
import 'home.dart';


class UpdateMealPlan extends StatefulWidget {
  final userDishes userDish;

  UpdateMealPlan({required this.userDish});

  @override
  _UpdateMealPlanState createState() => _UpdateMealPlanState();
}

class _UpdateMealPlanState extends State<UpdateMealPlan> {

   List<Food> allfoods =[] ;
  late TextEditingController dateController;
  late TextEditingController targetcal;
  late List<TextEditingController> foodItemsController;
  late List<Food> foodItemsList = [];
   List<Food> selectedFoodItems=[];

  @override
  void initState() {
    super.initState();
    initializeData();
    dateController = TextEditingController(text: widget.userDish.date);
    targetcal = TextEditingController(text: widget.userDish.target);

  }
  Future<void> initializeData() async {
    allfoods = await FoodsDatabase.instance.ReeadAllfoodsItem();


    final List<Food>  sss= await userDishes.jsonToFoodItems(widget.userDish.food_items);

    userDishes userdish = widget.userDish;
    foodItemsList = userDishes.jsonToFoodItems(widget.userDish.food_items);
    foodItemsController = List.generate(
      foodItemsList.length,
          (index) => TextEditingController(text: foodItemsList[index].name),
    );
    final List<Food> nnnn = await FoodsDatabase.instance.ReeadAllfoodsItem();
    setState(() {
      allfoods = nnnn;
      selectedFoodItems = sss;
      print("lenghth of grapes ${selectedFoodItems.first.name}");
    });
  }



  Future<bool> _updateMealPlan() async {
      final String newDate = dateController.text;
      final String newTarget = targetcal.text;
      final int newTarInt = int.parse(newTarget);
      final List<Food> newFoodItems = [];
      final String newFoodItemsJson = userDishes.foodItemsToJson(selectedFoodItems);
      int totalcal =0;
      for(int i =0 ;i<selectedFoodItems.length;i++)
      {
        totalcal += int.parse(selectedFoodItems[i].calories);
      }
      print("new target ${newTarInt} and total ${totalcal}");
     if(newTarInt >= totalcal )
     {
       await FoodsDatabase.instance.updateUserDish(widget.userDish.id!, newDate, newFoodItemsJson, newTarget);
       Navigator.pop(context, true);
       return true;
     }
     else{
       return false;
     }

      // Update the meal plan in the database
      // await FoodsDatabase.instance.updateUserDish(widget.userDish.id!, newDate, newFoodItems);

      // Navigate back to the previous screen


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Update Meal Plan',style: TextStyle(

        ),),

        backgroundColor: Colors.green[600],
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0,40.0,20.10,0),
          child: Column(

            children: [
              Text('Edit target calories',style: TextStyle(
                letterSpacing: 2.0,
                color: Colors.grey[800],
                fontSize: 22.0,
                fontWeight: FontWeight.bold,

              ),),
                SizedBox(height: 10.0,),
              TextFormField(
                controller: targetcal,
                decoration: InputDecoration(labelText: 'Target',
                labelStyle: TextStyle(
                  letterSpacing: 2.0,
                  color: Colors.grey[800],
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                )),
              ),
              SizedBox(height: 10.0),
              Text('Edit Meal Plan',style: TextStyle(
                letterSpacing: 2.0,
                color: Colors.grey[800],
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),),

              TextFormField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Date',
                    labelStyle: TextStyle(
                      letterSpacing: 2.0,
                      color: Colors.grey[800],
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              SizedBox(height: 10.0,),
              Text('Food Items',style: TextStyle(
                letterSpacing: 2.0,
                color: Colors.grey[800],
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),),

              Expanded(
                child: ListView.builder(
                  itemCount: allfoods.length,
                  itemBuilder: (context, index) {
                    print("lenght of allfoods ${allfoods.length}");
                    final foodItem = allfoods[index];
                    bool isChecked = selectedFoodItems.contains(foodItem);

                    print("is checked ${isChecked}");
                    return CheckboxListTile(
                      title: Text('${foodItem.name}   ${foodItem.calories} calories'),
                      value: selectedFoodItems.any((selectedItem) => selectedItem.name == foodItem.name),

                            onChanged: (bool? value) {
                            setState(() {
                            if (value != null) {
                            if (value) {
                            selectedFoodItems.add(foodItem);
                            } else {
                              selectedFoodItems.removeWhere((selectedItem) => selectedItem.name == foodItem.name);
                            }
                            }
                            }

                    );
                  }
                );}
              ),
                ),

              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Padding(
                   padding: const EdgeInsets.fromLTRB(0.0,0.0,0.0,20.0),
                   child: ElevatedButton(
                    onPressed: () async {
                    bool resultUpdate=  await _updateMealPlan();
                    if(resultUpdate){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Meal plan updated!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Total calories exceed the target. Please adjust your selection.'),
                          duration: Duration(seconds: 2),
                        ),);
                    }
                    },
                    child: Text('Update',style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18.0,
                    ),),
                     style: ButtonStyle(
                       padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(50,16,50,16)),
                       backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.green),

                     ),
                ),
                 ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,0.0,0.0,0),
                    child: Text(
                      'Total Calories: ${calculateTotalCalories()}',
                      style: TextStyle(
                        color: Colors.grey[800],

                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),

                    ),
                  ),
        ],
              ),

            ],
          ),
        ),
      ),
    );
  }
   int calculateTotalCalories() {
    int total =0;
     for(int i =0 ;i<selectedFoodItems.length;i++)
       {
         total += int.parse(selectedFoodItems[i].calories);
       }
     return total;
   }
}
