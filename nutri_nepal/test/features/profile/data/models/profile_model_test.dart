import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:nutri_nepal/features/profile/data/models/profile_model.dart';
import 'package:nutri_nepal/features/profile/domain/entities/profile_entity.dart';

void main() {
  test('fromJson trims text and parses positive measurements', () {
    final model = ProfileModel.fromJson({
      '_id': ' user-1 ',
      'firstName': ' Asha ',
      'lastName': ' Rai ',
      'email': ' asha@example.com ',
      'phone': ' 9800000000 ',
      'age': '28',
      'weight': '61.5',
      'height': 165,
      'healthConditions': ['asthma'],
      'role': 'member',
    });

    expect(model.userId, 'user-1');
    expect(model.firstName, 'Asha');
    expect(model.lastName, 'Rai');
    expect(model.email, 'asha@example.com');
    expect(model.phone, '9800000000');
    expect(model.age, 28);
    expect(model.weight, 61.5);
    expect(model.height, 165.0);
    expect(model.healthConditions, ['asthma']);
    expect(model.role, 'member');
  });

  test('fromJson rejects invalid measurements and applies defaults', () {
    final model = ProfileModel.fromJson({
      'id': 'user-2',
      'age': 0,
      'weight': -4,
      'height': double.infinity,
      'healthConditions': 'none',
    });

    expect(model.userId, 'user-2');
    expect(model.firstName, '');
    expect(model.age, isNull);
    expect(model.weight, isNull);
    expect(model.height, isNull);
    expect(model.healthConditions, isEmpty);
    expect(model.role, 'user');
  });

  test('fromResponse supports data, user, and direct response shapes', () {
    final responses = [
      {
        'data': {'_id': 'data-id', 'firstName': 'Data'},
      },
      {
        'user': {'_id': 'user-id', 'firstName': 'User'},
      },
      {'_id': 'direct-id', 'firstName': 'Direct'},
    ];

    final models = responses.map(ProfileModel.fromResponse).toList();

    expect(models.map((model) => model.userId), [
      'data-id',
      'user-id',
      'direct-id',
    ]);
    expect(models.map((model) => model.firstName), ['Data', 'User', 'Direct']);
  });

  test('fromAuth and toAuthEntity preserve account details', () {
    const auth = AuthEntity(
      userId: 'auth-1',
      firstName: 'Nima',
      lastName: 'Sherpa',
      email: 'nima@example.com',
      phone: '9811111111',
      password: 'secret',
      role: 'admin',
      age: 32,
      weight: 70,
      height: 176,
      healthConditions: ['none'],
    );

    final converted = ProfileModel.fromAuth(auth).toAuthEntity();

    expect(converted.userId, auth.userId);
    expect(converted.firstName, auth.firstName);
    expect(converted.lastName, auth.lastName);
    expect(converted.email, auth.email);
    expect(converted.role, auth.role);
    expect(converted.age, auth.age);
    expect(converted.password, '');
  });

  test('fromEntity and toUpdateJson retain editable fields only', () {
    const entity = ProfileEntity(
      userId: 'profile-3',
      firstName: 'Sita',
      lastName: 'Thapa',
      email: 'sita@example.com',
      phone: '9822222222',
      profilePicture: 'avatar.png',
      age: 25,
      role: 'admin',
    );

    final model = ProfileModel.fromEntity(entity);

    expect(model.userId, 'profile-3');
    expect(model.profilePicture, 'avatar.png');
    expect(model.age, 25);
    expect(model.role, 'admin');
    expect(model.toUpdateJson(), {
      'firstName': 'Sita',
      'lastName': 'Thapa',
      'email': 'sita@example.com',
      'phone': '9822222222',
    });
  });
}
