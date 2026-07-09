class DigitalPassport {
  final String qrData;
  final DateTime generatedAt;
  final DateTime expiresAt;

  DigitalPassport({
    required this.qrData,
    required this.generatedAt,
    required this.expiresAt,
  });
}
