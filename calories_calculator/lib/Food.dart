final String tablefood_item = 'foodItems';

class FoodItemsFields {
  static final List<String> values = [
    /// Add all fields
    id, name, calories
  ];

  static final String id = 'id_item';
  static final String name = 'name';
  static final String calories = 'calories';

}

class Food {
  final int? id;

  final String name;
  final String calories;


  const Food({
    this.id,
    required this.name,
    required this.calories,

  });

  Food copy({
    int? id,
    String? name,
    String? calories,

  }) =>
      Food(
        id: id ?? this.id,

        name: name ?? this.name,
        calories: calories ?? this.calories,

      );

  static Food fromJson(Map<String, Object?> json) => Food(
    id: json[FoodItemsFields.id] as int?,
    name: json[FoodItemsFields.name] as String,
    calories: json[FoodItemsFields.calories] as String,

  );

  Map<String, Object?> toJson() => {
    FoodItemsFields.id: id,
    FoodItemsFields.name: name,
    FoodItemsFields.calories: calories,

  };
}