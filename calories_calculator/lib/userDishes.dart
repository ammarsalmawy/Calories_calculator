import 'dart:convert';

import 'Food.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';


final String tableuser = 'userDishes';

class dishesFeild {
  static final List<String> values = [
    /// Add all fields
    id, food_items, date, target
  ];

  static final String id = 'id_dish';
  static final String food_items = 'fooditems';
  static final String date = 'date';
  static final String target = 'target';

}

class userDishes {
  final int? id;

  final String food_items;
  final String date;
  final String target;


  const userDishes({
    this.id,
    required this.food_items,
    required this.date,
    required this.target,

  });

  userDishes copy({
    int? id,
    String? food_items,
    String? date,
    String? target,

  }) =>
      userDishes(
        id: id ?? this.id,

        food_items: food_items ?? this.food_items,
        date: date ?? this.date,
        target: target ?? this.target,

      );

  static userDishes fromJson(Map<String, Object?> json) => userDishes(
    id: json[dishesFeild.id] as int?,
    food_items: json[dishesFeild.food_items] as String,
    date: json[dishesFeild.date] as String,
    target: json[dishesFeild.target] as String,

  );

  Map<String, Object?> toJson() => {
    dishesFeild.id: id,
    dishesFeild.food_items: food_items,
    dishesFeild.date: date,
    dishesFeild.target: target,

  };


  static String foodItemsToJson(List<Food> foodItems) {
    final List<Map<String, dynamic>> foodList = foodItems.map((food) => food.toJson()).toList();
    return jsonEncode(foodList);
  }

  // Convert JSON to list of Food
  static List<Food> jsonToFoodItems(String json) {
    final List<dynamic> foodList = jsonDecode(json);
    return foodList.map((foodJson) => Food.fromJson(foodJson)).toList();
  }
}