enum DocumentType {
  PASSPORT,
  VISA,
  STUDENT_CARD,
  RESIDENCE_PERMIT,
  INSURANCE,
  DIPLOMA,
  TRANSCRIPT,
  BANK_DOCUMENT,
  CONTRACT,
  MEDICAL,
  OTHER,
}

class RequiredDocument {
  final DocumentType documentType;
  final bool isMandatory;
  final String description;

  RequiredDocument({
    required this.documentType,
    required this.isMandatory,
    required this.description,
  });
}
