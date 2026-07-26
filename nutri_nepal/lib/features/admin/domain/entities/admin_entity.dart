import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';

class AdminDashboardStats extends Equatable {
  final int totalUsers;
  final int totalFoodItems;
  final int totalWorkouts;
  final int activeToday;
  final Map<String, int> fitnessGoals;
  final Map<String, int> bmiDistribution;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.totalFoodItems,
    required this.totalWorkouts,
    required this.activeToday,
    required this.fitnessGoals,
    required this.bmiDistribution,
  });

  @override
  List<Object?> get props => [
    totalUsers,
    totalFoodItems,
    totalWorkouts,
    activeToday,
    fitnessGoals,
    bmiDistribution,
  ];
}

class AdminUserList extends Equatable {
  final List<AuthEntity> users;
  final int totalUsers;
  final int newToday;

  const AdminUserList({
    required this.users,
    required this.totalUsers,
    required this.newToday,
  });

  @override
  List<Object?> get props => [users, totalUsers, newToday];
}

class AdminFoodList extends Equatable {
  final List<AdminFood> foods;
  final int totalItems;
  final int pendingApproval;

  const AdminFoodList({
    required this.foods,
    required this.totalItems,
    required this.pendingApproval,
  });

  @override
  List<Object?> get props => [foods, totalItems, pendingApproval];
}

class AdminFood extends Equatable {
  final String id;
  final String name;
  final String category;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double sugar;
  final double sodium;
  final String servingSize;
  final String description;
  final bool isApproved;
  final String status;
  final String? thumbnail;
  final String? thumbnailUrl;
  final List<String> images;

  const AdminFood({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    required this.servingSize,
    this.description = '',
    this.isApproved = true,
    this.status = 'approved',
    this.thumbnail,
    this.thumbnailUrl,
    this.images = const [],
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
    fiber,
    sugar,
    sodium,
    servingSize,
    description,
    isApproved,
    status,
    thumbnail,
    thumbnailUrl,
    images,
  ];
}

class AdminFoodInput {
  final String? id;
  final String name;
  final String category;
  final int servingSize;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double sugar;
  final double sodium;
  final String description;
  final bool isApproved;
  final File? thumbnailImage;
  final List<File> additionalImages;

  const AdminFoodInput({
    this.id,
    required this.name,
    required this.category,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.description,
    required this.isApproved,
    this.thumbnailImage,
    this.additionalImages = const [],
  });
}

class AdminWorkout extends Equatable {
  final String id;
  final String name;
  final String category;
  final String day;
  final String? difficulty;
  final String? duration;
  final int? caloriesBurned;
  final String? equipment;
  final String? thumbnail;
  final String? thumbnailUrl;
  final String? youtubeUrl;
  final int? sets;
  final int? reps;
  final String? rest;
  final String? intensity;
  final int? cycles;
  final String? focus;
  final String? description;

  const AdminWorkout({
    required this.id,
    required this.name,
    required this.category,
    required this.day,
    this.difficulty,
    this.duration,
    this.caloriesBurned,
    this.equipment,
    this.thumbnail,
    this.thumbnailUrl,
    this.youtubeUrl,
    this.sets,
    this.reps,
    this.rest,
    this.intensity,
    this.cycles,
    this.focus,
    this.description,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    day,
    difficulty,
    duration,
    caloriesBurned,
    equipment,
    thumbnail,
    thumbnailUrl,
    youtubeUrl,
    sets,
    reps,
    rest,
    intensity,
    cycles,
    focus,
    description,
  ];
}

class AdminWorkoutInput {
  final String? id;
  final String name;
  final String category;
  final String day;
  final int? sets;
  final int? reps;
  final String rest;
  final int? duration;
  final String intensity;
  final int? cycles;
  final String focus;
  final String description;
  final String youtubeUrl;
  final File? thumbnailImage;
  final List<File> additionalImages;

  const AdminWorkoutInput({
    this.id,
    required this.name,
    required this.category,
    required this.day,
    this.sets,
    this.reps,
    required this.rest,
    this.duration,
    required this.intensity,
    this.cycles,
    required this.focus,
    required this.description,
    required this.youtubeUrl,
    this.thumbnailImage,
    this.additionalImages = const [],
  });
}
