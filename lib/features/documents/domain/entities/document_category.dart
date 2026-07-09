enum DocumentCategory {
  id('ID'),
  passport('PASSPORT'),
  visa('VISA'),
  certificate('CERTIFICATE'),
  contract('CONTRACT'),
  other('OTHER');

  final String value;
  const DocumentCategory(this.value);

  static DocumentCategory fromString(String value) {
    return DocumentCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DocumentCategory.other,
    );
  }

  String get label {
    switch (this) {
      case DocumentCategory.id:
        return 'Carte d\'identité';
      case DocumentCategory.passport:
        return 'Passeport';
      case DocumentCategory.visa:
        return 'Visa';
      case DocumentCategory.certificate:
        return 'Certificat';
      case DocumentCategory.contract:
        return 'Contrat';
      case DocumentCategory.other:
        return 'Autre';
    }
  }
}
