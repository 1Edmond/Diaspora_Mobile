enum DocumentStatus {
  pending(0),
  active(1),
  expired(2),
  rejected(3);

  final int value;
  const DocumentStatus(this.value);

  static DocumentStatus fromValue(int value) {
    return DocumentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DocumentStatus.pending,
    );
  }

  String get label {
    switch (this) {
      case DocumentStatus.pending:
        return 'En attente';
      case DocumentStatus.active:
        return 'Actif';
      case DocumentStatus.expired:
        return 'Expiré';
      case DocumentStatus.rejected:
        return 'Rejeté';
    }
  }
}
