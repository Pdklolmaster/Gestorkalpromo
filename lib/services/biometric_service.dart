import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Serviço de autenticação biométrica
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica se biometria está disponível
  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticate = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticate && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Lista tipos de biometria disponíveis
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Autentica com biometria
  Future<bool> authenticate({String reason = 'Autentique para acessar o app'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Permite PIN como fallback
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Verifica se tem digital cadastrada
  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  /// Verifica se tem FaceID
  Future<bool> hasFaceID() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }
}
