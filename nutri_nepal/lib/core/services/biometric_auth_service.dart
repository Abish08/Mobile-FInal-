import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

class BiometricAuthService {
  final LocalAuthentication _auth;
  final FlutterSecureStorage _storage;

  BiometricAuthService({
    LocalAuthentication? auth,
    FlutterSecureStorage? storage,
  }) : _auth = auth ?? LocalAuthentication(),
       _storage = storage ?? const FlutterSecureStorage();

  Future<bool> canUseBiometricsForSavedSession() async {
    final hasSession = await hasSavedSession();
    if (!hasSession) return false;
    return canAuthenticateWithBiometrics();
  }

  Future<bool> hasSavedSession() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  Future<bool> canAuthenticateWithBiometrics() async {
    final supported = await _auth.isDeviceSupported();
    final canCheck = await _auth.canCheckBiometrics;
    final biometrics = await _auth.getAvailableBiometrics();

    return supported && canCheck && biometrics.isNotEmpty;
  }

  Future<bool> authenticate() {
    return _auth.authenticate(
      localizedReason: 'Use biometrics to unlock NutriNepal',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }
}
