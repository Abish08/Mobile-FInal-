import 'package:equatable/equatable.dart';

class UserWorkout extends Equatable {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? thumbnail;
  final String? youtubeUrl;
  final String? duration;
  final int? caloriesBurned;
  final String? difficulty;
  final int? sets;
  final int? reps;
  final String? rest;
  final String? equipment;

  const UserWorkout({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.thumbnail,
    this.youtubeUrl,
    this.duration,
    this.caloriesBurned,
    this.difficulty,
    this.sets,
    this.reps,
    this.rest,
    this.equipment,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    description,
    thumbnail,
    youtubeUrl,
    duration,
    caloriesBurned,
    difficulty,
    sets,
    reps,
    rest,
    equipment,
  ];
}
