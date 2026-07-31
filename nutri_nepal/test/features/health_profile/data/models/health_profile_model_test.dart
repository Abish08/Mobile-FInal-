import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_nepal/features/health_profile/data/models/health_profile_model.dart';
import 'package:nutri_nepal/features/health_profile/domain/entities/health_profile_entity.dart';

void main() {
  test('fromJson parses identifiers and numeric values', () {
    final model = HealthProfileModel.fromJson({
      '_id': 12,
      'userId': 34,
      'age': '27',
      'weight': '68.5',
      'height': 172,
      'gender': 'male',
      'fitnessGoal': 'build_strength',
      'bmi': '23.2',
      'bmr': 1650.8,
      'tdee': '2300',
      'targetCalories': 2100,
    });

    expect(model.id, '12');
    expect(model.userId, '34');
    expect(model.age, 27);
    expect(model.weight, 68.5);
    expect(model.height, 172.0);
    expect(model.bmi, 23.2);
    expect(model.bmr, 1650);
    expect(model.tdee, 2300);
    expect(model.targetCalories, 2100);
  });

  test('fromJson derives lose-weight fitness goal', () {
    final model = HealthProfileModel.fromJson({
      'age': 30,
      'weight': 80,
      'height': 175,
      'gender': 'female',
      'goal': 'lose',
    });

    expect(model.goal, 'lose');
    expect(model.fitnessGoal, 'lose_weight');
  });

  test('fromJson derives gain-muscle fitness goal', () {
    final model = HealthProfileModel.fromJson({
      'age': 30,
      'weight': 60,
      'height': 170,
      'gender': 'male',
      'goal': 'gain',
    });

    expect(model.goal, 'gain');
    expect(model.fitnessGoal, 'gain_muscle');
  });

  test('fromJson applies safe defaults to malformed optional data', () {
    final model = HealthProfileModel.fromJson({
      'id': 'profile-1',
      'age': 'invalid',
      'weight': null,
      'height': 'invalid',
      'gender': null,
      'healthConditions': 'none',
      'macros': const ['invalid'],
    });

    expect(model.id, 'profile-1');
    expect(model.age, 0);
    expect(model.weight, 0);
    expect(model.height, 0);
    expect(model.gender, '');
    expect(model.activityLevel, 'moderate');
    expect(model.goal, 'maintain');
    expect(model.fitnessGoal, 'maintain');
    expect(model.healthConditions, isEmpty);
    expect(model.macros, isNull);
  });

  test('fromEntity copies profile values', () {
    const entity = HealthProfileEntity(
      id: 'profile-2',
      userId: 'user-2',
      age: 24,
      weight: 57.5,
      height: 163,
      gender: 'female',
      fitnessGoal: 'maintain',
      healthConditions: ['asthma'],
      activityLevel: 'active',
      goal: 'maintain',
      bmi: 21.6,
      macros: {'protein': 90},
    );

    final model = HealthProfileModel.fromEntity(entity);

    expect(model.id, entity.id);
    expect(model.userId, entity.userId);
    expect(model.healthConditions, entity.healthConditions);
    expect(model.activityLevel, entity.activityLevel);
    expect(model.macros, entity.macros);
  });

  test('serialization separates user and health profile fields', () {
    const model = HealthProfileModel(
      age: 29,
      weight: 64,
      height: 168,
      gender: 'female',
      fitnessGoal: 'lose_weight',
      healthConditions: ['diabetes'],
      activityLevel: 'light',
      goal: 'lose',
      bmi: 22.7,
    );

    expect(model.toUserProfileJson(), {
      'age': 29,
      'weight': 64.0,
      'height': 168.0,
      'gender': 'female',
      'fitnessGoal': 'lose_weight',
      'healthConditions': ['diabetes'],
    });
    expect(model.toHealthProfileJson(), {
      'age': 29,
      'weight': 64.0,
      'height': 168.0,
      'gender': 'female',
      'fitnessGoal': 'lose_weight',
      'healthConditions': ['diabetes'],
      'activityLevel': 'light',
      'goal': 'lose',
    });
  });
}
