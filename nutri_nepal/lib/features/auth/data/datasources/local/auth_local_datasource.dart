import 'package:nutri_nepal/core/services/hive/hive_service.dart';
import 'package:nutri_nepal/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:nutri_nepal/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authLocalDatasourceProvider = Provider<IAuthDatasource>((ref) {
  return AuthLocalDatasource(ref.watch(hiveServiceProvider));
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource(this._hiveService);

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return _hiveService.getCurrentUser();
  }

  @override
  Future<bool> isEmailExists(String email) async {
    return _hiveService.isEmailTaken(email); // ✅ Correct: Call via _hiveService
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    return _hiveService.loginUser(email, password);
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    final normalizedEmail = model.email.toLowerCase();

    if (await _hiveService.isEmailTaken(normalizedEmail)) {
      // User exists, just update them instead of throwing error
      await _hiveService.saveUser(model);
      return true;
    }

    await _hiveService.saveUser(model);
    return true;
  }

  @override
  Future<bool> logout() async {
    await _hiveService.logoutUser();
    return true;
  }
}
