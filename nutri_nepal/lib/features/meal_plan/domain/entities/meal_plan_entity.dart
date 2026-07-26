import 'package:equatable/equatable.dart';

class FoodItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double servingSize;
  final String? thumbnail;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.servingSize,
    this.thumbnail,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    calories,
    protein,
    carbs,
    fats,
    servingSize,
    thumbnail,
  ];
}

class MealPlanMeal extends Equatable {
  final String name;
  final String category;
  final int calories;
  final int protein;
  final int carbs;
  final DateTime? date;

  const MealPlanMeal({
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.date,
  });

  @override
  List<Object?> get props => [name, category, calories, protein, carbs, date];
}
