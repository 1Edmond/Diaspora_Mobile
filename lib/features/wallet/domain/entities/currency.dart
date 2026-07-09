class Currency {
  final String code; // XOF, RUB, EUR, USD
  final String symbol;
  final String name;
  final String flag; // emoji or asset path

  Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

  // Equality support for Maps/Sets
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
