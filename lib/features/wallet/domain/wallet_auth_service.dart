abstract class IWalletAuthService {
  /// Returns true if a wallet PIN is configured.
  Future<bool> isPinSet();

  /// Persist a PIN (secure storage). In production this should be hashed.
  Future<void> setPin(String pin);

  /// Verify provided PIN against stored PIN.
  Future<bool> verifyPin(String pin);

  /// Clear stored PIN (for tests / logout).
  Future<void> clearPin();

  /// Whether the device can perform biometric authentication.
  Future<bool> canCheckBiometrics();

  /// Attempt biometric authentication (returns true on success).
  Future<bool> authenticateWithBiometrics({String reason});
}
