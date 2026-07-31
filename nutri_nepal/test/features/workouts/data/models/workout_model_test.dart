import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_nepal/features/workouts/data/models/workout_model.dart';

void main() {
  test('WorkoutModel prefers thumbnail over legacy media image', () {
    final workout = WorkoutModel.fromJson({
      '_id': 'workout-1',
      'name': 'Bench Press',
      'category': 'Strength',
      'thumbnail': '/uploads/workout-good.jpg',
      'media': [
        {'type': 'image', 'url': '/uploads/profile-missing.jpg'},
      ],
    });

    expect(
      workout.thumbnail,
      'http://192.168.1.167:3000/uploads/workout-good.jpg',
    );
  });
}
