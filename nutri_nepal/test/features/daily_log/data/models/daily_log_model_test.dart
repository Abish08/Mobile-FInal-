import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_nepal/features/daily_log/data/models/daily_log_model.dart';

void main() {
  test('fromResponses maps food logs and nutrition summary', () {
    final model = DailyLogModel.fromResponses(
      foodResponse: {
        'data': [
          {
            '_id': 'food-log-1',
            'foodId': {'name': 'Dal Bhat'},
            'totalCalories': 540.4,
            'mealType': 'Lunch',
          },
        ],
        'summary': {'calories': 540.4, 'protein': 21, 'carbs': 85, 'fats': 12},
      },
      workoutResponse: const {},
    );

    expect(model.foodLogs, hasLength(1));
    expect(model.foodLogs.single.title, 'Dal Bhat');
    expect(model.foodLogs.single.subtitle, '540 kcal - Lunch');
    expect(model.foodLogs.single.calories, 540.4);
    expect(model.consumedCalories, 540.4);
    expect(model.protein, 21);
    expect(model.carbs, 85);
    expect(model.fats, 12);
  });

  test('fromResponses maps workout logs and burned calories', () {
    final model = DailyLogModel.fromResponses(
      foodResponse: const {},
      workoutResponse: {
        'data': [
          {
            '_id': 'workout-log-1',
            'workoutId': {'name': 'Morning Run'},
            'caloriesBurned': 230.6,
            'duration': 31.5,
          },
        ],
        'summary': {'calories': 230.6},
      },
    );

    expect(model.workoutLogs, hasLength(1));
    expect(model.workoutLogs.single.title, 'Morning Run');
    expect(model.workoutLogs.single.subtitle, '231 kcal burned - 32 min');
    expect(model.burnedCalories, 230.6);
  });

  test('fromResponses extracts Mongo object identifiers', () {
    final model = DailyLogModel.fromResponses(
      foodResponse: {
        'data': [
          {
            '_id': {'\$oid': 'mongo-food-id'},
            'foodId': {'name': 'Momo'},
            'totalCalories': 300,
          },
        ],
      },
      workoutResponse: {
        'data': [
          {
            '_id': {'\$oid': 'mongo-workout-id'},
            'workoutId': {'name': 'Yoga'},
            'caloriesBurned': 80,
          },
        ],
      },
    );

    expect(model.foodLogs.single.id, 'mongo-food-id');
    expect(model.workoutLogs.single.id, 'mongo-workout-id');
  });

  test('fromResponses uses readable fallbacks for missing relations', () {
    final model = DailyLogModel.fromResponses(
      foodResponse: {
        'data': [
          {'_id': null, 'totalCalories': null},
        ],
      },
      workoutResponse: {
        'data': [
          {'_id': null, 'caloriesBurned': null, 'duration': null},
        ],
      },
    );

    expect(model.foodLogs.single.id, '');
    expect(model.foodLogs.single.title, 'Unknown Meal');
    expect(model.foodLogs.single.subtitle, '0 kcal - Meal');
    expect(model.workoutLogs.single.title, 'Unknown Workout');
    expect(model.workoutLogs.single.subtitle, '0 kcal burned - 0 min');
  });

  test('fromResponses returns empty zero summary for malformed responses', () {
    final model = DailyLogModel.fromResponses(
      foodResponse: const {'data': 'invalid', 'summary': 'invalid'},
      workoutResponse: const {'data': 42, 'summary': null},
    );

    expect(model.foodLogs, isEmpty);
    expect(model.workoutLogs, isEmpty);
    expect(model.consumedCalories, 0);
    expect(model.burnedCalories, 0);
    expect(model.protein, 0);
    expect(model.carbs, 0);
    expect(model.fats, 0);
  });

  test('fromResponses accepts numeric strings in logs and summaries', () {
    final model = DailyLogModel.fromResponses(
      foodResponse: {
        'data': [
          {
            '_id': 'food-log-2',
            'foodId': {'name': 'Fruit'},
            'totalCalories': '125.5',
          },
        ],
        'summary': {'calories': '125.5', 'protein': '2.5'},
      },
      workoutResponse: {
        'summary': {'calories': '50'},
      },
    );

    expect(model.foodLogs.single.calories, 125.5);
    expect(model.consumedCalories, 125.5);
    expect(model.burnedCalories, 50);
    expect(model.protein, 2.5);
  });
}
