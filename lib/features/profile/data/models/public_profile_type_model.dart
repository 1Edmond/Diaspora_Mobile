class PublicProfileType {
  final String id;
  final String countryCode;
  final String countryName;
  final String currency;
  final String phoneIndicatif;
  final String flag;

  const PublicProfileType({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.currency,
    required this.phoneIndicatif,
    required this.flag,
  });

  factory PublicProfileType.fromJson(Map<String, dynamic> json) {
    return PublicProfileType(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      countryCode: (json['countryCode'] ?? json['CountryCode'] ?? '').toString().toUpperCase(),
      countryName: (json['countryName'] ?? json['CountryName'] ?? '').toString(),
      currency: (json['currency'] ?? json['Currency'] ?? 'XOF').toString(),
      phoneIndicatif: (json['phoneIndicatif'] ?? json['PhoneIndicatif'] ?? '').toString(),
      flag: (json['flag'] ?? json['Flag'] ?? '🌍').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'countryCode': countryCode,
    'countryName': countryName,
    'currency': currency,
    'phoneIndicatif': phoneIndicatif,
    'flag': flag,
  };
}
