import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  PinService._();
  static final PinService instance = PinService._();

  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'echo_diary_pin';

  Future<void> setPin(String pin) => _storage.write(key: _pinKey, value: pin);
  Future<String?> getPin() => _storage.read(key: _pinKey);
  Future<void> clearPin() => _storage.delete(key: _pinKey);
}

