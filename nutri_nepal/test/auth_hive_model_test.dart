import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_nepal/features/auth/data/models/auth_hive_model.dart';

void main() {
  test('AuthHiveModel.fromJson maps backend id and clears password', () {
    final model = AuthHiveModel.fromJson({
      '_id': 'user-123',
      'firstName': 'Ayu',
      'lastName': 'Khanal',
      'email': 'ayu@example.com',
      'phone': '9800000000',
      'role': 'admin',
    });

    expect(model.userId, 'user-123');
    expect(model.password, isEmpty);
    expect(model.role, 'admin');
  });
}
