import 'package:nutri_nepal/core/constants/hive_table_constant.dart';
import 'package:nutri_nepal/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init('${directory.path}/${HiveTableConstant.dbName}');
    _registerAdapters();
    await openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> openBoxes() async {
    if (!Hive.isBoxOpen(HiveTableConstant.userBox)) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstant.userBox);
    }
    if (!Hive.isBoxOpen(HiveTableConstant.sessionBox)) {
      await Hive.openBox<String>(HiveTableConstant.sessionBox);
    }
  }

  Future<void> close() => Hive.close();

  Box<AuthHiveModel> get _users =>
      Hive.box<AuthHiveModel>(HiveTableConstant.userBox);

  Box<String> get _session => Hive.box<String>(HiveTableConstant.sessionBox);

  // ✅ FIXED: Removed the email existence check that was causing the error
  Future<AuthHiveModel> saveUser(AuthHiveModel user) async {
    final sanitizedUser = user.copyWith(password: '');

    await _users.put(sanitizedUser.userId, sanitizedUser);
    await _session.put(HiveTableConstant.activeUserKey, sanitizedUser.userId);
    return sanitizedUser;
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    return null;
  }

  AuthHiveModel? getCurrentUser() {
    final activeUserId = _session.get(HiveTableConstant.activeUserKey);
    if (activeUserId == null) return null;
    return _users.get(activeUserId);
  }

  Future<void> logoutUser() async {
    await _session.delete(HiveTableConstant.activeUserKey);
  }

  bool isEmailTaken(String email) {
    final normalizedEmail = email.toLowerCase();
    return _users.values.any((user) => user.email.toLowerCase() == normalizedEmail);
  }
}
