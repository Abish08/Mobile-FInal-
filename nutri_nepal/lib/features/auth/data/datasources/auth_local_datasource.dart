import 'package:nutri_nepal/features/auth/data/models/auth_hive_model.dart';

abstract class IAuthDatasource {
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> isEmailExists(String email);
  Future<AuthHiveModel?> login(String email, String password);
  Future<bool> register(AuthHiveModel model);
  Future<bool> logout();
}
